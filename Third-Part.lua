-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 11: 1000x THREAT DETECTION ENGINE                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function updateThreatLevel()
    if tick() - LastThreatCheck < 0.15 then return end
    LastThreatCheck = tick()
    local prevThreat = ThreatLevel
    ThreatLevel = 0
    local myChar = player.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos = myRoot.Position
    
    -- Validate position is a Vector3
    if typeof(myPos) ~= "Vector3" then return end

    local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
    if not players_ok or type(players_list) ~= "table" then return end

    for _, plr in ipairs(players_list) do
        if plr ~= player then
            local char_ok, char = pcall(function() return plr.Character end)
            if char_ok and char then
                local theirRoot = char:FindFirstChild("HumanoidRootPart")
                if theirRoot then
                    local pos_ok, theirPos = pcall(function() return theirRoot.Position end)
                    if pos_ok and typeof(theirPos) == "Vector3" then
                        local dist = (theirPos - myPos).Magnitude
                        local vel_ok, velocity = pcall(function() return theirRoot.Velocity.Magnitude end)
                        local vel = (vel_ok and type(velocity) == "number") and velocity or 0

                        if dist < ThreatRadius then
                            ThreatLevel = ThreatLevel + 1
                            if dist < ThreatRadius * 0.3 then ThreatLevel = ThreatLevel + 2 end
                            if dist < ThreatRadius * 0.1 then ThreatLevel = ThreatLevel + 3 end
                            if vel > 20 then ThreatLevel = ThreatLevel + 1 end

                            -- Check if they have tools equipped (aggression indicator)
                            local hasTool = false
                            local children_ok, children = pcall(function() return char:GetChildren() end)
                            if children_ok and type(children) == "table" then
                                for _, item in ipairs(children) do
                                    if item:IsA("Tool") then hasTool = true; break end
                                end
                            end
                            if hasTool then ThreatLevel = ThreatLevel + 1 end
                        end
                    end
                end
            end
        end
    end

    ThreatTrend = ThreatLevel - prevThreat
    if ThreatLevel > PeakThreat then PeakThreat = ThreatLevel end
    ThreatDecay = math.max(0, ThreatDecay - 0.1)

    table.insert(ThreatHistory, {time = tick(), level = ThreatLevel, trend = ThreatTrend})
    if #ThreatHistory > 60 then table.remove(ThreatHistory, 1) end

    -- Threat velocity tracking for AI
    table.insert(ThreatVelocity, {time = tick(), delta = ThreatTrend})
    if #ThreatVelocity > 30 then table.remove(ThreatVelocity, 1) end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 12: SENTINEL AI – BAYESIAN THREAT PROFILER                ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function AI_GetOrCreateProfile(killerName)
    if type(killerName) ~= "string" then killerName = "Unknown" end
    if not ThreatProfiles[killerName] then
        ThreatProfiles[killerName] = {
            Name = killerName,
            TotalKills = 0,
            AvgDistance = 0,
            AvgTTK = 0,
            Weapons = {},
            SuspectedFeatures = {},
            Confidence = {},
            LastSeen = 0,
            EngagementHistory = {},
            CounterHistory = {},
            ThreatScore = 0,
            FirstEncounter = os.time(),
            WinRate = 0,
            PositioningHabit = {},
            WeaponSwitchPattern = {},
            DeathVelocity = {},
        }
    end
    return ThreatProfiles[killerName]
end

