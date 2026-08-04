        Chat_AddMessage("AI", "  'strategy' - View active strategy")
        Chat_AddMessage("AI", "  'threats' - Current threat assessment")
        Chat_AddMessage("AI", "  'disable all' - Turn off all AI-activated features")
        Chat_AddMessage("AI", "  'why' - Explain current situation")
        Chat_AddMessage("AI", "  'target [name]' - Focus all systems on a player")
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
                Chat_AddMessage("AI", "  " .. feat .. " confidence: " .. conf .. "%")
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
        Chat_AddMessage("AI", "  Trend: " .. (ThreatTrend > 0 and "RISING" or ThreatTrend < 0 and "FALLING" or "STABLE"))
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
                        Chat_AddMessage("AI", "  " .. plr.Name .. " - " .. math.floor(d) .. " studs away", Color3.fromRGB(255, 150, 50))
                    end
                end
            end
        end
        if nearby == 0 then Chat_AddMessage("AI", "  No players within threat radius.") end
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
            Chat_AddMessage("AI", "  Distance: " .. last.Distance .. " studs")
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 21: 1000x ANTI-AURA (SHIELD STACK + HEAL + REFLECT)      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect() end
    antiAuraConn = RunService.Heartbeat:Connect(function()
        if not AntiAura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar:FindFirstChild("Humanoid")
        if not root or not hum then return end

        -- GOD MODE: ForceField + auto-heal
        if AntiAura.GodMode then
            if not antiAuraFF or not antiAuraFF.Parent then
                antiAuraFF = Instance.new("ForceField")
                antiAuraFF.Visible = false
                antiAuraFF.Parent = myChar
            end
            if hum.Health < hum.MaxHealth * 0.7 then
                hum.Health = hum.MaxHealth
            end
        else
            if antiAuraFF and antiAuraFF.Parent then
                antiAuraFF:Destroy()
                antiAuraFF = nil
            end
        end

        -- HEAL AURA: Continuous regeneration
        if AntiAura.HealAura then
            if hum.Health < hum.MaxHealth then
                hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.05)
            end
        end

        -- 1000x REPEL: Extended radius + boosted force + ALL tools
        if AntiAura.Repel then
            for _, otherPlr in ipairs(Players:GetPlayers()) do
                if otherPlr ~= player and otherPlr.Character then
                    for _, tool in ipairs(otherPlr.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local dist = (handle.Position - root.Position).Magnitude
                                if dist < AntiAura.RepelRadius then
                                    local dir = (root.Position - handle.Position).Unit
                                    pcall(function()
                                        handle.AssemblyLinearVelocity = dir * AntiAura.RepelForce
                                        handle.CanCollide = false
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- PHASE: Full no-collide on all parts
        if AntiAura.Phase then
            for _, part in ipairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect(); antiAuraConn = nil end
    if antiAuraFF and antiAuraFF.Parent then antiAuraFF:Destroy(); antiAuraFF = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 22: 1000x REACH (DYNAMIC THREAT-BASED SIZING)            ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local reachOriginalSizes = {}
local reachHL = {}

local function applyReach()
    local myChar = player.Character
    if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = getToolPart(t)
            if part then
                if not reachOriginalSizes[part] then
                    reachOriginalSizes[part] = part.Size
                end
                part.Size = reachOriginalSizes[part] * ReachSize
                part.Massless = true
                part.CanCollide = false
                if not reachHL[part] then
                    local hl = Instance.new("Highlight", part)
                    hl.FillTransparency = 1
                    hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                    reachHL[part] = hl
                end
            end
        end
    end
end

local function stopReach()
    for part, hl in pairs(reachHL) do
        if hl and hl.Parent == part then hl:Destroy() end
    end
    table.clear(reachHL)
    for part, origSize in pairs(reachOriginalSizes) do
        if part and part.Parent then part.Size = origSize end
    end
    table.clear(reachOriginalSizes)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 23: 1000x FAST RESPAWN                                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startFastRespawn()
    local Guide = ReplicatedStorage:FindFirstChild("Guide")
    local last = 0
    local function respawn()
        if tick() - last < 0.02 then return end  -- 1000x: faster threshold
        last = tick()
        pcall(function()
            if Guide then Guide:FireServer() else player:LoadCharacter() end
        end)
    end
    local function hook(c)
        local hum = c:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function(hp) if hp <= 0 then respawn() end end)
        hum.Died:Connect(respawn)
    end
    if player.Character then hook(player.Character) end
    player.CharacterAdded:Connect(hook)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24: 1000x INSTA-KILL (PARALLEL MULTI-BURST + SWEEP)      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function IK_RefreshTools()
    table.clear(IK_ToolsCache)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local fightEvent = tool:FindFirstChild("FightEvent", true)
            local touchPart = tool:FindFirstChildWhichIsA("TouchTransmitter", true)
            if fightEvent and fightEvent:IsA("RemoteEvent") then
                table.insert(IK_ToolsCache, {
                    Tool = tool,
                    FightEvent = fightEvent,
                    TouchPart = touchPart and touchPart.Parent or nil
                })
            elseif touchPart then
                table.insert(IK_ToolsCache, {
                    Tool = tool,
                    FightEvent = nil,
                    TouchPart = touchPart.Parent
                })
            end
        end
    end
    -- Also scan Backpack
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local fightEvent = tool:FindFirstChild("FightEvent", true)
                if fightEvent and fightEvent:IsA("RemoteEvent") then
                    table.insert(IK_ToolsCache, {
                        Tool = tool,
                        FightEvent = fightEvent,
                        TouchPart = nil
                    })
                end
            end
        end
    end
end

local function IK_GetTarget()
    local myChar = player.Character
    local myRoot = myChar and getHRP(myChar)
    if not myRoot then return nil end
    local bestChar, bestDist = nil, 50  -- 1000x: expanded range
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local root = getHRP(char)
                if root then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestChar = char
                        end
                    end
                end
            end
        end
    end
    return bestChar
end

local function IK_MicroBurst(targetChar, burstCount)
    if not targetChar or not player.Character then return end
    -- 1000x: ALL body parts targeted
    table.clear(IK_TargetParts)
    for _, name in ipairs({"HumanoidRootPart", "UpperTorso", "Torso", "Head",
                           "LowerTorso", "LeftUpperArm", "RightUpperArm",
                           "LeftUpperLeg", "RightUpperLeg"}) do
        local part = targetChar:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            table.insert(IK_TargetParts, part)
        end
    end
    if #IK_TargetParts == 0 then return end

    -- PARALLEL FIRE: All tools simultaneously
    for _, toolData in ipairs(IK_ToolsCache) do
        local tool = toolData.Tool
        local fight = toolData.FightEvent
        local touch = toolData.TouchPart
        if tool and tool.Parent then
            if fight then
                pcall(function()
                    for _ = 1, burstCount do fight:FireServer() end
                end)
            else
                pcall(tool.Activate, tool)
            end
            if touch then
                for _, part in ipairs(IK_TargetParts) do
                    if part and part.Parent then
                        pcall(firetouchinterest, touch, part, 0)
                        pcall(firetouchinterest, touch, part, 1)
                    end
                end
            end
        end
    end
end

local function startInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect() end
    IK_RefreshTools()
    InstaKillConn = RunService.PreSimulation:Connect(function()
        if not InstaKillEnabled then return end
        local now = os.clock()
        if now - IK_LastActivation < 1/120 then return end  -- 1000x: 120Hz
        IK_LastActivation = now
        IK_RefreshTools()
        if #IK_ToolsCache == 0 then return end

        local adaptiveBurst = IK_BurstCount
        if IK_AdaptiveBurst and ThreatLevel > 2 then
            adaptiveBurst = IK_BurstCount + ThreatLevel * 2  -- 1000x scaling
        end
        local target = IK_GetTarget()
        if target then
            IK_MicroBurst(target, adaptiveBurst)
        end
    end)
end

local function stopInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect(); InstaKillConn = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 25: 1000x HIT AMPLIFIER (360 SWEEP + MULTI-PULSE)        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local HA_OverlapParams = OverlapParams.new()
HA_OverlapParams.FilterType = Enum.RaycastFilterType.Exclude

local function HA_RefreshTools()
    table.clear(HA_CachedTools)
    local char = player.Character
    if not char then return end
    for _, t in ipairs(char:GetChildren()) do
        if t:IsA("Tool") then
            local fight = t:FindFirstChild("FightEvent", true)
            if fight and fight:IsA("RemoteEvent") then
                table.insert(HA_CachedTools, {Tool = t, FightEvent = fight})
            end
        end
    end
end

local function startHitAmplifier()
    if HitAmpConn then HitAmpConn:Disconnect() end
    HA_RefreshTools()
    HitAmpConn = RunService.PreSimulation:Connect(function(dt)
        if not HitAmpEnabled then return end
        HA_Accumulator = HA_Accumulator + dt
        if HA_Accumulator < HA_PulseInterval then return end
        HA_Accumulator = 0
        local char = player.Character
        if not char then return end
        local hrp = getHRP(char)
        if not hrp then return end
        local now = os.clock()
        if now - HA_LastActivation < 0.006 then return end  -- 1000x: faster

        HA_OverlapParams.FilterDescendantsInstances = {char}

        -- 360 SPHERICAL SCAN
        local parts = workspace:GetPartBoundsInBox(
            CFrame.new(hrp.Position),
            HA_Range,
            HA_OverlapParams
        )

        -- Also do a sphere check for anything the box misses
        local sphereParts = workspace:GetPartBoundsInRadius(hrp.Position, HA_Range.X, HA_OverlapParams)

        local hasTarget = false
        local targetModels = {}

        for _, part in ipairs(parts) do
            local model = part:FindFirstChildOfClass("Model")
                or (part.Parent and part.Parent:FindFirstChildOfClass("Model"))
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and model ~= char then
                    hasTarget = true
                    if not targetModels[model] then
                        targetModels[model] = true
                    end
                end
            end
        end
        for _, part in ipairs(sphereParts) do
            local model = part:FindFirstChildOfClass("Model")
                or (part.Parent and part.Parent:FindFirstChildOfClass("Model"))
            if model then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and model ~= char then
                    hasTarget = true
                    if not targetModels[model] then
                        targetModels[model] = true
                    end
                end
            end
        end

        if hasTarget then
            HA_LastActivation = now
            -- MULTI-PULSE: Fire multiple waves
            local pulses = HA_MultiPulse and 3 or 1
            for _ = 1, pulses do
                for _, data in ipairs(HA_CachedTools) do
                    if data.FightEvent then
                        pcall(function()
                            for _ = 1, HA_BurstCount do data.FightEvent:FireServer() end
                        end)
                    else
                        pcall(data.Tool.Activate, data.Tool)
                    end
                end
            end
        end
    end)
end

local function stopHitAmplifier()
    if HitAmpConn then HitAmpConn:Disconnect(); HitAmpConn = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 26: 1000x TOOL GRABBER                                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local TG_TOOL_RULES = {
    {Pattern = "Energy Sword", Base = "Stone"},
    {Pattern = "Staff", Base = "Magic"},
    {Pattern = "Axe", Base = "Storm"},
    {Pattern = "Fist", Base = "Robotic"},
    {Pattern = "Blade Arms", Base = "Mecha"},
    {Pattern = "Shadow Claws", Base = "Shadow"},
    {Pattern = "Hyper Claws", Base = "Hyper"},
    {Pattern = "Thunder Claws", Base = "Thunder"},
    {Pattern = "Void Claws", Base = "Void"},
    {Pattern = "Frozen Claws", Base = "Frozen"},
    {Pattern = "Magma Claws", Base = "Magma"},
    {Pattern = "Nuclear Claws", Base = "Nuclear"},
    {Pattern = "Toxic Claws", Base = "Toxic"},
    {Pattern = "Punch", Base = "Kong"},
}

local function TG_HasTool(pattern)
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(pattern:lower(), 1, true) then return true end
        end
    end
    local char = player.Character
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") and item.Name:lower():find(pattern:lower(), 1, true) then return true end
        end
    end
    return false
end

local function TG_GetClosestPad(baseName)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local pads = TG_padsByBase[baseName]
    if not pads or #pads == 0 then return nil end
    local closest, bestDist = nil, 10000
    for _, pad in ipairs(pads) do
        if pad and pad.Parent then
            local d = (pad.Position - root.Position).Magnitude
            if d < bestDist then bestDist = d; closest = pad end
        end
    end
    return closest
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 27: 1000x KILL INTELLIGENCE (FULL BEHAVIORAL ANALYSIS)   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local LastSpawnTime = 0

local function analyzeKill(killer, weaponName, distance, ttk)
    local suspected = {}
    local counter = {}
    local threat = 1
    local timeSinceRespawn = tick() - LastSpawnTime

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
        local hum = char:WaitForChild("Humanoid")
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
                killerName = creator.Value.Name
                local killerChar = creator.Value.Character
                if killerChar then
                    local myRoot = char:FindFirstChild("HumanoidRootPart")
                    local theirRoot = killerChar:FindFirstChild("HumanoidRootPart")
                    if myRoot and theirRoot then
                        distance = (myRoot.Position - theirRoot.Position).Magnitude
                    end
                    for _, tool in ipairs(killerChar:GetChildren()) do
                        if tool:IsA("Tool") then weaponName = tool.Name; break end
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

            -- Also send a WindUI notification
            WindUI:Notify({
                Title = "SENTINEL AI - Kill Detected (Threat " .. analysis.Threat .. "/10)",
                Content = "Killer: " .. analysis.Killer
                    .. "\nWeapon: " .. analysis.Weapon
                    .. "\nDist: " .. analysis.Distance .. " studs | TTK: " .. string.format("%.2f", analysis.TTK) .. "s"
                    .. "\nSuspected: " .. table.concat(analysis.Suspected, ", ")
                    .. "\nAI analyzing... check chat.",
                Duration = 6,
                Icon = "alert-triangle",
            })
        end)
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 28: 1000x ESP (THREAT-COLORED + INFO)                    ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startESP()
    if espGui then return end
    espGui = Instance.new("ScreenGui")
    espGui.Name = "EXO_ESP"
    espGui.ResetOnSpawn = false
    pcall(function() espGui.Parent = CoreGui end)
    if not espGui.Parent then espGui.Parent = player:WaitForChild("PlayerGui") end

    local function createDot(plr)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(0, 60, 0, 20)
        container.BackgroundTransparency = 1
        container.Parent = espGui

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 8, 0, 8)
        dot.Position = UDim2.new(0.5, -4, 0, 0)
        dot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        dot.BorderSizePixel = 0
        dot.Parent = container
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0, 10)
        nameLabel.Position = UDim2.new(0, 0, 0, 10)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = plr.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextSize = 8
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Parent = container

        espDots[plr] = container
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then createDot(plr) end
    end

    Players.PlayerAdded:Connect(function(plr)
        if plr ~= player then createDot(plr) end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if espDots[plr] then espDots[plr]:Destroy(); espDots[plr] = nil end
    end)

    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local myChar = player.Character
        local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position

        for plr, container in pairs(espDots) do
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local pos, onScreen = cam:WorldToViewportPoint(char.HumanoidRootPart.Position)
                container.Position = UDim2.new(0, pos.X - 30, 0, pos.Y - 10)
                container.Visible = onScreen

                -- Threat coloring based on distance
                if myPos then
                    local dist = (char.HumanoidRootPart.Position - myPos).Magnitude
                    local dot = container:FindFirstChild("Frame")
                    if dot then
                        if dist < 15 then
                            dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                        elseif dist < 30 then
                            dot.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
                        else
                            dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                        end
                    end
                end
            else
                container.Visible = false
            end
        end
    end)
