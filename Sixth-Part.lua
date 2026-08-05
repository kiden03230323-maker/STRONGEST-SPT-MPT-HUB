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
    if type(pattern) ~= "string" then return false end
    local patternLower = pattern:lower()
    
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        local bp_ok, bp_children = pcall(function() return bp:GetChildren() end)
        if bp_ok and type(bp_children) == "table" then
            for _, item in ipairs(bp_children) do
                if item:IsA("Tool") then
                    local name_ok, name_val = pcall(function() return item.Name end)
                    if name_ok and type(name_val) == "string" and name_val:lower():find(patternLower, 1, true) then 
                        return true 
                    end
                end
            end
        end
    end
    
    local char = player.Character
    if char then
        local char_ok, char_children = pcall(function() return char:GetChildren() end)
        if char_ok and type(char_children) == "table" then
            for _, item in ipairs(char_children) do
                if item:IsA("Tool") then
                    local name_ok, name_val = pcall(function() return item.Name end)
                    if name_ok and type(name_val) == "string" and name_val:lower():find(patternLower, 1, true) then 
                        return true 
                    end
                end
            end
        end
    end
    return false
end

local function TG_GetClosestPad(baseName)
    if type(baseName) ~= "string" then return nil end
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local pads = TG_padsByBase[baseName]
    if type(pads) ~= "table" or #pads == 0 then return nil end
    
    local closest, bestDist = nil, 10000
    for _, pad in ipairs(pads) do
        if pad and pad.Parent then
            local pos_ok, padPos = pcall(function() return pad.Position end)
            local rootPos_ok, rootPos = pcall(function() return root.Position end)
            if pos_ok and rootPos_ok and typeof(padPos) == "Vector3" and typeof(rootPos) == "Vector3" then
                local d = (padPos - rootPos).Magnitude
                if type(d) == "number" and d < bestDist then 
                    bestDist = d
                    closest = pad 
                end
            end
        end
    end
    return closest
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 27: 1000x KILL INTELLIGENCE (FULL BEHAVIORAL ANALYSIS)   ║
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 28: 1000x ESP (THREAT-COLORED + INFO)                    ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startESP()
    if espGui then return end
    
    local gui_ok, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "EXO_ESP"
        g.ResetOnSpawn = false
        return g
    end)
    if not gui_ok or not gui then 
        warn("[EXO] Failed to create ESP GUI")
        return 
    end
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then 
        pcall(function() gui.Parent = player:WaitForChild("PlayerGui") end)
    end
    if not gui.Parent then
        warn("[EXO] ESP GUI has no parent")
        return
    end
    espGui = gui

    local function createDot(plr)
        if not plr then return end
        local container_ok, container = pcall(function()
            local c = Instance.new("Frame")
            c.Size = UDim2.new(0, 60, 0, 20)
            c.BackgroundTransparency = 1
            c.Parent = espGui
            return c
        end)
        if not container_ok or not container then return end

        local dot_ok, dot = pcall(function()
            local d = Instance.new("Frame")
            d.Size = UDim2.new(0, 8, 0, 8)
            d.Position = UDim2.new(0.5, -4, 0, 0)
            d.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            d.BorderSizePixel = 0
            d.Parent = container
            Instance.new("UICorner", d).CornerRadius = UDim.new(1, 0)
            return d
        end)

        local name_ok, nameLabel = pcall(function()
            local n = Instance.new("TextLabel")
            n.Size = UDim2.new(1, 0, 0, 10)
            n.Position = UDim2.new(0, 0, 0, 10)
            n.BackgroundTransparency = 1
            n.Text = plr.Name
            n.TextColor3 = TextColor
            n.TextSize = 8
            n.Font = Enum.Font.Gotham
            n.Parent = container
            return n
        end)

        espDots[plr] = container
    end

    local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
    if players_ok and type(players_list) == "table" then
        for _, plr in ipairs(players_list) do
            if plr ~= player then createDot(plr) end
        end
    end

    Players.PlayerAdded:Connect(function(plr)
        if plr ~= player then createDot(plr) end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        if espDots[plr] then 
            pcall(function() espDots[plr]:Destroy() end)
            espDots[plr] = nil 
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not ESPEnabled then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        
        local myChar = player.Character
        local myPos = nil
        if myChar then
            local myRoot = myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                local pos_ok, pos_val = pcall(function() return myRoot.Position end)
                if pos_ok and typeof(pos_val) == "Vector3" then myPos = pos_val end
            end
        end

        for plr, container in pairs(espDots) do
            if container and container.Parent then
                local char_ok, char = pcall(function() return plr.Character end)
                if char_ok and char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vp_ok, pos, onScreen = pcall(function() 
                            return cam:WorldToViewportPoint(hrp.Position) 
                        end)
                        if vp_ok and typeof(pos) == "Vector3" then
                            pcall(function()
                                container.Position = UDim2.new(0, pos.X - 30, 0, pos.Y - 10)
                                container.Visible = onScreen
                            end)

                            -- Threat coloring based on distance
                            if myPos then
                                local dist_ok, dist = pcall(function() 
                                    return (hrp.Position - myPos).Magnitude 
                                end)
                                if dist_ok and type(dist) == "number" then
                                    local dot = container:FindFirstChild("Frame")
                                    if dot then
                                        local newColor
                                        if dist < 15 then
                                            newColor = Color3.fromRGB(255, 0, 0)
                                        elseif dist < 30 then
                                            newColor = Color3.fromRGB(255, 150, 0)
                                        else
                                            newColor = Color3.fromRGB(0, 255, 100)
                                        end
                                        pcall(function() dot.BackgroundColor3 = newColor end)
                                    end
                                end
                            end
                        end
                    else
                        pcall(function() container.Visible = false end)
                    end
                else
                    pcall(function() container.Visible = false end)
                end
            end
        end
    end)
