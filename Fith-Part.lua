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
                local ff_ok, ff = pcall(function()
                    local f = Instance.new("ForceField")
                    f.Visible = false
                    f.Parent = myChar
                    return f
                end)
                if ff_ok and ff then antiAuraFF = ff end
            end
            local health_ok, currentHealth = pcall(function() return hum.Health end)
            local maxHealth_ok, maxHealth = pcall(function() return hum.MaxHealth end)
            if health_ok and maxHealth_ok and type(currentHealth) == "number" and type(maxHealth) == "number" then
                if currentHealth < maxHealth * 0.7 then
                    pcall(function() hum.Health = maxHealth end)
                end
            end
        else
            if antiAuraFF and antiAuraFF.Parent then
                pcall(function() antiAuraFF:Destroy() end)
                antiAuraFF = nil
            end
        end

        -- HEAL AURA: Continuous regeneration
        if AntiAura.HealAura then
            local health_ok, currentHealth = pcall(function() return hum.Health end)
            local maxHealth_ok, maxHealth = pcall(function() return hum.MaxHealth end)
            if health_ok and maxHealth_ok and type(currentHealth) == "number" and type(maxHealth) == "number" then
                if currentHealth < maxHealth then
                    local healAmount = maxHealth * 0.05
                    pcall(function() hum.Health = math.min(maxHealth, currentHealth + healAmount) end)
                end
            end
        end

        -- 1000x REPEL: Extended radius + boosted force + ALL tools
        if AntiAura.Repel then
            local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
            if players_ok and type(players_list) == "table" then
                for _, otherPlr in ipairs(players_list) do
                    if otherPlr ~= player then
                        local char_ok, otherChar = pcall(function() return otherPlr.Character end)
                        if char_ok and otherChar then
                            local children_ok, children = pcall(function() return otherChar:GetChildren() end)
                            if children_ok and type(children) == "table" then
                                for _, tool in ipairs(children) do
                                    if tool:IsA("Tool") then
                                        local handle = tool:FindFirstChild("Handle")
                                        if handle then
                                            local pos_ok, handlePos = pcall(function() return handle.Position end)
                                            local rootPos_ok, rootPos = pcall(function() return root.Position end)
                                            if pos_ok and rootPos_ok and typeof(handlePos) == "Vector3" and typeof(rootPos) == "Vector3" then
                                                local dist = (handlePos - rootPos).Magnitude
                                                if type(dist) == "number" and dist < AntiAura.RepelRadius then
                                                    local dir = (rootPos - handlePos).Unit
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
                    end
                end
            end
        end

        -- PHASE: Full no-collide on all parts
        if AntiAura.Phase then
            local children_ok, children = pcall(function() return myChar:GetChildren() end)
            if children_ok and type(children) == "table" then
                for _, part in ipairs(children) do
                    if part:IsA("BasePart") then
                        pcall(function() part.CanCollide = false end)
                    end
                end
            end
        end
    end)
end

local function stopAntiAura()
    if antiAuraConn then 
        pcall(function() antiAuraConn:Disconnect() end)
        antiAuraConn = nil 
    end
    if antiAuraFF and antiAuraFF.Parent then 
        pcall(function() antiAuraFF:Destroy() end)
        antiAuraFF = nil 
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 22: 1000x REACH (DYNAMIC THREAT-BASED SIZING)            ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local reachOriginalSizes = {}
local reachHL = {}

local function applyReach()
    local myChar = player.Character
    if not myChar then return end
    
    local children_ok, children = pcall(function() return myChar:GetChildren() end)
    if not children_ok or type(children) ~= "table" then return end
    
    for _, t in ipairs(children) do
        if t:IsA("Tool") then
            local part = getToolPart(t)
            if part then
                if not reachOriginalSizes[part] then
                    local size_ok, origSize = pcall(function() return part.Size end)
                    if size_ok and typeof(origSize) == "Vector3" then
                        reachOriginalSizes[part] = origSize
                    end
                end
                
                if reachOriginalSizes[part] then
                    local newSize = reachOriginalSizes[part] * ReachSize
                    pcall(function() 
                        part.Size = newSize
                        part.Massless = true
                        part.CanCollide = false
                    end)
                    
                    if not reachHL[part] then
                        local hl_ok, hl = pcall(function()
                            local h = Instance.new("Highlight", part)
                            h.FillTransparency = 1
                            h.OutlineColor = AccentColor
                            return h
                        end)
                        if hl_ok and hl then reachHL[part] = hl end
                    end
                end
            end
        end
    end
end

