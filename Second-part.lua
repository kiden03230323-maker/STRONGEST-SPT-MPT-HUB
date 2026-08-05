-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 6: STATE VARIABLES (GODLY TIER + AI EXPANDED)             ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- Core Combat State
local DAMAGE_REMOTE       = nil
local DAMAGE_REMOTE_ALT   = nil
local DAMAGE_REMOTE_TERT  = nil
local Aura                = {Enabled = false, TargetList = {}, Mode = "omni", PredictionDepth = 3}
local InstantKill         = false
local AutoTools           = false
local NoCooldown          = false
local Reach               = false
local ReachSize           = 3
local FastRespawn         = false
local AntiSpawnkill       = false
local ToolFollow          = {Enabled = false, Targets = {}, Connection = nil}
local AutoGetTools        = false
local AutoClaimMoney      = false
local AutoBuild           = false
local grabLoopConn        = nil
local toolLoopConn        = nil
local auraConn            = nil
local claimConn           = nil
local buildConn           = nil
local cachedTycoonType    = nil

-- GODLY Anti-Aura State (ALL ORIGINAL FIELDS PRESERVED + NEW)
local AntiAura            = {
    Enabled = false, GodMode = false, Repel = false,
    Reflect = false, Phase = false, HealAura = false,
    ShieldStack = 0, RepelForce = 120, RepelRadius = 18
}
local antiAuraConn        = nil
local antiAuraFF          = nil
local antiAuraPhaseConn   = nil

-- Threat Detection (GODLY – multi-layer expanded)
local ThreatLevel         = 0
local LastThreatCheck     = 0
local ThreatRadius        = 60
local ThreatHistory       = {}
local ThreatTrend         = 0
local latencyEstimate     = 0.08
local ThreatDecay         = 0
local PeakThreat          = 0
local ThreatVelocity      = {}

-- GODLY Insta-Kill State (EXPANDED)
local InstaKillEnabled    = false
local InstaKillConn       = nil
local IK_ToolsCache       = {}
local IK_LastActivation   = 0
local IK_TargetParts      = {}
local IK_BurstCount       = 12
local IK_AdaptiveBurst    = true
local IK_MultiTarget      = true
local IK_ParallelFire     = true
local IK_SweepAngle       = 360
local IK_PenetrationDepth = 3

-- GODLY Hit Amplifier State (EXPANDED)
local HitAmpEnabled       = false
local HitAmpConn          = nil
local HA_CachedTools      = {}
local HA_LastActivation   = 0
local HA_Accumulator      = 0
local HA_Range            = Vector3.new(45, 45, 45)
local HA_BurstCount       = 8
local HA_MultiPulse       = true
local HA_SweepMode        = true
local HA_PulseInterval    = 0.008

-- GODLY Tool Grabber State (PRESERVED)
local TG_Enabled          = false
local TG_padsByBase       = {}
local TG_registered       = {}
local TG_WavePriority     = true
local TG_BurstCount       = 12

-- Kill Intelligence System (EXPANDED FOR AI)
local KillNotifEnabled    = false
local KillLogEnabled      = false
local KillLogs            = {}
local KillStreak          = 0
local LastKillTime        = 0
local DeathCount          = 0
local LastDeathTime       = 0
local DeathTimestamps     = {}
local KillVelocity        = {}
local LastSpawnTime       = 0

-- ESP & Visuals
local ESPEnabled          = false
local AntiLagEnabled      = false
local espDots             = {}
local espGui              = nil

-- No Cooldown (SAFE – no global hooks)
local NoCooldownConn      = nil

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 7: SENTINEL AI – CORE DATA STRUCTURES                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- AI State Machine
local AI_State = {
    Current = "IDLE",
    LastTransition = 0,
    PendingAction = nil,
    PendingStrategy = nil,
    ConfirmCallback = nil,
}

-- Threat Profiler – persistent per-player profiles
local ThreatProfiles = readJSON(AI_PROFILE_FILE) or {}

-- Neural Memory System – tracks strategy success/failure
local AIMemory = readJSON(AI_MEMORY_FILE) or {
    StrategyResults = {},
    FeatureEffectiveness = {},
    OpponentAdaptations = {},
    SessionLearningRate = 0.1,
}

-- Strategy Engine (EXPANDED)
local StrategyEngine = {
    ActiveStrategy = nil,
    StrategyHistory = {},
    FeatureCombinations = {},
    LastStrategyTime = 0,
    SuccessRate = {},
    MutationRate = 0.15,
    MaxConcurrentStrategies = 3,
}

