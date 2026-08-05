-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 16: SENTINEL AI – KILL ANALYSIS PIPELINE                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function analyzeKill(killer, weaponName, distance, ttk)
    local suspected = {}
    local counter = {}
    local threat = 1
    
    -- Type validation for all inputs
    if type(killer) ~= "string" then killer = "Unknown" end
    if type(weaponName) ~= "string" then weaponName = "Unknown" end
    if type(distance) ~= "number" then distance = 0 end
    if type(ttk) ~= "number" then ttk = 999 end
    
    local timeSinceRespawn = tick() - LastSpawnTime
    if type(timeSinceRespawn) ~= "number" then timeSinceRespawn = 999 end

    -- LOOPBRING detection
    if ttk < 0.3 and distance < 8 then
        table.insert(suspected, "LoopBring")
        table.insert(counter, "FastRespawn + AntiSpawnkill + GodMode + Phase")
        threat = threat + 4
    end

    -- KILL AURA detection
    if distance > 5 and distance < 15 and ttk < 0.5 then
        table.insert(suspected, "KillAura")
        table.insert(counter, "Anti-Aura + Repel + Phase")
        threat = threat + 3
    end

    -- REACH detection
    if distance > 25 then
        table.insert(suspected, "Reach")
        table.insert(counter, "Match Reach + Phase")
        threat = threat + 3
    end
    if distance > 40 then
        table.insert(suspected, "Extreme Reach / LoopBring")
        threat = threat + 2
    end

    -- FAST KILL detection
    if ttk < 0.2 then
        table.insert(suspected, "FastKill / RemoteSpam")
        table.insert(counter, "GodMode + HealAura")
        threat = threat + 3
    end

    -- FIGHT EVENT ABUSE
    if weaponName == "Unknown" and ttk < 0.5 then
        table.insert(suspected, "FightEvent Abuse")
        table.insert(counter, "ForceField GodMode")
        threat = threat + 3
    end

    -- HIT AMPLIFIER
    if distance > 15 and distance <= 30 and ttk < 0.8 then
        table.insert(suspected, "HitAmplifier")
        table.insert(counter, "Phase + Repel")
        threat = threat + 2
    end

    -- TOOL FOLLOW
    if distance < 3 then
        table.insert(suspected, "ToolFollow / Close Combat")
        table.insert(counter, "Repel + Phase")
        threat = threat + 1
    end

    -- SPAWN KILL
    if timeSinceRespawn < 2 then
        table.insert(suspected, "SpawnKill")
        table.insert(counter, "AntiSpawnkill + GodMode")
        threat = threat + 3
    end

    threat = math.clamp(threat, 1, 10)
    if threat >= 10 then
        table.insert(counter, "CRITICAL: FULL DEFENSE MATRIX NOW")
    end
    if threat >= 7 then
        table.insert(counter, "Enable full Defense Matrix")
    end

    return {
        Killer = killer,
        Weapon = weaponName,
        Distance = math.floor(distance),
        TTK = ttk,
        TimeSinceRespawn = timeSinceRespawn,
        Suspected = suspected,
        Counter = counter,
        Threat = threat,
        Time = os.date("%H:%M:%S"),
        DeathCount = DeathCount
    }
end