local function AI_DetectFeatures(killData, profile)
    if type(killData) ~= "table" then return {} end
    if type(profile) ~= "table" then return {} end
    
    local features = {}
    local ttk = killData.TTK or 999
    local distance = killData.Distance or 0
    local weapon = killData.Weapon or "Unknown"
    local tsr = killData.TimeSinceRespawn or 999

    -- LOOPBRING DETECTION: Extremely fast TTK + close range + repeated
    if type(ttk) == "number" and type(distance) == "number" then
        if ttk < 0.3 and distance < 8 then
            features["LoopBring"] = 85
            if profile.TotalKills > 2 and profile.AvgTTK < 0.4 then
                features["LoopBring"] = 95
            end
        end

        -- KILL AURA DETECTION: Multiple rapid kills, medium range, no visible weapon swing
        if distance > 5 and distance < 15 and ttk < 0.5 then
            features["KillAura"] = 75
            if weapon == "Unknown" then
                features["KillAura"] = 90
            end
        end

        -- REACH DETECTION: Kills from impossible distance
        if distance > 25 then
            features["Reach"] = 80
            if distance > 40 then
                features["Reach"] = 95
            end
        end

        -- FAST KILL / REMOTE SPAM: Very fast TTK regardless of distance
        if ttk < 0.2 then
            features["FastKill"] = 85
            features["RemoteSpam"] = 70
        end

        -- FIGHT EVENT ABUSE: No weapon detected, fast kills
        if weapon == "Unknown" and ttk < 0.5 then
            features["FightEventAbuse"] = 80
        end

        -- HIT AMPLIFIER: Medium range, consistent TTK
        if distance > 15 and distance <= 30 and ttk < 0.8 then
            features["HitAmplifier"] = 70
        end

        -- TOOL FOLLOW: Very close, persistent kills
        if distance < 3 and profile.TotalKills > 3 then
            features["ToolFollow"] = 75
        end

        -- SPAWN KILL: Kills happening very shortly after your respawn
        if type(tsr) == "number" and tsr < 2 then
            features["SpawnKill"] = 90
        end
    end

    -- TEMPORAL PATTERN: Deaths clustering in time windows
    if type(DeathTimestamps) == "table" and #DeathTimestamps >= 3 then
        local recentWindow = 0
        for i = #DeathTimestamps, math.max(1, #DeathTimestamps - 4), -1 do
            if DeathTimestamps[i] and DeathTimestamps[i-1] then
                recentWindow = recentWindow + (DeathTimestamps[i] - DeathTimestamps[i-1])
            end
        end
        if recentWindow < 5 and recentWindow > 0 then
            features["BurstKillPattern"] = 80
        end
    end

    return features
end

local function AI_CalculateThreatScore(profile)
    if type(profile) ~= "table" then return 0 end
    
    local score = 0
    score = score + math.min((profile.TotalKills or 0) * 2, 20)
    score = score + math.min(profile.ThreatScore or 0, 10)

    if type(profile.Confidence) == "table" then
        for feature, confidence in pairs(profile.Confidence) do
            if type(confidence) == "number" then
                score = score + math.floor(confidence / 20)
            end
        end
    end

    if type(profile.AvgTTK) == "number" and profile.AvgTTK < 0.3 then score = score + 10 end
    if type(profile.AvgDistance) == "number" and profile.AvgDistance > 30 then score = score + 8 end
    if type(profile.TotalKills) == "number" and profile.TotalKills > 5 then score = score + 5 end

    -- Bayesian adjustment based on memory
    if type(AIMemory) == "table" and type(AIMemory.FeatureEffectiveness) == "table" then
        for feat, eff in pairs(AIMemory.FeatureEffectiveness) do
            if type(eff) == "number" and type(profile.Confidence) == "table" and profile.Confidence[feat] and eff < 0.3 then
                score = score + 5 -- Increase threat if our counters failed before
            end
        end
    end

    return math.clamp(score, 0, 100)
end

