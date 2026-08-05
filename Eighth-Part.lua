-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 36: BUILD ZYRONX UI – SENTINEL AI TAB (NEW)               ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local AITab = Window:CreateTab("Sentinel AI")
    if not AITab then warn("[EXO] Sentinel AI tab failed") end
    local AIPage = AITab and AITab:CreatePage("Brain")

    if AIPage then
        local AIControlSec = AIPage:CreateSection("AI Control")
        AIControlSec:AddToggle("Enable Sentinel AI", true, function(state)
            KillNotifEnabled = state
            KillLogEnabled = state
            if state then
                Chat_CreateGUI()
                Chat_AddMessage("AI", "Sentinel AI activated. I'm watching your back. Enable Kill Notifications to feed me data.", Color3.fromRGB(0, 255, 100))
                Library:Notify({Title = "Sentinel AI", Description = "AI Combat Brain ONLINE. Chat overlay active."})
            else
                Chat_AddMessage("AI", "Sentinel AI deactivated.", Color3.fromRGB(255, 200, 0))
            end
        end, {Title = "Enable Sentinel AI", Description = "Activates the kill analysis pipeline, robot animator, and chat system. Requires Kill Notifications to be ON."})
        
        AIControlSec:AddToggle("Auto-Analyze Kills", true, function(state)
            KillNotifEnabled = state
        end, {Title = "Auto-Analyze Kills", Description = "Automatically triggers AI analysis on every death event."})
        
        AIControlSec:AddButton("Open AI Chat", function()
            Chat_CreateGUI()
            Chat_AddMessage("AI", "Chat opened manually. Type 'help' for commands.")
        end, {Title = "Open AI Chat", Description = "Manually opens the persistent chat overlay if it was closed or hidden."})
        
        AIControlSec:AddButton("Disable All AI Features", function()
            Aura.Enabled = false; stopAuraLoop()
            InstaKillEnabled = false; stopInstaKill()
            HitAmpEnabled = false; stopHitAmplifier()
            AntiAura.Enabled = false; stopAntiAura()
            Reach = false; stopReach()
            ToolFollow.Enabled = false; stopToolFollow()
            Chat_AddMessage("AI", "All AI-activated features disabled via emergency stop.", Color3.fromRGB(255, 200, 0))
            Robot_SetState("IDLE")
        end, {Title = "Disable All AI Features", Description = "Emergency stop. Disables all combat systems activated by the AI strategy engine."})

        local AIInfoSec = AIPage:CreateSection("AI Intelligence")
        AIInfoSec:AddLabel("Bayesian Threat Profiler: Per-player pattern tracking with confidence scoring")
        AIInfoSec:AddLabel("Adaptive Strategy Engine: Mutates counters when previous attempts fail")
        AIInfoSec:AddLabel("Neural Memory System: Persistent learning across sessions")
        AIInfoSec:AddLabel("Temporal Pattern Analysis: Detects burst kills and spawn camping")
        AIInfoSec:AddLabel("Chat System: Full bidirectional conversation with confirmation gate")
        AIInfoSec:AddLabel("Robot Analyst: Animated kill report processor with 5 states")
        
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
                Library:Notify({Title = "Profiles", Description = "No threat profiles recorded yet. Die to generate data."})
            end
        end, {Title = "View All Threat Profiles", Description = "Displays notification summary for every tracked opponent."})
        
        AIInfoSec:AddButton("Reset All Profiles", function()
            ThreatProfiles = {}
            writeJSON(AI_PROFILE_FILE, ThreatProfiles)
            Library:Notify({Title = "Profiles", Description = "All threat profiles cleared from storage."})
            Chat_AddMessage("SYSTEM", "Threat profiles reset.", Color3.fromRGB(255, 80, 80))
        end, {Title = "Reset All Profiles", Description = "Permanently deletes all opponent tracking data from disk."})
        
        AIInfoSec:AddButton("Reset AI Memory", function()
            AIMemory = {
                StrategyResults = {},
                FeatureEffectiveness = {},
                OpponentAdaptations = {},
                SessionLearningRate = 0.1
            }
            writeJSON(AI_MEMORY_FILE, AIMemory)
            Library:Notify({Title = "Memory", Description = "AI neural memory reset. Learning rate restored to 0.1."})
            Chat_AddMessage("SYSTEM", "AI memory wiped. Fresh learning cycle started.", Color3.fromRGB(255, 80, 80))
        end, {Title = "Reset AI Memory", Description = "Clears strategy success/failure history and feature effectiveness data. AI will relearn from scratch."})
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 37: BUILD ZYRONX UI – SETTINGS TAB                        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local SettingsTab = Window:CreateTab("Settings")
    if not SettingsTab then warn("[EXO] Settings tab failed") end
    local SettingsPage = SettingsTab and SettingsTab:CreatePage("Config")

    if SettingsPage then
        local GenSec = SettingsPage:CreateSection("General")
        GenSec:AddToggle("Anti-Lag Shield", false, function(state)
            AntiLagEnabled = state
            if state then startAntiLag() else stopAntiLag() end
        end, {Title = "Anti-Lag Shield", Description = "Disables particles, beams, trails, sounds, post-effects. Sets quality to Level01."})
        
        GenSec:AddToggle("ESP (Threat-Colored)", false, function(state)
            ESPEnabled = state
            if state then startESP() else stopESP() end
        end, {Title = "ESP (Threat-Colored)", Description = "Shows player dots colored by distance: Red (<15), Orange (<30), Green (>30). Includes names."})
        
        GenSec:AddToggle("Kill Notifications", false, function(state)
            KillNotifEnabled = state
            if state then
                Library:Notify({Title = "Kill Notifications", Description = "Behavioral analysis + Sentinel AI pipeline enabled."})
            end
        end, {Title = "Kill Notifications", Description = "Enables death event hook that feeds data to AI analyzer and ZyronX notifications."})
        
        GenSec:AddToggle("Kill Logs", false, function(state) 
            KillLogEnabled = state 
        end, {Title = "Kill Logs", Description = "Persists kill analysis reports to exo_v9_logs.dat for later review."})
        
        GenSec:AddButton("View Kill Logs", function()
            if #KillLogs == 0 then
                Library:Notify({Title = "Kill Logs", Description = "No kills recorded this session."})
                return
            end
            local lastLog = KillLogs[#KillLogs]
            Library:Notify({
                Title = "Last Kill Log",
                Description = "Killer: " .. lastLog.Killer .. "\nWeapon: " .. lastLog.Weapon
                    .. "\nThreat: " .. lastLog.Threat .. "/10\nTTK: " .. string.format("%.2f", lastLog.TTK) .. "s\nTotal logs: " .. #KillLogs,
                Duration = 5,
            })
        end, {Title = "View Kill Logs", Description = "Shows the most recent kill analysis report in a notification."})

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
            Library:Notify({Title = "Config Saved", Description = "All combat parameters saved to exo_v9_cfg.dat."})
        end, {Title = "Save Config", Description = "Writes current slider/toggle values to disk for persistence across sessions."})
        
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
                
                -- Apply reach if active
                if Reach then stopReach(); applyReach() end
                
                Library:Notify({Title = "Config Loaded", Description = "Settings restored from exo_v9_cfg.dat."})
            else
                Library:Notify({Title = "No Config", Description = "No saved config found at exo_v9_cfg.dat."})
            end
        end, {Title = "Load Config", Description = "Reads saved parameters from disk and applies them to live state."})
        
        ConfigSec:AddButton("Rejoin Server", function()
            pcall(function() TeleportService:Teleport(game.PlaceId, player) end)
        end, {Title = "Rejoin Server", Description = "Teleports to same place ID. Useful for resetting tycoon state or escaping stuck sessions."})
    end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 38: BUILD ZYRONX UI – UPDATES TAB                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
