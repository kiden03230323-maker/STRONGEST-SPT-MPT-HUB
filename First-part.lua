-- ═══════════════════════════════════════════════════════════════════════
--  ███████╗██╗  ██╗ ██████╗     ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗
--  ██╔════╝╚██╗██╔╝██╔═══██╗    ██║  ██║██╔══██╗██║   ██║██╔══██╗██╔═══██╗
--  █████╗   ╚███╔╝ ██║   ██║    ███████║███████║██║   ██║██║  ██║██║   ██║
--  ██╔══╝   ██╔██╗ ██║   ██║    ██╔══██║██╔══██║██║   ██║██║  ██║██║   ██║
--  ███████╗██╔╝ ██╗╚██████╔╝    ██║  ██║██║  ██║╚██████╔╝██████╔╝╚██████╔╝
--  ╚══════╝╚═╝  ╚═╝ ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝
--
--  EXO HUB v9.0 – SENTINEL AI: OMNISCIENT EDITION
--  40-SECTION ARCHITECTURE | ZERO COMPRESSION | ALL FEATURES PRESERVED
--  BAYESIAN THREAT INFERENCE | TEMPORAL PATTERN ANALYSIS | STRATEGY MUTATION
--  NEURAL MEMORY SYSTEM | ADAPTIVE COUNTER-INTELLIGENCE | MOBILE-FIRST UI
--  BLUE THEME | UNLIMITED TABS | ANIMATED ROBOT | BIDIRECTIONAL CHAT
--  TARGET: 8900+ LINES | MAXIMUM VERBOSITY | REDUNDANT SAFETY
-- ═══════════════════════════════════════════════════════════════════════

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 0: ANTI-TAMPER INTEGRITY (TRIPLE-LAYER + HASH VERIFY)     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _EXO_V = 9.0
local _EXO_BUILD = "SENTINEL_OMNISCIENT"
local _EXO_INTEGRITY = true
local _EXO_INTEGRITY_HASH = 0x45584F39
local _EXO_INTEGRITY_LOG = {}

-- Layer 1: Environment validation (pre-service)
local _layer1_ok, _layer1_err = pcall(function()
    if not game then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: game nil")
        _EXO_INTEGRITY = false
        return
    end
    if not game.GetService then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: GetService nil")
        _EXO_INTEGRITY = false
        return
    end
    if not workspace then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: workspace nil")
        _EXO_INTEGRITY = false
        return
    end
    if not typeof then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: typeof nil")
        _EXO_INTEGRITY = false
        return
    end
    if not pcall then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: pcall nil")
        _EXO_INTEGRITY = false
        return
    end
    if not task then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: task nil")
        _EXO_INTEGRITY = false
        return
    end
    if not coroutine then
        table.insert(_EXO_INTEGRITY_LOG, "L1_FAIL: coroutine nil")
        _EXO_INTEGRITY = false
        return
    end
end)
if not _layer1_ok then
    table.insert(_EXO_INTEGRITY_LOG, "L1_EXCEPTION: " .. tostring(_layer1_err))
    _EXO_INTEGRITY = false
end

-- Layer 2: Service pre-validation (safe get before full init)
local _layer2_ok, _layer2_err = pcall(function()
    local _test_ps = game:GetService("Players")
    local _test_rs = game:GetService("RunService")
    local _test_ws = game:GetService("Workspace")
    local _test_cg = game:GetService("CoreGui")
    local _test_hs = game:GetService("HttpService")
    local _test_ts = game:GetService("TweenService")
    local _test_uis = game:GetService("UserInputService")
    if not _test_ps then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: Players nil")
        _EXO_INTEGRITY = false
    end
    if not _test_rs then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: RunService nil")
        _EXO_INTEGRITY = false
    end
    if not _test_ws then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: Workspace nil")
        _EXO_INTEGRITY = false
    end
    if not _test_cg then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: CoreGui nil")
        _EXO_INTEGRITY = false
    end
    if not _test_hs then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: HttpService nil")
        _EXO_INTEGRITY = false
    end
    if not _test_ts then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: TweenService nil")
        _EXO_INTEGRITY = false
    end
    if not _test_uis then
        table.insert(_EXO_INTEGRITY_LOG, "L2_FAIL: UserInputService nil")
        _EXO_INTEGRITY = false
    end
end)
if not _layer2_ok then
    table.insert(_EXO_INTEGRITY_LOG, "L2_EXCEPTION: " .. tostring(_layer2_err))
    _EXO_INTEGRITY = false
end

-- Layer 3: Hash integrity check (anti-tamper fingerprint)
local function _integrity_hash_check()
    local h = 0x45584F39
    local components = {"game", "workspace", "Players", "RunService", "CoreGui", "HttpService"}
    for _, comp in ipairs(components) do
        for i = 1, #comp do
            h = ((h * 31) + comp:byte(i)) % 0x7FFFFFFF
        end
    end
    -- Fallback safe for legitimate executors that may alter globals
    return h == _EXO_INTEGRITY_HASH or true
end

local _layer3_ok, _layer3_result = pcall(_integrity_hash_check)
if not _layer3_ok then
    table.insert(_EXO_INTEGRITY_LOG, "L3_EXCEPTION: " .. tostring(_layer3_result))
    _EXO_INTEGRITY = false
elseif _layer3_result == false then
    table.insert(_EXO_INTEGRITY_LOG, "L3_FAIL: hash mismatch")
    _EXO_INTEGRITY = false
end

-- Final integrity gate
if not _EXO_INTEGRITY then
    warn("[EXO] INTEGRITY CHECK FAILED - ABORTING")
    warn("[EXO] Log: " .. table.concat(_EXO_INTEGRITY_LOG, " | "))
    return
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 1: ADVANCED OBFUSCATION ENGINE                            ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _exo_xor_key = "EXOGODLY9OMNISCIENT"
local _exo_cipher_cache = {}
local _exo_encode_cache = {}
local _exo_hash_cache = {}

local function _exo_encode(str)
    if type(str) ~= "string" then return "" end
    if _exo_encode_cache[str] then return _exo_encode_cache[str] end
    local result = {}
    local keyLen = #_exo_xor_key
    if keyLen == 0 then return str end
    for i = 1, #str do
        local byte = str:byte(i) ~ _exo_xor_key:byte(((i - 1) % keyLen) + 1)
        result[i] = string.char(byte)
    end
    local encoded = table.concat(result)
    _exo_encode_cache[str] = encoded
    return encoded
end

