-- ═══════════════════════════════════════════════════════════════════════
--  ███████╗██╗  ██╗ ██████╗     ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗
--  ██╔════╝╚██╗██╔╝██╔═══██╗    ██║  ██║██╔══██╗██║   ██║██╔══██╗██╔═══██╗
--  █████╗   ╚███╔╝ ██║   ██║    ███████║███████║██║   ██║██║  ██║██║   ██║
--  ██╔══╝   ██╔██╗ ██║   ██║    ██╔══██║██╔══██║██║   ██║██║  ██║██║   ██║
--  ███████╗██╔╝ ██╗╚██████╔╝    ██║  ██║██║  ██║╚██████╔╝██████╔╝╚██████╔╝
--  ╚══════╝╚═╝  ╚═╝ ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝
--  EXO HUB v8.0 – SENTINEL AI | ZYRONX BLUE | GODLY TIER+ | PROTECTED
--  FULL 32-SECTION ARCHITECTURE | NO SHORTENING | ALL FEATURES PRESERVED
-- ═══════════════════════════════════════════════════════════════════════

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 0: ANTI-TAMPER INTEGRITY                                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _EXO_V = 8.0
local _EXO_BUILD = "SENTINEL_AI_FULL"
local _EXO_INTEGRITY = true

pcall(function()
    if not game then _EXO_INTEGRITY = false end
    if not game.GetService then _EXO_INTEGRITY = false end
    if not workspace then _EXO_INTEGRITY = false end
end)

if not _EXO_INTEGRITY then return end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 1: OBFUSCATION ENGINE                                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local _exo_xor_key = "EXOGODLY8"
local _exo_cipher_cache = {}

