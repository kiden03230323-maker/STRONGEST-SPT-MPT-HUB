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
        nameLabel.TextColor3 = TextColor
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
-- ║  SECTION 31: BUILD ZYRONX UI (ALL TABS + SENTINEL AI TAB)         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local Window = Library:CreateWindow({
    Title = "EXO Hub v8.0",
    Subtitle = "SENTINEL AI | BLUE EDITION",
    SubtitleColor = AccentColor,
    SphereText = true,
    SphereWords = "EXO",
})

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 1: SPT COMBAT (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local CombatTab = Window:CreateTab("Combat", true)
    local CombatPage = CombatTab:CreatePage("Main")

    local AuraSec = CombatPage:CreateSection("1000x Multi-Target Aura")
    AuraSec:AddToggle("Enable Aura", false, function(state)
        Aura.Enabled = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            Library:Notify({Title = "Aura", Description = "ENGAGED - " .. #Aura.TargetList .. " targets. Multi-vector prediction active."})
        else stopAuraLoop() end
    end)
    AuraSec:AddToggle("Instant Kill", false, function(state) InstantKill = state end)
    AuraSec:AddSlider("Prediction Depth", 3, 30, 8, function(val) latencyEstimate = val / 100 end)
    AuraSec:AddDropdown("Aura Targets", getServerPlayers(), true, function(selected)
        table.clear(Aura.TargetList)
        if selected then
            for _, name in ipairs(selected) do
                local plr = Players:FindFirstChild(name)
                if plr then table.insert(Aura.TargetList, plr) end
            end
        end
    end)

    local ToolFollowSec = CombatPage:CreateSection("1000x Tool Follow")
    ToolFollowSec:AddToggle("Enable Tool Follow", false, function(state)
        ToolFollow.Enabled = state
        if state then
            ToolFollow.Targets = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(ToolFollow.Targets, plr) end
            end
            startToolFollow()
        else stopToolFollow() end
    end)

    local DefenseSec = CombatPage:CreateSection("1000x Defense / Anti-Aura")
    DefenseSec:AddToggle("Enable Anti-Aura", false, function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end)
    DefenseSec:AddToggle("God Mode (ForceField)", false, function(state) AntiAura.GodMode = state end)
    DefenseSec:AddToggle("Repel (Anti-Touch)", false, function(state) AntiAura.Repel = state end)
    DefenseSec:AddToggle("Phase (No Collide)", false, function(state) AntiAura.Phase = state end)
    DefenseSec:AddToggle("Heal Aura", false, function(state) AntiAura.HealAura = state end)
    DefenseSec:AddSlider("Repel Force", 50, 300, 120, function(val) AntiAura.RepelForce = val end)
    DefenseSec:AddSlider("Repel Radius", 8, 30, 18, function(val) AntiAura.RepelRadius = val end)
    DefenseSec:AddToggle("Anti Spawnkill", false, function(state)
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
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 2: SPT TYCOON (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local TycoonTab = Window:CreateTab("Tycoon")
    local TycoonPage = TycoonTab:CreatePage("Automation")

    local TycoonSec = TycoonPage:CreateSection("1000x Tycoon Automation")
    TycoonSec:AddToggle("Auto Claim Money", false, function(state)
        AutoClaimMoney = state
        if state then startClaimMoney() else stopClaimMoney() end
    end)
    TycoonSec:AddToggle("Smart Auto Build (Multi-Buy)", false, function(state)
        AutoBuild = state
        if state then startAutoBuild() else stopAutoBuild() end
    end)
    TycoonSec:AddToggle("Auto Grab Weapons", false, function(state)
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
    end)

    local CooldownSec = TycoonPage:CreateSection("Tools & Cooldown")
    CooldownSec:AddToggle("Auto Use Tools (0 delay)", false, function(state)
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
    end)
    CooldownSec:AddToggle("No Cooldown (SAFE)", false, function(state)
        NoCooldown = state
        if state then startNoCooldown() else stopNoCooldown() end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 3: SPT MISC (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local MiscTab = Window:CreateTab("Misc")
    local MiscPage = MiscTab:CreatePage("Utilities")

    local ReachSec = MiscPage:CreateSection("1000x Reach")
    ReachSec:AddToggle("Enable Reach", false, function(state)
        Reach = state
        if state then applyReach() else stopReach() end
    end)
    ReachSec:AddSlider("Reach Size", 1, 15, 3, function(val)
        ReachSize = val
        if Reach then stopReach(); applyReach() end
    end)

    local RespawnSec = MiscPage:CreateSection("Respawn & Protection")
    RespawnSec:AddToggle("Fast Respawn", false, function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end)

    local UtilsSec = MiscPage:CreateSection("Remote Configuration")
    UtilsSec:AddTextbox("Set Damage Remote", "game.ReplicatedStorage.DealDamage", function(text)
        if text and text ~= "" then
            local ok, remote = pcall(function() return loadstring("return " .. text)() end)
            if ok and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                DAMAGE_REMOTE = remote
                Library:Notify({Title = "Remote Set", Description = "Damage remote updated."})
            else
                Library:Notify({Title = "Error", Description = "Invalid remote path."})
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 4: MPT KILL ENGINE (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local KillTab = Window:CreateTab("Kill Engine")
    local KillPage = KillTab:CreatePage("Omni-Kill")

    local OmniSec = KillPage:CreateSection("1000x Omni-Kill Engine")
    OmniSec:AddToggle("Enable Omni-Kill", false, function(state)
        Aura.Enabled = state; InstantKill = state
        if state then
            Aura.TargetList = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= player then table.insert(Aura.TargetList, plr) end
            end
            startAuraLoop()
            Library:Notify({Title = "OMNI-KILL", Description = "ENGAGED - " .. #Aura.TargetList .. " targets."})
        else stopAuraLoop() end
    end)
    OmniSec:AddToggle("Insta-Kill Micro-Burst", false, function(state)
        InstaKillEnabled = state
        if state then startInstaKill() else stopInstaKill() end
    end)
    OmniSec:AddToggle("Adaptive Burst (Threat-Based)", true, function(state)
        IK_AdaptiveBurst = state
    end)
    OmniSec:AddSlider("Prediction Aggression", 3, 30, 8, function(val) latencyEstimate = val / 100 end)
    OmniSec:AddSlider("Burst Count", 3, 20, 12, function(val) IK_BurstCount = val end)
    OmniSec:AddButton("Manual Kill Burst", function()
        local orig = Aura.Enabled
        Aura.Enabled = true; InstantKill = true
        task.wait(0.15)
        Aura.Enabled = orig
        if not orig then InstantKill = false end
        Library:Notify({Title = "Kill Burst", Description = "Burst fired."})
    end)
    OmniSec:AddButton("Refresh Target List", function()
        table.clear(Aura.TargetList)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then table.insert(Aura.TargetList, plr) end
        end
        Library:Notify({Title = "Targets", Description = "Refreshed: " .. #Aura.TargetList .. " players."})
    end)

    local HitAmpSec = KillPage:CreateSection("1000x Hit Amplifier")
    HitAmpSec:AddToggle("Enable Hit Amplifier", false, function(state)
        HitAmpEnabled = state
        if state then startHitAmplifier() else stopHitAmplifier() end
    end)
    HitAmpSec:AddSlider("Scan Range", 15, 60, 45, function(val)
        HA_Range = Vector3.new(val, val, val)
    end)
    HitAmpSec:AddSlider("Burst Count", 1, 15, 8, function(val) HA_BurstCount = val end)
    HitAmpSec:AddToggle("Multi-Pulse (3x waves)", true, function(state) HA_MultiPulse = state end)
    HitAmpSec:AddLabel("360 sphere+box scan | 6ms cooldown | OverlapParams")

    local ArsenalSec = KillPage:CreateSection("1000x Tool Arsenal")
    ArsenalSec:AddToggle("Enable Tool Arsenal", false, function(state)
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
    end)
    ArsenalSec:AddButton("Force Acquire All", function()
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
            Library:Notify({Title = "Tool Arsenal", Description = "Force acquire burst fired."})
        end
    end)
    ArsenalSec:AddLabel("14 Bases: Stone, Magic, Storm, Robotic, Mecha, Shadow, Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong")
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 5: MPT ECONOMY (1000x)
-- ═══════════════════════════════════════════════════════════════════════
do
    local EconTab = Window:CreateTab("Economy")
    local EconPage = EconTab:CreatePage("Sovereign")

    local SovSec = EconPage:CreateSection("1000x Sovereign Economy")
    SovSec:AddToggle("Enable Sovereign Economy", false, function(state)
        AutoClaimMoney = state; AutoBuild = state
        if state then startClaimMoney(); startAutoBuild()
        else stopClaimMoney(); stopAutoBuild() end
    end)
    SovSec:AddSlider("Defense Threat Radius", 20, 120, 60, function(val) ThreatRadius = val end)
    SovSec:AddButton("Force Buy Next Upgrade", function()
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
            Library:Notify({Title = "Purchased", Description = "Bought: " .. best.Name})
        else
            Library:Notify({Title = "No Purchase", Description = "Nothing affordable."})
        end
    end)

    local SpawnSec = EconPage:CreateSection("Spawn Supremacy")
    SpawnSec:AddToggle("Supremacy Mode", false, function(state)
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
    end)
    SpawnSec:AddToggle("Fast Respawn", false, function(state)
        FastRespawn = state
        if state then startFastRespawn() end
    end)

    local DefSec = EconPage:CreateSection("1000x Defense Matrix")
    DefSec:AddToggle("Enable Defense Matrix", false, function(state)
        AntiAura.Enabled = state
        if state then startAntiAura() else stopAntiAura() end
    end)
    DefSec:AddToggle("ForceField God Mode", false, function(state) AntiAura.GodMode = state end)
    DefSec:AddToggle("Weapon Repel", false, function(state) AntiAura.Repel = state end)
    DefSec:AddToggle("Phase Mode (No Collide)", false, function(state) AntiAura.Phase = state end)
    DefSec:AddToggle("Heal Aura", false, function(state) AntiAura.HealAura = state end)
    DefSec:AddButton("Emergency Heal", function()
        local myChar = player.Character
        if myChar then
            local hum = myChar:FindFirstChild("Humanoid")
            if hum then
                hum.Health = hum.MaxHealth
                Library:Notify({Title = "Healed", Description = "Health restored."})
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 6: SENTINEL AI (NEW)
-- ═══════════════════════════════════════════════════════════════════════
do
    local AITab = Window:CreateTab("Sentinel AI")
    local AIPage = AITab:CreatePage("Brain")

    local AIControlSec = AIPage:CreateSection("AI Control")
    AIControlSec:AddToggle("Enable Sentinel AI", true, function(state)
        KillNotifEnabled = state
        KillLogEnabled = state
        if state then
            Chat_CreateGUI()
            Chat_AddMessage("AI", "Sentinel AI activated. I'm watching your back. Enable Kill Notifications to feed me data.", Color3.fromRGB(0, 255, 100))
            Library:Notify({Title = "Sentinel AI", Description = "AI Combat Brain ONLINE. Chat overlay active."})
        end
    end)
    AIControlSec:AddToggle("Auto-Analyze Kills", true, function(state)
        KillNotifEnabled = state
    end)
    AIControlSec:AddButton("Open AI Chat", function()
        Chat_CreateGUI()
        Chat_AddMessage("AI", "Chat opened. Type 'help' for commands.")
    end)
    AIControlSec:AddButton("Disable All AI Features", function()
        Aura.Enabled = false; stopAuraLoop()
        InstaKillEnabled = false; stopInstaKill()
        HitAmpEnabled = false; stopHitAmplifier()
        AntiAura.Enabled = false; stopAntiAura()
        Reach = false; stopReach()
        Chat_AddMessage("AI", "All AI-activated features disabled.", Color3.fromRGB(255, 200, 0))
    end)

    local AIInfoSec = AIPage:CreateSection("AI Intelligence")
    AIInfoSec:AddLabel("Threat Profiler: Tracks every killer's patterns")
    AIInfoSec:AddLabel("Strategy Engine: Combines features to counter threats")
    AIInfoSec:AddLabel("Chat System: Full bidirectional conversation")
    AIInfoSec:AddLabel("Robot Analyst: Animated kill report processor")
    AIInfoSec:AddLabel("Confirmation Gate: AI asks before acting")
    AIInfoSec:AddButton("View All Threat Profiles", function()
        local count = 0
        for name, prof in pairs(ThreatProfiles) do
            count = count + 1
            Library:Notify({
                Title = "Profile: " .. name,
                Description = "Kills: " .. prof.TotalKills .. " | Threat: " .. prof.ThreatScore
                    .. "/100\nFeatures: " .. table.concat(prof.SuspectedFeatures, ", "),
                Duration = 4,
            })
        end
        if count == 0 then
            Library:Notify({Title = "Profiles", Description = "No threat profiles yet."})
        end
    end)
    AIInfoSec:AddButton("Reset All Profiles", function()
        ThreatProfiles = {}
        writeJSON(AI_PROFILE_FILE, ThreatProfiles)
        Library:Notify({Title = "Profiles", Description = "All threat profiles cleared."})
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 7: SETTINGS
-- ═══════════════════════════════════════════════════════════════════════
do
    local SettingsTab = Window:CreateTab("Settings")
    local SettingsPage = SettingsTab:CreatePage("Config")

    local UISec = SettingsPage:CreateSection("General")
    UISec:AddToggle("Anti-Lag Shield", false, function(state)
        AntiLagEnabled = state
        if state then startAntiLag() else stopAntiLag() end
    end)
    UISec:AddToggle("ESP (Threat-Colored)", false, function(state)
        ESPEnabled = state
        if state then startESP() else stopESP() end
    end)
    UISec:AddToggle("Kill Notifications", false, function(state)
        KillNotifEnabled = state
        if state then
            Library:Notify({Title = "Kill Notifications", Description = "Behavioral analysis + Sentinel AI enabled."})
        end
    end)
    UISec:AddToggle("Kill Logs", false, function(state) KillLogEnabled = state end)
    UISec:AddButton("View Kill Logs", function()
        if #KillLogs == 0 then
            Library:Notify({Title = "Kill Logs", Description = "No kills recorded yet."})
            return
        end
        local lastLog = KillLogs[#KillLogs]
        Library:Notify({
            Title = "Last Kill Log",
            Description = "Killer: " .. lastLog.Killer .. "\nWeapon: " .. lastLog.Weapon
                .. "\nThreat: " .. lastLog.Threat .. "/10\nTTK: " .. string.format("%.2f", lastLog.TTK) .. "s\nTotal logs: " .. #KillLogs,
            Duration = 5,
        })
    end)

    local ConfigSec = SettingsPage:CreateSection("Configuration")
    ConfigSec:AddButton("Save Config", function()
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
        Library:Notify({Title = "Config Saved", Description = "Settings saved."})
    end)
    ConfigSec:AddButton("Load Config", function()
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
            Library:Notify({Title = "Config Loaded", Description = "Settings restored."})
        else
            Library:Notify({Title = "No Config", Description = "No saved config found."})
        end
    end)
    ConfigSec:AddButton("Rejoin Server", function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  TAB 8: UPDATES
-- ═══════════════════════════════════════════════════════════════════════
do
    local UpdatesTab = Window:CreateTab("Updates")
    local UpdatesPage = UpdatesTab:CreatePage("Changelog")
    local ChangeSec = UpdatesPage:CreateSection("EXO Hub Changelog")
    ChangeSec:AddLabel("v8.0 - SENTINEL AI (CURRENT)")
    ChangeSec:AddLabel("  - NEW: Sentinel AI Combat Brain")
    ChangeSec:AddLabel("  - NEW: Animated Robot Kill Analyst")
    ChangeSec:AddLabel("  - NEW: Persistent Bidirectional Chat")
    ChangeSec:AddLabel("  - NEW: Threat Profiler (per-player)")
    ChangeSec:AddLabel("  - NEW: Strategy Engine (feature combos)")
    ChangeSec:AddLabel("  - NEW: Confirmation Gate (asks before acting)")
    ChangeSec:AddLabel("  - NEW: AI explains WHY you're losing")
    ChangeSec:AddLabel("  - 1000x: Aura (multi-vector, triple remote, multi-hitbox)")
    ChangeSec:AddLabel("  - 1000x: InstaKill (120Hz, parallel, 9 hitboxes)")
    ChangeSec:AddLabel("  - 1000x: HitAmp (360 sphere+box, multi-pulse)")
    ChangeSec:AddLabel("  - 1000x: AntiAura (heal, boosted repel, phase)")
    ChangeSec:AddLabel("  - 1000x: ESP (threat-colored, names, distance)")
    ChangeSec:AddLabel("  - 1000x: Tycoon (multi-buy, expanded claim)")
    ChangeSec:AddLabel("  - 1000x: Reach (dynamic, up to 15x)")
    ChangeSec:AddLabel("  - UI: ZyronX Blue + Unlimited Tabs + Mobile")
    ChangeSec:AddLabel(" ")
    ChangeSec:AddLabel("v7.0 - UNLIMITED POWER")
    ChangeSec:AddLabel("v6.0 - GODLY TIER")
    ChangeSec:AddLabel("v5.0 - WindUI Edition")
    ChangeSec:AddLabel("v4.0 - Embedded/Velocity/Cerberus")
    ChangeSec:AddLabel("v3.0 - ZyronX migration")
    ChangeSec:AddLabel("v1.1 - Initial release")
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 32: SETUP & FINALIZE                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
setupKillNotifications()

Library:Notify({
    Title = "EXO Hub v8.0 – SENTINEL AI",
    Description = "All systems online. 1000x UPGRADE. AI Combat Brain ACTIVE.\nTap EXO sphere to toggle UI. Enable Kill Notifications to feed the AI.",
    Duration = 5,
})

print("[EXO] Hub v8.0 SENTINEL AI loaded. Build: " .. _EXO_BUILD)
print("[EXO] Full 32-section architecture. Zero compression. All features preserved.")
print("[EXO] Mobile: Tap EXO sphere to open/close. Drag top bar to move.")
print("[EXO] AI: Enable Kill Notifications → die once → robot analyzes → chat opens → confirm strategy")
print("[EXO] Chat Commands: help, status, profiles, profile [name], threats, strategy, target [name], disable all, why, clear")