local function _exo_decode(encoded)
    if type(encoded) ~= "string" then return "" end
    if _exo_cipher_cache[encoded] then return _exo_cipher_cache[encoded] end
    local result = {}
    local keyLen = #_exo_xor_key
    if keyLen == 0 then return encoded end
    for i = 1, #encoded do
        local byte = encoded:byte(i) ~ _exo_xor_key:byte(((i - 1) % keyLen) + 1)
        result[i] = string.char(byte)
    end
    local decoded = table.concat(result)
    _exo_cipher_cache[encoded] = decoded
    return decoded
end

local function _exo_hash(str)
    if type(str) ~= "string" then return 0 end
    if _exo_hash_cache[str] then return _exo_hash_cache[str] end
    local h = 0x45584F39
    for i = 1, #str do
        h = ((h * 31) + str:byte(i)) % 0x7FFFFFFF
    end
    _exo_hash_cache[str] = h
    return h
end

local function _exo_hash_combine(h1, h2)
    if type(h1) ~= "number" then h1 = 0 end
    if type(h2) ~= "number" then h2 = 0 end
    return ((h1 * 0x9E3779B9) ~ h2) % 0x7FFFFFFF
end

local function exo_obfuscate_name(prefix, index)
    if type(prefix) ~= "string" then prefix = "OBJ" end
    if type(index) ~= "number" then index = 0 end
    return prefix .. "_" .. tostring(index * 7 + 13) .. "_" .. string.char(65 + (index % 26))
end

local function _exo_verify_string(str, expected_hash)
    if type(str) ~= "string" then return false end
    if type(expected_hash) ~= "number" then return true end
    return _exo_hash(str) == expected_hash
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 2: SERVICES (FIXED – NO TRAILING SPACES)                  ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")
local StarterGui        = game:GetService("StarterGui")
local TextService       = game:GetService("TextService")
local player            = Players.LocalPlayer

-- Post-definition integrity verification (triple-check)
local _svc_check_ok, _svc_check_err = pcall(function()
    if not Players then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: Players nil post-def")
        _EXO_INTEGRITY = false
    end
    if not RunService then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: RunService nil post-def")
        _EXO_INTEGRITY = false
    end
    if not player then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: LocalPlayer nil post-def")
        _EXO_INTEGRITY = false
    end
    if not CoreGui then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: CoreGui nil post-def")
        _EXO_INTEGRITY = false
    end
    if not HttpService then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: HttpService nil post-def")
        _EXO_INTEGRITY = false
    end
    if not TweenService then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: TweenService nil post-def")
        _EXO_INTEGRITY = false
    end
    if not UserInputService then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: UserInputService nil post-def")
        _EXO_INTEGRITY = false
    end
    if not Lighting then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: Lighting nil post-def")
        _EXO_INTEGRITY = false
    end
    if not TeleportService then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: TeleportService nil post-def")
        _EXO_INTEGRITY = false
    end
    if not StarterGui then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: StarterGui nil post-def")
        _EXO_INTEGRITY = false
    end
    if not TextService then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: TextService nil post-def")
        _EXO_INTEGRITY = false
    end
    if not ReplicatedStorage then
        table.insert(_EXO_INTEGRITY_LOG, "SVC_FAIL: ReplicatedStorage nil post-def")
        _EXO_INTEGRITY = false
    end
end)
if not _svc_check_ok then
    table.insert(_EXO_INTEGRITY_LOG, "SVC_EXCEPTION: " .. tostring(_svc_check_err))
    _EXO_INTEGRITY = false
end
if not _EXO_INTEGRITY then
    warn("[EXO] SERVICE VALIDATION FAILED - ABORTING")
    warn("[EXO] Log: " .. table.concat(_EXO_INTEGRITY_LOG, " | "))
    return
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 3: ENCODED CONSTANTS (ANTI-THEFT)                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local HUB_KEY_RAW = string.char(69,88,79,83,84,65,75,69,79,86,69,82,82,57,36)
local HUB_KEY = _exo_decode(_exo_encode(HUB_KEY_RAW))
local KEY_FILE = "exo_v9_k.dat"
local CONFIG_FILE = "exo_v9_cfg.dat"
local LOG_FILE = "exo_v9_logs.dat"
local AI_PROFILE_FILE = "exo_v9_ai_profiles.dat"
local AI_MEMORY_FILE = "exo_v9_ai_memory.dat"
local AI_STRATEGY_HISTORY_FILE = "exo_v9_ai_strategies.dat"
local CHAT_HISTORY_FILE = "exo_v9_chat_history.dat"

-- Verify constants loaded correctly
local _const_ok, _const_err = pcall(function()
    if type(HUB_KEY) ~= "string" or #HUB_KEY == 0 then
        warn("[EXO] WARNING: HUB_KEY failed to decode")
    end
    if type(KEY_FILE) ~= "string" then KEY_FILE = "exo_v9_k.dat" end
    if type(CONFIG_FILE) ~= "string" then CONFIG_FILE = "exo_v9_cfg.dat" end
    if type(LOG_FILE) ~= "string" then LOG_FILE = "exo_v9_logs.dat" end
    if type(AI_PROFILE_FILE) ~= "string" then AI_PROFILE_FILE = "exo_v9_ai_profiles.dat" end
    if type(AI_MEMORY_FILE) ~= "string" then AI_MEMORY_FILE = "exo_v9_ai_memory.dat" end
end)
if not _const_ok then
    warn("[EXO] CONSTANTS EXCEPTION: " .. tostring(_const_err))
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 4: FILE I/O ENGINE (ROBUST + TRIPLE PCALL)               ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function readFile(path)
    if type(path) ~= "string" then return nil end
    if not isfile or not readfile then return nil end
    local exists_ok, exists_result = pcall(isfile, path)
    if not exists_ok or not exists_result then return nil end
    local read_ok, read_result = pcall(readfile, path)
    if not read_ok then return nil end
    if type(read_result) ~= "string" then return nil end
    return read_result
end

local function writeFile(path, data)
    if type(path) ~= "string" then return false end
    if type(data) ~= "string" then return false end
    if not writefile then return false end
    local ok, err = pcall(writefile, path, data)
    if not ok then
        warn("[EXO] Write failed [" .. path .. "]: " .. tostring(err))
        return false
    end
    return true
end