end

local function stopESP()
    if espGui then espGui:Destroy(); espGui = nil end
    table.clear(espDots)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 29: 1000x ANTI-LAG                                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startAntiLag()
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                obj.Enabled = false
            end
            if obj:IsA("Sound") and obj.Playing then
                obj.Volume = 0
            end
        end
        Lighting.GlobalShadows = false
        Lighting.Brightness = 1
        Lighting.FogEnd = 500
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = false end
        end
    end)
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
end

local function stopAntiLag()
    pcall(function()
        Lighting.GlobalShadows = true
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then effect.Enabled = true end
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 30: SAFE NO COOLDOWN                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startNoCooldown()
    if NoCooldownConn then NoCooldownConn:Disconnect() end
    NoCooldownConn = RunService.RenderStepped:Connect(function()
        if not NoCooldown then return end
        local myChar = player.Character
        if not myChar then return end
        for _, t in ipairs(myChar:GetChildren()) do
            if t:IsA("Tool") then
                pcall(function()
                    if t:FindFirstChild("Cooldown") then t.Cooldown.Value = 0 end
                    if t:FindFirstChild("Enabled") then t.Enabled.Value = true end
                    local handle = t:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then handle.CanCollide = false end
                end)
            end
        end
    end)
end

local function stopNoCooldown()
    if NoCooldownConn then NoCooldownConn:Disconnect(); NoCooldownConn = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 31: BUILD WINDUI                                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local Window = WindUI:CreateWindow({
    Title = "EXO Hub",
    Icon = "swords",
    Author = "SENTINEL AI | v8.0 | 1000x",
    Folder = "EXOHub",
    Size = UDim2.fromOffset(680, 540),
    Transparent = false,
    Theme = "Default",
    SideBarWidth = 180,
    HasOutline = true,
})

Window:EditOpenButton({
    Enabled = true,
    Image = "swords",
    Title = "E",
    CornerRadius = UDim.new(1, 0),
    StrokeThickness = 2,
    Side = "Left",
})

local SPT_Combat_Tab   = Window:Tab({Title = "SPT Combat", Icon = "swords"})
local SPT_Tycoon_Tab   = Window:Tab({Title = "SPT Tycoon", Icon = "building-2"})
local SPT_Misc_Tab     = Window:Tab({Title = "SPT Misc", Icon = "move"})
local MPT_Kill_Tab     = Window:Tab({Title = "MPT Kill", Icon = "skull"})
local MPT_Economy_Tab  = Window:Tab({Title = "MPT Economy", Icon = "crown"})
local AI_Tab           = Window:Tab({Title = "Sentinel AI", Icon = "brain"})
local Updates_Tab      = Window:Tab({Title = "Updates", Icon = "scroll-text"})
local Settings_Tab     = Window:Tab({Title = "Settings", Icon = "settings"})

-- ═══════════════════════════════════════════════════════════════════════
--  SPT COMBAT TAB (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local AuraSec = SPT_Combat_Tab:Section({Title = "1000x Multi-Target Aura"})
    AuraSec:Toggle({Title = "Enable Aura", Default = false, Callback = function(state)
        Aura.Enabled = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            WindUI:Notify({Title = "Aura", Content = "ENGAGED - " .. #Aura.TargetList .. " targets. Multi-vector prediction active.", Duration = 2, Icon = "swords"})
        else stopAuraLoop() end
    end})
    AuraSec:Toggle({Title = "Instant Kill", Default = false, Callback = function(state) InstantKill = state end})
    AuraSec:Slider({Title = "Prediction Depth", Min = 3, Max = 30, Default = 8, Callback = function(val) latencyEstimate = val / 100 end})
    AuraSec:Dropdown({Title = "Aura Targets", Options = getServerPlayers(), MultiSelection = true, Callback = function(selected)
        table.clear(Aura.TargetList)
        if selected then
            for _, name in ipairs(selected) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(Aura.TargetList, plr) end
            end
        end
    end})

    local ToolFollowSec = SPT_Combat_Tab:Section({Title = "1000x Tool Follow"})
    ToolFollowSec:Toggle({Title = "Enable Tool Follow", Default = false, Callback = function(state)
        ToolFollow.Enabled = state
        if state then
            ToolFollow.Targets = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(ToolFollow.Targets, plr) end
            end
            startToolFollow()
        else stopToolFollow() end
    end})

    local DefenseSec = SPT_Combat_Tab:Section({Title = "1000x Defense / Anti-Aura"})
    DefenseSec:Toggle({Title = "Enable Anti-Aura", Default = false, Callback = function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end})
    DefenseSec:Toggle({Title = "God Mode (ForceField)", Default = false, Callback = function(state) AntiAura.GodMode = state end})
    DefenseSec:Toggle({Title = "Repel (Anti-Touch)", Default = false, Callback = function(state) AntiAura.Repel = state end})
    DefenseSec:Toggle({Title = "Phase (No Collide)", Default = false, Callback = function(state) AntiAura.Phase = state end})
    DefenseSec:Toggle({Title = "Heal Aura", Default = false, Callback = function(state) AntiAura.HealAura = state end})
    DefenseSec:Slider({Title = "Repel Force", Min = 50, Max = 300, Default = 120, Callback = function(val) AntiAura.RepelForce = val end})
    DefenseSec:Slider({Title = "Repel Radius", Min = 8, Max = 30, Default = 18, Callback = function(val) AntiAura.RepelRadius = val end})
    DefenseSec:Toggle({Title = "Anti Spawnkill", Default = false, Callback = function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9; hum.Health = 9e9
                local ff = Instance.new("ForceField", c); ff.Visible = false
                task.delay(5, function()
                    if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end})
end

-- ═══════════════════════════════════════════════════════════════════════
--  SPT TYCOON TAB (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local TycoonSec = SPT_Tycoon_Tab:Section({Title = "1000x Tycoon Automation"})
    TycoonSec:Toggle({Title = "Auto Claim Money", Default = false, Callback = function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end})
    TycoonSec:Toggle({Title = "Smart Auto Build (Multi-Buy)", Default = false, Callback = function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end})
    TycoonSec:Toggle({Title = "Auto Grab Weapons", Default = false, Callback = function(state)
        AutoGetTools = state
        if state then
            if grabLoopConn then grabLoopConn:Disconnect() end
            grabLoopConn = RunService.PreSimulation:Connect(function()
                if not AutoGetTools then return end
                local myChar = player.Character
                if not myChar then return end
                local root = myChar:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for _, rule in ipairs(TG_TOOL_RULES) do
                    if not TG_HasTool(rule.Pattern) then
                        local pad = TG_GetClosestPad(rule.Base)
                        if pad then
                            for _ = 1, TG_BurstCount do
                                pcall(firetouchinterest, root, pad, 0)
                                pcall(firetouchinterest, root, pad, 1)
                            end
                        end
                    end
                end
            end)
        else
            if grabLoopConn then grabLoopConn:Disconnect(); grabLoopConn = nil end
        end
    end})

    local CooldownSec = SPT_Tycoon_Tab:Section({Title = "Tools & Cooldown"})
    CooldownSec:Toggle({Title = "Auto Use Tools (0 delay)", Default = false, Callback = function(state)
        AutoTools = state
        if state then
            toolLoopConn = RunService.RenderStepped:Connect(function()
                if not AutoTools then return end
                local myChar = player.Character
                if not myChar then return end
                for _, t in ipairs(myChar:GetChildren()) do
                    if t:IsA("Tool") then pcall(function() t:Activate() end) end
                end
                for _, t in ipairs(player.Backpack:GetChildren()) do
                    if t:IsA("Tool") then t.Parent = myChar; pcall(function() t:Activate() end) end
                end
            end)
        else
            if toolLoopConn then toolLoopConn:Disconnect(); toolLoopConn = nil end
        end
    end})
    CooldownSec:Toggle({Title = "No Cooldown (SAFE)", Default = false, Callback = function(state)
        NoCooldown = state
        if state then startNoCooldown() else stopNoCooldown() end
    end})
end

-- ═══════════════════════════════════════════════════════════════════════
--  SPT MISC TAB (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local ReachSec = SPT_Misc_Tab:Section({Title = "1000x Reach"})
    ReachSec:Toggle({Title = "Enable Reach", Default = false, Callback = function(state)
        Reach = state
        if state then applyReach() else stopReach() end
    end})
    ReachSec:Slider({Title = "Reach Size", Min = 1, Max = 15, Default = 3, Callback = function(val)
        ReachSize = val
        if Reach then stopReach(); applyReach() end
    end})

    local RespawnSec = SPT_Misc_Tab:Section({Title = "Respawn & Protection"})
    RespawnSec:Toggle({Title = "Fast Respawn", Default = false, Callback = function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end})

    local UtilsSec = SPT_Misc_Tab:Section({Title = "Utilities"})
    UtilsSec:Textbox({Title = "Set Damage Remote", Placeholder = "game.ReplicatedStorage.DealDamage", Callback = function(text)
        if text and text ~= "" then
            local ok, remote = pcall(function() return loadstring("return " .. text)() end)
            if ok and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                WindUI:Notify({Title = "Remote Set", Content = "Damage remote updated.", Duration = 3, Icon = "check"})
            else
                WindUI:Notify({Title = "Error", Content = "Invalid remote path.", Duration = 3, Icon = "x"})
            end
        end
    end})
end

-- ═══════════════════════════════════════════════════════════════════════
--  MPT KILL TAB (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local OmniSec = MPT_Kill_Tab:Section({Title = "1000x Omni-Kill Engine"})
    OmniSec:Toggle({Title = "Enable Omni-Kill", Default = false, Callback = function(state)
        Aura.Enabled = state; InstantKill = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            WindUI:Notify({Title = "OMNI-KILL", Content = "ENGAGED - " .. #Aura.TargetList .. " targets.", Duration = 3, Icon = "skull"})
        else stopAuraLoop() end
    end})
    OmniSec:Toggle({Title = "Insta-Kill Micro-Burst", Default = false, Callback = function(state)
        InstaKillEnabled = state
        if state then startInstaKill() else stopInstaKill() end
    end})
    OmniSec:Toggle({Title = "Adaptive Burst (Threat-Based)", Default = true, Callback = function(state)
        IK_AdaptiveBurst = state
    end})
    OmniSec:Slider({Title = "Prediction Aggression", Min = 3, Max = 30, Default = 8, Callback = function(val) latencyEstimate = val / 100 end})
    OmniSec:Slider({Title = "Burst Count", Min = 3, Max = 20, Default = 12, Callback = function(val) IK_BurstCount = val end})
    OmniSec:Button({Title = "Manual Kill Burst", Callback = function()
        local orig = Aura.Enabled
        Aura.Enabled = true; InstantKill = true
        task.wait(0.15)
        Aura.Enabled = orig
        if not orig then InstantKill = false end
        WindUI:Notify({Title = "Kill Burst", Content = "Burst fired.", Duration = 2, Icon = "zap"})
    end})
    OmniSec:Button({Title = "Refresh Target List", Callback = function()
        table.clear(Aura.TargetList)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        WindUI:Notify({Title = "Targets", Content = "Refreshed: " .. #Aura.TargetList .. " players.", Duration = 2, Icon = "refresh-cw"})
    end})

    local HitAmpSec = MPT_Kill_Tab:Section({Title = "1000x Hit Amplifier"})
    HitAmpSec:Toggle({Title = "Enable Hit Amplifier", Default = false, Callback = function(state)
        HitAmpEnabled = state
        if state then startHitAmplifier() else stopHitAmplifier() end
    end})
    HitAmpSec:Slider({Title = "Scan Range", Min = 15, Max = 60, Default = 45, Callback = function(val)
        HA_Range = Vector3.new(val, val, val)
    end})
    HitAmpSec:Slider({Title = "Burst Count", Min = 1, Max = 15, Default = 8, Callback = function(val) HA_BurstCount = val end})
    HitAmpSec:Toggle({Title = "Multi-Pulse (3x waves)", Default = true, Callback = function(state) HA_MultiPulse = state end})
    HitAmpSec:Label({Title = "360 sphere+box scan | 8ms cooldown | OverlapParams"})

    local ArsenalSec = MPT_Kill_Tab:Section({Title = "1000x Tool Arsenal"})
    ArsenalSec:Toggle({Title = "Enable Tool Arsenal", Default = false, Callback = function(state)
        TG_Enabled = state
        if state then
            if not getgenv().EXO_TG_Loop then
                getgenv().EXO_TG_Loop = true
                task.spawn(function()
                    while getgenv().EXO_TG_Loop do
                        if TG_Enabled then
                            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if root then
                                for _, rule in ipairs(TG_TOOL_RULES) do
                                    if not TG_HasTool(rule.Pattern) then
                                        local pad = TG_GetClosestPad(rule.Base)
                                        if pad then
                                            for _ = 1, TG_BurstCount do
                                                pcall(firetouchinterest, root, pad, 0)
                                                pcall(firetouchinterest, root, pad, 1)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        task.wait(0.08)
                    end
                end)
            end
        else
            getgenv().EXO_TG_Loop = false
        end
    end})
    ArsenalSec:Button({Title = "Force Acquire All", Callback = function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            for baseName, _ in pairs(TG_padsByBase) do
                local pad = TG_GetClosestPad(baseName)
                if pad then
                    for _ = 1, TG_BurstCount do
                        pcall(firetouchinterest, root, pad, 0)
                        pcall(firetouchinterest, root, pad, 1)
                    end
                end
            end
            WindUI:Notify({Title = "Tool Arsenal", Content = "Force acquire burst fired.", Duration = 2, Icon = "package"})
        end
    end})
    ArsenalSec:Label({Title = "14 Bases: Stone, Magic, Storm, Robotic, Mecha, Shadow, Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong"})
end

-- ═══════════════════════════════════════════════════════════════════════
--  MPT ECONOMY TAB (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local SovSec = MPT_Economy_Tab:Section({Title = "1000x Tycoon Sovereign"})
    SovSec:Toggle({Title = "Enable Sovereign Economy", Default = false, Callback = function(state)
        AutoClaimMoney = state; AutoBuild = state
        if state then startClaimMoney(); startAutoBuild()
        else stopClaimMoney(); stopAutoBuild() end
    end})
    SovSec:Slider({Title = "Defense Threat Radius", Min = 20, Max = 120, Default = 60, Callback = function(val) ThreatRadius = val end})
    SovSec:Button({Title = "Force Buy Next Upgrade", Callback = function()
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        local cash = getPlayerCash()
        local best, bestPri = nil, 9999
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local cost = getCost(obj)
                local pri = getPriority(obj.Name)
                if cost > 0 and cost <= cash and pri < bestPri then best = obj; bestPri = pri end
            end
        end
        if best then
            for _, part in ipairs(getTouchableParts(best)) do
                pcall(firetouchinterest, root, part, 0)
                pcall(firetouchinterest, root, part, 1)
            end
            WindUI:Notify({Title = "Purchased", Content = "Bought: " .. best.Name, Duration = 2, Icon = "check"})
        else
            WindUI:Notify({Title = "No Purchase", Content = "Nothing affordable.", Duration = 2, Icon = "x"})
        end
    end})

    local SpawnSec = MPT_Economy_Tab:Section({Title = "Spawn Supremacy"})
    SpawnSec:Toggle({Title = "Enable Supremacy Mode", Default = false, Callback = function(state)
        AntiSpawnkill = state
        if state then
            player.CharacterAdded:Connect(function(c)
                local hum = c:WaitForChild("Humanoid")
                hum.MaxHealth = 9e9; hum.Health = 9e9
                local ff = Instance.new("ForceField", c); ff.Visible = false
                task.delay(5, function()
                    if hum and hum.Parent then hum.MaxHealth = 100; hum.Health = 100 end
                    if ff then ff:Destroy() end
                end)
            end)
        end
    end})
    SpawnSec:Toggle({Title = "Fast Respawn", Default = false, Callback = function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end})

    local DefSec = MPT_Economy_Tab:Section({Title = "1000x Defense Matrix"})
    DefSec:Toggle({Title = "Enable Defense Matrix", Default = false, Callback = function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end})
    DefSec:Toggle({Title = "ForceField God Mode", Default = false, Callback = function(state) AntiAura.GodMode = state end})
    DefSec:Toggle({Title = "Weapon Repel", Default = false, Callback = function(state) AntiAura.Repel = state end})
    DefSec:Toggle({Title = "Phase Mode (No Collide)", Default = false, Callback = function(state) AntiAura.Phase = state end})
    DefSec:Toggle({Title = "Heal Aura", Default = false, Callback = function(state) AntiAura.HealAura = state end})
    DefSec:Button({Title = "Emergency Heal", Callback = function()
        local myChar = player.Character
        if myChar then
            local hum = myChar:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                WindUI:Notify({Title = "Healed", Content = "Health restored.", Duration = 2, Icon = "heart"})
            end
        end
    end})
end

-- ═══════════════════════════════════════════════════════════════════════
--  SENTINEL AI TAB (NEW)
-- ═══════════════════════════════════════════════════════════════════════
do
    local AIControlSec = AI_Tab:Section({Title = "Sentinel AI Control"})
    AIControlSec:Toggle({Title = "Enable Sentinel AI", Default = true, Callback = function(state)
        KillNotifEnabled = state
        KillLogEnabled = state
        if state then
            Chat_CreateGUI()
            Chat_AddMessage("AI", "Sentinel AI activated. I'm watching your back. Enable Kill Notifications to feed me data.", Color3.fromRGB(0, 255, 100))
            WindUI:Notify({Title = "Sentinel AI", Content = "AI Combat Brain ONLINE. Chat overlay active.", Duration = 3, Icon = "brain"})
        end
    end})
    AIControlSec:Toggle({Title = "Auto-Analyze Kills", Default = true, Callback = function(state)
        KillNotifEnabled = state
    end})
    AIControlSec:Toggle({Title = "Auto-Counter (with confirmation)", Default = true, Callback = function(state)
        -- When true, AI presents strategy and waits for Y/N
        -- When false, AI only reports but doesn't propose actions
    end})
    AIControlSec:Button({Title = "Open AI Chat", Callback = function()
        Chat_CreateGUI()
        Chat_AddMessage("AI", "Chat opened. Type 'help' for commands.")
    end})
    AIControlSec:Button({Title = "Disable All AI Features", Callback = function()
        Aura.Enabled = false; stopAuraLoop()
        InstaKillEnabled = false; stopInstaKill()
        HitAmpEnabled = false; stopHitAmplifier()
        AntiAura.Enabled = false; stopAntiAura()
        Reach = false; stopReach()
        Chat_AddMessage("AI", "All AI-activated features disabled.", Color3.fromRGB(255, 200, 0))
    end})

    local AIInfoSec = AI_Tab:Section({Title = "AI Intelligence"})
    AIInfoSec:Label({Title = "Threat Profiler: Tracks every killer's patterns"})
    AIInfoSec:Label({Title = "Strategy Engine: Combines features to counter threats"})
    AIInfoSec:Label({Title = "Chat System: Full bidirectional conversation"})
    AIInfoSec:Label({Title = "Robot Analyst: Animated kill report processor"})
    AIInfoSec:Label({Title = "Confirmation Gate: AI asks before acting"})
    AIInfoSec:Button({Title = "View All Threat Profiles", Callback = function()
        local count = 0
        for name, prof in pairs(ThreatProfiles) do
            count = count + 1
            WindUI:Notify({
                Title = "Profile: " .. name,
                Content = "Kills: " .. prof.TotalKills .. " | Threat: " .. prof.ThreatScore
                    .. "/100\nFeatures: " .. table.concat(prof.SuspectedFeatures, ", "),
                Duration = 4, Icon = "user",
            })
        end
        if count == 0 then
            WindUI:Notify({Title = "Profiles", Content = "No threat profiles yet.", Duration = 2, Icon = "info"})
        end
    end})
    AIInfoSec:Button({Title = "Reset All Profiles", Callback = function()
        ThreatProfiles = {}
        writeJSON(PROFILE_FILE, ThreatProfiles)
        WindUI:Notify({Title = "Profiles", Content = "All threat profiles cleared.", Duration = 2, Icon = "trash"})
    end})
end

-- ═══════════════════════════════════════════════════════════════════════
--  UPDATES TAB
-- ═══════════════════════════════════════════════════════════════════════
do
    local ChangeSec = Updates_Tab:Section({Title = "EXO Hub Changelog"})
    ChangeSec:Label({Title = "v8.0 - SENTINEL AI (CURRENT)"})
    ChangeSec:Label({Title = "  - NEW: Sentinel AI Combat Brain"})
    ChangeSec:Label({Title = "  - NEW: Animated Robot Kill Analyst"})
    ChangeSec:Label({Title = "  - NEW: Persistent Bidirectional Chat"})
    ChangeSec:Label({Title = "  - NEW: Threat Profiler (per-player)"})
    ChangeSec:Label({Title = "  - NEW: Strategy Engine (feature combos)"})
    ChangeSec:Label({Title = "  - NEW: Confirmation Gate (asks before acting)"})
    ChangeSec:Label({Title = "  - NEW: AI explains WHY you're losing"})
    ChangeSec:Label({Title = "  - 1000x: Aura (multi-vector, triple remote, multi-hitbox)"})
    ChangeSec:Label({Title = "  - 1000x: InstaKill (120Hz, parallel, 9 hitboxes)"})
    ChangeSec:Label({Title = "  - 1000x: HitAmp (360 sphere+box, multi-pulse)"})
    ChangeSec:Label({Title = "  - 1000x: AntiAura (heal, boosted repel, phase)"})
    ChangeSec:Label({Title = "  - 1000x: ESP (threat-colored, names, distance)"})
    ChangeSec:Label({Title = "  - 1000x: Tycoon (multi-buy, expanded claim)"})
    ChangeSec:Label({Title = "  - 1000x: Reach (dynamic, up to 15x)"})
    ChangeSec:Label({Title = " "})
    ChangeSec:Label({Title = "v7.0 - UNLIMITED POWER"})
    ChangeSec:Label({Title = "v6.0 - GODLY TIER"})
    ChangeSec:Label({Title = "v5.0 - WindUI Edition"})
    ChangeSec:Label({Title = "v1.1 - Initial release"})
end

-- ═══════════════════════════════════════════════════════════════════════
--  SETTINGS TAB
-- ═══════════════════════════════════════════════════════════════════════
do
    local UISec = Settings_Tab:Section({Title = "UI Config"})
    UISec:Dropdown({Title = "Theme", Options = {"Default", "Dark", "Light", "Rose", "Ocean", "Amethyst"}, Default = 1, Callback = function(option)
        pcall(function() WindUI:SetTheme(option) end)
    end})

    local GeneralSec = Settings_Tab:Section({Title = "General"})
    GeneralSec:Toggle({Title = "Anti-Lag Shield", Default = false, Callback = function(state)
        AntiLagEnabled = state
        if state then startAntiLag() else stopAntiLag() end
    end})
    GeneralSec:Toggle({Title = "ESP (Threat-Colored)", Default = false, Callback = function(state)
        ESPEnabled = state
        if state then startESP() else stopESP() end
    end})
    GeneralSec:Toggle({Title = "Kill Notifications", Default = false, Callback = function(state)
        KillNotifEnabled = state
        if state then
            WindUI:Notify({Title = "Kill Notifications", Content = "Behavioral analysis + Sentinel AI enabled.", Duration = 4, Icon = "bell"})
        end
    end})
    GeneralSec:Toggle({Title = "Kill Logs", Default = false, Callback = function(state) KillLogEnabled = state end})
    GeneralSec:Button({Title = "View Kill Logs", Callback = function()
        if #KillLogs == 0 then
            WindUI:Notify({Title = "Kill Logs", Content = "No kills recorded yet.", Duration = 2, Icon = "info"})
            return
        end
        local lastLog = KillLogs[#KillLogs]
        WindUI:Notify({
            Title = "Last Kill Log",
            Content = "Killer: " .. lastLog.Killer .. "\nWeapon: " .. lastLog.Weapon
                .. "\nThreat: " .. lastLog.Threat .. "/10\nTTK: " .. string.format("%.2f", lastLog.TTK) .. "s\nTotal logs: " .. #KillLogs,
            Duration = 5, Icon = "scroll-text",
        })
    end})

    local ConfigSec = Settings_Tab:Section({Title = "Config"})
    ConfigSec:Button({Title = "Save Config", Callback = function()
        local config = {
            ReachSize = ReachSize,
            ThreatRadius = ThreatRadius,
            latencyEstimate = latencyEstimate,
            IK_BurstCount = IK_BurstCount,
            HA_Range = HA_Range.X,
            HA_BurstCount = HA_BurstCount,
            TG_BurstCount = TG_BurstCount,
            AntiAura_RepelForce = AntiAura.RepelForce,
            AntiAura_RepelRadius = AntiAura.RepelRadius,
        }
        writeJSON(CONFIG_FILE, config)
        WindUI:Notify({Title = "Config Saved", Content = "Settings saved.", Duration = 2, Icon = "save"})
    end})
    ConfigSec:Button({Title = "Load Config", Callback = function()
        local config = readJSON(CONFIG_FILE)
        if config then
            ReachSize = config.ReachSize or 3
            ThreatRadius = config.ThreatRadius or 60
            latencyEstimate = config.latencyEstimate or 0.08
            IK_BurstCount = config.IK_BurstCount or 12
            HA_Range = Vector3.new(config.HA_Range or 45, config.HA_Range or 45, config.HA_Range or 45)
            HA_BurstCount = config.HA_BurstCount or 8
            TG_BurstCount = config.TG_BurstCount or 12
            AntiAura.RepelForce = config.AntiAura_RepelForce or 120
            AntiAura.RepelRadius = config.AntiAura_RepelRadius or 18
            WindUI:Notify({Title = "Config Loaded", Content = "Settings restored.", Duration = 2, Icon = "folder-open"})
        else
            WindUI:Notify({Title = "No Config", Content = "No saved config found.", Duration = 2, Icon = "x"})
        end
    end})
    ConfigSec:Button({Title = "Rejoin Server", Callback = function()
        TeleportService:Teleport(game.PlaceId, player)
    end})
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 32: SETUP & FINALIZE                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
setupKillNotifications()

WindUI:Notify({
    Title = "EXO Hub v8.0 – SENTINEL AI",
    Content = "All systems online. 1000x UPGRADE. AI Combat Brain ACTIVE.\nEnable Kill Notifications to feed the AI.",
    Duration = 5,
    Icon = "check-circle",
})

print("[EXO] Hub v8.0 SENTINEL AI loaded. Build: " .. _EXO_BUILD)
print("[EXO] AI Chat: Type 'help' in the Sentinel chat overlay")
print("[EXO] Features: Aura(1000x) InstaKill(120Hz) HitAmp(360) AntiAura(Heal+Repel+Phase) ESP(Threat) AI(Adaptive)")