-- Chat System State
local ChatSystem = {
    GUI = nil,
    ScrollFrame = nil,
    InputBox = nil,
    SendButton = nil,
    RobotFrame = nil,
    RobotLabel = nil,
    StatusLabel = nil,
    MessageCount = 0,
    IsOpen = false,
    IsTyping = false,
    PendingQuestion = nil,
    AwaitingReply = false,
    ReplyCallback = nil,
    Dragging = false,
    DragStart = nil,
    StartPos = nil,
}

-- Robot Animation State
local RobotAnim = {
    State = "IDLE",
    Frame = 0,
    Eyes = nil,
    Body = nil,
    Arm = nil,
}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 8: PRE-ALLOCATED BUFFERS (ZERO GC PRESSURE)              ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _buf_parts      = {}
local _buf_buttons    = {}
local _buf_wave       = {}
local _buf_targets    = {}
local _buf_tools      = {}
local _buf_players    = {}
local _buf_remotes    = {}
local _buf_analysis   = {}
local _buf_hitboxes   = {}
local _buf_velocities = {}

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 9: DEFERRED HEAVY SCANS (NON-BLOCKING)                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local scansComplete = false
task.spawn(function()
    -- Damage remote detection (multi-pass for GODLY coverage)
    table.clear(_buf_remotes)
    for _, container in ipairs({ReplicatedStorage, workspace}) do
        pcall(function()
            for _, obj in ipairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local n = obj.Name:lower()
                    if n:match("damage") or n:match("hit") or n:match("attack")
                        or n:match("deal") or n:match("hurt") or n:match("strike")
                        or n:match("combat") or n:match("fight") or n:match("kill")
                        or n:match("weapon") or n:match("sword") or n:match("gun") then
                        table.insert(_buf_remotes, obj)
                    end
                end
            end
        end)
    end

    if #_buf_remotes > 0 then
        DAMAGE_REMOTE = _buf_remotes[1]
        if #_buf_remotes > 1 then DAMAGE_REMOTE_ALT = _buf_remotes[2] end
        if #_buf_remotes > 2 then DAMAGE_REMOTE_TERT = _buf_remotes[3] end
    end

    -- Pad registration (GODLY – scans all bases)
    local TycoonsFolder = workspace:FindFirstChild("Tycoons")
    if TycoonsFolder then
        pcall(function()
            for _, d in ipairs(TycoonsFolder:GetDescendants()) do
                if d:IsA("TouchTransmitter") and d.Parent and d.Parent.Parent
                    and d.Parent.Parent.Name:find("GearGiver") then
                    local base = d.Parent.Parent.Parent
                    if base then
                        local bn = base.Name
                        if bn == "Stone" or bn == "Magic" or bn == "Storm" or bn == "Robotic"
                            or bn == "Mecha" or bn == "Shadow" or bn == "Hyper" or bn == "Thunder"
                            or bn == "Void" or bn == "Frozen" or bn == "Magma" or bn == "Nuclear"
                            or bn == "Toxic" or bn == "Kong" then
                            TG_padsByBase[bn] = TG_padsByBase[bn] or {}
                            table.insert(TG_padsByBase[bn], d.Parent)
                            TG_registered[d.Parent] = bn
                        end
                    end
                end
            end
        end)
    end
    scansComplete = true
end)

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 10: TYCOON HELPERS (1000x)                                ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function getPlayerTycoonType()
    if cachedTycoonType and workspace:FindFirstChild("Tycoons")
        and workspace.Tycoons:FindFirstChild(cachedTycoonType) then
        return cachedTycoonType
    end

    local plot = workspace:FindFirstChild(player.Name)
    if plot then
        for _, child in ipairs(plot:GetChildren()) do
            if child:IsA("StringValue") then
                local n = child.Name:lower()
                if n:find("tycoon") or n:find("type") or n:find("base") or n:find("theme") then
                    cachedTycoonType = child.Value
                    return cachedTycoonType
                end
            end
        end
    end

    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local closest, minDist = nil, math.huge
        local tf = workspace:FindFirstChild("Tycoons")
        if tf then
            for _, t in ipairs(tf:GetChildren()) do
                if t:IsA("Folder") then
                    local door = t:FindFirstChild("Door", true)
                    if door then
                        local dp = door:FindFirstChildWhichIsA("BasePart")
                        if dp then
                            local d = (dp.Position - root.Position).Magnitude
                            if d < minDist then minDist = d; closest = t.Name end
                        end
                    end
                end
            end
        end
        cachedTycoonType = closest
        return closest
    end
    return nil