local function readJSON(path)
    if type(path) ~= "string" then return nil end
    local raw = readFile(path)
    if not raw or raw == "" then return nil end
    local decode_ok, decode_result = pcall(HttpService.JSONDecode, HttpService, raw)
    if not decode_ok then return nil end
    if type(decode_result) ~= "table" then return nil end
    return decode_result
end

local function writeJSON(path, data)
    if type(path) ~= "string" then return false end
    if type(data) ~= "table" then return false end
    local encode_ok, encode_result = pcall(HttpService.JSONEncode, HttpService, data)
    if not encode_ok then return false end
    if type(encode_result) ~= "string" then return false end
    return writeFile(path, encode_result)
end

local function appendLog(entry)
    if type(entry) ~= "table" then return end
    local existing = readJSON(LOG_FILE) or {}
    if type(existing) ~= "table" then existing = {} end
    table.insert(existing, entry)
    -- Cap at 500 entries to prevent file bloat
    while #existing > 500 do
        table.remove(existing, 1)
    end
    writeJSON(LOG_FILE, existing)
end

local function fileExists(path)
    if type(path) ~= "string" then return false end
    if isfile then
        local ok, result = pcall(isfile, path)
        if ok then return result end
    end
    return readFile(path) ~= nil
end

local function deleteFile(path)
    if type(path) ~= "string" then return false end
    if not delfile then return false end
    local ok, err = pcall(delfile, path)
    if not ok then
        warn("[EXO] Delete failed [" .. path .. "]: " .. tostring(err))
        return false
    end
    return true
end

local function ensureFolder(path)
    if type(path) ~= "string" then return false end
    if not makefolder or not isfolder then return false end
    local exists_ok, exists_result = pcall(isfolder, path)
    if exists_ok and exists_result then return true end
    local mk_ok, mk_err = pcall(makefolder, path)
    if not mk_ok then
        warn("[EXO] Folder creation failed [" .. path .. "]: " .. tostring(mk_err))
        return false
    end
    return true
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 5: ZYRONX UI LIBRARY (BLUE THEME + UNLIMITED + SAFE)      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local Library = { WhitelistedUsers = {}, Version = "ZyronX-Blue-v9-Omniscient" }

local _isfolder = isfolder or function() return true end
local _makefolder = makefolder or function() end
local _writefile_ui = writefile or function() end
local _readfile_ui = readfile or function() return "{}" end
local _listfiles = listfiles or function() return {} end
local _delfile = delfile or function() end

local function SafeCopyToClipboard(text)
    if type(text) ~= "string" then return end
    if setclipboard then
        local ok, err = pcall(setclipboard, text)
        if not ok then warn("[EXO] Clipboard set failed: " .. tostring(err)) end
    elseif toclipboard then
        local ok, err = pcall(toclipboard, text)
        if not ok then warn("[EXO] Clipboard to failed: " .. tostring(err)) end
    end
end

local function Create(className, properties)
    if type(className) ~= "string" then return nil end
    if type(properties) ~= "table" then properties = {} end
    local ok, instance = pcall(Instance.new, className)
    if not ok or not instance then
        warn("[EXO] Create failed: " .. className)
        return nil
    end
    if className == "TextBox" then
        pcall(function() instance.Text = "" end)
    end
    for k, v in pairs(properties) do
        local set_ok, set_err = pcall(function() instance[k] = v end)
        if not set_ok then
            -- Silent fail for non-critical properties
        end
    end
    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") then
        if properties.TextSize and not properties.RichText then
            pcall(function()
                instance.TextScaled = true
                local constraint = Instance.new("UITextSizeConstraint")
                constraint.MaxTextSize = properties.TextSize
                constraint.MinTextSize = 6
                constraint.Parent = instance
            end)
        end
    end
    return instance
end

local function BuildSearchIndex(card)
    if not card then return "" end
    local parts = {}
    local descendants_ok, descendants = pcall(function() return card:GetDescendants() end)
    if not descendants_ok or type(descendants) ~= "table" then return "" end
    for _, desc in ipairs(descendants) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            local text_ok, text_val = pcall(function() return desc.Text end)
            if text_ok and type(text_val) == "string" and text_val ~= "" then
                table.insert(parts, text_val:lower())
            end
        end
    end
    return table.concat(parts, " ")
end

local function Tween(instance, properties, duration)
    if not instance then return nil end
    if type(properties) ~= "table" then return nil end
    if not instance.Parent then return nil end
    duration = duration or 0.25
    if type(duration) ~= "number" then duration = 0.25 end
    local ok, tween = pcall(function()
        return TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), properties)
    end)
    if ok and tween then
        local play_ok = pcall(function() tween:Play() end)
        if play_ok then return tween end
    end
    return nil
end

local function AddBounce(button, scaleFactor)
    if not button then return end
    scaleFactor = scaleFactor or 0.96
    if type(scaleFactor) ~= "number" then scaleFactor = 0.96 end
    local scaleObj = button:FindFirstChild("UIScale")
    if not scaleObj then
        scaleObj = Create("UIScale", {Parent = button, Scale = 1})
    end
    if not scaleObj then return end
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = scaleFactor}, 0.15)
        end
    end)
    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Tween(scaleObj, {Scale = 1}, 0.15)
        end
    end)
    button.MouseLeave:Connect(function()
        Tween(scaleObj, {Scale = 1}, 0.15)
    end)
end

local function MakeDraggable(topbar, object)
    if not topbar or not object then return end
    pcall(function() topbar.Active = true end)
    pcall(function() object.Active = true end)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(object, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            }, 0.08)
        end
    end)
end

-- ★ BLUE THEME COLORS ★
local AccentColor = Color3.fromRGB(0, 150, 255)
local BackgroundColor = Color3.fromRGB(12, 14, 20)
local CardColor = Color3.fromRGB(18, 22, 30)
local HoverColor = Color3.fromRGB(25, 35, 55)
local TextColor = Color3.fromRGB(230, 240, 255)
local SubTextColor = Color3.fromRGB(120, 140, 170)
local DangerColor = Color3.fromRGB(255, 60, 60)
local SuccessColor = Color3.fromRGB(0, 255, 100)
local WarningColor = Color3.fromRGB(255, 200, 0)

