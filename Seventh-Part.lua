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

-- Force visibility after creation (triple-check)
task.spawn(function()
    task.wait(0.3)
    if Window.MainFrame and Window.MainFrame.Parent then
        pcall(function() Window.MainFrame.Visible = true end)
    end
    task.wait(0.3)
    if Window.MainFrame and Window.MainFrame.Parent and not Window.MainFrame.Visible then
        pcall(function() Window.MainFrame.Visible = true end)
    end
    task.wait(0.3)
    if Window.MainFrame and Window.MainFrame.Parent and not Window.MainFrame.Visible then
        pcall(function() Window.MainFrame.Visible = true end)
        warn("[EXO] UI required triple-force visibility on init")
    end
end)

do
    local CombatTab = Window:CreateTab("Combat", true)
    if not CombatTab then warn("[EXO] Combat tab failed") end
    local CombatPage = CombatTab and CombatTab:CreatePage("Main")

    if CombatPage then
        local AuraSec = CombatPage:CreateSection("1000x Multi-Target Aura")
        AuraSec:AddToggle("Enable Aura", false, function(state)
            Aura.Enabled = state
            if state then
                Aura.TargetList = {}
                local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
                if players_ok and type(players_list) == "table" then
                    for _, plr in ipairs(players_list) do
                        if plr ~= player then table.insert(Aura.TargetList, plr) end
                    end
                end
                startAuraLoop()
                Library:Notify({Title = "Aura", Description = "ENGAGED - " .. #Aura.TargetList .. " targets. Multi-vector prediction active."})
            else stopAuraLoop() end
        end, {Title = "Multi-Target Aura", Description = "Teleports damage parts to predicted enemy positions using velocity extrapolation. Fires triple remotes + touch fallback."})
        
        AuraSec:AddToggle("Instant Kill", false, function(state) 
            InstantKill = state 
        end, {Title = "Instant Kill", Description = "Sets target humanoid health to 0 and anchors HRP on contact."})
        
        AuraSec:AddSlider("Prediction Depth", 3, 30, 8, function(val) 
            latencyEstimate = val / 100 
        end, {Title = "Prediction Depth", Description = "Controls velocity extrapolation multiplier. Higher = more aggressive leading of moving targets."})
        
        AuraSec:AddDropdown("Aura Targets", getServerPlayers(), true, function(selected)
            table.clear(Aura.TargetList)
            if type(selected) == "table" then
                for _, name in ipairs(selected) do
                    local plr = Players:FindFirstChild(name)
                    if plr then table.insert(Aura.TargetList, plr) end
                end
            end
        end, {Title = "Aura Targets", Description = "Select specific players to target. Multi-selection enabled."})

        local ToolFollowSec = CombatPage:CreateSection("1000x Tool Follow")
        ToolFollowSec:AddToggle("Enable Tool Follow", false, function(state)
            ToolFollow.Enabled = state
            if state then
                ToolFollow.Targets = {}
                local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
                if players_ok and type(players_list) == "table" then
                    for _, plr in ipairs(players_list) do
                        if plr ~= player then table.insert(ToolFollow.Targets, plr) end
                    end
                end
                startToolFollow()
            else stopToolFollow() end
        end, {Title = "Tool Follow", Description = "Predictively positions your tools on enemy torsos using velocity interpolation. Makes weapons track targets automatically."})

        local DefenseSec = CombatPage:CreateSection("1000x Defense / Anti-Aura")
        DefenseSec:AddToggle("Enable Anti-Aura", false, function(state)
            AntiAura.Enabled = state
            if state then startAntiAura() else stopAntiAura() end
        end, {Title = "Anti-Aura Master Switch", Description = "Enables the entire defensive suite including GodMode, Repel, Phase, and HealAura."})
        
        DefenseSec:AddToggle("God Mode (ForceField)", false, function(state) 
            AntiAura.GodMode = state 
        end, {Title = "God Mode", Description = "Creates invisible ForceField + auto-heals when HP drops below 70%."})
        
        DefenseSec:AddToggle("Repel (Anti-Touch)", false, function(state) 
            AntiAura.Repel = state 
        end, {Title = "Repel", Description = "Pushes enemy tool handles away using AssemblyLinearVelocity. Prevents touch-based damage."})
        
        DefenseSec:AddToggle("Phase (No Collide)", false, function(state) 
            AntiAura.Phase = state 
        end, {Title = "Phase Mode", Description = "Sets CanCollide=false on all character parts. Makes you pass through enemy hitboxes."})
        
        DefenseSec:AddToggle("Heal Aura", false, function(state) 
            AntiAura.HealAura = state 
        end, {Title = "Heal Aura", Description = "Continuous regeneration at 5% MaxHealth per heartbeat tick."})
        
        DefenseSec:AddSlider("Repel Force", 50, 300, 120, function(val) 
            AntiAura.RepelForce = val 
        end, {Title = "Repel Force", Description = "Velocity magnitude applied to enemy tools. Higher = stronger pushback."})
        
        DefenseSec:AddSlider("Repel Radius", 8, 30, 18, function(val) 
            AntiAura.RepelRadius = val 
        end, {Title = "Repel Radius", Description = "Detection range for repel effect in studs."})
        
        DefenseSec:AddToggle("Anti Spawnkill", false, function(state)
            AntiSpawnkill = state
            if state then
                player.CharacterAdded:Connect(function(c)
                    local hum_ok, hum = pcall(function() return c:WaitForChild("Humanoid", 10) end)
                    if not hum_ok or not hum then return end
                    pcall(function() hum.MaxHealth = 9e9; hum.Health = 9e9 end)
                    local ff_ok, ff = pcall(function() 
                        local f = Instance.new("ForceField", c)
                        f.Visible = false
                        return f
                    end)
                    task.delay(5, function()
                        if hum and hum.Parent then 
                            pcall(function() hum.MaxHealth = 100; hum.Health = 100 end) 
                        end
                        if ff_ok and ff then pcall(function() ff:Destroy() end) end
                    end)
                end)
            end
        end, {Title = "Anti Spawnkill", Description = "Grants 5 seconds of invincibility (9e9 HP + ForceField) on every respawn."})
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 32: BUILD ZYRONX UI – TYCOON TAB                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local TycoonTab = Window:CreateTab("Tycoon")
    if not TycoonTab then warn("[EXO] Tycoon tab failed") end
    local TycoonPage = TycoonTab and TycoonTab:CreatePage("Automation")

    if TycoonPage then
        local TycoonSec = TycoonPage:CreateSection("1000x Tycoon Automation")
        TycoonSec:AddToggle("Auto Claim Money", false, function(state)
            AutoClaimMoney = state
            if state then startClaimMoney() else stopClaimMoney() end
        end, {Title = "Auto Claim Money", Description = "Continuously fires touch interest on all cash registers and money collectors in your tycoon."})
        
        TycoonSec:AddToggle("Smart Auto Build (Multi-Buy)", false, function(state)
            AutoBuild = state
            if state then startAutoBuild() else stopAutoBuild() end
        end, {Title = "Smart Auto Build", Description = "Automatically purchases up to 3 items per cycle based on priority scoring. Buys generators > gear > walls."})
        
        TycoonSec:AddToggle("Auto Grab Weapons", false, function(state)
            AutoGetTools = state
            if state then
                if grabLoopConn then pcall(function() grabLoopConn:Disconnect() end) end
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
                if grabLoopConn then pcall(function() grabLoopConn:Disconnect() end); grabLoopConn = nil end
            end
        end, {Title = "Auto Grab Weapons", Description = "Automatically collects all 14 weapon types from their respective tycoon bases."})

        local CooldownSec = TycoonPage:CreateSection("Tools & Cooldown")
        CooldownSec:AddToggle("Auto Use Tools (0 delay)", false, function(state)
            AutoTools = state
            if state then
                toolLoopConn = RunService.RenderStepped:Connect(function()
                    if not AutoTools then return end
                    local myChar = player.Character
                    if not myChar then return end
                    local children_ok, children = pcall(function() return myChar:GetChildren() end)
                    if children_ok and type(children) == "table" then
                        for _, t in ipairs(children) do
                            if t:IsA("Tool") then pcall(function() t:Activate() end) end
                        end
                    end
                    local bp = player:FindFirstChildOfClass("Backpack")
                    if bp then
                        local bp_ok, bp_children = pcall(function() return bp:GetChildren() end)
                        if bp_ok and type(bp_children) == "table" then
                            for _, t in ipairs(bp_children) do
                                if t:IsA("Tool") then 
                                    pcall(function() t.Parent = myChar end)
                                    pcall(function() t:Activate() end) 
                                end
                            end
                        end
                    end
                end)
            else
                if toolLoopConn then pcall(function() toolLoopConn:Disconnect() end); toolLoopConn = nil end
            end
        end, {Title = "Auto Use Tools", Description = "Activates all equipped and backpack tools every frame with zero delay."})
        
        CooldownSec:AddToggle("No Cooldown (SAFE)", false, function(state)
            NoCooldown = state
            if state then startNoCooldown() else stopNoCooldown() end
        end, {Title = "No Cooldown (SAFE)", Description = "Sets tool Cooldown.Value=0, Enabled.Value=true, and Handle.CanCollide=false every frame. Does NOT hook global wait functions."})
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 33: BUILD ZYRONX UI – MISC TAB                            ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local MiscTab = Window:CreateTab("Misc")
    if not MiscTab then warn("[EXO] Misc tab failed") end
    local MiscPage = MiscTab and MiscTab:CreatePage("Utilities")

    if MiscPage then
        local ReachSec = MiscPage:CreateSection("1000x Reach")
        ReachSec:AddToggle("Enable Reach", false, function(state)
            Reach = state
            if state then applyReach() else stopReach() end
        end, {Title = "Enable Reach", Description = "Multiplies tool hitbox size by ReachSize factor. Adds blue highlight outline."})
        
        ReachSec:AddSlider("Reach Size", 1, 15, 3, function(val)
            ReachSize = val
            if Reach then stopReach(); applyReach() end
        end, {Title = "Reach Size", Description = "Multiplier for tool hitbox expansion. Range: 1x to 15x original size."})

        local RespawnSec = MiscPage:CreateSection("Respawn & Protection")
        RespawnSec:AddToggle("Fast Respawn", false, function(state)
            FastRespawn = state
            if state then startFastRespawn() end
        end, {Title = "Fast Respawn", Description = "Fires Guide remote or LoadCharacter within 20ms of death. Near-instant respawn."})

        local UtilsSec = MiscPage:CreateSection("Remote Configuration")
        UtilsSec:AddTextbox("Set Damage Remote", "game.ReplicatedStorage.DealDamage", function(text)
            if type(text) == "string" and text ~= "" then
                local ok, remote = pcall(function() return loadstring("return " .. text)() end)
                if ok and remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                    DAMAGE_REMOTE = remote
                    Library:Notify({Title = "Remote Set", Description = "Damage remote updated successfully."})
                else
                    Library:Notify({Title = "Error", Description = "Invalid remote path. Check syntax."})
                end
            end
        end, {Title = "Set Damage Remote", Description = "Manually override the damage remote used by Aura and InstaKill. Accepts full Lua path expressions."})
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 34: BUILD ZYRONX UI – KILL ENGINE TAB                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local KillTab = Window:CreateTab("Kill Engine")
    if not KillTab then warn("[EXO] Kill Engine tab failed") end
    local KillPage = KillTab and KillTab:CreatePage("Omni-Kill")

    if KillPage then
        local OmniSec = KillPage:CreateSection("1000x Omni-Kill Engine")
        OmniSec:AddToggle("Enable Omni-Kill", false, function(state)
            Aura.Enabled = state; InstantKill = state
            if state then
                Aura.TargetList = {}
                local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
                if players_ok and type(players_list) == "table" then
                    for _, plr in ipairs(players_list) do
                        if plr ~= player then table.insert(Aura.TargetList, plr) end
                    end
                end
                startAuraLoop()
                Library:Notify({Title = "OMNI-KILL", Description = "ENGAGED - " .. #Aura.TargetList .. " targets."})
            else stopAuraLoop() end
        end, {Title = "Omni-Kill", Description = "Combines Aura + InstantKill for maximum lethality. Targets all players simultaneously."})
        
        OmniSec:AddToggle("Insta-Kill Micro-Burst", false, function(state)
            InstaKillEnabled = state
            if state then startInstaKill() else stopInstaKill() end
        end, {Title = "Insta-Kill Micro-Burst", Description = "120Hz parallel burst firing across all tools. Targets 9 hitboxes per enemy."})
        
        OmniSec:AddToggle("Adaptive Burst (Threat-Based)", true, function(state)
            IK_AdaptiveBurst = state
        end, {Title = "Adaptive Burst", Description = "Automatically increases burst count based on current threat level. More threats = more bullets."})
        
        OmniSec:AddSlider("Prediction Aggression", 3, 30, 8, function(val) 
            latencyEstimate = val / 100 
        end, {Title = "Prediction Aggression", Description = "Velocity extrapolation multiplier for InstaKill targeting."})
        
        OmniSec:AddSlider("Burst Count", 3, 20, 12, function(val) 
            IK_BurstCount = val 
        end, {Title = "Burst Count", Description = "Number of remote fires per burst cycle. Range: 3-20."})
        
        OmniSec:AddButton("Manual Kill Burst", function()
            local orig = Aura.Enabled
            Aura.Enabled = true; InstantKill = true
            task.wait(0.15)
            Aura.Enabled = orig
            if not orig then InstantKill = false end
            Library:Notify({Title = "Kill Burst", Description = "Manual burst fired."})
        end, {Title = "Manual Kill Burst", Description = "Fires a single concentrated burst without enabling persistent systems."})
        
        OmniSec:AddButton("Refresh Target List", function()
            table.clear(Aura.TargetList)
            local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
            if players_ok and type(players_list) == "table" then
                for _, plr in ipairs(players_list) do
                    if plr ~= player then table.insert(Aura.TargetList, plr) end
                end
            end
            Library:Notify({Title = "Targets", Description = "Refreshed: " .. #Aura.TargetList .. " players"})
        end, {Title = "Refresh Target List", Description = "Re-scans server for all players and updates Aura target list."})

        local HitAmpSec = KillPage:CreateSection("1000x Hit Amplifier")
        HitAmpSec:AddToggle("Enable Hit Amplifier", false, function(state)
            HitAmpEnabled = state
            if state then startHitAmplifier() else stopHitAmplifier() end
        end, {Title = "Hit Amplifier", Description = "360° spherical + box overlap scan. Detects enemies in range and fires tool remotes."})
        
        HitAmpSec:AddSlider("Scan Range", 15, 60, 45, function(val)
            HA_Range = Vector3.new(val, val, val)
        end, {Title = "Scan Range", Description = "Radius of overlap detection in studs. Range: 15-60."})
        
        HitAmpSec:AddSlider("Burst Count", 1, 15, 8, function(val) 
            HA_BurstCount = val 
        end, {Title = "Burst Count", Description = "Remote fires per pulse. Range: 1-15."})
        
        HitAmpSec:AddToggle("Multi-Pulse (3x waves)", true, function(state) 
            HA_MultiPulse = state 
        end, {Title = "Multi-Pulse", Description = "Fires 3 consecutive waves per detection cycle for triple damage output."})
        
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
        end, {Title = "Tool Arsenal", Description = "Background loop that continuously attempts to acquire all 14 weapon types from tycoon pads."})
        
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
                Library:Notify({Title = "Tool Arsenal", Description = "Force acquire burst fired on all bases."})
            end
        end, {Title = "Force Acquire All", Description = "Immediately fires touch interest on all registered tycoon pads regardless of inventory state."})
        
        ArsenalSec:AddLabel("14 Bases: Stone, Magic, Storm, Robotic, Mecha, Shadow, Hyper, Thunder, Void, Frozen, Magma, Nuclear, Toxic, Kong")
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 35: BUILD ZYRONX UI – ECONOMY TAB                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local EconTab = Window:CreateTab("Economy")
    if not EconTab then warn("[EXO] Economy tab failed") end
    local EconPage = EconTab and EconTab:CreatePage("Sovereign")

    if EconPage then
        local SovSec = EconPage:CreateSection("1000x Sovereign Economy")
        SovSec:AddToggle("Enable Sovereign Economy", false, function(state)
            AutoClaimMoney = state; AutoBuild = state
            if state then startClaimMoney(); startAutoBuild()
            else stopClaimMoney(); stopAutoBuild() end
        end, {Title = "Sovereign Economy", Description = "Master toggle for Auto Claim + Auto Build. Full tycoon automation."})
        
        SovSec:AddSlider("Defense Threat Radius", 20, 120, 60, function(val) 
            ThreatRadius = val 
        end, {Title = "Threat Radius", Description = "Detection range for threat level calculation. Used by AI strategy engine."})
        
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
            local descendants_ok, descendants = pcall(function() return tycoonFolder:GetDescendants() end)
            if descendants_ok and type(descendants) == "table" then
                for _, obj in ipairs(descendants) do
                    if obj:IsA("Model") then
                        local cost = getCost(obj)
                        local pri = getPriority(obj.Name)
                        if cost > 0 and cost <= cash and pri < bestPri then best = obj; bestPri = pri end
                    end
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
        end, {Title = "Force Buy Next Upgrade", Description = "Manually triggers purchase of highest-priority affordable item."})

        local SpawnSec = EconPage:CreateSection("Spawn Supremacy")
        SpawnSec:AddToggle("Supremacy Mode", false, function(state)
            AntiSpawnkill = state
            if state then
                player.CharacterAdded:Connect(function(c)
                    local hum_ok, hum = pcall(function() return c:WaitForChild("Humanoid", 10) end)
                    if not hum_ok or not hum then return end
                    pcall(function() hum.MaxHealth = 9e9; hum.Health = 9e9 end)
                    local ff_ok, ff = pcall(function() 
                        local f = Instance.new("ForceField", c)
                        f.Visible = false
                        return f
                    end)
                    task.delay(5, function()
                        if hum and hum.Parent then 
                            pcall(function() hum.MaxHealth = 100; hum.Health = 100 end) 
                        end
                        if ff_ok and ff then pcall(function() ff:Destroy() end) end
                    end)
                end)
            end
        end, {Title = "Supremacy Mode", Description = "5-second spawn invincibility with 9e9 HP + ForceField."})
        
        SpawnSec:AddToggle("Fast Respawn", false, function(state)
            FastRespawn = state
            if state then startFastRespawn() end
        end, {Title = "Fast Respawn", Description = "Near-instant respawn via Guide remote or LoadCharacter."})

        local DefSec = EconPage:CreateSection("1000x Defense Matrix")
        DefSec:AddToggle("Enable Defense Matrix", false, function(state)
            AntiAura.Enabled = state
            if state then startAntiAura() else stopAntiAura() end
        end, {Title = "Defense Matrix", Description = "Master switch for full defensive suite."})
        
        DefSec:AddToggle("ForceField God Mode", false, function(state) 
            AntiAura.GodMode = state 
        end, {Title = "God Mode", Description = "Invisible ForceField + auto-heal below 70% HP."})
        
        DefSec:AddToggle("Weapon Repel", false, function(state) 
            AntiAura.Repel = state 
        end, {Title = "Weapon Repel", Description = "Pushes enemy tools away with configurable force and radius."})
        
        DefSec:AddToggle("Phase Mode", false, function(state) 
            AntiAura.Phase = state 
        end, {Title = "Phase Mode", Description = "NoCollide on all character parts. Pass through enemy hitboxes."})
        
        DefSec:AddToggle("Heal Aura", false, function(state) 
            AntiAura.HealAura = state 
        end, {Title = "Heal Aura", Description = "Continuous 5% MaxHealth regen per heartbeat."})
        
        DefSec:AddButton("Emergency Heal", function()
            local myChar = player.Character
            if myChar then
                local hum = myChar:FindFirstChild("Humanoid")
                if hum then
                    local maxHP_ok, maxHP = pcall(function() return hum.MaxHealth end)
                    if maxHP_ok and type(maxHP) == "number" then
                        pcall(function() hum.Health = maxHP end)
                        Library:Notify({Title = "Healed", Description = "Health restored to max."})
                    end
                end
            end
        end, {Title = "Emergency Heal", Description = "Instantly sets health to MaxHealth. Manual override."})
    end
end