local function stopReach()
    for part, hl in pairs(reachHL) do
        if hl and hl.Parent == part then 
            pcall(function() hl:Destroy() end) 
        end
    end
    table.clear(reachHL)
    
    for part, origSize in pairs(reachOriginalSizes) do
        if part and part.Parent and typeof(origSize) == "Vector3" then 
            pcall(function() part.Size = origSize end) 
        end
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
            if Guide then 
                Guide:FireServer() 
            else 
                player:LoadCharacter() 
            end
        end)
    end
    
    local function hook(c)
        if not c then return end
        local hum_ok, hum = pcall(function() return c:WaitForChild("Humanoid", 10) end)
        if not hum_ok or not hum then return end
        
        hum.HealthChanged:Connect(function(hp)
            if type(hp) == "number" and hp <= 0 then 
                respawn() 
            end
        end)
        hum.Died:Connect(respawn)
    end
    
    if player.Character then 
        hook(player.Character) 
    end
    player.CharacterAdded:Connect(hook)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24: 1000x INSTA-KILL (PARALLEL MULTI-BURST + SWEEP)      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function IK_RefreshTools()
    table.clear(IK_ToolsCache)
    local char = player.Character
    if not char then return end
    
    local children_ok, children = pcall(function() return char:GetChildren() end)
    if children_ok and type(children) == "table" then
        for _, tool in ipairs(children) do
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
    end
    
    -- Also scan Backpack
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        local bp_children_ok, bp_children = pcall(function() return bp:GetChildren() end)
        if bp_children_ok and type(bp_children) == "table" then
            for _, tool in ipairs(bp_children) do
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
end

local function IK_GetTarget()
    local myChar = player.Character
    local myRoot = myChar and getHRP(myChar)
    if not myRoot then return nil end
    
    local bestChar, bestDist = nil, 50  -- 1000x: expanded range
    local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
    if not players_ok or type(players_list) ~= "table" then return nil end
    
    for _, plr in ipairs(players_list) do
        if plr ~= player then
            local char_ok, char = pcall(function() return plr.Character end)
            if char_ok and char then
                local root = getHRP(char)
                if root then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local health_ok, health = pcall(function() return hum.Health end)
                        if health_ok and type(health) == "number" and health > 0 then
                            local pos_ok, dist = pcall(function() return (root.Position - myRoot.Position).Magnitude end)
                            if pos_ok and type(dist) == "number" and dist < bestDist then
                                bestDist = dist
                                bestChar = char
                            end
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
    if type(burstCount) ~= "number" then burstCount = IK_BurstCount end
    
    -- 1000x: ALL body parts targeted
    table.clear(IK_TargetParts)
    local hitboxNames = {"HumanoidRootPart", "UpperTorso", "Torso", "Head",
                         "LowerTorso", "LeftUpperArm", "RightUpperArm",
                         "LeftUpperLeg", "RightUpperLeg"}
    
    for _, name in ipairs(hitboxNames) do
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
                    for _ = 1, burstCount do 
                        fight:FireServer() 
                    end
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
    if InstaKillConn then 
        pcall(function() InstaKillConn:Disconnect() end)
        InstaKillConn = nil 
    end
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
    
    local children_ok, children = pcall(function() return char:GetChildren() end)
    if not children_ok or type(children) ~= "table" then return end
    
    for _, t in ipairs(children) do
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
        if type(dt) ~= "number" then dt = 0.016 end
        
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
        local pos_ok, hrpPos = pcall(function() return hrp.Position end)
        if not pos_ok or typeof(hrpPos) ~= "Vector3" then return end
        
        local parts_ok, parts = pcall(function() 
            return workspace:GetPartBoundsInBox(CFrame.new(hrpPos), HA_Range, HA_OverlapParams) 
        end)
        
        -- Also do a sphere check for anything the box misses
        local sphere_ok, sphereParts = pcall(function() 
            return workspace:GetPartBoundsInRadius(hrpPos, HA_Range.X, HA_OverlapParams) 
        end)

        local hasTarget = false
        local targetModels = {}

        if parts_ok and type(parts) == "table" then
            for _, part in ipairs(parts) do
                local model = part:FindFirstChildOfClass("Model")
                    or (part.Parent and part.Parent:FindFirstChildOfClass("Model"))
                if model then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local health_ok, health = pcall(function() return hum.Health end)
                        if health_ok and type(health) == "number" and health > 0 and model ~= char then
                            hasTarget = true
                            if not targetModels[model] then
                                targetModels[model] = true
                            end
                        end
                    end
                end
            end
        end
        
        if sphere_ok and type(sphereParts) == "table" then
            for _, part in ipairs(sphereParts) do
                local model = part:FindFirstChildOfClass("Model")
                    or (part.Parent and part.Parent:FindFirstChildOfClass("Model"))
                if model then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum then
                        local health_ok, health = pcall(function() return hum.Health end)
                        if health_ok and type(health) == "number" and health > 0 and model ~= char then
                            hasTarget = true
                            if not targetModels[model] then
                                targetModels[model] = true
                            end
                        end
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
                            for _ = 1, HA_BurstCount do 
                                data.FightEvent:FireServer() 
                            end
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
    if HitAmpConn then 
        pcall(function() HitAmpConn:Disconnect() end)
        HitAmpConn = nil 
    end
end