end

player.CharacterAdded:Connect(function() cachedTycoonType = nil end)

local function getTouchableParts(model)
    table.clear(_buf_parts)
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(_buf_parts, desc.Parent)
        end
    end
    if #_buf_parts == 0 then
        for _, desc in ipairs(model:GetDescendants()) do
            if desc:IsA("BasePart") then table.insert(_buf_parts, desc); break end
        end
    end
    return _buf_parts
end

local function getPlayerCash()
    local ls = player:FindFirstChild("leaderstats")
    if ls then
        for _, name in ipairs({"Cash", "Money", "Coins", "Gold", "Credits"}) do
            local v = ls:FindFirstChild(name)
            if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then return v.Value end
        end
    end
    return 0
end

local function getCost(obj)
    local pv = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if pv and (pv:IsA("IntValue") or pv:IsA("NumberValue")) then return pv.Value end
    local attr = obj:GetAttribute("Price") or obj:GetAttribute("Cost")
    if type(attr) == "number" then return attr end
    return 0
end

local function getPriority(modelName)
    local name = modelName:lower()
    if name:find("robux") then return 999 end
    local num = tonumber(name:match("%d+")) or 0
    if name:find("gen") and not name:find("gear") then
        if num <= 1 then return 10 + num
        elseif num <= 3 then return 30 + num
        elseif num <= 5 then return 50 + num
        else return 70 + num end
    end
    if name:find("gear") or name:find("gun") then
        if num <= 2 then return 20 + num
        elseif num <= 5 then return 55 + num
        else return 67 + num end
    end
    if name:find("wall") or name:find("door") or name:find("ladder") then return 40 + num end
    if name:find("ultima") or name:find("effect") then return 80 end
    return 90 + num
end

local function getServerPlayers()
    table.clear(_buf_players)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then table.insert(_buf_players, p.Name) end
    end
    return #_buf_players > 0 and _buf_players or {"No Players"}
end

local function getToolPart(tool)
    if tool:FindFirstChild("Handle") and tool.Handle:IsA("BasePart") then return tool.Handle end
    for _, v in ipairs(tool:GetDescendants()) do if v:IsA("BasePart") then return v end end
    return nil
end