local function AI_UpdateProfile(killerName, killData)
    if type(killerName) ~= "string" then killerName = "Unknown" end
    if type(killData) ~= "table" then return nil end
    
    local profile = AI_GetOrCreateProfile(killerName)
    profile.TotalKills = (profile.TotalKills or 0) + 1
    profile.LastSeen = os.time()

    -- Running average for distance
    local kd_dist = killData.Distance or 0
    if type(kd_dist) == "number" and type(profile.AvgDistance) == "number" then
        profile.AvgDistance = ((profile.AvgDistance * (profile.TotalKills - 1)) + kd_dist) / profile.TotalKills
    end
    
    -- Running average for TTK
    local kd_ttk = killData.TTK or 1
    if type(kd_ttk) == "number" and type(profile.AvgTTK) == "number" then
        profile.AvgTTK = ((profile.AvgTTK * (profile.TotalKills - 1)) + kd_ttk) / profile.TotalKills
    end

    -- Track weapons
    local kd_weapon = killData.Weapon
    if type(kd_weapon) == "string" and kd_weapon ~= "Unknown" then
        if type(profile.Weapons) ~= "table" then profile.Weapons = {} end
        profile.Weapons[kd_weapon] = (profile.Weapons[kd_weapon] or 0) + 1
    end

    -- Store engagement
    if type(profile.EngagementHistory) ~= "table" then profile.EngagementHistory = {} end
    table.insert(profile.EngagementHistory, {
        time = os.time(),
        distance = kd_dist,
        ttk = kd_ttk,
        weapon = kd_weapon,
        suspected = killData.Suspected,
    })
    if #profile.EngagementHistory > 50 then
        table.remove(profile.EngagementHistory, 1)
    end

    -- Feature detection with confidence scoring (Bayesian update)
    local features = AI_DetectFeatures(killData, profile)
    if type(profile.Confidence) ~= "table" then profile.Confidence = {} end
    if type(profile.SuspectedFeatures) ~= "table" then profile.SuspectedFeatures = {} end
    
    for feature, confidence in pairs(features) do
        if type(confidence) == "number" then
            local prev = profile.Confidence[feature] or 0
            -- Bayesian smoothing: weight new evidence against prior
            local learningRate = (type(AIMemory) == "table" and type(AIMemory.SessionLearningRate) == "number") and AIMemory.SessionLearningRate or 0.1
            profile.Confidence[feature] = math.min(100, math.max(prev, prev * (1 - learningRate) + confidence * learningRate))
            if confidence > 50 then
                local found = false
                for _, f in ipairs(profile.SuspectedFeatures) do
                    if f == feature then found = true; break end
                end
                if not found then table.insert(profile.SuspectedFeatures, feature) end
            end
        end
    end

    -- Calculate composite threat score
    profile.ThreatScore = AI_CalculateThreatScore(profile)

    -- Persist
    writeJSON(AI_PROFILE_FILE, ThreatProfiles)
    return profile
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13: SENTINEL AI – ADAPTIVE STRATEGY ENGINE                ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function AI_FormulateStrategy(profile, killData)
    if type(profile) ~= "table" then return {Target="Unknown", Actions={}, Explanations={}, Priority="NORMAL", Confidence=0} end
    if type(killData) ~= "table" then killData = {} end
    
    local strategy = {
        Target = profile.Name or "Unknown",
        Actions = {},
        Explanations = {},
        Priority = "NORMAL",
        Confidence = 0,
        FeatureCombos = {},
        MutatedFrom = nil,
    }

    local threats = (type(profile.SuspectedFeatures) == "table") and profile.SuspectedFeatures or {}
    local avgDist = (type(profile.AvgDistance) == "number") and profile.AvgDistance or 0
    local avgTTK = (type(profile.AvgTTK) == "number") and profile.AvgTTK or 1
    local totalKills = (type(profile.TotalKills) == "number") and profile.TotalKills or 0

    -- Determine priority using threat score + temporal analysis
    local threatScore = (type(profile.ThreatScore) == "number") and profile.ThreatScore or 0
    if threatScore >= 80 or totalKills >= 5 then
        strategy.Priority = "CRITICAL"
    elseif threatScore >= 50 or totalKills >= 3 then
        strategy.Priority = "HIGH"
    end

    -- Check memory for previously failed strategies against this player
    local previousFailure = nil
    if type(AIMemory) == "table" and type(AIMemory.StrategyResults) == "table" then
        for _, result in ipairs(AIMemory.StrategyResults) do
            if type(result) == "table" and result.Target == profile.Name and result.Success == false then
                previousFailure = result
                break
            end
        end
    end

    -- BUILD COUNTER-STRATEGY BASED ON DETECTED FEATURES
    for _, feature in ipairs(threats) do
        if type(feature) == "string" then
            if feature == "LoopBring" then
                table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Minimize downtime between deaths"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiSpawnkill", reason = "Prevent immediate re-kill on spawn"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField blocks touch-based loopbring"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "NoCollide prevents touch contact"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Repel", reason = "Push their tools away from you"})
                -- MUTATION: If previous strategy failed, add extra layer
                if previousFailure then
                    table.insert(strategy.Actions, {type = "set", feature = "AntiAura.RepelForce", value = 200, reason = "PREVIOUS FAILED: Boosted repel force"})
                    table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "PREVIOUS FAILED: Added offensive counter"})
                    strategy.MutatedFrom = previousFailure.StrategyID
                end
                table.insert(strategy.Explanations,
                    "They're using LOOPBRING - teleporting their weapon to you repeatedly. " ..
                    "Average TTK: " .. string.format("%.2f", avgTTK) .. "s. " ..
                    "I'm activating a 5-layer defense: FastRespawn + AntiSpawnkill + GodMode + Phase + Repel." ..
                    (previousFailure and " (MUTATED: Previous attempt failed, adding boosted repel + offense)" or ""))

            elseif feature == "KillAura" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Enabled", reason = "Master anti-aura switch"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField negates aura damage"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Repel", reason = "Push their aura tools away"})
                table.insert(strategy.Actions, {type = "set", feature = "AntiAura.RepelForce", value = 150, reason = "Maximum repel force to break aura range"})
                table.insert(strategy.Actions, {type = "set", feature = "AntiAura.RepelRadius", value = 25, reason = "Extended repel radius"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "Phase through their aura hits"})
                if previousFailure then
                    table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.HealAura", reason = "PREVIOUS FAILED: Added heal to outpace DPS"})
                    strategy.MutatedFrom = previousFailure.StrategyID
                end
                table.insert(strategy.Explanations,
                    "KILL AURA detected. They're damaging you through tool proximity without swinging. " ..
                    "Avg distance: " .. math.floor(avgDist) .. " studs. " ..
                    "Counter: Full Anti-Aura suite with boosted repel force (150) and radius (25)." ..
                    (previousFailure and " (MUTATED: Added HealAura due to prior failure)" or ""))

            elseif feature == "Reach" then
                local reachMult = math.max(4, math.ceil(avgDist / 8))
                table.insert(strategy.Actions, {type = "enable", feature = "Reach", reason = "Match their reach"})
                table.insert(strategy.Actions, {type = "set", feature = "ReachSize", value = reachMult, reason = "Scale reach to counter theirs"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "Phase to avoid their extended hitbox"})
                table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "Strike first before they reach you"})
                if previousFailure then
                    table.insert(strategy.Actions, {type = "set", feature = "ReachSize", value = reachMult + 2, reason = "PREVIOUS FAILED: Extra reach margin"})
                    strategy.MutatedFrom = previousFailure.StrategyID
                end
                table.insert(strategy.Explanations,
                    "REACH user detected. Killing you from " .. math.floor(avgDist) .. " studs away. " ..
                    "I'm setting your reach to " .. reachMult .. "x to match/exceed theirs, " ..
                    "plus Phase mode and InstaKill to strike first." ..
                    (previousFailure and " (MUTATED: +2 extra reach multiplier)" or ""))

            elseif feature == "FastKill" or feature == "RemoteSpam" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField blocks remote damage"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.HealAura", reason = "Auto-heal to outpace their DPS"})
                table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Minimize death downtime"})
                table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "Kill them before they can spam again"})
                table.insert(strategy.Actions, {type = "set", feature = "IK_BurstCount", value = 15, reason = "Maximum burst to overwhelm their defense"})
                if previousFailure then
                    table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "PREVIOUS FAILED: Phase to dodge remotes"})
                    strategy.MutatedFrom = previousFailure.StrategyID
                end
                table.insert(strategy.Explanations,
                    "FAST KILL / REMOTE SPAM detected. TTK: " .. string.format("%.2f", avgTTK) .. "s. " ..
                    "They're firing damage remotes as fast as possible. " ..
                    "Counter: GodMode + HealAura to survive, InstaKill with 15-burst to end them first." ..
                    (previousFailure and " (MUTATED: Added Phase for remote evasion)" or ""))

            elseif feature == "FightEventAbuse" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Enabled", reason = "Full defense suite"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "Block FightEvent damage"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiSpawnkill", reason = "Protect after respawn"})
                table.insert(strategy.Explanations,
                    "FIGHT EVENT ABUSE detected. No visible weapon but taking damage. " ..
                    "They're directly firing FightEvent remotes. GodMode ForceField blocks this.")

            elseif feature == "HitAmplifier" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "Phase out of their overlap scan"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Repel", reason = "Push tools out of scan range"})
                table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Quick recovery"})
                table.insert(strategy.Explanations,
                    "HIT AMPLIFIER detected. They're scanning a " .. math.floor(avgDist) .. " stud radius. " ..
                    "Phase mode makes you invisible to their OverlapParams scan.")

            elseif feature == "ToolFollow" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Repel", reason = "Push their following tools away"})
                table.insert(strategy.Actions, {type = "set", feature = "AntiAura.RepelForce", value = 200, reason = "Max force to break tool follow"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "Phase through followed tools"})
                table.insert(strategy.Explanations,
                    "TOOL FOLLOW detected. Their weapons are tracking your body. " ..
                    "Repel at force 200 + Phase will break their tracking.")

            elseif feature == "SpawnKill" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiSpawnkill", reason = "Extended spawn protection"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField on spawn"})
                table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Quick respawn to reset position"})
                table.insert(strategy.Explanations,
                    "SPAWN KILL detected. They're camping your spawn point. " ..
                    "AntiSpawnkill gives you 5 seconds of invincibility on spawn.")

            elseif feature == "BurstKillPattern" then
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "Survive burst window"})
                table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.HealAura", reason = "Regen between bursts"})
                table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Escape burst cycle"})
                table.insert(strategy.Explanations,
                    "BURST KILL PATTERN detected. Deaths are clustering in rapid succession. " ..
                    "This suggests timed ability usage or macro-based attacks. GodMode + Heal breaks the cycle.")
            end
        end
    end

    -- If no specific features detected but still dying
    if #strategy.Actions == 0 then
        table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Enabled", reason = "General defense"})
        table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField protection"})
        table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Quick recovery"})
        table.insert(strategy.Explanations,
            "General threat detected from " .. tostring(profile.Name) .. ". " ..
            "Activating standard defense suite while I gather more data.")
    end

    -- Add offensive counter if threat is high
    if threatScore >= 60 then
        table.insert(strategy.Actions, {type = "enable", feature = "Aura.Enabled", reason = "Offensive pressure"})
        table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "Eliminate threat quickly"})
        table.insert(strategy.Explanations,
            "Threat score is " .. threatScore .. "/100. " ..
            "Activating offensive counter: Aura + InstaKill targeting " .. tostring(profile.Name) .. " specifically.")
    end

    strategy.Confidence = math.min(95, 40 + (totalKills * 10) + (#strategy.Actions * 5))
    return strategy
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 14: SENTINEL AI – EXECUTION ENGINE + MEMORY UPDATE        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function AI_ExecuteStrategy(strategy)
    if type(strategy) ~= "table" then return end
    if type(strategy.Actions) ~= "table" then return end

    for _, action in ipairs(strategy.Actions) do
        if type(action) == "table" then
            pcall(function()
                if action.type == "enable" then
                    if action.feature == "FastRespawn" then
                        FastRespawn = true
                        startFastRespawn()
                    elseif action.feature == "AntiSpawnkill" then
                        AntiSpawnkill = true
                    elseif action.feature == "AntiAura.Enabled" then
                        AntiAura.Enabled = true
                        startAntiAura()
                    elseif action.feature == "AntiAura.GodMode" then
                        AntiAura.GodMode = true
                    elseif action.feature == "AntiAura.Repel" then
                        AntiAura.Repel = true
                    elseif action.feature == "AntiAura.Phase" then
                        AntiAura.Phase = true
                    elseif action.feature == "AntiAura.HealAura" then
                        AntiAura.HealAura = true
                    elseif action.feature == "Reach" then
                        Reach = true
                        applyReach()
                    elseif action.feature == "InstaKillEnabled" then
                        InstaKillEnabled = true
                        startInstaKill()
                    elseif action.feature == "Aura.Enabled" then
                        Aura.Enabled = true
                        if strategy.Target then
                            local targetPlr = Players:FindFirstChild(strategy.Target)
                            if targetPlr then
                                Aura.TargetList = {targetPlr}
                            end
                        end
                        startAuraLoop()
                    elseif action.feature == "HitAmpEnabled" then
                        HitAmpEnabled = true
                        startHitAmplifier()
                    end

                elseif action.type == "set" then
                    if action.feature == "ReachSize" and type(action.value) == "number" then
                        ReachSize = action.value
                        if Reach then stopReach(); applyReach() end
                    elseif action.feature == "IK_BurstCount" and type(action.value) == "number" then
                        IK_BurstCount = action.value
                    elseif action.feature == "AntiAura.RepelForce" and type(action.value) == "number" then
                        AntiAura.RepelForce = action.value
                    elseif action.feature == "AntiAura.RepelRadius" and type(action.value) == "number" then
                        AntiAura.RepelRadius = action.value
                    elseif action.feature == "HA_Range" and type(action.value) == "number" then
                        HA_Range = Vector3.new(action.value, action.value, action.value)
                    end

                elseif action.type == "disable" then
                    -- Reserved for future adaptive disabling
                end
            end)
        end
    end

    -- Record strategy execution in memory
    local strategyID = HttpService:GenerateGUID(false)
    if type(StrategyEngine.StrategyHistory) ~= "table" then StrategyEngine.StrategyHistory = {} end
    table.insert(StrategyEngine.StrategyHistory, {
        time = os.time(),
        target = strategy.Target,
        priority = strategy.Priority,
        actionCount = #strategy.Actions,
        strategyID = strategyID,
        mutatedFrom = strategy.MutatedFrom,
    })
    if #StrategyEngine.StrategyHistory > 100 then
        table.remove(StrategyEngine.StrategyHistory, 1)
    end

    -- Update memory with strategy result placeholder (will be updated on next kill/survival)
    if type(AIMemory) ~= "table" then AIMemory = {StrategyResults={}, FeatureEffectiveness={}, OpponentAdaptations={}, SessionLearningRate=0.1} end
    if type(AIMemory.StrategyResults) ~= "table" then AIMemory.StrategyResults = {} end
    table.insert(AIMemory.StrategyResults, {
        StrategyID = strategyID,
        Target = strategy.Target,
        Time = os.time(),
        Actions = strategy.Actions,
        Success = nil, -- Will be determined by next engagement outcome
        MutatedFrom = strategy.MutatedFrom,
    })
    if #AIMemory.StrategyResults > 100 then
        table.remove(AIMemory.StrategyResults, 1)
    end
    writeJSON(AI_MEMORY_FILE, AIMemory)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 15: SENTINEL AI – CHAT UI SYSTEM                          ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function Chat_CreateGUI()
    if ChatSystem.GUI then return end

    local gui_ok, gui = pcall(function()
        local g = Instance.new("ScreenGui")
        g.Name = "EXO_SentinelChat"
        g.ResetOnSpawn = false
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        return g
    end)
    if not gui_ok or not gui then 
        warn("[EXO] Failed to create Chat GUI")
        return 
    end
    
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then 
        pcall(function() gui.Parent = player:WaitForChild("PlayerGui") end)
    end
    if not gui.Parent then
        warn("[EXO] Chat GUI has no parent")
        return
    end
    ChatSystem.GUI = gui

    -- Main chat window
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "ChatMain"
    mainFrame.Size = UDim2.new(0, 380, 0, 460)
    mainFrame.Position = UDim2.new(1, -400, 0.5, -230)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = gui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = AccentColor
    stroke.Thickness = 2
    stroke.Parent = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 40, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "EXO SENTINEL AI"
    titleLabel.TextColor3 = AccentColor
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Status indicator
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.Position = UDim2.new(0, 12, 0.5, -4)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = titleBar
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(1, -30, 0.5, -12)
    minBtn.BackgroundTransparency = 1
    minBtn.Text = "—"
    minBtn.TextColor3 = SubTextColor
    minBtn.TextSize = 16
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = titleBar

    -- Robot display area
    local robotArea = Instance.new("Frame")
    robotArea.Name = "RobotArea"
    robotArea.Size = UDim2.new(1, 0, 0, 80)
    robotArea.Position = UDim2.new(0, 0, 0, 36)
    robotArea.BackgroundColor3 = Color3.fromRGB(8, 10, 16)
    robotArea.BorderSizePixel = 0
    robotArea.Parent = mainFrame

    -- Robot body
    local robotBody = Instance.new("Frame")
    robotBody.Name = "RobotBody"
    robotBody.Size = UDim2.new(0, 40, 0, 40)
    robotBody.Position = UDim2.new(0, 15, 0.5, -20)
    robotBody.BackgroundColor3 = AccentColor
    robotBody.BorderSizePixel = 0
    robotBody.Parent = robotArea
    Instance.new("UICorner", robotBody).CornerRadius = UDim.new(0, 8)

    -- Robot eyes
    local eyeL = Instance.new("Frame")
    eyeL.Name = "EyeL"
    eyeL.Size = UDim2.new(0, 8, 0, 8)
    eyeL.Position = UDim2.new(0, 8, 0, 12)
    eyeL.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    eyeL.BorderSizePixel = 0
    eyeL.Parent = robotBody
    Instance.new("UICorner", eyeL).CornerRadius = UDim.new(1, 0)

    local eyeR = Instance.new("Frame")
    eyeR.Name = "EyeR"
    eyeR.Size = UDim2.new(0, 8, 0, 8)
    eyeR.Position = UDim2.new(0, 24, 0, 12)
    eyeR.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    eyeR.BorderSizePixel = 0
    eyeR.Parent = robotBody
    Instance.new("UICorner", eyeR).CornerRadius = UDim.new(1, 0)

    -- Robot mouth
    local mouth = Instance.new("Frame")
    mouth.Name = "Mouth"
    mouth.Size = UDim2.new(0, 16, 0, 3)
    mouth.Position = UDim2.new(0, 12, 0, 28)
    mouth.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    mouth.BorderSizePixel = 0
    mouth.Parent = robotBody

    -- Robot arm (for thumbs up)
    local arm = Instance.new("Frame")
    arm.Name = "Arm"
    arm.Size = UDim2.new(0, 6, 0, 20)
    arm.Position = UDim2.new(1, 2, 0, 15)
    arm.BackgroundColor3 = Color3.fromRGB(0, 120, 220)
    arm.BorderSizePixel = 0
    arm.Parent = robotBody
    Instance.new("UICorner", arm).CornerRadius = UDim.new(0, 3)

    RobotAnim.Body = robotBody
    RobotAnim.Eyes = {eyeL, eyeR}
    RobotAnim.Arm = arm

    -- Robot status text
    local robotStatus = Instance.new("TextLabel")
    robotStatus.Name = "RobotStatus"
    robotStatus.Size = UDim2.new(1, -80, 0, 60)
    robotStatus.Position = UDim2.new(0, 70, 0, 10)
    robotStatus.BackgroundTransparency = 1
    robotStatus.Text = "SENTINEL ONLINE\nAwaiting combat data..."
    robotStatus.TextColor3 = AccentColor
    robotStatus.TextSize = 11
    robotStatus.Font = Enum.Font.Gotham
    robotStatus.TextXAlignment = Enum.TextXAlignment.Left
    robotStatus.TextYAlignment = Enum.TextYAlignment.Top
    robotStatus.TextWrapped = true
    robotStatus.Parent = robotArea
    ChatSystem.StatusLabel = robotStatus

    -- Chat scroll area
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ChatScroll"
    scrollFrame.Size = UDim2.new(1, -10, 1, -155)
    scrollFrame.Position = UDim2.new(0, 5, 0, 118)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = AccentColor
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 4)
    listLayout.Parent = scrollFrame

    ChatSystem.ScrollFrame = scrollFrame

    -- Input area
    local inputArea = Instance.new("Frame")
    inputArea.Name = "InputArea"
    inputArea.Size = UDim2.new(1, -10, 0, 32)
    inputArea.Position = UDim2.new(0, 5, 1, -38)
    inputArea.BackgroundColor3 = Color3.fromRGB(18, 22, 30)
    inputArea.BorderSizePixel = 0
    inputArea.Parent = mainFrame
    Instance.new("UICorner", inputArea).CornerRadius = UDim.new(0, 8)

    local inputBox = Instance.new("TextBox")
    inputBox.Name = "ChatInput"
    inputBox.Size = UDim2.new(1, -45, 1, -4)
    inputBox.Position = UDim2.new(0, 5, 0, 2)
    inputBox.BackgroundTransparency = 1
    inputBox.PlaceholderText = "Type a message..."
    inputBox.PlaceholderColor3 = SubTextColor
    inputBox.Text = ""
    inputBox.TextColor3 = TextColor
    inputBox.TextSize = 12
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextXAlignment = Enum.TextXAlignment.Left
    inputBox.ClearTextOnFocus = true
    inputBox.Parent = inputArea

    local sendBtn = Instance.new("TextButton")
    sendBtn.Name = "SendBtn"
    sendBtn.Size = UDim2.new(0, 32, 0, 24)
    sendBtn.Position = UDim2.new(1, -37, 0.5, -12)
    sendBtn.BackgroundColor3 = AccentColor
    sendBtn.Text = "▶"
    sendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    sendBtn.TextSize = 12
    sendBtn.Font = Enum.Font.GothamBold
    sendBtn.BorderSizePixel = 0
    sendBtn.Parent = inputArea
    Instance.new("UICorner", sendBtn).CornerRadius = UDim.new(0, 6)

    ChatSystem.InputBox = inputBox
    ChatSystem.SendButton = sendBtn

    -- Drag functionality
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ChatSystem.Dragging = true
            ChatSystem.DragStart = input.Position
            ChatSystem.StartPos = mainFrame.Position
        end
    end)

    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            ChatSystem.Dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if ChatSystem.Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - ChatSystem.DragStart
            mainFrame.Position = UDim2.new(
                ChatSystem.StartPos.X.Scale, ChatSystem.StartPos.X.Offset + delta.X,
                ChatSystem.StartPos.Y.Scale, ChatSystem.StartPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Minimize toggle
    minBtn.MouseButton1Click:Connect(function()
        if mainFrame.Size == UDim2.new(0, 380, 0, 460) then
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 380, 0, 36)
            }):Play()
            minBtn.Text = "+"
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0, 380, 0, 460)
            }):Play()
            minBtn.Text = "—"
        end
    end)

    -- Send message handler
    local function handleSend()
        local text = inputBox.Text
        if type(text) ~= "string" or text == "" then return end
        inputBox.Text = ""
        Chat_AddMessage("USER", text)

        if ChatSystem.AwaitingReply and ChatSystem.ReplyCallback then
            ChatSystem.AwaitingReply = false
            local cb = ChatSystem.ReplyCallback
            ChatSystem.ReplyCallback = nil
            pcall(cb, text)
        else
            AI_ProcessUserMessage(text)
        end
    end

    sendBtn.MouseButton1Click:Connect(handleSend)
    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then handleSend() end
    end)

    ChatSystem.IsOpen = true