do
    local UpdatesTab = Window:CreateTab("Updates")
    if not UpdatesTab then warn("[EXO] Updates tab failed") end
    local UpdatesPage = UpdatesTab and UpdatesTab:CreatePage("Changelog")
    
    if UpdatesPage then
        local ChangeSec = UpdatesPage:CreateSection("EXO Hub Changelog")
        ChangeSec:AddLabel("v9.0 - SENTINEL AI: OMNISCIENT (CURRENT)")
        ChangeSec:AddLabel("  - NEW: Bayesian Threat Inference Engine")
        ChangeSec:AddLabel("  - NEW: Neural Memory System (learns from outcomes)")
        ChangeSec:AddLabel("  - NEW: Adaptive Strategy Mutation (evolves on failure)")
        ChangeSec:AddLabel("  - NEW: Temporal Kill Pattern Analysis")
        ChangeSec:AddLabel("  - NEW: Animated Robot Kill Analyst (5 states)")
        ChangeSec:AddLabel("  - NEW: Persistent Bidirectional Chat Overlay")
        ChangeSec:AddLabel("  - NEW: Confirmation Gate (asks before acting)")
        ChangeSec:AddLabel("  - NEW: AI explains WHY you're losing")
        ChangeSec:AddLabel("  - FIX: UI guaranteed visible (triple-redundancy)")
        ChangeSec:AddLabel("  - FIX: Mobile-first touch toggle (no keyboard bind)")
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
    if type(Window.Tabs) ~= "table" or #Window.Tabs < 7 then
        validationPassed = false
        table.insert(issues, "Missing tabs: expected 7+, got " .. tostring(Window.Tabs and #Window.Tabs or 0))
    end
    if not scansComplete then
        table.insert(issues, "Scans still running (non-fatal)")
    end
    if type(ThreatProfiles) ~= "table" then
        validationPassed = false
        table.insert(issues, "ThreatProfiles invalid")
    end
    if type(AIMemory) ~= "table" then
        validationPassed = false
        table.insert(issues, "AIMemory invalid")
    end

    if validationPassed then
        print("[EXO] ✓ Post-build validation PASSED")
    else
        warn("[EXO] ✗ Post-build validation ISSUES: " .. table.concat(issues, ", "))
    end
    
    -- Triple-force visibility one final time
    if Window and Window.MainFrame and Window.MainFrame.Parent then
        if not Window.MainFrame.Visible then
            pcall(function() Window.MainFrame.Visible = true end)
            print("[EXO] Post-validation forced UI visibility")
        end
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