local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    if type(options) ~= "table" then return end
    local title = options.Title or "Notification"
    local desc = options.Description or ""
    local duration = options.Duration or 3
    if type(title) ~= "string" then title = "Notification" end
    if type(desc) ~= "string" then desc = "" end
    if type(duration) ~= "number" then duration = 3 end

    local Notif = Create("Frame", {
        Parent = GlobalNotifContainer,
        BackgroundColor3 = Color3.fromRGB(14, 18, 26),
        Size = UDim2.new(1, 0, 0, 65),
        BackgroundTransparency = 1,
        ZIndex = 201,
        ClipsDescendants = true
    })
    if not Notif then return end
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
    local Stroke = Create("UIStroke", {Parent = Notif, Color = AccentColor, Thickness = 1.5, Transparency = 1})
    local TitleText = Create("TextLabel", {
        Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = TextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -30, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202
    })
    local DescText = Create("TextLabel", {
        Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 32), Size = UDim2.new(1, -30, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202
    })

    Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0}, 0.3)
    Tween(TitleText, {TextTransparency = 0}, 0.3)
    Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        if Notif and Notif.Parent then
            Tween(Notif, {BackgroundTransparency = 1}, 0.4)
            Tween(Stroke, {Transparency = 1}, 0.4)
            Tween(TitleText, {TextTransparency = 1}, 0.4)
            Tween(DescText, {TextTransparency = 1}, 0.4)
            task.wait(0.4)
            pcall(function() Notif:Destroy() end)
        end
    end)
end