end

local function stopESP()
    if espGui then 
        pcall(function() espGui:Destroy() end)
        espGui = nil 
    end
    table.clear(espDots)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 29: 1000x ANTI-LAG                                       ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startAntiLag()
    pcall(function()
        local descendants_ok, descendants = pcall(function() return workspace:GetDescendants() end)
        if descendants_ok and type(descendants) == "table" then
            for _, obj in ipairs(descendants) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                    pcall(function() obj.Enabled = false end)
                end
                if obj:IsA("Sound") then
                    local playing_ok, isPlaying = pcall(function() return obj.Playing end)
                    if playing_ok and isPlaying then
                        pcall(function() obj.Volume = 0 end)
                    end
                end
            end
        end
        
        pcall(function() Lighting.GlobalShadows = false end)
        pcall(function() Lighting.Brightness = 1 end)
        pcall(function() Lighting.FogEnd = 500 end)
        
        local lighting_children_ok, lighting_children = pcall(function() return Lighting:GetChildren() end)
        if lighting_children_ok and type(lighting_children) == "table" then
            for _, effect in ipairs(lighting_children) do
                if effect:IsA("PostEffect") then 
                    pcall(function() effect.Enabled = false end) 
                end
            end
        end
    end)
    
    pcall(function() 
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 
    end)
end

local function stopAntiLag()
    pcall(function()
        pcall(function() Lighting.GlobalShadows = true end)
        pcall(function() Lighting.Brightness = 2 end)
        pcall(function() Lighting.FogEnd = 100000 end)
        
        local lighting_children_ok, lighting_children = pcall(function() return Lighting:GetChildren() end)
        if lighting_children_ok and type(lighting_children) == "table" then
            for _, effect in ipairs(lighting_children) do
                if effect:IsA("PostEffect") then 
                    pcall(function() effect.Enabled = true end) 
                end
            end
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 30: SAFE NO COOLDOWN                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startNoCooldown()
    if NoCooldownConn then 
        pcall(function() NoCooldownConn:Disconnect() end)
    end
    
    NoCooldownConn = RunService.RenderStepped:Connect(function()
        if not NoCooldown then return end
        local myChar = player.Character
        if not myChar then return end
        
        local children_ok, children = pcall(function() return myChar:GetChildren() end)
        if not children_ok or type(children) ~= "table" then return end
        
        for _, t in ipairs(children) do
            if t:IsA("Tool") then
                pcall(function()
                    local cooldown = t:FindFirstChild("Cooldown")
                    if cooldown then 
                        pcall(function() cooldown.Value = 0 end) 
                    end
                    
                    local enabled = t:FindFirstChild("Enabled")
                    if enabled then 
                        pcall(function() enabled.Value = true end) 
                    end
                    
                    local handle = t:FindFirstChild("Handle")
                    if handle and handle:IsA("BasePart") then 
                        pcall(function() handle.CanCollide = false end) 
                    end
                end)
            end
        end
    end)
end

local function stopNoCooldown()
    if NoCooldownConn then 
        pcall(function() NoCooldownConn:Disconnect() end)
        NoCooldownConn = nil 
    end
end