end

-- Add a message to the chat
function Chat_AddMessage(sender, text, color)
    if not ChatSystem.ScrollFrame then return end
    if type(text) ~= "string" then text = tostring(text) end

    ChatSystem.MessageCount = ChatSystem.MessageCount + 1
    local msgFrame = Instance.new("Frame")
    msgFrame.Name = "Msg_" .. ChatSystem.MessageCount
    msgFrame.Size = UDim2.new(1, -8, 0, 0)
    msgFrame.AutomaticSize = Enum.AutomaticSize.Y
    msgFrame.BackgroundTransparency = 1
    msgFrame.LayoutOrder = ChatSystem.MessageCount
    msgFrame.Parent = ChatSystem.ScrollFrame

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Size = UDim2.new(1, -8, 0, 0)
    msgLabel.Position = UDim2.new(0, 4, 0, 0)
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextWrapped = true
    msgLabel.TextSize = 11
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.Parent = msgFrame

    local prefix = ""
    local textColor = color or TextColor

    if sender == "AI" then
        prefix = "[SENTINEL] "
        textColor = color or AccentColor
    elseif sender == "USER" then
        prefix = "[YOU] "
        textColor = color or Color3.fromRGB(255, 255, 100)
    elseif sender == "SYSTEM" then
        prefix = "[SYSTEM] "
        textColor = color or Color3.fromRGB(255, 80, 80)
    end

    msgLabel.Text = prefix .. text
    msgLabel.TextColor3 = textColor

    -- Auto scroll to bottom
    task.defer(function()
        if ChatSystem.ScrollFrame then
            ChatSystem.ScrollFrame.CanvasPosition = Vector2.new(0, ChatSystem.ScrollFrame.AbsoluteCanvasSize.Y)
        end
    end)