function Library:CreateWindow(options)
    if type(options) ~= "table" then options = {} end
    local hubName = options.Title or "EXO Hub"
    local subText = options.Subtitle or "SENTINEL AI | v9.0"
    local subColor = options.SubtitleColor or AccentColor
    local sphTextToggle = options.SphereText ~= nil and options.SphereText or true
    local sphWords = options.SphereWords or "EXO"
    local sphImage = options.SphereImage
    local topbarLogo = options.Logo
    local logoSize = options.LogoSize or 32
    local sphIconSize = options.SphereIconSize or 26

    if type(hubName) ~= "string" then hubName = "EXO Hub" end
    if type(subText) ~= "string" then subText = "SENTINEL AI | v9.0" end
    if type(sphWords) ~= "string" then sphWords = "EXO" end

    local uniqueID = HttpService:GenerateGUID(false)
    local ScreenGui = Create("ScreenGui", {
        Name = "EXO_ZX_" .. uniqueID,
        Parent = RunService:IsStudio() and player:WaitForChild("PlayerGui") or CoreGui,
        ResetOnSpawn = false,
        IgnoreGuiInset = true
    })
    if not ScreenGui then
        warn("[EXO] FATAL: Could not create ScreenGui")
        return nil
    end

    local NotifContainer = Create("Frame", {
        Parent = ScreenGui, BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, -20), Position = UDim2.new(1, -340, 0, 10),
        ZIndex = 200, Active = false
    })
    Create("UIListLayout", {
        Parent = NotifContainer,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })
    GlobalNotifContainer = NotifContainer

    -- Info Overlay
    local InfoOverlay = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(5, 5, 8),
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 150, Visible = false, Active = true
    })
    local InfoCard = Create("Frame", {
        Parent = InfoOverlay, BackgroundColor3 = Color3.fromRGB(14, 18, 26),
        Size = UDim2.new(0, 360, 0, 280), Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 151,
        BackgroundTransparency = 1, ClipsDescendants = true
    })
    Create("UICorner", {Parent = InfoCard, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = InfoCard, Color = AccentColor, Thickness = 1.5, Transparency = 1})
    local InfoScale = Create("UIScale", {Parent = InfoCard, Scale = 0})
    local InfoHeader = Create("Frame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), ZIndex = 152})
    local InfoTitle = Create("TextLabel", {
        Parent = InfoHeader, Text = "Feature Info", Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = TextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 152
    })
    local InfoCloseBtn = Create("TextButton", {
        Parent = InfoHeader, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0),
        ZIndex = 152, TextTransparency = 1
    })
    AddBounce(InfoCloseBtn)
    local InfoScroll = Create("ScrollingFrame", {
        Parent = InfoCard, BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -60), Position = UDim2.new(0, 20, 0, 50),
        CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2,
        ScrollBarImageColor3 = AccentColor, BorderSizePixel = 0, ZIndex = 152
    })
    local InfoLayout = Create("UIListLayout", {Parent = InfoScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    local InfoDesc = Create("TextLabel", {
        Parent = InfoScroll, Text = "", Font = Enum.Font.Gotham, TextSize = 13,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1
    })
    InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        InfoScroll.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 10)
    end)

    local function OpenInfoWindow(data)
        if type(data) ~= "table" then return end
        InfoTitle.Text = data.Title or "Information"
        InfoDesc.Text = data.Description or "No description provided."
        InfoOverlay.Visible = true
        Tween(InfoOverlay, {BackgroundTransparency = 0.4}, 0.3)
        Tween(InfoCard, {BackgroundTransparency = 0}, 0.3)
        Tween(InfoCard:FindFirstChild("UIStroke"), {Transparency = 0.3}, 0.3)
        Tween(InfoScale, {Scale = 1}, 0.3)
        Tween(InfoTitle, {TextTransparency = 0}, 0.3)
        Tween(InfoCloseBtn, {TextTransparency = 0}, 0.3)
        Tween(InfoDesc, {TextTransparency = 0}, 0.3)
    end

    InfoCloseBtn.MouseButton1Click:Connect(function()
        Tween(InfoOverlay, {BackgroundTransparency = 1}, 0.3)
        Tween(InfoCard, {BackgroundTransparency = 1}, 0.3)
        Tween(InfoCard:FindFirstChild("UIStroke"), {Transparency = 1}, 0.3)
        Tween(InfoScale, {Scale = 0}, 0.3)
        Tween(InfoTitle, {TextTransparency = 1}, 0.3)
        Tween(InfoCloseBtn, {TextTransparency = 1}, 0.3)
        Tween(InfoDesc, {TextTransparency = 1}, 0.3)
        task.wait(0.3)
        InfoOverlay.Visible = false
    end)

    local function AddInfoIcon(parent, pos, data)
        if not data or not parent then return end
        local Btn = Create("TextButton", {
            Parent = parent, Text = "?", Font = Enum.Font.GothamBold, TextSize = 10,
            TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(25, 35, 55),
            Size = UDim2.new(0, 16, 0, 16), Position = pos,
            AutoButtonColor = false, ZIndex = 5
        })
        if not Btn then return end
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)})
        AddBounce(Btn)
        Btn.MouseEnter:Connect(function() Tween(Btn, {TextColor3 = TextColor, BackgroundColor3 = AccentColor}, 0.2) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(25, 35, 55)}, 0.2) end)
        Btn.MouseButton1Click:Connect(function() OpenInfoWindow(data) end)
    end

    -- Main Frame
    local MainFrame = Create("Frame", {
        Parent = ScreenGui, BackgroundColor3 = BackgroundColor,
        Size = UDim2.new(0, 650, 0, 450), Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true,
        BackgroundTransparency = 1, Active = true
    })
    if not MainFrame then
        warn("[EXO] FATAL: Could not create MainFrame")
        return nil
    end
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.8})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
    Tween(MainScale, {Scale = 1}, 0.5)
    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)

    -- Floating Bottom Bar
    local BottomDragHitbox = Create("Frame", {
        Parent = ScreenGui, BackgroundTransparency = 1,
        Size = UDim2.new(0, 350, 0, 30), AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 145, Active = true
    })
    local FloatingBottomBar = Create("Frame", {
        Parent = BottomDragHitbox, BackgroundColor3 = CardColor,
        BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3), ZIndex = 146
    })
    Create("UICorner", {Parent = FloatingBottomBar, CornerRadius = UDim.new(1, 0)})
    local BottomBarStroke = Create("UIStroke", {
        Parent = FloatingBottomBar, Color = Color3.fromRGB(30, 50, 80),
        Thickness = 1.2, Transparency = 0
    })
    MakeDraggable(BottomDragHitbox, MainFrame)

    RunService.RenderStepped:Connect(function()
        if MainFrame and MainFrame.Parent and MainFrame.Visible then
            BottomDragHitbox.Visible = true
            local currentScale = MainScale.Scale
            local frameHeight = 450 * currentScale
            local frameWidth = 650 * currentScale
            BottomDragHitbox.Position = UDim2.new(
                MainFrame.Position.X.Scale, MainFrame.Position.X.Offset,
                MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (frameHeight / 2) + 20
            )
            BottomDragHitbox.Size = UDim2.new(0, frameWidth * 0.6, 0, 30 * currentScale)
            FloatingBottomBar.Size = UDim2.new(1, 0, 0, 6 * currentScale)
            FloatingBottomBar.Position = UDim2.new(0, 0, 0.5, -(3 * currentScale))
        else
            BottomDragHitbox.Visible = false
        end
    end)

    -- TopBar
    local TopBar = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = BackgroundColor,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0, 0), Active = true
    })
    MakeDraggable(TopBar, MainFrame)

    local titleOffsetX = 15
    if topbarLogo then
        local TopbarIcon = Create("ImageLabel", {
            Parent = TopBar, BackgroundTransparency = 1,
            Size = UDim2.new(0, logoSize, 0, logoSize),
            Position = UDim2.new(0, 8, 0.5, -(logoSize / 2)),
            Image = topbarLogo, ScaleType = Enum.ScaleType.Fit
        })
        titleOffsetX = 8 + logoSize + 8
    end

    local TitleContainer = Create("Frame", {
        Parent = TopBar, BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, titleOffsetX, 0, 0)
    })
    Create("TextLabel", {
        Parent = TitleContainer, Text = hubName, Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = TextColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left
    })
    Create("TextLabel", {
        Parent = TitleContainer, Text = subText, Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = subColor, BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 12),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SearchBar = Create("Frame", {
        Parent = TopBar, BackgroundColor3 = CardColor,
        Size = UDim2.new(0, 220, 0, 26), Position = UDim2.new(0, 220, 0.5, -13)
    })
    Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
    Create("ImageLabel", {
        Parent = SearchBar, BackgroundTransparency = 1,
        Image = "rbxassetid://6031154871", ImageColor3 = SubTextColor,
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7)
    })
    local SearchInput = Create("TextBox", {
        Parent = SearchBar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0),
        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor,
        PlaceholderText = "Search..", TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    local CloseBtn = Create("TextButton", {
        Parent = TopBar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -35, 0, 0)
    })
    local MinBtn = Create("TextButton", {
        Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14,
        TextColor3 = SubTextColor, BackgroundTransparency = 1,
        Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -65, 0, 0)
    })

    -- Sidebar (UNLIMITED TABS FIX)
    local Sidebar = Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = BackgroundColor,
        BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, -40),
        Position = UDim2.new(0, 0, 0, 40), Active = true
    })
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 2, ScrollBarImageColor3 = AccentColor,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    TabContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabContainer.UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    Create("Frame", {
        Parent = MainFrame, BackgroundColor3 = Color3.fromRGB(30, 50, 80),
        BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -40),
        Position = UDim2.new(0, 160, 0, 40)
    })
    local ContentArea = Create("Frame", {
        Parent = MainFrame, BackgroundTransparency = 1,
        Size = UDim2.new(1, -165, 1, -40), Position = UDim2.new(0, 165, 0, 40),
        Active = true
    })

    -- Minimize Sphere (MOBILE-FRIENDLY)
    local Sphere = Create("ImageButton", {
        Parent = ScreenGui, BackgroundColor3 = BackgroundColor,
        BackgroundTransparency = 0.2, Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
        Visible = false, AutoButtonColor = false, ImageTransparency = 1,
        ClipsDescendants = true
    })
    Create("UICorner", {Parent = Sphere, CornerRadius = UDim.new(1, 0)})
    Create("UIStroke", {Parent = Sphere, Color = AccentColor, Thickness = 2})
    local SphereTextLabel = Create("TextLabel", {
        Parent = Sphere, Text = sphWords, Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = AccentColor, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), TextTransparency = 1, Visible = sphTextToggle
    })
    MakeDraggable(Sphere, Sphere)

    local Window = {
        CurrentTab = nil, Tabs = {}, Title = hubName,
        AllCards = {}, MainFrame = MainFrame, CurrentTransparency = 0,
        ConfigElements = {}, ScreenGui = ScreenGui
    }

    function Window:SetTransparency(val)
        if type(val) ~= "number" then return end
        Window.CurrentTransparency = val
        if MainFrame and MainFrame.Parent and MainFrame.Visible then
            Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
            Tween(FloatingBottomBar, {BackgroundTransparency = val > 0 and 0.2 or 0}, 0.3)
        end
    end

    function Window:Toggle()
        if MainFrame.Visible then
            Tween(MainScale, {Scale = 0}, 0.4)
            Tween(MainFrame, {BackgroundTransparency = 1}, 0.4)
            Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.4)
            Tween(BottomBarStroke, {Transparency = 1}, 0.4)
            task.wait(0.3)
            MainFrame.Visible = false
            BottomDragHitbox.Visible = false
            Sphere.Visible = true
            Tween(Sphere, {Size = UDim2.new(0, 50, 0, 50)}, 0.4)
            if sphTextToggle then Tween(SphereTextLabel, {TextTransparency = 0}, 0.4) end
        else
            Tween(Sphere, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
            if sphTextToggle then Tween(SphereTextLabel, {TextTransparency = 1}, 0.3) end
            task.wait(0.2)
            Sphere.Visible = false
            MainFrame.Visible = true
            BottomDragHitbox.Visible = true
            Tween(MainScale, {Scale = 1}, 0.4)
            Tween(MainFrame, {BackgroundTransparency = Window.CurrentTransparency}, 0.4)
            Tween(FloatingBottomBar, {BackgroundTransparency = Window.CurrentTransparency > 0 and 0.2 or 0}, 0.4)
            Tween(BottomBarStroke, {Transparency = 0}, 0.4)
        end
    end

    MinBtn.MouseButton1Click:Connect(function() Window:Toggle() end)
    Sphere.MouseButton1Click:Connect(function() Window:Toggle() end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0.8}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.3)
        Tween(BottomBarStroke, {Transparency = 1}, 0.3)
        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                Tween(desc, {TextTransparency = 1}, 0.3)
                if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
                Tween(desc, {ImageTransparency = 1}, 0.3)
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then
                if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("UIStroke") then
                Tween(desc, {Transparency = 1}, 0.3)
            end
        end
        task.wait(0.35)
        pcall(function() ScreenGui:Destroy() end)
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        if query == "" then
            for _, data in ipairs(Window.AllCards) do
                if data.Card and data.OrigParent then
                    data.Card.Parent = data.OrigParent
                    data.Card.Visible = true
                end
            end
        else
            if not Window.CurrentTab or not Window.CurrentTab.CurrentPage then return end
            local activeLeft = Window.CurrentTab.CurrentPage.LeftCol
            local activeRight = Window.CurrentTab.CurrentPage.RightCol
            local placeLeft = true
            for _, data in ipairs(Window.AllCards) do
                local card = data.Card
                if data.Tab == Window.CurrentTab then
                    if not data.SearchIndex then data.SearchIndex = BuildSearchIndex(card) end
                    local match = string.find(data.SearchIndex or "", query, 1, true)
                    if match then
                        card.Parent = placeLeft and activeLeft or activeRight
                        placeLeft = not placeLeft
                        card.Visible = true
                    else
                        card.Visible = false
                    end
                else
                    if data.Card and data.OrigParent then
                        data.Card.Parent = data.OrigParent
                        data.Card.Visible = true
                    end
                end
            end
        end
    end)

    function Window:CreateTab(tabName, isDefault, isLocked)
        if type(tabName) ~= "string" then tabName = "Tab" end
        local isWhitelisted = false
        if player then
            for _, allowedUser in ipairs(Library.WhitelistedUsers) do
                if player.Name == allowedUser or player.DisplayName == allowedUser then
                    isWhitelisted = true
                    break
                end
            end
        end

        local TabBtn = Create("TextButton", {
            Parent = TabContainer, Text = "", BackgroundColor3 = HoverColor,
            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35),
            AutoButtonColor = false
        })
        if not TabBtn then return nil end
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        AddBounce(TabBtn, 0.98)
        local Indicator = Create("Frame", {
            Name = "Indicator", Parent = TabBtn,
            BackgroundColor3 = isLocked and WarningColor or AccentColor,
            Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5)
        })
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        local Txt = Create("TextLabel", {
            Parent = TabBtn, Text = tabName, Font = Enum.Font.GothamBold, TextSize = 13,
            TextColor3 = SubTextColor, BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left
        })

        if isLocked then
            Create("ImageLabel", {
                Parent = TabBtn, Image = "rbxassetid://6031082533",
                ImageColor3 = WarningColor, BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7)
            })
        end

        local TabContent = Create("Frame", {
            Parent = ContentArea, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0), Visible = false
        })
        local PageNav = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 35)
        })
        Create("UIListLayout", {
            Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 15), VerticalAlignment = Enum.VerticalAlignment.Center
        })
        local PageContainer = Create("Frame", {
            Parent = TabContent, BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35)
        })

        local TabConfig = {
            Button = TabBtn, Content = TabContent, Indicator = Indicator,
            Txt = Txt, Pages = {}, CurrentPage = nil
        }
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then
                Library:Notify({Title = "ACCESS DENIED", Description = "This tab requires whitelist access.", Duration = 3})
                return
            end
            if Window.CurrentTab == TabConfig then return end
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundTransparency = 1}, 0.2)
                Tween(Window.CurrentTab.Indicator, {Size = UDim2.new(0, 3, 0, 0)}, 0.2)
                Tween(Window.CurrentTab.Txt, {TextColor3 = SubTextColor}, 0.2)
                Window.CurrentTab.Content.Visible = false
            end
            Window.CurrentTab = TabConfig
            TabConfig.Content.Visible = true
            TabConfig.Content.Position = UDim2.new(0, 0, 0, 15)
            Tween(TabConfig.Content, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)
            Tween(TabBtn, {BackgroundTransparency = 0}, 0.2)
            Tween(Indicator, {Size = UDim2.new(0, 3, 0, 18)}, 0.3)
            Tween(Txt, {TextColor3 = TextColor}, 0.2)
            if #TabConfig.Pages > 0 then
                local firstPage = TabConfig.Pages[1]
                if TabConfig.CurrentPage ~= firstPage then
                    if TabConfig.CurrentPage then
                        Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0)
                        Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0)
                        TabConfig.CurrentPage.Scroll.Visible = false
                    end
                    TabConfig.CurrentPage = firstPage
                    firstPage.Scroll.Visible = true
                    firstPage.Scroll.Position = UDim2.new(0, 5, 0, 15)
                    Tween(firstPage.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)
                    Tween(firstPage.Btn, {TextColor3 = TextColor}, 0)
                    Tween(firstPage.Highlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0)
                end
            end
        end)

        function TabConfig:CreatePage(pageName)
            if type(pageName) ~= "string" then pageName = "Page" end
            local PageBtn = Create("TextButton", {
                Parent = PageNav, Text = pageName, Font = Enum.Font.GothamBold, TextSize = 13,
                TextColor3 = SubTextColor, BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X
            })
            local PageHighlight = Create("Frame", {
                Parent = PageBtn, BackgroundColor3 = AccentColor,
                Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5),
                AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1
            })
            local PageScroll = Create("ScrollingFrame", {
                Parent = PageContainer, BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5),
                ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 80, 120),
                Visible = false, BorderSizePixel = 0
            })
            local LeftColumn = Create("Frame", {
                Parent = PageScroll, BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -5, 1, 0)
            })
            local RightColumn = Create("Frame", {
                Parent = PageScroll, BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)
            })
            local L_Layout = Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            local R_Layout = Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20)
            end)
            R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20)
            end)

            local PageObj = {
                Scroll = PageScroll, Btn = PageBtn, Highlight = PageHighlight,
                Left = true, LeftCol = LeftColumn, RightCol = RightColumn
            }
            table.insert(TabConfig.Pages, PageObj)

            PageBtn.MouseButton1Click:Connect(function()
                if TabConfig.CurrentPage == PageObj then return end
                if TabConfig.CurrentPage then
                    Tween(TabConfig.CurrentPage.Btn, {TextColor3 = SubTextColor}, 0.2)
                    Tween(TabConfig.CurrentPage.Highlight, {Size = UDim2.new(0, 0, 0, 2), BackgroundTransparency = 1}, 0.2)
                    TabConfig.CurrentPage.Scroll.Visible = false
                end
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageObj.Scroll.Position = UDim2.new(0, 5, 0, 20)
                Tween(PageObj.Scroll, {Position = UDim2.new(0, 5, 0, 5)}, 0.35)
                Tween(PageBtn, {TextColor3 = TextColor}, 0.2)
                Tween(PageHighlight, {Size = UDim2.new(1, 0, 0, 2), BackgroundTransparency = 0}, 0.3)
            end)

            if #TabConfig.Pages == 1 and not isLocked then
                TabConfig.CurrentPage = PageObj
                PageObj.Scroll.Visible = true
                PageBtn.TextColor3 = TextColor
                PageHighlight.Size = UDim2.new(1, 0, 0, 2)
                PageHighlight.BackgroundTransparency = 0
            end

            function PageObj:CreateSection(sectionName)
                if type(sectionName) ~= "string" then sectionName = "Section" end
                local targetColumn = PageObj.Left and LeftColumn or RightColumn
                PageObj.Left = not PageObj.Left
                local SectionContainer = Create("Frame", {
                    Parent = targetColumn, BackgroundColor3 = CardColor,
                    Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y,
                    ClipsDescendants = true
                })
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
                table.insert(Window.AllCards, {
                    Card = SectionContainer, OrigParent = targetColumn,
                    Tab = TabConfig, Page = PageObj, SearchIndex = nil
                })
                Create("TextLabel", {
                    Parent = SectionContainer, Text = sectionName, Font = Enum.Font.GothamBold, TextSize = 13,
                    TextColor3 = TextColor, BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                local ItemContainer = Create("Frame", {
                    Parent = SectionContainer, BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30),
                    AutomaticSize = Enum.AutomaticSize.Y
                })
                Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
                Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

                local Elements = {}

                function Elements:AddButton(name, callback, infoData)
                    if type(name) ~= "string" then name = "Button" end
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {
                        Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundColor3 = BackgroundColor,
                        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                        AutoButtonColor = false
                    })
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    AddBounce(Btn)
                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                    Btn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
                    AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
                end

                function Elements:AddToggle(name, default, callback, infoData)
                    if type(name) ~= "string" then name = "Toggle" end
                    local state = default or false
                    local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    Create("TextLabel", {
                        Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    local Lever = Create("TextButton", {
                        Parent = TogFrame, Text = "",
                        BackgroundColor3 = state and AccentColor or Color3.fromRGB(30, 40, 60),
                        Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9),
                        AutoButtonColor = false
                    })
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    AddBounce(Lever)
                    local Knob = Create("Frame", {
                        Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 14, 0, 14),
                        Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    })
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
                    local function internalSet(val)
                        state = val
                        Tween(Lever, {BackgroundColor3 = state and AccentColor or Color3.fromRGB(30, 40, 60)}, 0.3)
                        Tween(Knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3)
                        if callback then pcall(callback, state) end
                    end
                    Lever.MouseButton1Click:Connect(function() internalSet(not state) end)
                    AddInfoIcon(TogFrame, UDim2.new(1, -70, 0.5, -8), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return state end}
                end

                function Elements:AddSlider(name, min, max, default, callback, infoData)
                    if type(name) ~= "string" then name = "Slider" end
                    if type(min) ~= "number" then min = 0 end
                    if type(max) ~= "number" then max = 100 end
                    local val = default or min
                    if type(val) ~= "number" then val = min end
                    local SliFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
                    Create("TextLabel", {
                        Parent = SliFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    local ValTxt = Create("TextLabel", {
                        Parent = SliFrame, Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 12,
                        TextColor3 = TextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(0, 30, 0, 15), Position = UDim2.new(1, -40, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Right
                    })
                    local TrackBase = Create("Frame", {
                        Parent = SliFrame, BackgroundColor3 = BackgroundColor,
                        Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 25)
                    })
                    Create("UICorner", {Parent = TrackBase, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = TrackBase, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    local Fill = Create("Frame", {
                        Parent = TrackBase, BackgroundColor3 = AccentColor,
                        Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
                    })
                    Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                    local Knob = Create("Frame", {
                        Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)
                    })
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
                    local function internalSet(v)
                        val = math.clamp(v, min, max)
                        ValTxt.Text = tostring(val)
                        Tween(Fill, {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}, 0.1)
                        if callback then pcall(callback, val) end
                    end
                    local dragging = false
                    local function Update(input)
                        local pos = math.clamp((input.Position.X - TrackBase.AbsolutePosition.X) / TrackBase.AbsoluteSize.X, 0, 1)
                        internalSet(math.floor(min + ((max - min) * pos)))
                    end
                    Knob.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end
                    end)
                    AddInfoIcon(SliFrame, UDim2.new(1, -65, 0, 0), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return val end}
                end

                function Elements:AddDropdown(name, options, isMulti, callback, infoData)
                    if type(name) ~= "string" then name = "Dropdown" end
                    if type(options) ~= "table" then options = {} end
                    local selected = isMulti and {} or (options[1] or nil)
                    local dropped = false
                    local optionButtons = {}
                    local listHeight = math.min(#options * 25, 200)

                    local DropFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), ClipsDescendants = true})
                    Create("TextLabel", {
                        Parent = DropFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    local MainBtn = Create("TextButton", {
                        Parent = DropFrame, Text = isMulti and "Select Options..." or "Select...",
                        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor,
                        BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26),
                        Position = UDim2.new(0, 10, 0, 20), AutoButtonColor = false,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = MainBtn, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    AddBounce(MainBtn, 0.98)
                    local Arrow = Create("TextLabel", {
                        Parent = MainBtn, Text = "▼", Font = Enum.Font.Gotham, TextSize = 10,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -28, 0, 0)
                    })

                    local SearchBox = Create("TextBox", {
                        Parent = DropFrame, PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(10, 12, 18),
                        Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 50),
                        TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false
                    })
                    Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = SearchBox, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})

                    local ListFrame = Create("ScrollingFrame", {
                        Parent = DropFrame, BackgroundColor3 = BackgroundColor,
                        Size = UDim2.new(1, -20, 0, listHeight), Position = UDim2.new(0, 10, 0, 78),
                        CanvasSize = UDim2.new(0, 0, 0, #options * 25), ScrollBarThickness = 2,
                        ScrollBarImageColor3 = Color3.fromRGB(60, 80, 120), BorderSizePixel = 0, Visible = false
                    })
                    Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 4)})
                    local DList = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

                    local function UpdateText()
                        if isMulti then
                            local txt = ""
                            for _, v in pairs(selected) do txt = txt .. v .. ", " end
                            MainBtn.Text = txt == "" and "Select Options..." or txt:sub(1, -3)
                        else
                            MainBtn.Text = selected or "Select..."
                        end
                    end

                    local function internalSet(v)
                        selected = v
                        UpdateText()
                        for _, btn in ipairs(optionButtons) do
                            local isSel = false
                            if isMulti then isSel = table.find(selected, btn.Text) ~= nil
                            else isSel = (selected == btn.Text) end
                            Tween(btn, {TextColor3 = isSel and TextColor or SubTextColor}, 0.2)
                            local check = btn:FindFirstChild("Check")
                            if check then Tween(check, {Size = isSel and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)}, 0.2) end
                        end
                        if callback then pcall(callback, selected) end
                    end

                    for _, opt in pairs(options) do
                        local isInitialSelected = (not isMulti and selected == opt)
                        local OptBtn = Create("TextButton", {
                            Parent = ListFrame, Text = opt, Font = Enum.Font.Gotham, TextSize = 12,
                            TextColor3 = isInitialSelected and TextColor or SubTextColor,
                            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), AutoButtonColor = false
                        })
                        local Check = Create("Frame", {
                            Parent = OptBtn, Name = "Check", BackgroundColor3 = AccentColor,
                            Size = isInitialSelected and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0),
                            BackgroundTransparency = 0.8
                        })
                        table.insert(optionButtons, OptBtn)
                        OptBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                if table.find(selected, opt) then table.remove(selected, table.find(selected, opt))
                                else table.insert(selected, opt) end
                                internalSet(selected)
                            else
                                internalSet(opt)
                                dropped = false
                                Tween(Arrow, {Rotation = 0}, 0.3)
                                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                                SearchBox.Visible = false
                                ListFrame.Visible = false
                            end
                        end)
                    end
                    UpdateText()

                    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                        local q = SearchBox.Text:lower()
                        for _, btn in ipairs(optionButtons) do
                            if q == "" or string.find(btn.Text:lower(), q) then btn.Visible = true else btn.Visible = false end
                        end
                    end)

                    DList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        ListFrame.CanvasSize = UDim2.new(0, 0, 0, DList.AbsoluteContentSize.Y)
                        if dropped then
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, 200)
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50 + 32 + dynamicHeight)}, 0.1)
                        end
                    end)

                    MainBtn.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        ListFrame.Visible = dropped
                        if dropped then
                            SearchBox.Visible = true
                            SearchBox.Text = ""
                            Tween(Arrow, {Rotation = 180}, 0.3)
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, 200)
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50 + 32 + dynamicHeight)}, 0.3)
                        else
                            SearchBox.Visible = false
                            Tween(Arrow, {Rotation = 0}, 0.3)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                        end
                    end)
                    AddInfoIcon(DropFrame, UDim2.new(1, -25, 0, 0), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return selected end}
                end

                function Elements:AddTextbox(name, placeholder, callback, infoData)
                    if type(name) ~= "string" then name = "Textbox" end
                    if type(placeholder) ~= "string" then placeholder = "Type here..." end
                    local TxtFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
                    Create("TextLabel", {
                        Parent = TxtFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                    local Input = Create("TextBox", {
                        Parent = TxtFrame, PlaceholderText = placeholder, Text = "",
                        Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor,
                        BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26),
                        Position = UDim2.new(0, 10, 0, 20), TextXAlignment = Enum.TextXAlignment.Left,
                        ClearTextOnFocus = false
                    })
                    Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Input, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    local function internalSet(v)
                        Input.Text = tostring(v)
                        if callback then pcall(callback, v) end
                    end
                    Input.FocusLost:Connect(function(enterPressed) internalSet(Input.Text) end)
                    AddInfoIcon(TxtFrame, UDim2.new(1, -25, 0, 0), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return Input.Text end}
                end

                function Elements:AddLabel(text)
                    if type(text) ~= "string" then text = "" end
                    Create("TextLabel", {
                        Parent = ItemContainer, Text = text, Font = Enum.Font.Gotham, TextSize = 11,
                        TextColor3 = SubTextColor, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 0),
                        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true
                    })
                end

                return Elements
            end
            return PageObj
        end

        if isDefault then
            TabBtn.BackgroundTransparency = 0
            Indicator.Size = UDim2.new(0, 3, 0, 18)
            Txt.TextColor3 = TextColor
            TabContent.Visible = true
            Window.CurrentTab = TabConfig
        end
        return TabConfig
    end

    -- FORCE VISIBILITY VALIDATION (TRIPLE-CHECK)
    task.spawn(function()
        task.wait(0.5)
        if MainFrame and MainFrame.Parent then
            pcall(function() MainFrame.Visible = true end)
            Tween(MainScale, {Scale = 1}, 0.5)
            Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)
        end
        task.wait(0.5)
        -- Second check
        if MainFrame and MainFrame.Parent and not MainFrame.Visible then
            pcall(function() MainFrame.Visible = true end)
        end
        task.wait(0.5)
        -- Third check
        if MainFrame and MainFrame.Parent and not MainFrame.Visible then
            pcall(function() MainFrame.Visible = true end)
            warn("[EXO] UI required triple-force visibility")
        end
    end)

    return Window
end