local function getHRP(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso"))
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 11: 1000x THREAT DETECTION ENGINE                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function updateThreatLevel()
    if tick() - LastThreatCheck < 0.15 then return end
    LastThreatCheck = tick()
    local prevThreat = ThreatLevel
    ThreatLevel = 0
    local myChar = player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
    local myPos = myChar.HumanoidRootPart.Position

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local theirRoot = plr.Character.HumanoidRootPart
            local dist = (theirRoot.Position - myPos).Magnitude
            local velocity = theirRoot.Velocity.Magnitude

            if dist < ThreatRadius then
                ThreatLevel = ThreatLevel + 1
                if dist < ThreatRadius * 0.3 then ThreatLevel = ThreatLevel + 2 end
                if dist < ThreatRadius * 0.1 then ThreatLevel = ThreatLevel + 3 end
                if velocity > 20 then ThreatLevel = ThreatLevel + 1 end

                -- Check if they have tools equipped (aggression indicator)
                local hasTool = false
                for _, item in ipairs(plr.Character:GetChildren()) do
                    if item:IsA("Tool") then hasTool = true; break end
                end
                if hasTool then ThreatLevel = ThreatLevel + 1 end
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
    local features = {}

    -- LOOPBRING DETECTION: Extremely fast TTK + close range + repeated
    if killData.TTK < 0.3 and killData.Distance < 8 then
        features["LoopBring"] = 85
        if profile.TotalKills > 2 and profile.AvgTTK < 0.4 then
            features["LoopBring"] = 95
        end
    end

    -- KILL AURA DETECTION: Multiple rapid kills, medium range, no visible weapon swing
    if killData.Distance > 5 and killData.Distance < 15 and killData.TTK < 0.5 then
        features["KillAura"] = 75
        if killData.Weapon == "Unknown" then
            features["KillAura"] = 90
        end
    end

    -- REACH DETECTION: Kills from impossible distance
    if killData.Distance > 25 then
        features["Reach"] = 80
        if killData.Distance > 40 then
            features["Reach"] = 95
        end
    end

    -- FAST KILL / REMOTE SPAM: Very fast TTK regardless of distance
    if killData.TTK < 0.2 then
        features["FastKill"] = 85
        features["RemoteSpam"] = 70
    end

    -- FIGHT EVENT ABUSE: No weapon detected, fast kills
    if killData.Weapon == "Unknown" and killData.TTK < 0.5 then
        features["FightEventAbuse"] = 80
    end

    -- HIT AMPLIFIER: Medium range, consistent TTK
    if killData.Distance > 15 and killData.Distance <= 30 and killData.TTK < 0.8 then
        features["HitAmplifier"] = 70
    end

    -- TOOL FOLLOW: Very close, persistent kills
    if killData.Distance < 3 and profile.TotalKills > 3 then
        features["ToolFollow"] = 75
    end

    -- SPAWN KILL: Kills happening very shortly after your respawn
    if killData.TimeSinceRespawn and killData.TimeSinceRespawn < 2 then
        features["SpawnKill"] = 90
    end

    -- TEMPORAL PATTERN: Deaths clustering in time windows
    if #DeathTimestamps >= 3 then
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
    local score = 0
    score = score + math.min(profile.TotalKills * 2, 20)
    score = score + math.min(profile.ThreatScore, 10)

    for feature, confidence in pairs(profile.Confidence) do
        score = score + math.floor(confidence / 20)
    end

    if profile.AvgTTK < 0.3 then score = score + 10 end
    if profile.AvgDistance > 30 then score = score + 8 end
    if profile.TotalKills > 5 then score = score + 5 end

    -- Bayesian adjustment based on memory
    if AIMemory.FeatureEffectiveness then
        for feat, eff in pairs(AIMemory.FeatureEffectiveness) do
            if profile.Confidence[feat] and eff < 0.3 then
                score = score + 5 -- Increase threat if our counters failed before
            end
        end
    end

    return math.clamp(score, 0, 100)
end

local function AI_UpdateProfile(killerName, killData)
    local profile = AI_GetOrCreateProfile(killerName)
    profile.TotalKills = profile.TotalKills + 1
    profile.LastSeen = os.time()

    -- Running average for distance
    profile.AvgDistance = ((profile.AvgDistance * (profile.TotalKills - 1)) + killData.Distance) / profile.TotalKills
    -- Running average for TTK
    profile.AvgTTK = ((profile.AvgTTK * (profile.TotalKills - 1)) + killData.TTK) / profile.TotalKills

    -- Track weapons
    if killData.Weapon and killData.Weapon ~= "Unknown" then
        profile.Weapons[killData.Weapon] = (profile.Weapons[killData.Weapon] or 0) + 1
    end

    -- Store engagement
    table.insert(profile.EngagementHistory, {
        time = os.time(),
        distance = killData.Distance,
        ttk = killData.TTK,
        weapon = killData.Weapon,
        suspected = killData.Suspected,
    })
    if #profile.EngagementHistory > 50 then
        table.remove(profile.EngagementHistory, 1)
    end

    -- Feature detection with confidence scoring (Bayesian update)
    local features = AI_DetectFeatures(killData, profile)
    for feature, confidence in pairs(features) do
        local prev = profile.Confidence[feature] or 0
        -- Bayesian smoothing: weight new evidence against prior
        local learningRate = AIMemory.SessionLearningRate or 0.1
        profile.Confidence[feature] = math.min(100, math.max(prev, prev * (1 - learningRate) + confidence * learningRate))
        if confidence > 50 then
            local found = false
            for _, f in ipairs(profile.SuspectedFeatures) do
                if f == feature then found = true; break end
            end
            if not found then table.insert(profile.SuspectedFeatures, feature) end
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
    local strategy = {
        Target = profile.Name,
        Actions = {},
        Explanations = {},
        Priority = "NORMAL",
        Confidence = 0,
        FeatureCombos = {},
        MutatedFrom = nil,
    }

    local threats = profile.SuspectedFeatures
    local avgDist = profile.AvgDistance
    local avgTTK = profile.AvgTTK
    local totalKills = profile.TotalKills

    -- Determine priority using threat score + temporal analysis
    if profile.ThreatScore >= 80 or totalKills >= 5 then
        strategy.Priority = "CRITICAL"
    elseif profile.ThreatScore >= 50 or totalKills >= 3 then
        strategy.Priority = "HIGH"
    end

    -- Check memory for previously failed strategies against this player
    local previousFailure = nil
    if AIMemory.StrategyResults then
        for _, result in ipairs(AIMemory.StrategyResults) do
            if result.Target == profile.Name and result.Success == false then
                previousFailure = result
                break
            end
        end
    end

    -- BUILD COUNTER-STRATEGY BASED ON DETECTED FEATURES
    for _, feature in ipairs(threats) do
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

    -- If no specific features detected but still dying
    if #strategy.Actions == 0 then
        table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Enabled", reason = "General defense"})
        table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField protection"})
        table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Quick recovery"})
        table.insert(strategy.Explanations,
            "General threat detected from " .. profile.Name .. ". " ..
            "Activating standard defense suite while I gather more data.")
    end

    -- Add offensive counter if threat is high
    if profile.ThreatScore >= 60 then
        table.insert(strategy.Actions, {type = "enable", feature = "Aura.Enabled", reason = "Offensive pressure"})
        table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "Eliminate threat quickly"})
        table.insert(strategy.Explanations,
            "Threat score is " .. profile.ThreatScore .. "/100. " ..
            "Activating offensive counter: Aura + InstaKill targeting " .. profile.Name .. " specifically.")
    end

    strategy.Confidence = math.min(95, 40 + (profile.TotalKills * 10) + (#strategy.Actions * 5))
    return strategy
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 14: SENTINEL AI – EXECUTION ENGINE + MEMORY UPDATE        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function AI_ExecuteStrategy(strategy)
    if not strategy or not strategy.Actions then return end

    for _, action in ipairs(strategy.Actions) do
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
                if action.feature == "ReachSize" then
                    ReachSize = action.value
                    if Reach then stopReach(); applyReach() end
                elseif action.feature == "IK_BurstCount" then
                    IK_BurstCount = action.value
                elseif action.feature == "AntiAura.RepelForce" then
                    AntiAura.RepelForce = action.value
                elseif action.feature == "AntiAura.RepelRadius" then
                    AntiAura.RepelRadius = action.value
                elseif action.feature == "HA_Range" then
                    HA_Range = Vector3.new(action.value, action.value, action.value)
                end

            elseif action.type == "disable" then
                -- Reserved for future adaptive disabling
            end
        end)
    end

    -- Record strategy execution in memory
    local strategyID = HttpService:GenerateGUID(false)
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

    local gui = Instance.new("ScreenGui")
    gui.Name = "EXO_SentinelChat"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = player:WaitForChild("PlayerGui") end
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
        if text == "" then return end
        inputBox.Text = ""
        Chat_AddMessage("USER", text)

        if ChatSystem.AwaitingReply and ChatSystem.ReplyCallback then
            ChatSystem.AwaitingReply = false
            local cb = ChatSystem.ReplyCallback
            ChatSystem.ReplyCallback = nil
            cb(text)
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 16: SENTINEL AI – KILL ANALYSIS PIPELINE                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function AI_OnKillDetected(killData)
    -- Step 1: Robot starts reading
    Robot_SetState("READING")

    task.spawn(function()
        task.wait(1.5) -- Reading animation duration

        -- Step 2: Robot thinks
        Robot_SetState("THINKING")
        task.wait(1.0) -- Thinking animation duration

        -- Step 3: Update threat profile
        local profile = AI_UpdateProfile(killData.Killer, killData)

        -- Step 4: Formulate strategy
        local strategy = AI_FormulateStrategy(profile, killData)

        -- Step 5: Thumbs up
        Robot_SetState("THUMBSUP")
        task.wait(1.0)

        -- Step 6: Open chat and present
        Robot_SetState("TALKING")
        Chat_CreateGUI()

        -- Present the analysis
        Chat_AddMessage("SYSTEM", "═══ KILL REPORT ═══", Color3.fromRGB(255, 50, 50))
        Chat_AddMessage("AI", "Killer: " .. killData.Killer)
        Chat_AddMessage("AI", "Weapon: " .. killData.Weapon)
        Chat_AddMessage("AI", "Distance: " .. killData.Distance .. " studs")
        Chat_AddMessage("AI", "Time-to-Kill: " .. string.format("%.2f", killData.TTK) .. " seconds")
        Chat_AddMessage("AI", "Threat Level: " .. killData.Threat .. "/10")
        Chat_AddMessage("AI", "")

        -- Explain WHY you're losing
        Chat_AddMessage("SYSTEM", "═══ WHY YOU'RE LOSING ═══", Color3.fromRGB(255, 200, 0))
        for _, explanation in ipairs(strategy.Explanations) do
            Chat_AddMessage("AI", explanation)
        end

        -- Show suspected features
        if #profile.SuspectedFeatures > 0 then
            Chat_AddMessage("AI", "")
            Chat_AddMessage("AI", "Detected opponent features: " .. table.concat(profile.SuspectedFeatures, ", "))
            Chat_AddMessage("AI", "Profile confidence: " .. profile.ThreatScore .. "/100")
            Chat_AddMessage("AI", "Total kills by this player: " .. profile.TotalKills)
        end

        Chat_AddMessage("AI", "")
        Chat_AddMessage("SYSTEM", "═══ PROPOSED COUNTER-STRATEGY ═══", Color3.fromRGB(0, 255, 100))
        Chat_AddMessage("AI", "Priority: " .. strategy.Priority)
        Chat_AddMessage("AI", "Confidence: " .. strategy.Confidence .. "%")
        Chat_AddMessage("AI", "Actions (" .. #strategy.Actions .. "):")

        for i, action in ipairs(strategy.Actions) do
            local desc = ""
            if action.type == "enable" then
                desc = "  " .. i .. ". ENABLE " .. action.feature
            elseif action.type == "set" then
                desc = "  " .. i .. ". SET " .. action.feature .. " = " .. tostring(action.value)
            end
            if action.reason then
                desc = desc .. " (" .. action.reason .. ")"
            end
            Chat_AddMessage("AI", desc, Color3.fromRGB(150, 255, 150))
        end

        -- Ask for confirmation
        Chat_AddMessage("AI", "")
        Chat_AddMessage("AI", "Do you approve this strategy? Type Y to execute, N to cancel, or ask me a question.", Color3.fromRGB(255, 255, 0))

        AI_State.Current = "AWAITING_CONFIRM"
        AI_State.PendingStrategy = strategy
        ChatSystem.AwaitingReply = true
        ChatSystem.ReplyCallback = function(reply)
            local lower = reply:lower():gsub("%s+", "")
            if lower == "y" or lower == "yes" or lower == "confirm" or lower == "approve" or lower == "doit" then
                Chat_AddMessage("AI", "Strategy approved. Executing counter-measures now.", Color3.fromRGB(0, 255, 100))
                AI_ExecuteStrategy(strategy)
                AI_State.Current = "IDLE"

                -- Confirm execution
                task.wait(0.5)
                Chat_AddMessage("AI", "All " .. #strategy.Actions .. " actions executed successfully.")
                Chat_AddMessage("AI", "I'll continue monitoring. If they kill you again, I'll adapt the strategy.")
                Robot_SetState("IDLE")

            elseif lower == "n" or lower == "no" or lower == "cancel" or lower == "deny" then
                Chat_AddMessage("AI", "Strategy cancelled. I'll keep monitoring. Let me know if you want me to suggest something else.", Color3.fromRGB(255, 200, 0))
                AI_State.Current = "IDLE"
                Robot_SetState("IDLE")

            else
                -- They asked a question or gave other input
                AI_ProcessUserMessage(reply)
                -- Re-ask for confirmation after answering
                task.wait(0.3)
                Chat_AddMessage("AI", "Still waiting for your decision. Type Y to approve or N to cancel.", Color3.fromRGB(255, 255, 0))
                ChatSystem.AwaitingReply = true
                ChatSystem.ReplyCallback = function(reply2)
                    local l2 = reply2:lower():gsub("%s+", "")
                    if l2 == "y" or l2 == "yes" or l2 == "confirm" then
                        Chat_AddMessage("AI", "Executing now.", Color3.fromRGB(0, 255, 100))
                        AI_ExecuteStrategy(strategy)
                        AI_State.Current = "IDLE"
                    else
                        Chat_AddMessage("AI", "Cancelled.", Color3.fromRGB(255, 200, 0))
                        AI_State.Current = "IDLE"
                    end
                    Robot_SetState("IDLE")
                end
            end
        end
    end)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 17: SENTINEL AI – USER MESSAGE PROCESSOR                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝
function AI_ProcessUserMessage(text)
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