end

-- Robot animation sequences
local function Robot_SetState(state)
    if type(state) ~= "string" then state = "IDLE" end
    RobotAnim.State = state
    if not ChatSystem.StatusLabel then return end

    if state == "READING" then
        ChatSystem.StatusLabel.Text = "ANALYZING KILL REPORT...\nScanning threat patterns..."
        task.spawn(function()
            for i = 1, 3 do
                if RobotAnim.Eyes then
                    for _, eye in ipairs(RobotAnim.Eyes) do
                        TweenService:Create(eye, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 200, 0)}):Play()
                    end
                    task.wait(0.2)
                    for _, eye in ipairs(RobotAnim.Eyes) do
                        TweenService:Create(eye, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    end
                    task.wait(0.2)
                end
            end
        end)

    elseif state == "THINKING" then
        ChatSystem.StatusLabel.Text = "FORMULATING COUNTER-STRATEGY...\nCross-referencing threat database..."
        if RobotAnim.Eyes then
            for _, eye in ipairs(RobotAnim.Eyes) do
                TweenService:Create(eye, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    BackgroundColor3 = Color3.fromRGB(0, 255, 200)
                }):Play()
            end
        end

    elseif state == "THUMBSUP" then
        ChatSystem.StatusLabel.Text = "ANALYSIS COMPLETE ✓\nStrategy ready. Opening chat..."
        if RobotAnim.Arm then
            TweenService:Create(RobotAnim.Arm, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, 2, 0, -5),
                Rotation = -30,
            }):Play()
        end
        if RobotAnim.Eyes then
            for _, eye in ipairs(RobotAnim.Eyes) do
                TweenService:Create(eye, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 255, 100)}):Play()
            end
        end

    elseif state == "TALKING" then
        ChatSystem.StatusLabel.Text = "SENTINEL ONLINE\nReady for your commands."
        if RobotAnim.Eyes then
            for _, eye in ipairs(RobotAnim.Eyes) do
                TweenService:Create(eye, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            end
        end
        if RobotAnim.Arm then
            TweenService:Create(RobotAnim.Arm, TweenInfo.new(0.3), {
                Position = UDim2.new(1, 2, 0, 15),
                Rotation = 0,
            }):Play()
        end

    elseif state == "IDLE" then
        ChatSystem.StatusLabel.Text = "SENTINEL ONLINE\nAwaiting combat data..."
    end
end
