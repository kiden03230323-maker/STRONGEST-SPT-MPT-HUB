-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 31: BUILD ZYRONX UI – COMBAT TAB                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local Window = Library:CreateWindow({
    Title = "EXO Hub v9.0",
    Subtitle = "SENTINEL AI | OMNISCIENT | BLUE",
    SubtitleColor = AccentColor,
    SphereText = true,
    SphereWords = "EXO",
})

if not Window then
    warn("[EXO] FATAL: Window creation failed. Aborting.")
    return
end

-- Force visibility after creation
task.spawn(function()
    task.wait(0.3)
    if Window.MainFrame and Window.MainFrame.Parent then
        Window.MainFrame.Visible = true
    end
end)

do
    local CombatTab = Window:CreateTab("Combat", true)
    if not CombatTab then warn("[EXO] Combat tab failed"); return end
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 32: BUILD ZYRONX UI – TYCOON TAB                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local TycoonTab = Window:CreateTab("Tycoon")
    if not TycoonTab then warn("[EXO] Tycoon tab failed") end
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 33: BUILD ZYRONX UI – MISC TAB                            ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local MiscTab = Window:CreateTab("Misc")
    if not MiscTab then warn("[EXO] Misc tab failed") end
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 34: BUILD ZYRONX UI – KILL ENGINE TAB                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local KillTab = Window:CreateTab("Kill Engine")
    if not KillTab then warn("[EXO] Kill Engine tab failed") end
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 35: BUILD ZYRONX UI – ECONOMY TAB                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local EconTab = Window:CreateTab("Economy")
    if not EconTab then warn("[EXO] Economy tab failed") end
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 36: BUILD ZYRONX UI – SENTINEL AI TAB (NEW)               ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local AITab = Window:CreateTab("Sentinel AI")
    if not AITab then warn("[EXO] Sentinel AI tab failed") end
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
    AIInfoSec:AddLabel("Bayesian Threat Profiler: Per-player pattern tracking")
    AIInfoSec:AddLabel("Adaptive Strategy Engine: Mutates on failure")
    AIInfoSec:AddLabel("Neural Memory System: Learns from outcomes")
    AIInfoSec:AddLabel("Temporal Pattern Analysis: Detects burst kills")
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
    AIInfoSec:AddButton("Reset AI Memory", function()
        AIMemory = {StrategyResults = {}, FeatureEffectiveness = {}, OpponentAdaptations = {}, SessionLearningRate = 0.1}
        writeJSON(AI_MEMORY_FILE, AIMemory)
        Library:Notify({Title = "Memory", Description = "AI memory reset. Learning rate restored."})
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 37: BUILD ZYRONX UI – SETTINGS TAB                        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local SettingsTab = Window:CreateTab("Settings")
    if not SettingsTab then warn("[EXO] Settings tab failed") end
    local SettingsPage = SettingsTab:CreatePage("Config")

    local GenSec = SettingsPage:CreateSection("General")
    GenSec:AddToggle("Anti-Lag Shield", false, function(state)
        AntiLagEnabled = state
        if state then startAntiLag() else stopAntiLag() end
    end)
    GenSec:AddToggle("ESP (Threat-Colored)", false, function(state)
        ESPEnabled = state
        if state then startESP() else stopESP() end
    end)
    GenSec:AddToggle("Kill Notifications", false, function(state)
        KillNotifEnabled = state
        if state then
            Library:Notify({Title = "Kill Notifications", Description = "Behavioral analysis + Sentinel AI enabled."})
        end
    end)
    GenSec:AddToggle("Kill Logs", false, function(state) KillLogEnabled = state end)
    GenSec:AddButton("View Kill Logs", function()
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 38: BUILD ZYRONX UI – UPDATES TAB                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local UpdatesTab = Window:CreateTab("Updates")
    if not UpdatesTab then warn("[EXO] Updates tab failed") end
    local UpdatesPage = UpdatesTab:CreatePage("Changelog")
    local ChangeSec = UpdatesPage:CreateSection("EXO Hub Changelog")
    ChangeSec:AddLabel("v9.0 - SENTINEL AI: OMNISCIENT (CURRENT)")
    ChangeSec:AddLabel("  - NEW: Bayesian Threat Inference Engine")
    ChangeSec:AddLabel("  - NEW: Neural Memory System (learns from outcomes)")
    ChangeSec:AddLabel("  - NEW: Adaptive Strategy Mutation (evolves on failure)")
    ChangeSec:AddLabel("  - NEW: Temporal Kill Pattern Analysis")
    ChangeSec:AddLabel("  - NEW: Animated Robot Kill Analyst")
    ChangeSec:AddLabel("  - NEW: Persistent Bidirectional Chat")
    ChangeSec:AddLabel("  - NEW: Confirmation Gate (asks before acting)")
    ChangeSec:AddLabel("  - NEW: AI explains WHY you're losing")
    ChangeSec:AddLabel("  - FIX: UI guaranteed visible (triple-redundancy)")
    ChangeSec:AddLabel("  - FIX: Mobile-first touch toggle")
    ChangeSec:AddLabel("  - 1000x: Aura (multi-vector, triple remote, multi-hitbox)")
    ChangeSec:AddLabel("  - 1000x: InstaKill (120Hz, parallel, 9 hitboxes)")
    ChangeSec:AddLabel("  - 1000x: HitAmp (360 sphere+box, multi-pulse)")
    ChangeSec:AddLabel("  - 1000x: AntiAura (heal, boosted repel, phase)")
    ChangeSec:AddLabel("  - 1000x: ESP (threat-colored, names, distance)")
    ChangeSec:AddLabel("  - 1000x: Tycoon (multi-buy, expanded claim)")
    ChangeSec:AddLabel("  - 1000x: Reach (dynamic, up to 15x)")
    ChangeSec:AddLabel("  - UI: ZyronX Blue + Unlimited Tabs + Mobile")
    ChangeSec:AddLabel("  - 40 sections, zero compression, all features preserved")
    ChangeSec:AddLabel(" ")
    ChangeSec:AddLabel("v8.0 - SENTINEL AI")
    ChangeSec:AddLabel("v7.0 - UNLIMITED POWER")
    ChangeSec:AddLabel("v6.0 - GODLY TIER")
    ChangeSec:AddLabel("v5.0 - WindUI Edition")
    ChangeSec:AddLabel("v4.0 - Embedded/Velocity/Cerberus")
    ChangeSec:AddLabel("v3.0 - ZyronX migration")
    ChangeSec:AddLabel("v1.1 - Initial release")
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 39: POST-BUILD VALIDATION                                 ║
-- ╚══════════════════════════════════════════════════════════════════════╝
task.spawn(function()
    task.wait(1.0)
    -- Validate all critical systems initialized
    local validationPassed = true
    local issues = {}

    if not Window or not Window.MainFrame then
        validationPassed = false
        table.insert(issues, "Window/MainFrame missing")
    end
    if not GlobalNotifContainer then
        validationPassed = false
        table.insert(issues, "Notification container missing")
    end
    if #Window.Tabs < 7 then
        validationPassed = false
        table.insert(issues, "Missing tabs: expected 7+, got " .. #Window.Tabs)
    end
    if not scansComplete then
        table.insert(issues, "Scans still running (non-fatal)")
    end

    if validationPassed then
        print("[EXO] ✓ Post-build validation PASSED")
    else
        warn("[EXO] ✗ Post-build validation ISSUES: " .. table.concat(issues, ", "))
    end
end)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 40: SETUP & FINALIZE                                      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
setupKillNotifications()

Library:Notify({
    Title = "EXO Hub v9.0 – SENTINEL AI: OMNISCIENT",
    Description = "All systems online. 40 sections. Zero compression.\nTap EXO sphere to toggle UI.\nEnable Kill Notifications to feed the AI.\nType 'help' in chat for commands.",
    Duration = 6,
})

print("═══════════════════════════════════════════════════════════")
print("[EXO] Hub v9.0 SENTINEL AI: OMNISCIENT loaded.")
print("[EXO] Build: " .. _EXO_BUILD)
print("[EXO] Architecture: 40 sections, zero compression")
print("[EXO] AI: Bayesian profiler + Neural memory + Strategy mutation")
print("[EXO] UI: ZyronX Blue, unlimited tabs, mobile-first")
print("[EXO] Mobile: Tap EXO sphere to open/close. Drag top bar to move.")
print("[EXO] Chat Commands: help, status, profiles, profile [name],")
print("[EXO]   threats, strategy, target [name], disable all, why,")
print("[EXO]   memory, clear")
print("[EXO] AI Pipeline: Die → Robot analyzes → Chat opens → Confirm → Execute")
print("═══════════════════════════════════════════════════════════")