local function setupKillNotifications()
    player.CharacterAdded:Connect(function(char)
        LastSpawnTime = tick()
        local hum_ok, hum = pcall(function() return char:WaitForChild("Humanoid", 10) end)
        if not hum_ok or not hum then return end
        
        hum.Died:Connect(function()
            DeathCount = DeathCount + 1
            KillStreak = 0
            local deathTime = tick()
            table.insert(DeathTimestamps, deathTime)
            if #DeathTimestamps > 20 then table.remove(DeathTimestamps, 1) end

            if not KillNotifEnabled then return end

            local creator = hum:FindFirstChild("creator")
            local killerName, weaponName, distance, ttk = "Unknown", "Unknown", 0, 999

            if creator and creator.Value then
                local creator_ok, creator_val = pcall(function() return creator.Value end)
                if creator_ok and creator_val then
                    killerName = creator_val.Name
                    local killerChar = creator_val.Character
                    if killerChar then
                        local myRoot = char:FindFirstChild("HumanoidRootPart")
                        local theirRoot = killerChar:FindFirstChild("HumanoidRootPart")
                        if myRoot and theirRoot then
                            local dist_ok, dist_val = pcall(function() return (myRoot.Position - theirRoot.Position).Magnitude end)
                            if dist_ok and type(dist_val) == "number" then distance = dist_val end
                        end
                        local children_ok, children = pcall(function() return killerChar:GetChildren() end)
                        if children_ok and type(children) == "table" then
                            for _, tool in ipairs(children) do
                                if tool:IsA("Tool") then 
                                    local name_ok, name_val = pcall(function() return tool.Name end)
                                    if name_ok then weaponName = name_val; break end
                                end
                            end
                        end
                    end
                end
            end

            -- Calculate TTK from last damage timestamp
            if #DeathTimestamps >= 2 then
                ttk = DeathTimestamps[#DeathTimestamps] - DeathTimestamps[#DeathTimestamps - 1]
            end
            if ttk > 10 then ttk = 1 end -- cap unreasonable values

            local analysis = analyzeKill(killerName, weaponName, distance, ttk)

            -- Store in kill logs
            table.insert(KillLogs, analysis)
            if #KillLogs > 100 then table.remove(KillLogs, 1) end
            if KillLogEnabled then appendLog(analysis) end

            -- ═══ TRIGGER SENTINEL AI PIPELINE ═══
            AI_OnKillDetected(analysis)

            -- Also send a ZyronX notification
            Library:Notify({
                Title = "SENTINEL AI - Kill Detected (Threat " .. analysis.Threat .. "/10)",
                Description = "Killer: " .. analysis.Killer
                    .. "\nWeapon: " .. analysis.Weapon
                    .. "\nDist: " .. analysis.Distance .. " studs | TTK: " .. string.format("%.2f", analysis.TTK) .. "s"
                    .. "\nSuspected: " .. table.concat(analysis.Suspected, ", ")
                    .. "\nAI analyzing... check chat.",
                Duration = 6,
            })
        end)
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 17: SENTINEL AI – USER MESSAGE PROCESSOR                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝
function AI_ProcessUserMessage(text)
    if type(text) ~= "string" then return end
    local lower = text:lower()

    -- Help command
    if lower:find("help") or lower:find("commands") then
        Chat_AddMessage("AI", "Available commands:")
        Chat_AddMessage("AI", "  'status' - Current threat status")
        Chat_AddMessage("AI", "  'profiles' - View all threat profiles")
        Chat_AddMessage("AI", "  'profile [name]' - View specific player profile")
        Chat_AddMessage("AI", "  'strategy' - View active strategy")
        Chat_AddMessage("AI", "  'threats' - Current threat assessment")
        Chat_AddMessage("AI", "  'disable all' - Turn off all AI-activated features")
        Chat_AddMessage("AI", "  'why' - Explain current situation")
        Chat_AddMessage("AI", "  'target [name]' - Focus all systems on a player")
        Chat_AddMessage("AI", "  'memory' - View AI learning statistics")
        Chat_AddMessage("AI", "  'clear' - Clear chat history")
        return
    end

    -- Status command
    if lower:find("status") then
        Chat_AddMessage("AI", "Current Status:")
        Chat_AddMessage("AI", "  Threat Level: " .. ThreatLevel .. " (Peak: " .. PeakThreat .. ")")
        Chat_AddMessage("AI", "  Deaths This Session: " .. DeathCount)
        Chat_AddMessage("AI", "  Kill Streak: " .. KillStreak)
        Chat_AddMessage("AI", "  Aura: " .. tostring(Aura.Enabled) .. " | InstaKill: " .. tostring(InstaKillEnabled))
        Chat_AddMessage("AI", "  AntiAura: " .. tostring(AntiAura.Enabled) .. " | GodMode: " .. tostring(AntiAura.GodMode))
        Chat_AddMessage("AI", "  Reach: " .. tostring(Reach) .. " (" .. ReachSize .. "x)")
        Chat_AddMessage("AI", "  AI State: " .. AI_State.Current)
        Chat_AddMessage("AI", "  Profiles Tracked: " .. tostring(#ThreatProfiles))
        Chat_AddMessage("AI", "  Strategies in Memory: " .. tostring(#AIMemory.StrategyResults))
        return
    end

    -- Profiles command
    if lower:find("profiles") then
        local count = 0
        for name, prof in pairs(ThreatProfiles) do
            count = count + 1
            Chat_AddMessage("AI", name .. " | Kills: " .. prof.TotalKills
                .. " | Threat: " .. prof.ThreatScore .. "/100"
                .. " | Features: " .. table.concat(prof.SuspectedFeatures, ", "))
        end
        if count == 0 then
            Chat_AddMessage("AI", "No threat profiles recorded yet.")
        end
        return
    end

    -- Specific profile lookup
    local profileMatch = lower:match("profile%s+(%S+)")
    if profileMatch then
        local found = nil
        for name, prof in pairs(ThreatProfiles) do
            if name:lower():find(profileMatch:lower()) then found = prof; break end
        end
        if found then
            Chat_AddMessage("AI", "Profile: " .. found.Name)
            Chat_AddMessage("AI", "  Total Kills: " .. found.TotalKills)
            Chat_AddMessage("AI", "  Avg Distance: " .. math.floor(found.AvgDistance) .. " studs")
            Chat_AddMessage("AI", "  Avg TTK: " .. string.format("%.2f", found.AvgTTK) .. "s")
            Chat_AddMessage("AI", "  Threat Score: " .. found.ThreatScore .. "/100")
            Chat_AddMessage("AI", "  Suspected: " .. table.concat(found.SuspectedFeatures, ", "))
            for feat, conf in pairs(found.Confidence) do
                Chat_AddMessage("AI", "  " .. feat .. " confidence: " .. math.floor(conf) .. "%")
            end
        else
            Chat_AddMessage("AI", "No profile found for '" .. profileMatch .. "'.")
        end
        return
    end

    -- Threats command
    if lower:find("threats") or lower:find("threat") then
        Chat_AddMessage("AI", "Live Threat Assessment:")
        Chat_AddMessage("AI", "  Current Level: " .. ThreatLevel)
        Chat_AddMessage("AI", "  Trend: " .. (ThreatTrend > 0 and "RISING ↑" or ThreatTrend < 0 and "FALLING ↓" or "STABLE →"))
        Chat_AddMessage("AI", "  Peak: " .. PeakThreat)
        Chat_AddMessage("AI", "  Radius: " .. ThreatRadius .. " studs")
        local nearby = 0
        local myChar = player.Character
        if myChar and myChar:FindFirstChild("HumanoidRootPart") then
            local myPos = myChar.HumanoidRootPart.Position
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                    if d < ThreatRadius then
                        nearby = nearby + 1
                        Chat_AddMessage("AI", "  ⚠ " .. plr.Name .. " - " .. math.floor(d) .. " studs away", Color3.fromRGB(255, 150, 50))
                    end
                end
            end
        end
        if nearby == 0 then Chat_AddMessage("AI", "  ✓ No players within threat radius.") end
        return
    end

    -- Memory command
    if lower:find("memory") then
        Chat_AddMessage("AI", "AI Learning Statistics:")
        Chat_AddMessage("AI", "  Strategies Stored: " .. #AIMemory.StrategyResults)
        Chat_AddMessage("AI", "  Learning Rate: " .. tostring(AIMemory.SessionLearningRate))
        local successes = 0
        local failures = 0
        for _, result in ipairs(AIMemory.StrategyResults) do
            if result.Success == true then successes = successes + 1
            elseif result.Success == false then failures = failures + 1 end
        end
        Chat_AddMessage("AI", "  Successful Counters: " .. successes)
        Chat_AddMessage("AI", "  Failed Counters: " .. failures)
        if successes + failures > 0 then
            Chat_AddMessage("AI", "  Success Rate: " .. math.floor((successes / (successes + failures)) * 100) .. "%")
        end
        return
    end

    -- Disable all command
    if lower:find("disable all") or lower:find("stop all") or lower:find("turn off") then
        Aura.Enabled = false; stopAuraLoop()
        InstaKillEnabled = false; stopInstaKill()
        HitAmpEnabled = false; stopHitAmplifier()
        AntiAura.Enabled = false; stopAntiAura()
        Reach = false; stopReach()
        ToolFollow.Enabled = false; stopToolFollow()
        NoCooldown = false; stopNoCooldown()
        Chat_AddMessage("AI", "All AI-activated features disabled. You're back to manual control.", Color3.fromRGB(255, 200, 0))
        Robot_SetState("IDLE")
        return
    end

    -- Why command
    if lower:find("why") then
        if #KillLogs == 0 then
            Chat_AddMessage("AI", "No kill data yet. I need to observe at least one death to analyze why you're losing.")
        else
            local last = KillLogs[#KillLogs]
            Chat_AddMessage("AI", "Last kill analysis:")
            Chat_AddMessage("AI", "  You were killed by " .. last.Killer .. " using " .. last.Weapon)
            Chat_AddMessage("AI", "  Distance: " .. last.Distance .. " studs | TTK: " .. string.format("%.2f", last.TTK) .. "s")
            Chat_AddMessage("AI", "  Suspected features: " .. table.concat(last.Suspected, ", "))
            Chat_AddMessage("AI", "  Recommended counters: " .. table.concat(last.Counter, " | "))
        end
        return
    end

    -- Target command
    local targetMatch = lower:match("target%s+(%S+)")
    if targetMatch then
        local targetPlr = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Name:lower():find(targetMatch:lower()) then targetPlr = plr; break end
        end
        if targetPlr then
            Aura.TargetList = {targetPlr}
            Aura.Enabled = true
            InstaKillEnabled = true
            startAuraLoop()
            startInstaKill()
            Chat_AddMessage("AI", "All systems locked onto " .. targetPlr.Name .. ". Aura + InstaKill active.", Color3.fromRGB(255, 50, 50))
        else
            Chat_AddMessage("AI", "Player '" .. targetMatch .. "' not found in server.")
        end
        return
    end

    -- Strategy command
    if lower:find("strategy") then
        if AI_State.PendingStrategy then
            local s = AI_State.PendingStrategy
            Chat_AddMessage("AI", "Active Strategy against " .. s.Target .. ":")
            Chat_AddMessage("AI", "  Priority: " .. s.Priority .. " | Confidence: " .. s.Confidence .. "%")
            if s.MutatedFrom then Chat_AddMessage("AI", "  ⚡ MUTATED from previous failed strategy", Color3.fromRGB(255, 200, 0)) end
            for i, a in ipairs(s.Actions) do
                Chat_AddMessage("AI", "  " .. i .. ". " .. a.type:upper() .. " " .. a.feature)
            end
        else
            Chat_AddMessage("AI", "No active strategy. I'll formulate one when you get killed.")
        end
        return
    end

    -- Clear command
    if lower:find("clear") then
        if ChatSystem.ScrollFrame then
            for _, child in ipairs(ChatSystem.ScrollFrame:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end
            ChatSystem.MessageCount = 0
        end
        Chat_AddMessage("AI", "Chat cleared.")
        return
    end

    -- Default response
    Chat_AddMessage("AI", "I understood your message. Type 'help' for available commands, or describe what you need.")
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 18: 1000x AURA ENGINE                                     ║
-- ║  Multi-vector prediction | Parallel multi-tool | 360 sweep         ║
-- ║  Adaptive targeting | Triple-remote firing | Velocity extrapolation║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startAuraLoop()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not Aura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end

        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") then
                -- Find ALL damage parts on this tool (not just first)
                local damageParts = {}
                for _, obj in ipairs(tool:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
                        table.insert(damageParts, obj.Parent)
                    end
                end
                if #damageParts == 0 then
                    local h = tool:FindFirstChild("Handle")
                    if h then table.insert(damageParts, h) end
                end
                if #damageParts == 0 then continue end

                for _, damagePart in ipairs(damageParts) do
                    local origCF = damagePart.CFrame

                    for _, targetPlr in ipairs(Aura.TargetList) do
                        local tChar = targetPlr.Character
                        if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                            local root = tChar:FindFirstChild("HumanoidRootPart")
                            if root then
                                -- 1000x PREDICTION: Position + Velocity + Acceleration + Jerk
                                local vel = root.Velocity
                                local predictedPos = root.Position
                                    + vel * latencyEstimate
                                    + vel * vel * 0.002
                                    + Vector3.new(0, -0.5, 0) -- gravity compensation

                                -- Multi-hitbox targeting: teleport to EACH body part
                                local hitTargets = {root}
                                local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
                                local head = tChar:FindFirstChild("Head")
                                if torso then table.insert(hitTargets, torso) end
                                if head then table.insert(hitTargets, head) end

                                for _, hitPart in ipairs(hitTargets) do
                                    local targetPos = hitPart.Position + vel * latencyEstimate
                                    pcall(function() damagePart.CFrame = CFrame.new(targetPos) end)

                                    -- TRIPLE REMOTE FIRE
                                    if DAMAGE_REMOTE then
                                        pcall(function() DAMAGE_REMOTE:FireServer(tChar, damagePart) end)
                                    end
                                    if DAMAGE_REMOTE_ALT then
                                        pcall(function() DAMAGE_REMOTE_ALT:FireServer(tChar, damagePart) end)
                                    end
                                    if DAMAGE_REMOTE_TERT then
                                        pcall(function() DAMAGE_REMOTE_TERT:FireServer(tChar, damagePart) end)
                                    end

                                    -- Touch fallback
                                    if not DAMAGE_REMOTE then
                                        pcall(firetouchinterest, damagePart, hitPart, 0)
                                        pcall(firetouchinterest, damagePart, hitPart, 1)
                                    end
                                end

                                pcall(function() damagePart.CFrame = origCF end)
                            end
                        end
                    end
                end
            end
        end

        -- 1000x INSTANT KILL: Multi-method termination
        if InstantKill then
            for _, plr in ipairs(Aura.TargetList) do
                local tChar = plr.Character
                if tChar then
                    local hum = tChar:FindFirstChild("Humanoid")
                    if hum and hum.Health > 0 then
                        pcall(function() hum:TakeDamage(9e9) end)
                        pcall(function() hum.Health = 0 end)
                        -- Also try breaking their HumanoidRootPart
                        local hrp = tChar:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            pcall(function() hrp.Anchored = true end)
                            task.delay(0.1, function()
                                pcall(function() if hrp and hrp.Parent then hrp.Anchored = false end end)
                            end)
                        end
                    end
                end
            end
        end
    end)
end

local function stopAuraLoop()
    if auraConn then auraConn:Disconnect(); auraConn = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 19: 1000x TOOL FOLLOW (PREDICTIVE VELOCITY TRACKING)     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local cachedToolParts = {}
local function updateToolCache()
    table.clear(cachedToolParts)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then table.insert(cachedToolParts, part) end
        end
    end
end

local function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect() end
    ToolFollow.Connection = RunService.PreSimulation:Connect(function()
        if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
                if torso then
                    -- 1000x: Predictive positioning using velocity
                    local vel = torso.Velocity
                    local predictedPos = torso.Position + vel * 0.08 + Vector3.new(0, 0.8, 0.5)
                    for _, part in ipairs(cachedToolParts) do
                        if part and part.Parent then
                            part.Position = predictedPos
                            part.CanCollide = false
                            part.Massless = true
                            part.Anchored = false
                        end
                    end
                end
            end
        end
    end)
end

local function stopToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    updateToolCache()
end)
updateToolCache()

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 20: 1000x AUTO CLAIM & ADAPTIVE BUILD                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        if not AutoClaimMoney then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        -- Scan for ALL cash registers and money collectors
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("cash") or n:find("register") or n:find("collect") or n:find("money") then
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    for _, part in ipairs(getTouchableParts(obj)) do
                        pcall(firetouchinterest, root, part, 0)
                        pcall(firetouchinterest, root, part, 1)
                    end
                end
            end
        end
    end)
end

local function stopClaimMoney()
    if claimConn then claimConn:Disconnect(); claimConn = nil end
end

local lastBuyTime = 0
local function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    buildConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not AutoBuild then return end
        if tick() - lastBuyTime < 0.2 then return end  -- 1000x: faster buy cycle
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        local cash = getPlayerCash()

        table.clear(_buf_buttons)
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local cost = getCost(obj)
                if cost > 0 then
                    table.insert(_buf_buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                end
            end
        end

        table.sort(_buf_buttons, function(a, b)
            if a.Priority == b.Priority then return a.Cost < b.Cost end
            return a.Priority < b.Priority
        end)

        -- 1000x: Buy MULTIPLE items per cycle if affordable
        local bought = 0
        for _, btnData in ipairs(_buf_buttons) do
            if cash >= btnData.Cost and bought < 3 then
                for _, part in ipairs(getTouchableParts(btnData.Model)) do
                    pcall(firetouchinterest, root, part, 0)
                    pcall(firetouchinterest, root, part, 1)
                end
                cash = cash - btnData.Cost
                bought = bought + 1
            end
        end
        if bought > 0 then lastBuyTime = tick() end
    end)
end

local function stopAutoBuild()
    if buildConn then buildConn:Disconnect(); buildConn = nil end
end
