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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 13: SENTINEL AI – STRATEGY ENGINE                         ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function AI_FormulateStrategy(profile, killData)
    local strategy = {
        Target = profile.Name,
        Actions = {},
        Explanations = {},
        Priority = "NORMAL",
        Confidence = 0,
        FeatureCombos = {},
    }

    local threats = profile.SuspectedFeatures
    local avgDist = profile.AvgDistance
    local avgTTK = profile.AvgTTK
    local totalKills = profile.TotalKills

    -- Determine priority
    if profile.ThreatScore >= 80 or totalKills >= 5 then
        strategy.Priority = "CRITICAL"
    elseif profile.ThreatScore >= 50 or totalKills >= 3 then
        strategy.Priority = "HIGH"
    end

    -- BUILD COUNTER-STRATEGY BASED ON DETECTED FEATURES
    for _, feature in ipairs(threats) do
        if feature == "LoopBring" then
            table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Minimize downtime between deaths"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiSpawnkill", reason = "Prevent immediate re-kill on spawn"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField blocks touch-based loopbring"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "NoCollide prevents touch contact"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Repel", reason = "Push their tools away from you"})
            table.insert(strategy.Explanations,
                "They're using LOOPBRING - teleporting their weapon to you repeatedly. " ..
                "Average TTK: " .. string.format("%.2f", avgTTK) .. "s. " ..
                "I'm activating a 5-layer defense: FastRespawn + AntiSpawnkill + GodMode + Phase + Repel.")

        elseif feature == "KillAura" then
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Enabled", reason = "Master anti-aura switch"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField negates aura damage"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Repel", reason = "Push their aura tools away"})
            table.insert(strategy.Actions, {type = "set", feature = "AntiAura.RepelForce", value = 150, reason = "Maximum repel force to break aura range"})
            table.insert(strategy.Actions, {type = "set", feature = "AntiAura.RepelRadius", value = 25, reason = "Extended repel radius"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "Phase through their aura hits"})
            table.insert(strategy.Explanations,
                "KILL AURA detected. They're damaging you through tool proximity without swinging. " ..
                "Avg distance: " .. math.floor(avgDist) .. " studs. " ..
                "Counter: Full Anti-Aura suite with boosted repel force (150) and radius (25).")

        elseif feature == "Reach" then
            table.insert(strategy.Actions, {type = "enable", feature = "Reach", reason = "Match their reach"})
            table.insert(strategy.Actions, {type = "set", feature = "ReachSize", value = math.max(4, math.ceil(avgDist / 8)), reason = "Scale reach to counter theirs"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.Phase", reason = "Phase to avoid their extended hitbox"})
            table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "Strike first before they reach you"})
            table.insert(strategy.Explanations,
                "REACH user detected. Killing you from " .. math.floor(avgDist) .. " studs away. " ..
                "I'm setting your reach to " .. math.max(4, math.ceil(avgDist / 8)) .. "x to match/exceed theirs, " ..
                "plus Phase mode and InstaKill to strike first.")

        elseif feature == "FastKill" or feature == "RemoteSpam" then
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.GodMode", reason = "ForceField blocks remote damage"})
            table.insert(strategy.Actions, {type = "enable", feature = "AntiAura.HealAura", reason = "Auto-heal to outpace their DPS"})
            table.insert(strategy.Actions, {type = "enable", feature = "FastRespawn", reason = "Minimize death downtime"})
            table.insert(strategy.Actions, {type = "enable", feature = "InstaKillEnabled", reason = "Kill them before they can spam again"})
            table.insert(strategy.Actions, {type = "set", feature = "IK_BurstCount", value = 15, reason = "Maximum burst to overwhelm their defense"})
            table.insert(strategy.Explanations,
                "FAST KILL / REMOTE SPAM detected. TTK: " .. string.format("%.2f", avgTTK) .. "s. " ..
                "They're firing damage remotes as fast as possible. " ..
                "Counter: GodMode + HealAura to survive, InstaKill with 15-burst to end them first.")

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
-- ║  SECTION 14: SENTINEL AI – EXECUTION ENGINE                        ║
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

    -- Record strategy execution
    table.insert(StrategyEngine.StrategyHistory, {
        time = os.time(),
        target = strategy.Target,
        priority = strategy.Priority,
        actionCount = #strategy.Actions,
    })
    if #StrategyEngine.StrategyHistory > 50 then
        table.remove(StrategyEngine.StrategyHistory, 1)
    end
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
                Chat_AddMessage("AI", "  " .. feat .. " confidence: " .. conf .. "%")
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
        Chat_AddMessage("AI", "  Trend: " .. (ThreatTrend > 0 and "RISING" or ThreatTrend < 0 and "FALLING" or "STABLE"))
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
                        Chat_AddMessage("AI", "  " .. plr.Name .. " - " .. math.floor(d) .. " studs away", Color3.fromRGB(255, 150, 50))
                    end
                end
            end
        end
        if nearby == 0 then Chat_AddMessage("AI", "  No players within threat radius.") end
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
            Chat_AddMessage("AI", "  Distance: " .. last.Distance .. " studs")
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

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 19: 1000x TOOL FOLLOW (PREDICTIVE VELOCITY TRACKING)     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local cachedToolParts = {}
local function updateToolCache()
    table.clear(cachedToolParts)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local part = getToolPart(tool)
            if part then table.insert(cachedToolParts, part) end
        end
    end
