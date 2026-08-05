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

-- Validate state initialization
local _state_init_ok, _state_init_err = pcall(function()
    if type(Aura) ~= "table" then warn("[EXO] Aura state invalid") end
    if type(AntiAura) ~= "table" then warn("[EXO] AntiAura state invalid") end
    if type(ToolFollow) ~= "table" then warn("[EXO] ToolFollow state invalid") end
    if type(IK_ToolsCache) ~= "table" then warn("[EXO] IK_ToolsCache invalid") end
    if type(HA_CachedTools) ~= "table" then warn("[EXO] HA_CachedTools invalid") end
    if type(TG_padsByBase) ~= "table" then warn("[EXO] TG_padsByBase invalid") end
    if type(KillLogs) ~= "table" then warn("[EXO] KillLogs invalid") end
    if type(DeathTimestamps) ~= "table" then warn("[EXO] DeathTimestamps invalid") end
    if type(ThreatHistory) ~= "table" then warn("[EXO] ThreatHistory invalid") end
end)
if not _state_init_ok then
    warn("[EXO] STATE INIT EXCEPTION: " .. tostring(_state_init_err))
end

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

-- Validate AI structures
local _ai_init_ok, _ai_init_err = pcall(function()
    if type(AI_State) ~= "table" then warn("[EXO] AI_State invalid") end
    if type(ThreatProfiles) ~= "table" then ThreatProfiles = {}; warn("[EXO] ThreatProfiles reset") end
    if type(AIMemory) ~= "table" then AIMemory = {StrategyResults={}, FeatureEffectiveness={}, OpponentAdaptations={}, SessionLearningRate=0.1}; warn("[EXO] AIMemory reset") end
    if type(StrategyEngine) ~= "table" then warn("[EXO] StrategyEngine invalid") end
    if type(ChatSystem) ~= "table" then warn("[EXO] ChatSystem invalid") end
    if type(RobotAnim) ~= "table" then warn("[EXO] RobotAnim invalid") end
end)
if not _ai_init_ok then
    warn("[EXO] AI INIT EXCEPTION: " .. tostring(_ai_init_err))
end

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

-- Pre-allocate buffer capacity hints (Luau optimization)
local _buf_prealloc_ok, _buf_prealloc_err = pcall(function()
    table.create(100, nil) -- Warm up allocator
    table.clear(_buf_parts)
    table.clear(_buf_buttons)
    table.clear(_buf_wave)
    table.clear(_buf_targets)
    table.clear(_buf_tools)
    table.clear(_buf_players)
    table.clear(_buf_remotes)
    table.clear(_buf_analysis)
    table.clear(_buf_hitboxes)
    table.clear(_buf_velocities)
end)
if not _buf_prealloc_ok then
    warn("[EXO] BUFFER PREALLOC EXCEPTION: " .. tostring(_buf_prealloc_err))
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 9: DEFERRED HEAVY SCANS (NON-BLOCKING)                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local scansComplete = false
task.spawn(function()
    local scan_start = tick()
    
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
    local scan_duration = tick() - scan_start
    print("[EXO] Deferred scans completed in " .. string.format("%.3f", scan_duration) .. "s")
    print("[EXO] Remotes found: " .. #_buf_remotes)
    print("[EXO] Tycoon bases registered: " .. tostring(#TG_padsByBase))
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
    if not model then return _buf_parts end
    local descendants_ok, descendants = pcall(function() return model:GetDescendants() end)
    if not descendants_ok or type(descendants) ~= "table" then return _buf_parts end
    
    for _, desc in ipairs(descendants) do
        if desc:IsA("TouchTransmitter") and desc.Parent and desc.Parent:IsA("BasePart") then
            table.insert(_buf_parts, desc.Parent)
        end
    end
    if #_buf_parts == 0 then
        for _, desc in ipairs(descendants) do
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
            if v and (v:IsA("IntValue") or v:IsA("NumberValue")) then 
                local val_ok, val = pcall(function() return v.Value end)
                if val_ok and type(val) == "number" then return val end
            end
        end
    end
    return 0
end

local function getCost(obj)
    if not obj then return 0 end
    local pv = obj:FindFirstChild("Price") or obj:FindFirstChild("Cost") or obj:FindFirstChild("Value")
    if pv and (pv:IsA("IntValue") or pv:IsA("NumberValue")) then 
        local val_ok, val = pcall(function() return pv.Value end)
        if val_ok and type(val) == "number" then return val end
    end
    local attr_ok, attr = pcall(function() return obj:GetAttribute("Price") or obj:GetAttribute("Cost") end)
    if attr_ok and type(attr) == "number" then return attr end
    return 0
end

local function getPriority(modelName)
    if type(modelName) ~= "string" then return 90 end
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
    local players_ok, players_list = pcall(function() return Players:GetPlayers() end)
    if not players_ok or type(players_list) ~= "table" then return {"No Players"} end
    
    for _, p in ipairs(players_list) do
        if p ~= player then 
            local name_ok, name = pcall(function() return p.Name end)
            if name_ok and type(name) == "string" then table.insert(_buf_players, name) end
        end
    end
    return #_buf_players > 0 and _buf_players or {"No Players"}
end

local function getToolPart(tool)
    if not tool then return nil end
    local handle = tool:FindFirstChild("Handle")
    if handle and handle:IsA("BasePart") then return handle end
    local descendants_ok, descendants = pcall(function() return tool:GetDescendants() end)
    if descendants_ok and type(descendants) == "table" then
        for _, v in ipairs(descendants) do 
            if v:IsA("BasePart") then return v end 
        end
    end
    return nil
end

local function getHRP(char)
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then return hrp end
    local torso = char:FindFirstChild("Torso")
    if torso then return torso end
    return nil
end