local function _exo_encode(str)
    local result = {}
    for i = 1, #str do
        local byte = str:byte(i) ~ _exo_xor_key:byte(((i - 1) % #_exo_xor_key) + 1)
        result[i] = string.char(byte)
    end
    return table.concat(result)
end

local function _exo_decode(encoded)
    if _exo_cipher_cache[encoded] then return _exo_cipher_cache[encoded] end
    local result = {}
    for i = 1, #encoded do
        local byte = encoded:byte(i) ~ _exo_xor_key:byte(((i - 1) % #_exo_xor_key) + 1)
        result[i] = string.char(byte)
    end
    local decoded = table.concat(result)
    _exo_cipher_cache[encoded] = decoded
    return decoded
end

local function _exo_hash(str)
    local h = 0x45584F
    for i = 1, #str do
        h = (h * 31 + str:byte(i)) % 0x7FFFFFFF
    end
    return h
end

local function exo_obfuscate_name(prefix, index)
    return prefix .. "" .. tostring(index * 7 + 13) .. "_" .. string.char(65 + (index % 26))
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 2: LOAD ZYRONX UI LIBRARY (BLUE THEME)                    ║
-- ╚══════════════════════════════════════════════════════════════════════╝
-- Full ZyronX library embedded with Blue theme + Unlimited Tabs patch
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")

local Library = { WhitelistedUsers = {} }

local _isfolder = isfolder or function() return true end
local _makefolder = makefolder or function() end
local _writefile = writefile or function(path, data) warn("File saving not supported.") end
local _readfile = readfile or function() return "{}" end
local _listfiles = listfiles or function() return {} end
local _delfile = delfile or function() warn("File deletion not supported.") end

local function SafeCopyToClipboard(text)
    if setclipboard then setclipboard(text)
    elseif toclipboard then toclipboard(text)
    else warn("Clipboard not supported.") end
end

local function Create(className, properties)
    local instance = Instance.new(className)
    if className == "TextBox" then instance.Text = "" end
    for k, v in pairs(properties or {}) do instance[k] = v end
    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") then
        if properties.TextSize and properties.RichText ~= true then
            instance.TextScaled = true
            local constraint = Instance.new("UITextSizeConstraint")
            constraint.MaxTextSize = properties.TextSize
            constraint.MinTextSize = 6
            constraint.Parent = instance
        end
    end
    return instance
end

local function BuildSearchIndex(card)
    local parts = {}
    for _, desc in ipairs(card:GetDescendants()) do
        if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
            if desc.Text and desc.Text ~= "" then table.insert(parts, desc.Text:lower()) end
        end
    end
    return table.concat(parts, " ")
end

local function Tween(instance, properties, duration)
    duration = duration or 0.25
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

local function AddBounce(button, scaleFactor)
    scaleFactor = scaleFactor or 0.96
    local scaleObj = button:FindFirstChild("UIScale") or Create("UIScale", {Parent = button, Scale = 1})
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
    button.MouseLeave:Connect(function() Tween(scaleObj, {Scale = 1}, 0.15) end)
end

local function MakeDraggable(topbar, object)
    topbar.Active = true
    object.Active = true
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
            Tween(object, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.08)
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

local GlobalNotifContainer

function Library:Notify(options)
    if not GlobalNotifContainer then return end
    local title = options.Title or "Notification"
    local desc = options.Description or "Information updated."
    local duration = options.Duration or 3

    local Notif = Create("Frame", {Parent = GlobalNotifContainer, BackgroundColor3 = Color3.fromRGB(14, 18, 26), Size = UDim2.new(1, 0, 0, 65), BackgroundTransparency = 1, ZIndex = 201, ClipsDescendants = true})
    Create("UICorner", {Parent = Notif, CornerRadius = UDim.new(0, 8)})
    local Stroke = Create("UIStroke", {Parent = Notif, Color = AccentColor, Thickness = 1.5, Transparency = 1})
    local TitleText = Create("TextLabel", {Parent = Notif, Text = title, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 15), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})
    local DescText = Create("TextLabel", {Parent = Notif, Text = desc, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 15, 0, 32), Size = UDim2.new(1, -30, 0, 15), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 202})

    Tween(Notif, {BackgroundTransparency = 0}, 0.3)
    Tween(Stroke, {Transparency = 0}, 0.3)
    Tween(TitleText, {TextTransparency = 0}, 0.3)
    Tween(DescText, {TextTransparency = 0}, 0.3)

    task.delay(duration, function()
        Tween(Notif, {BackgroundTransparency = 1}, 0.4)
        Tween(Stroke, {Transparency = 1}, 0.4)
        Tween(TitleText, {TextTransparency = 1}, 0.4)
        Tween(DescText, {TextTransparency = 1}, 0.4)
        task.wait(0.4); Notif:Destroy()
    end)
end

function Library:CreateWindow(options)
    local hubName = "EXO Hub"
    local subText = "SENTINEL AI | v8.0"
    local subColor = AccentColor
    local sphTextToggle = true
    local sphWords = "EXO"
    local sphImage = nil
    local topbarLogo = nil
    local logoSize = 32
    local sphIconSize = 26

    if type(options) == "table" then
        hubName = options.Title or hubName
        subText = options.Subtitle or subText
        subColor = options.SubtitleColor or subColor
        if options.SphereText ~= nil then sphTextToggle = options.SphereText end
        if options.SphereWords ~= nil then
            local wordList = string.split(tostring(options.SphereWords), " ")
            if #wordList > 2 then sphWords = wordList[1] .. " " .. wordList[2]
            else sphWords = tostring(options.SphereWords) end
        end
        sphImage = options.SphereImage
        topbarLogo = options.Logo
        logoSize = options.LogoSize or 32
        sphIconSize = options.SphereIconSize or 26
    elseif type(options) == "string" then hubName = options end

    local uniqueID = HttpService:GenerateGUID(false)
    local ScreenGui = Create("ScreenGui", {
        Name = "EXO_ZX_" .. uniqueID,
        Parent = RunService:IsStudio() and game.Players.LocalPlayer:WaitForChild("PlayerGui") or CoreGui,
        ResetOnSpawn = false, IgnoreGuiInset = true
    })

    local NotifContainer = Create("Frame", {
        Parent = ScreenGui, BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, -20), Position = UDim2.new(1, -340, 0, 10),
        ZIndex = 200, Active = false
    })
    Create("UIListLayout", {Parent = NotifContainer, VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12)})
    GlobalNotifContainer = NotifContainer

    -- Info Overlay
    local InfoOverlay = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = Color3.fromRGB(5, 5, 8), BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), ZIndex = 150, Visible = false, Active = true})
    local InfoCard = Create("Frame", {Parent = InfoOverlay, BackgroundColor3 = Color3.fromRGB(14, 18, 26), Size = UDim2.new(0, 360, 0, 280), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 151, BackgroundTransparency = 1, ClipsDescendants = true})
    Create("UICorner", {Parent = InfoCard, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = InfoCard, Color = AccentColor, Thickness = 1.5, Transparency = 1})
    local InfoScale = Create("UIScale", {Parent = InfoCard, Scale = 0})
    local InfoHeader = Create("Frame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), ZIndex = 152})
    local InfoTitle = Create("TextLabel", {Parent = InfoHeader, Text = "Feature Info", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 20, 0, 0), Size = UDim2.new(1, -60, 1, 0), TextXAlignment = Enum.TextXAlignment.Left, TextTransparency = 1, ZIndex = 152})
    local InfoCloseBtn = Create("TextButton", {Parent = InfoHeader, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), ZIndex = 152, TextTransparency = 1})
    AddBounce(InfoCloseBtn)
    local InfoScroll = Create("ScrollingFrame", {Parent = InfoCard, BackgroundTransparency = 1, Size = UDim2.new(1, -40, 1, -60), Position = UDim2.new(0, 20, 0, 50), CanvasSize = UDim2.new(0, 0, 0, 0), ScrollBarThickness = 2, ScrollBarImageColor3 = AccentColor, BorderSizePixel = 0, ZIndex = 152})
    local InfoLayout = Create("UIListLayout", {Parent = InfoScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
    local InfoDesc = Create("TextLabel", {Parent = InfoScroll, Text = "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 152, TextTransparency = 1})
    InfoLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() InfoScroll.CanvasSize = UDim2.new(0, 0, 0, InfoLayout.AbsoluteContentSize.Y + 10) end)

    local function OpenInfoWindow(data)
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
        task.wait(0.3); InfoOverlay.Visible = false
    end)

    local function AddInfoIcon(parent, pos, data)
        if not data then return end
        local Btn = Create("TextButton", {Parent = parent, Text = "?", Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(25, 35, 55), Size = UDim2.new(0, 16, 0, 16), Position = pos, AutoButtonColor = false, ZIndex = 5})
        Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(1, 0)})
        AddBounce(Btn)
        Btn.MouseEnter:Connect(function() Tween(Btn, {TextColor3 = TextColor, BackgroundColor3 = AccentColor}, 0.2) end)
        Btn.MouseLeave:Connect(function() Tween(Btn, {TextColor3 = SubTextColor, BackgroundColor3 = Color3.fromRGB(25, 35, 55)}, 0.2) end)
        Btn.MouseButton1Click:Connect(function() OpenInfoWindow(data) end)
    end

    local MainFrame = Create("Frame", {Parent = ScreenGui, BackgroundColor3 = BackgroundColor, Size = UDim2.new(0, 650, 0, 450), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), ClipsDescendants = true, BackgroundTransparency = 1, Active = true})
    local MainScale = Create("UIScale", {Parent = MainFrame, Scale = 0.8})
    Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = MainFrame, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
    Tween(MainScale, {Scale = 1}, 0.5)
    Tween(MainFrame, {BackgroundTransparency = 0}, 0.5)

    -- Floating Bottom Bar
    local BottomDragHitbox = Create("Frame", {Parent = ScreenGui, BackgroundTransparency = 1, Size = UDim2.new(0, 350, 0, 30), AnchorPoint = Vector2.new(0.5, 0.5), ZIndex = 145, Active = true})
    local FloatingBottomBar = Create("Frame", {Parent = BottomDragHitbox, BackgroundColor3 = CardColor, BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), ZIndex = 146})
    Create("UICorner", {Parent = FloatingBottomBar, CornerRadius = UDim.new(1, 0)})
    local BottomBarStroke = Create("UIStroke", {Parent = FloatingBottomBar, Color = Color3.fromRGB(30, 50, 80), Thickness = 1.2, Transparency = 0})
    MakeDraggable(BottomDragHitbox, MainFrame)

    RunService.RenderStepped:Connect(function()
        if MainFrame and MainFrame.Visible then
            BottomDragHitbox.Visible = true
            local currentScale = MainScale.Scale
            local frameHeight = 450 * currentScale
            local frameWidth = 650 * currentScale
            BottomDragHitbox.Position = UDim2.new(MainFrame.Position.X.Scale, MainFrame.Position.X.Offset, MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset + (frameHeight / 2) + 20)
            BottomDragHitbox.Size = UDim2.new(0, frameWidth * 0.6, 0, 30 * currentScale)
            FloatingBottomBar.Size = UDim2.new(1, 0, 0, 6 * currentScale)
            FloatingBottomBar.Position = UDim2.new(0, 0, 0.5, -(3 * currentScale))
        else BottomDragHitbox.Visible = false end
    end)

    local TopBar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, 0), Active = true})
    MakeDraggable(TopBar, MainFrame)

    local titleOffsetX = 15
    if topbarLogo then
        local TopbarIcon = Create("ImageLabel", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, logoSize, 0, logoSize), Position = UDim2.new(0, 8, 0.5, -(logoSize / 2)), Image = topbarLogo, ScaleType = Enum.ScaleType.Fit})
        titleOffsetX = 8 + logoSize + 8
    end

    local TitleContainer = Create("Frame", {Parent = TopBar, BackgroundTransparency = 1, Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, titleOffsetX, 0, 0)})
    local Title = Create("TextLabel", {Parent = TitleContainer, Text = hubName, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = TextColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 5), Size = UDim2.new(1, 0, 0, 16), TextXAlignment = Enum.TextXAlignment.Left})
    local Subtitle = Create("TextLabel", {Parent = TitleContainer, Text = subText, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = subColor, BackgroundTransparency = 1, Position = UDim2.new(0, 0, 0, 22), Size = UDim2.new(1, 0, 0, 12), TextXAlignment = Enum.TextXAlignment.Left})

    local SearchBar = Create("Frame", {Parent = TopBar, BackgroundColor3 = CardColor, Size = UDim2.new(0, 220, 0, 26), Position = UDim2.new(0, 220, 0.5, -13)})
    Create("UICorner", {Parent = SearchBar, CornerRadius = UDim.new(0, 6)})
    local SearchIcon = Create("ImageLabel", {Parent = SearchBar, BackgroundTransparency = 1, Image = "rbxassetid://6031154871", ImageColor3 = SubTextColor, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7)})
    local SearchInput = Create("TextBox", {Parent = SearchBar, BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Position = UDim2.new(0, 30, 0, 0), Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, PlaceholderText = "Search..", TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})

    local CloseBtn = Create("TextButton", {Parent = TopBar, Text = "X", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -35, 0, 0)})
    local MinBtn = Create("TextButton", {Parent = TopBar, Text = "—", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 1, 0), Position = UDim2.new(1, -65, 0, 0)})

    -- Sidebar (UNLIMITED TABS FIX)
    local Sidebar = Create("Frame", {Parent = MainFrame, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 1, Size = UDim2.new(0, 160, 1, -40), Position = UDim2.new(0, 0, 0, 40), Active = true})
    local TabContainer = Create("ScrollingFrame", {Parent = Sidebar, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 2, ScrollBarImageColor3 = AccentColor, CanvasSize = UDim2.new(0, 0, 0, 0)})
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    TabContainer.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabContainer.UIListLayout.AbsoluteContentSize.Y + 10)
    end)

    local Divider = Create("Frame", {Parent = MainFrame, BackgroundColor3 = Color3.fromRGB(30, 50, 80), BorderSizePixel = 0, Size = UDim2.new(0, 1, 1, -40), Position = UDim2.new(0, 160, 0, 40)})
    local ContentArea = Create("Frame", {Parent = MainFrame, BackgroundTransparency = 1, Size = UDim2.new(1, -165, 1, -40), Position = UDim2.new(0, 165, 0, 40), Active = true})

    -- Minimize Sphere
    local Sphere = Create("ImageButton", {Parent = ScreenGui, BackgroundColor3 = BackgroundColor, BackgroundTransparency = 0.2, Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), Visible = false, AutoButtonColor = false, ImageTransparency = 1, ClipsDescendants = true})
    Create("UICorner", {Parent = Sphere, CornerRadius = UDim.new(1, 0)})
    Create("UIStroke", {Parent = Sphere, Color = AccentColor, Thickness = 2})
    local SphereTextLabel = Create("TextLabel", {Parent = Sphere, Text = sphWords, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = AccentColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), TextTransparency = 1, Visible = sphTextToggle})
    MakeDraggable(Sphere, Sphere)

    local Window = {CurrentTab = nil, Tabs = {}, Title = Title, AllCards = {}, MainFrame = MainFrame, CurrentTransparency = 0, ConfigElements = {}}

    function Window:SetTransparency(val)
        Window.CurrentTransparency = val
        if MainFrame.Visible then
            Tween(MainFrame, {BackgroundTransparency = val}, 0.3)
            Tween(FloatingBottomBar, {BackgroundTransparency = val > 0 and 0.2 or 0}, 0.3)
        end
    end

    MinBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0}, 0.4)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.4)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.4)
        Tween(BottomBarStroke, {Transparency = 1}, 0.4)
        task.wait(0.3)
        MainFrame.Visible = false; BottomDragHitbox.Visible = false
        Sphere.Visible = true
        Tween(Sphere, {Size = UDim2.new(0, 50, 0, 50)}, 0.4)
        if sphTextToggle then Tween(SphereTextLabel, {TextTransparency = 0}, 0.4) end
    end)

    Sphere.MouseButton1Click:Connect(function()
        Tween(Sphere, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        if sphTextToggle then Tween(SphereTextLabel, {TextTransparency = 1}, 0.3) end
        task.wait(0.2)
        Sphere.Visible = false; MainFrame.Visible = true; BottomDragHitbox.Visible = true
        Tween(MainScale, {Scale = 1}, 0.4)
        Tween(MainFrame, {BackgroundTransparency = Window.CurrentTransparency}, 0.4)
        Tween(FloatingBottomBar, {BackgroundTransparency = Window.CurrentTransparency > 0 and 0.2 or 0}, 0.4)
        Tween(BottomBarStroke, {Transparency = 0}, 0.4)
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(MainScale, {Scale = 0.8}, 0.3)
        Tween(MainFrame, {BackgroundTransparency = 1}, 0.3)
        Tween(FloatingBottomBar, {BackgroundTransparency = 1}, 0.3)
        Tween(BottomBarStroke, {Transparency = 1}, 0.3)
        for _, desc in ipairs(MainFrame:GetDescendants()) do
            if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
                Tween(desc, {TextTransparency = 1}, 0.3)
                if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then Tween(desc, {ImageTransparency = 1}, 0.3)
            elseif desc:IsA("Frame") or desc:IsA("ScrollingFrame") then if desc.BackgroundTransparency < 1 then Tween(desc, {BackgroundTransparency = 1}, 0.3) end
            elseif desc:IsA("UIStroke") then Tween(desc, {Transparency = 1}, 0.3) end
        end
        task.wait(0.35); ScreenGui:Destroy()
    end)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        if query == "" then
            for _, data in ipairs(Window.AllCards) do data.Card.Parent = data.OrigParent; data.Card.Visible = true end
        else
            if not Window.CurrentTab or not Window.CurrentTab.CurrentPage then return end
            local activeLeft = Window.CurrentTab.CurrentPage.LeftCol
            local activeRight = Window.CurrentTab.CurrentPage.RightCol
            local placeLeft = true
            for _, data in ipairs(Window.AllCards) do
                local card = data.Card
                if data.Tab == Window.CurrentTab then
                    if not data.SearchIndex then data.SearchIndex = BuildSearchIndex(card) end
                    local match = string.find(data.SearchIndex, query, 1, true)
                    if match then card.Parent = placeLeft and activeLeft or activeRight; placeLeft = not placeLeft; card.Visible = true
                    else card.Visible = false end
                else card.Parent = data.OrigParent; card.Visible = true end
            end
        end
    end)

    function Window:CreateTab(tabName, isDefault, isLocked)
        local isWhitelisted = false
        local player = game:GetService("Players").LocalPlayer
        if player then
            for _, allowedUser in ipairs(Library.WhitelistedUsers) do
                if player.Name == allowedUser or player.DisplayName == allowedUser then isWhitelisted = true; break end
            end
        end

        local TabBtn = Create("TextButton", {Parent = TabContainer, Text = "", BackgroundColor3 = HoverColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35), AutoButtonColor = false})
        Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        AddBounce(TabBtn, 0.98)
        local Indicator = Create("Frame", {Name = "Indicator", Parent = TabBtn, BackgroundColor3 = isLocked and Color3.fromRGB(255, 215, 0) or AccentColor, Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0), AnchorPoint = Vector2.new(0, 0.5)})
        Create("UICorner", {Parent = Indicator, CornerRadius = UDim.new(1, 0)})
        local Txt = Create("TextLabel", {Parent = TabBtn, Text = tabName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 15, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})

        if isLocked then
            Create("ImageLabel", {Parent = TabBtn, Image = "rbxassetid://6031082533", ImageColor3 = Color3.fromRGB(255, 215, 0), BackgroundTransparency = 1, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -22, 0.5, -7)})
        end

        local TabContent = Create("Frame", {Parent = ContentArea, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Visible = false})
        local PageNav = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 35)})
        local PageNavList = Create("UIListLayout", {Parent = PageNav, FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 15), VerticalAlignment = Enum.VerticalAlignment.Center})
        local PageContainer = Create("Frame", {Parent = TabContent, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, -35), Position = UDim2.new(0, 0, 0, 35)})

        local TabConfig = {Button = TabBtn, Content = TabContent, Indicator = Indicator, Txt = Txt, Pages = {}, CurrentPage = nil}
        table.insert(Window.Tabs, TabConfig)

        TabBtn.MouseButton1Click:Connect(function()
            if isLocked and not isWhitelisted then Library:Notify({Title = "ACCESS DENIED", Description = "This tab is whitelisted."}); return end
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
            local PageBtn = Create("TextButton", {Parent = PageNav, Text = pageName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
            local PageHighlight = Create("Frame", {Parent = PageBtn, BackgroundColor3 = AccentColor, Size = UDim2.new(0, 0, 0, 2), Position = UDim2.new(0.5, 0, 1, -5), AnchorPoint = Vector2.new(0.5, 0), BackgroundTransparency = 1})
            local PageScroll = Create("ScrollingFrame", {Parent = PageContainer, BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 80, 120), Visible = false, BorderSizePixel = 0})
            local LeftColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0)})
            local RightColumn = Create("Frame", {Parent = PageScroll, BackgroundTransparency = 1, Size = UDim2.new(0.5, -5, 1, 0), Position = UDim2.new(0.5, 5, 0, 0)})
            local L_Layout = Create("UIListLayout", {Parent = LeftColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            local R_Layout = Create("UIListLayout", {Parent = RightColumn, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)})
            L_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)
            R_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() PageScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(L_Layout.AbsoluteContentSize.Y, R_Layout.AbsoluteContentSize.Y) + 20) end)

            local PageObj = {Scroll = PageScroll, Btn = PageBtn, Highlight = PageHighlight, Left = true, LeftCol = LeftColumn, RightCol = RightColumn}
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
                local targetColumn = PageObj.Left and LeftColumn or RightColumn
                PageObj.Left = not PageObj.Left
                local SectionContainer = Create("Frame", {Parent = targetColumn, BackgroundColor3 = CardColor, Size = UDim2.new(1, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, ClipsDescendants = true})
                Create("UICorner", {Parent = SectionContainer, CornerRadius = UDim.new(0, 6)})
                table.insert(Window.AllCards, {Card = SectionContainer, OrigParent = targetColumn, Tab = TabConfig, Page = PageObj, SearchIndex = nil})
                local TitleLbl = Create("TextLabel", {Parent = SectionContainer, Text = sectionName, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 30), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                local ItemContainer = Create("Frame", {Parent = SectionContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y})
                local Pad = Create("UIPadding", {Parent = ItemContainer, PaddingBottom = UDim.new(0, 10), PaddingTop = UDim.new(0, 5)})
                local SList = Create("UIListLayout", {Parent = ItemContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

                local Elements = {}

                function Elements:AddButton(name, callback, infoData)
                    local BtnFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 30)})
                    local Btn = Create("TextButton", {Parent = BtnFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), AutoButtonColor = false})
                    Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = Btn, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    AddBounce(Btn)
                    Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = HoverColor}, 0.2) end)
                    Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = BackgroundColor}, 0.2) end)
                    Btn.MouseButton1Click:Connect(function() if callback then callback() end end)
                    AddInfoIcon(BtnFrame, UDim2.new(1, -40, 0.5, -8), infoData)
                end

                function Elements:AddToggle(name, default, callback, infoData)
                    local state = default or false
                    local TogFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 24)})
                    Create("TextLabel", {Parent = TogFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local Lever = Create("TextButton", {Parent = TogFrame, Text = "", BackgroundColor3 = state and AccentColor or Color3.fromRGB(30, 40, 60), Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -46, 0.5, -9), AutoButtonColor = false})
                    Create("UICorner", {Parent = Lever, CornerRadius = UDim.new(1, 0)})
                    AddBounce(Lever)
                    local Knob = Create("Frame", {Parent = Lever, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 14, 0, 14), Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
                    local function internalSet(val)
                        state = val
                        Tween(Lever, {BackgroundColor3 = state and AccentColor or Color3.fromRGB(30, 40, 60)}, 0.3)
                        Tween(Knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.3)
                        if callback then callback(state) end
                    end
                    Lever.MouseButton1Click:Connect(function() internalSet(not state) end)
                    AddInfoIcon(TogFrame, UDim2.new(1, -70, 0.5, -8), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return state end}
                end

                function Elements:AddSlider(name, min, max, default, callback, infoData)
                    local val = default or min
                    local SliFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 45)})
                    Create("TextLabel", {Parent = SliFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local ValTxt = Create("TextLabel", {Parent = SliFrame, Text = tostring(val), Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = TextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 15), Position = UDim2.new(1, -40, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
                    local TrackBase = Create("Frame", {Parent = SliFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 25)})
                    Create("UICorner", {Parent = TrackBase, CornerRadius = UDim.new(1, 0)})
                    Create("UIStroke", {Parent = TrackBase, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    local Fill = Create("Frame", {Parent = TrackBase, BackgroundColor3 = AccentColor, Size = UDim2.new((val-min)/(max-min), 0, 1, 0)})
                    Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})
                    local Knob = Create("Frame", {Parent = Fill, BackgroundColor3 = Color3.fromRGB(255, 255, 255), Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -6, 0.5, -6)})
                    Create("UICorner", {Parent = Knob, CornerRadius = UDim.new(1, 0)})
                    local function internalSet(v)
                        val = math.clamp(v, min, max)
                        ValTxt.Text = tostring(val)
                        Tween(Fill, {Size = UDim2.new((val-min)/(max-min), 0, 1, 0)}, 0.1)
                        if callback then callback(val) end
                    end
                    local dragging = false
                    local function Update(input)
                        local pos = math.clamp((input.Position.X - TrackBase.AbsolutePosition.X) / TrackBase.AbsoluteSize.X, 0, 1)
                        internalSet(math.floor(min + ((max - min) * pos)))
                    end
                    Knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                    UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then Update(input) end end)
                    AddInfoIcon(SliFrame, UDim2.new(1, -65, 0, 0), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return val end}
                end

                function Elements:AddDropdown(name, options, isMulti, callback, infoData)
                    local selected = isMulti and {} or (options[1] or nil)
                    local dropped = false
                    local optionButtons = {}
                    -- UNLIMITED DROPDOWN FIX: No maxVisible cap
                    local listHeight = math.min(#options * 25, 200)
                    local dropOpenHeight = 50 + 32 + listHeight

                    local DropFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), ClipsDescendants = true})
                    Create("TextLabel", {Parent = DropFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local MainBtn = Create("TextButton", {Parent = DropFrame, Text = isMulti and "Select Options..." or "Select...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), AutoButtonColor = false, TextXAlignment = Enum.TextXAlignment.Left})
                    Create("UIPadding", {Parent = MainBtn, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = MainBtn, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = MainBtn, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    AddBounce(MainBtn, 0.98)
                    local Arrow = Create("TextLabel", {Parent = MainBtn, Text = "▼", Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -28, 0, 0)})

                    local SearchBox = Create("TextBox", {Parent = DropFrame, PlaceholderText = "Search...", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = Color3.fromRGB(10, 12, 18), Size = UDim2.new(1, -20, 0, 24), Position = UDim2.new(0, 10, 0, 50), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Visible = false})
                    Create("UIPadding", {Parent = SearchBox, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = SearchBox, CornerRadius = UDim.new(0, 4)})
                    Create("UIStroke", {Parent = SearchBox, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})

                    local ListFrame = Create("ScrollingFrame", {Parent = DropFrame, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, listHeight), Position = UDim2.new(0, 10, 0, 78), CanvasSize = UDim2.new(0, 0, 0, #options * 25), ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(60, 80, 120), BorderSizePixel = 0})
                    Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 4)})
                    local DList = Create("UIListLayout", {Parent = ListFrame, SortOrder = Enum.SortOrder.LayoutOrder})

                    local function UpdateText()
                        if isMulti then
                            local txt = ""
                            for _, v in pairs(selected) do txt = txt .. v .. ", " end
                            MainBtn.Text = txt == "" and "Select Options..." or txt:sub(1, -3)
                        else MainBtn.Text = selected or "Select..." end
                    end

                    local function internalSet(v)
                        selected = v; UpdateText()
                        for _, btn in ipairs(optionButtons) do
                            local isSel = false
                            if isMulti then isSel = table.find(selected, btn.Text) ~= nil
                            else isSel = (selected == btn.Text) end
                            Tween(btn, {TextColor3 = isSel and TextColor or SubTextColor}, 0.2)
                            Tween(btn:FindFirstChild("Check"), {Size = isSel and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0)}, 0.2)
                        end
                        if callback then callback(selected) end
                    end

                    for _, opt in pairs(options) do
                        local isInitialSelected = (not isMulti and selected == opt)
                        local OptBtn = Create("TextButton", {Parent = ListFrame, Text = opt, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = isInitialSelected and TextColor or SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 25), AutoButtonColor = false})
                        local Check = Create("Frame", {Parent = OptBtn, Name = "Check", BackgroundColor3 = AccentColor, Size = isInitialSelected and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0), BackgroundTransparency = 0.8})
                        table.insert(optionButtons, OptBtn)
                        OptBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                if table.find(selected, opt) then table.remove(selected, table.find(selected, opt))
                                else table.insert(selected, opt) end
                                internalSet(selected)
                            else
                                internalSet(opt); dropped = false
                                Tween(Arrow, {Rotation = 0}, 0.3)
                                Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
                                SearchBox.Visible = false
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
                            local newOpenHeight = 50 + 32 + dynamicHeight
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newOpenHeight)}, 0.1)
                        end
                    end)

                    MainBtn.MouseButton1Click:Connect(function()
                        dropped = not dropped
                        if dropped then
                            SearchBox.Visible = true; SearchBox.Text = ""
                            Tween(Arrow, {Rotation = 180}, 0.3)
                            local dynamicHeight = math.min(DList.AbsoluteContentSize.Y, 200)
                            local newOpenHeight = 50 + 32 + dynamicHeight
                            ListFrame.Size = UDim2.new(1, -20, 0, dynamicHeight)
                            Tween(DropFrame, {Size = UDim2.new(1, 0, 0, newOpenHeight)}, 0.3)
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
                    local TxtFrame = Create("Frame", {Parent = ItemContainer, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50)})
                    Create("TextLabel", {Parent = TxtFrame, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 15), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left})
                    local Input = Create("TextBox", {Parent = TxtFrame, PlaceholderText = placeholder or "Type here...", Text = "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = TextColor, BackgroundColor3 = BackgroundColor, Size = UDim2.new(1, -20, 0, 26), Position = UDim2.new(0, 10, 0, 20), TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
                    Create("UIPadding", {Parent = Input, PaddingLeft = UDim.new(0, 8)})
                    Create("UICorner", {Parent = Input, CornerRadius = UDim.new(0, 4)})
                    local Stroke = Create("UIStroke", {Parent = Input, Color = Color3.fromRGB(30, 50, 80), Thickness = 1})
                    local function internalSet(v) Input.Text = tostring(v); if callback then callback(v) end end
                    Input.FocusLost:Connect(function(enterPressed) internalSet(Input.Text) end)
                    AddInfoIcon(TxtFrame, UDim2.new(1, -25, 0, 0), infoData)
                    Window.ConfigElements[name] = {Set = internalSet, Get = function() return Input.Text end}
                end

                function Elements:AddLabel(text)
                    Create("TextLabel", {Parent = ItemContainer, Text = text, Font = Enum.Font.Gotham, TextSize = 11, TextColor3 = SubTextColor, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 18), Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
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
    return Window
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 3: SERVICES (FIXED: NO TRAILING SPACES)                   ║
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
local player            = Players.LocalPlayer

-- POST-DEFINITION INTEGRITY CHECK
pcall(function()
    if not Players then _EXO_INTEGRITY = false end
    if not RunService then _EXO_INTEGRITY = false end
    if not player then _EXO_INTEGRITY = false end
end)
if not _EXO_INTEGRITY then return end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 4: ENCODED CONSTANTS (ANTI-THEFT)                        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local HUB_KEY_RAW = string.char(69,88,79,83,84,65,75,69,79,86,69,82,82,56,36)
local HUB_KEY = _exo_decode(_exo_encode(HUB_KEY_RAW))
local KEY_FILE = "exo_v8_k.dat"
local CONFIG_FILE = "exo_v8_cfg.dat"
local LOG_FILE = "exo_v8_logs.dat"
local AI_PROFILE_FILE = "exo_v8_ai_profiles.dat"

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 5: FILE I/O ENGINE                                        ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function readFile(path)
    if isfile and readfile and isfile(path) then
        local ok, r = pcall(readfile, path)
        if ok then return r end
    end
    return nil
end

local function writeFile(path, data)
    if writefile then pcall(writefile, path, data) end
end

local function readJSON(path)
    local raw = readFile(path)
    if raw then
        local ok, d = pcall(HttpService.JSONDecode, HttpService, raw)
        if ok then return d end
    end
    return nil
end

local function writeJSON(path, data)
    local ok, e = pcall(HttpService.JSONEncode, HttpService, data)
    if ok then writeFile(path, e) end
end

local function appendLog(entry)
    local existing = readJSON(LOG_FILE) or {}
    table.insert(existing, entry)
    if #existing > 200 then table.remove(existing, 1) end
    writeJSON(LOG_FILE, existing)
end

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

-- GODLY Anti-Aura State (ALL ORIGINAL FIELDS PRESERVED)
local AntiAura            = {
    Enabled = false, GodMode = false, Repel = false,
    Reflect = false, Phase = false, HealAura = false,
    ShieldStack = 0, RepelForce = 120, RepelRadius = 18
}
local antiAuraConn        = nil
local antiAuraFF          = nil
local antiAuraPhaseConn   = nil

-- Threat Detection (GODLY – multi-layer)
local ThreatLevel         = 0
local LastThreatCheck     = 0
local ThreatRadius        = 60
local ThreatHistory       = {}
local ThreatTrend         = 0
local latencyEstimate     = 0.08
local ThreatDecay         = 0
local PeakThreat          = 0
local ThreatVelocity      = {}

-- GODLY Insta-Kill State
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

-- GODLY Hit Amplifier State
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

-- GODLY Tool Grabber State
local TG_Enabled          = false
local TG_padsByBase       = {}
local TG_registered       = {}
local TG_WavePriority     = true
local TG_BurstCount       = 12

-- Kill Intelligence System (EXPANDED)
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

-- Strategy Engine
local StrategyEngine = {
    ActiveStrategy = nil,
    StrategyHistory = {},
    FeatureCombinations = {},
    LastStrategyTime = 0,
    SuccessRate = {},
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
-- ║  SECTION 12: SENTINEL AI – THREAT PROFILER                         ║
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
        }
    end
    return ThreatProfiles[killerName]
end

local function AI_DetectFeatures(killData, profile)
    local features = {}

    -- LOOPBRING DETECTION
    if killData.TTK < 0.3 and killData.Distance < 8 then
        features["LoopBring"] = 85
        if profile.TotalKills > 2 and profile.AvgTTK < 0.4 then
            features["LoopBring"] = 95
        end
    end

    -- KILL AURA DETECTION
    if killData.Distance > 5 and killData.Distance < 15 and killData.TTK < 0.5 then
        features["KillAura"] = 75
        if killData.Weapon == "Unknown" then
            features["KillAura"] = 90
        end
    end

    -- REACH DETECTION
    if killData.Distance > 25 then
        features["Reach"] = 80
        if killData.Distance > 40 then
            features["Reach"] = 95
        end
    end

    -- FAST KILL / REMOTE SPAM
    if killData.TTK < 0.2 then
        features["FastKill"] = 85
        features["RemoteSpam"] = 70
    end

    -- FIGHT EVENT ABUSE
    if killData.Weapon == "Unknown" and killData.TTK < 0.5 then
        features["FightEventAbuse"] = 80
    end

    -- HIT AMPLIFIER
    if killData.Distance > 15 and killData.Distance <= 30 and killData.TTK < 0.8 then
        features["HitAmplifier"] = 70
    end

    -- TOOL FOLLOW
    if killData.Distance < 3 and profile.TotalKills > 3 then
        features["ToolFollow"] = 75
    end

    -- SPAWN KILL
    if killData.TimeSinceRespawn and killData.TimeSinceRespawn < 2 then
        features["SpawnKill"] = 90
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
    if #profile.EngagementHistory > 30 then
        table.remove(profile.EngagementHistory, 1)
    end

    -- Feature detection with confidence scoring
    local features = AI_DetectFeatures(killData, profile)
    for feature, confidence in pairs(features) do
        local prev = profile.Confidence[feature] or 0
        profile.Confidence[feature] = math.min(100, math.max(prev, confidence))
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