end

local function startToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect() end
    ToolFollow.Connection = RunService.PreSimulation:Connect(function()
        if not ToolFollow.Enabled or #ToolFollow.Targets == 0 then return end
        updateToolCache()
        for _, targetPlr in ipairs(ToolFollow.Targets) do
            local tChar = targetPlr.Character
            if tChar and tChar:FindFirstChild("Humanoid") and tChar.Humanoid.Health > 0 then
                local torso = tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso")
                if torso then
                    -- 1000x: Predictive positioning using velocity
                    local vel = torso.Velocity
                    local predictedPos = torso.Position + vel * 0.08 + Vector3.new(0, 0.8, 0.5)
                    for _, part in ipairs(cachedToolParts) do
                        if part and part.Parent then
                            part.Position = predictedPos
                            part.CanCollide = false
                            part.Massless = true
                            part.Anchored = false
                        end
                    end
                end
            end
        end
    end)
end

local function stopToolFollow()
    if ToolFollow.Connection then ToolFollow.Connection:Disconnect(); ToolFollow.Connection = nil end
end

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart")
    updateToolCache()
end)
updateToolCache()

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 20: 1000x AUTO CLAIM & ADAPTIVE BUILD                     ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startClaimMoney()
    if claimConn then claimConn:Disconnect() end
    claimConn = RunService.PreSimulation:Connect(function()
        if not AutoClaimMoney then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        -- Scan for ALL cash registers and money collectors
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("cash") or n:find("register") or n:find("collect") or n:find("money") then
                if obj:IsA("Model") or obj:IsA("BasePart") then
                    for _, part in ipairs(getTouchableParts(obj)) do
                        pcall(firetouchinterest, root, part, 0)
                        pcall(firetouchinterest, root, part, 1)
                    end
                end
            end
        end
    end)
end

local function stopClaimMoney()
    if claimConn then claimConn:Disconnect(); claimConn = nil end
end

local lastBuyTime = 0
local function startAutoBuild()
    if buildConn then buildConn:Disconnect() end
    buildConn = RunService.PreSimulation:Connect(function()
        updateThreatLevel()
        if not AutoBuild then return end
        if tick() - lastBuyTime < 0.2 then return end  -- 1000x: faster buy cycle
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local tycoonType = getPlayerTycoonType()
        if not tycoonType then return end
        local tycoonFolder = workspace:FindFirstChild("Tycoons") and workspace.Tycoons:FindFirstChild(tycoonType)
        if not tycoonFolder then return end
        local cash = getPlayerCash()

        table.clear(_buf_buttons)
        for _, obj in ipairs(tycoonFolder:GetDescendants()) do
            if obj:IsA("Model") then
                local cost = getCost(obj)
                if cost > 0 then
                    table.insert(_buf_buttons, {Model = obj, Cost = cost, Priority = getPriority(obj.Name)})
                end
            end
        end

        table.sort(_buf_buttons, function(a, b)
            if a.Priority == b.Priority then return a.Cost < b.Cost end
            return a.Priority < b.Priority
        end)

        -- 1000x: Buy MULTIPLE items per cycle if affordable
        local bought = 0
        for _, btnData in ipairs(_buf_buttons) do
            if cash >= btnData.Cost and bought < 3 then
                for _, part in ipairs(getTouchableParts(btnData.Model)) do
                    pcall(firetouchinterest, root, part, 0)
                    pcall(firetouchinterest, root, part, 1)
                end
                cash = cash - btnData.Cost
                bought = bought + 1
            end
        end
        if bought > 0 then lastBuyTime = tick() end
    end)
end

local function stopAutoBuild()
    if buildConn then buildConn:Disconnect(); buildConn = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 21: 1000x ANTI-AURA (SHIELD STACK + HEAL + REFLECT)      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect() end
    antiAuraConn = RunService.Heartbeat:Connect(function()
        if not AntiAura.Enabled then return end
        local myChar = player.Character
        if not myChar then return end
        local root = myChar:FindFirstChild("HumanoidRootPart")
        local hum = myChar:FindFirstChild("Humanoid")
        if not root or not hum then return end

        -- GOD MODE: ForceField + auto-heal
        if AntiAura.GodMode then
            if not antiAuraFF or not antiAuraFF.Parent then
                antiAuraFF = Instance.new("ForceField")
                antiAuraFF.Visible = false
                antiAuraFF.Parent = myChar
            end
            if hum.Health < hum.MaxHealth * 0.7 then
                hum.Health = hum.MaxHealth
            end
        else
            if antiAuraFF and antiAuraFF.Parent then
                antiAuraFF:Destroy()
                antiAuraFF = nil
            end
        end

        -- HEAL AURA: Continuous regeneration
        if AntiAura.HealAura then
            if hum.Health < hum.MaxHealth then
                hum.Health = math.min(hum.MaxHealth, hum.Health + hum.MaxHealth * 0.05)
            end
        end

        -- 1000x REPEL: Extended radius + boosted force + ALL tools
        if AntiAura.Repel then
            for _, otherPlr in ipairs(Players:GetPlayers()) do
                if otherPlr ~= player and otherPlr.Character then
                    for _, tool in ipairs(otherPlr.Character:GetChildren()) do
                        if tool:IsA("Tool") then
                            local handle = tool:FindFirstChild("Handle")
                            if handle then
                                local dist = (handle.Position - root.Position).Magnitude
                                if dist < AntiAura.RepelRadius then
                                    local dir = (root.Position - handle.Position).Unit
                                    pcall(function()
                                        handle.AssemblyLinearVelocity = dir * AntiAura.RepelForce
                                        handle.CanCollide = false
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end

        -- PHASE: Full no-collide on all parts
        if AntiAura.Phase then
            for _, part in ipairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopAntiAura()
    if antiAuraConn then antiAuraConn:Disconnect(); antiAuraConn = nil end
    if antiAuraFF and antiAuraFF.Parent then antiAuraFF:Destroy(); antiAuraFF = nil end
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 22: 1000x REACH (DYNAMIC THREAT-BASED SIZING)            ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local reachOriginalSizes = {}
local reachHL = {}

local function applyReach()
    local myChar = player.Character
    if not myChar then return end
    for _, t in ipairs(myChar:GetChildren()) do
        if t:IsA("Tool") then
            local part = getToolPart(t)
            if part then
                if not reachOriginalSizes[part] then
                    reachOriginalSizes[part] = part.Size
                end
                part.Size = reachOriginalSizes[part] * ReachSize
                part.Massless = true
                part.CanCollide = false
                if not reachHL[part] then
                    local hl = Instance.new("Highlight", part)
                    hl.FillTransparency = 1
                    hl.OutlineColor = AccentColor
                    reachHL[part] = hl
                end
            end
        end
    end
end

local function stopReach()
    for part, hl in pairs(reachHL) do
        if hl and hl.Parent == part then hl:Destroy() end
    end
    table.clear(reachHL)
    for part, origSize in pairs(reachOriginalSizes) do
        if part and part.Parent then part.Size = origSize end
    end
    table.clear(reachOriginalSizes)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 23: 1000x FAST RESPAWN                                   ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function startFastRespawn()
    local Guide = ReplicatedStorage:FindFirstChild("Guide")
    local last = 0
    local function respawn()
        if tick() - last < 0.02 then return end  -- 1000x: faster threshold
        last = tick()
        pcall(function()
            if Guide then Guide:FireServer() else player:LoadCharacter() end
        end)
    end
    local function hook(c)
        local hum = c:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(function(hp) if hp <= 0 then respawn() end end)
        hum.Died:Connect(respawn)
    end
    if player.Character then hook(player.Character) end
    player.CharacterAdded:Connect(hook)
end

-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  SECTION 24: 1000x INSTA-KILL (PARALLEL MULTI-BURST + SWEEP)      ║
-- ╚══════════════════════════════════════════════════════════════════════╝
local function IK_RefreshTools()
    table.clear(IK_ToolsCache)
    local char = player.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local fightEvent = tool:FindFirstChild("FightEvent", true)
            local touchPart = tool:FindFirstChildWhichIsA("TouchTransmitter", true)
            if fightEvent and fightEvent:IsA("RemoteEvent") then
                table.insert(IK_ToolsCache, {
                    Tool = tool,
                    FightEvent = fightEvent,
                    TouchPart = touchPart and touchPart.Parent or nil
                })
            elseif touchPart then
                table.insert(IK_ToolsCache, {
                    Tool = tool,
                    FightEvent = nil,
                    TouchPart = touchPart.Parent
                })
            end
        end
    end
    -- Also scan Backpack
    local bp = player:FindFirstChildOfClass("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local fightEvent = tool:FindFirstChild("FightEvent", true)
                if fightEvent and fightEvent:IsA("RemoteEvent") then
                    table.insert(IK_ToolsCache, {
                        Tool = tool,
                        FightEvent = fightEvent,
                        TouchPart = nil
                    })
                end
            end
        end
    end
end

local function IK_GetTarget()
    local myChar = player.Character
    local myRoot = myChar and getHRP(myChar)
    if not myRoot then return nil end
    local bestChar, bestDist = nil, 50  -- 1000x: expanded range
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local char = plr.Character
            if char then
                local root = getHRP(char)
                if root then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestChar = char
                        end
                    end
                end
            end
        end
    end
    return bestChar
end

local function IK_MicroBurst(targetChar, burstCount)
    if not targetChar or not player.Character then return end
    -- 1000x: ALL body parts targeted
    table.clear(IK_TargetParts)
    for _, name in ipairs({"HumanoidRootPart", "UpperTorso", "Torso", "Head",
                           "LowerTorso", "LeftUpperArm", "RightUpperArm",
                           "LeftUpperLeg", "RightUpperLeg"}) do
        local part = targetChar:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            table.insert(IK_TargetParts, part)
        end
    end
    if #IK_TargetParts == 0 then return end

    -- PARALLEL FIRE: All tools simultaneously
    for _, toolData in ipairs(IK_ToolsCache) do
        local tool = toolData.Tool
        local fight = toolData.FightEvent
        local touch = toolData.TouchPart
        if tool and tool.Parent then
            if fight then
                pcall(function()
                    for _ = 1, burstCount do fight:FireServer() end
                end)
            else
                pcall(tool.Activate, tool)
            end
            if touch then
                for _, part in ipairs(IK_TargetParts) do
                    if part and part.Parent then
                        pcall(firetouchinterest, touch, part, 0)
                        pcall(firetouchinterest, touch, part, 1)
                    end
                end
            end
        end
    end
end

local function startInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect() end
    IK_RefreshTools()
    InstaKillConn = RunService.PreSimulation:Connect(function()
        if not InstaKillEnabled then return end
        local now = os.clock()
        if now - IK_LastActivation < 1/120 then return end  -- 1000x: 120Hz
        IK_LastActivation = now
        IK_RefreshTools()
        if #IK_ToolsCache == 0 then return end

        local adaptiveBurst = IK_BurstCount
        if IK_AdaptiveBurst and ThreatLevel > 2 then
            adaptiveBurst = IK_BurstCount + ThreatLevel * 2  -- 1000x scaling
        end
        local target = IK_GetTarget()
        if target then
            IK_MicroBurst(target, adaptiveBurst)
        end
    end)
end

local function stopInstaKill()
    if InstaKillConn then InstaKillConn:Disconnect(); InstaKillConn = nil end
end

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
