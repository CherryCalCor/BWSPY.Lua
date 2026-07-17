local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local hookmetamethod = hookmetamethod or (hookfunction and function(obj, meta, func)
    local mt = getrawmetatable(obj)
    local old = mt[meta]
    if setreadonly then setreadonly(mt, false) end
    mt[meta] = func
    if setreadonly then setreadonly(mt, true) end
    return old
end)
local newcclosure = newcclosure or function(f) return f end
local checkcaller = checkcaller or function() return false end
local setclipboard = setclipboard or (toclipboard or print)
local getgc = getgc or function() return {} end

if CoreGui:FindFirstChild("BWSPY_Gui") then
    CoreGui.BWSPY_Gui:Destroy()
end

local function formatValue(val, indentLevel)
    local t = typeof(val)
    local indent = string.rep("    ", indentLevel or 0)
    
    if t == "string" then
        return '"' .. val:gsub('"', '\\"') .. '"'
    elseif t == "number" or t == "boolean" then
        return tostring(val)
    elseif t == "Instance" then
        if val.Parent == nil then return "nil --[[ Destroyed Instance ]]" end
        return val:GetFullName()
    elseif t == "Vector3" then
        return string.format("Vector3.new(%f, %f, %f)", val.X, val.Y, val.Z)
    elseif t == "CFrame" then
        return string.format("CFrame.new(%f, %f, %f)", val.X, val.Y, val.Z)
    elseif t == "Color3" then
        return string.format("Color3.new(%f, %f, %f)", val.R, val.G, val.B)
    elseif t == "table" then
        local str = "{\n"
        local newIndent = indent .. "    "
        for k, v in pairs(val) do
            local keyStr = type(k) == "string" and '["' .. k .. '"]' or "[" .. tostring(k) .. "]"
            str = str .. newIndent .. keyStr .. " = " .. formatValue(v, (indentLevel or 0) + 1) .. ",\n"
        end
        return str .. indent .. "}"
    else
        return "nil --[[ " .. t .. " ]]"
    end
end

local function generateRemoteDetails(remote, method, args)
    local name = tostring(remote.Name)
    local path = typeof(remote) == "Instance" and remote:GetFullName() or "Unknown"
    local id = "N/A"
    pcall(function()
        id = remote:GetAttribute("Id") or remote:GetAttribute("ID") or "N/A"
    end)

    local displayText = "--- [ PACKET DETAILS ] ---\n"
    displayText = displayText .. "Name: " .. name .. "\n"
    displayText = displayText .. "ID: " .. tostring(id) .. "\n"
    displayText = displayText .. "Method: " .. method .. "\n"
    displayText = displayText .. "Path:\n" .. path .. "\n"
    
    displayText = displayText .. "\n--- [ ARGUMENTS ] ---\n"
    if #args == 0 then
        displayText = displayText .. "No arguments\n"
    else
        for i, arg in ipairs(args) do
            displayText = displayText .. "[" .. i .. "] = " .. formatValue(arg, 0) .. "\n"
        end
    end

    displayText = displayText .. "\n--- [ READY CODE ] ---\n"
    local codeToCopy = "local args = {\n"
    for i, arg in ipairs(args) do
        codeToCopy = codeToCopy .. "    [" .. i .. "] = " .. formatValue(arg, 1) .. ",\n"
    end
    codeToCopy = codeToCopy .. "}\n\n"
    codeToCopy = codeToCopy .. "game." .. path .. ":" .. method .. "(unpack(args))"
    displayText = displayText .. codeToCopy

    return displayText, codeToCopy
end

local function generatePacketDetails(name, id, args)
    local displayText = "--- [ PACKET (Alt Method) ] ---\n"
    displayText = displayText .. "Name: " .. tostring(name) .. "\n"
    displayText = displayText .. "ID: " .. tostring(id) .. "\n"
    
    displayText = displayText .. "\n--- [ ARGUMENTS ] ---\n"
    if #args == 0 then
        displayText = displayText .. "No arguments\n"
    else
        for i, arg in ipairs(args) do
            displayText = displayText .. "[" .. i .. "] = " .. formatValue(arg, 0) .. "\n"
        end
    end
    return displayText, ""
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BWSPY_Gui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Size = UDim2.new(0, 650, 0, 400)
MainFrame.Position = UDim2.new(0.5, -325, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 30)
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -120, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "BWSPY V1.01 | Beta Test"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SettingsBtn = Instance.new("ImageButton")
SettingsBtn.Size = UDim2.new(0, 18, 0, 18)
SettingsBtn.Position = UDim2.new(1, -90, 0.5, -9)
SettingsBtn.BackgroundTransparency = 1
SettingsBtn.Image = "rbxassetid://104919049969988" 
SettingsBtn.ImageColor3 = Color3.fromRGB(200, 200, 200)
SettingsBtn.ZIndex = 10
SettingsBtn.Parent = TopBar

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 18
MinimizeBtn.ZIndex = 10
MinimizeBtn.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 10
CloseBtn.Parent = TopBar

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, 0, 1, -30)
ContentHolder.Position = UDim2.new(0, 0, 0, 30)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = MainFrame

local LeftPanel = Instance.new("ScrollingFrame")
LeftPanel.Size = UDim2.new(0.35, -10, 1, -10)
LeftPanel.Position = UDim2.new(0, 5, 0, 5)
LeftPanel.BackgroundTransparency = 1
LeftPanel.ScrollBarThickness = 2
LeftPanel.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
LeftPanel.AutomaticCanvasSize = Enum.AutomaticSize.Y
LeftPanel.CanvasSize = UDim2.new(0, 0, 0, 0)
LeftPanel.Parent = ContentHolder

local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Padding = UDim.new(0, 4)
LeftLayout.Parent = LeftPanel

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0.65, -10, 1, -10)
RightPanel.Position = UDim2.new(0.35, 5, 0, 5)
RightPanel.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
RightPanel.BorderSizePixel = 0
RightPanel.Parent = ContentHolder

Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 6)

local CodeScroll = Instance.new("ScrollingFrame")
CodeScroll.Size = UDim2.new(1, -10, 1, -35)
CodeScroll.Position = UDim2.new(0, 5, 0, 5)
CodeScroll.BackgroundTransparency = 1
CodeScroll.ScrollBarThickness = 2
CodeScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
CodeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
CodeScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
CodeScroll.Parent = RightPanel

local CodeText = Instance.new("TextLabel")
CodeText.Size = UDim2.new(1, -5, 0, 0)
CodeText.Position = UDim2.new(0, 5, 0, 0)
CodeText.BackgroundTransparency = 1
CodeText.Text = "-- Select RemoteEvent to view details"
CodeText.TextColor3 = Color3.fromRGB(200, 200, 200)
CodeText.Font = Enum.Font.Code
CodeText.TextSize = 13
CodeText.TextXAlignment = Enum.TextXAlignment.Left
CodeText.TextYAlignment = Enum.TextYAlignment.Top
CodeText.TextWrapped = true
CodeText.AutomaticSize = Enum.AutomaticSize.Y
CodeText.Parent = CodeScroll

local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(1, -10, 0, 24)
CopyBtn.Position = UDim2.new(0, 5, 1, -29)
CopyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CopyBtn.Text = "Copy Code Only"
CopyBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 11
CopyBtn.Parent = RightPanel
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, 0, 1, 0)
SettingsFrame.Position = UDim2.new(1, 0, 0, 0) 
SettingsFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame

local SettingsTopBar = Instance.new("Frame")
SettingsTopBar.Size = UDim2.new(1, 0, 0, 30)
SettingsTopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
SettingsTopBar.BorderSizePixel = 0
SettingsTopBar.Parent = SettingsFrame

local BackBtn = Instance.new("TextButton")
BackBtn.Size = UDim2.new(0, 60, 1, 0)
BackBtn.Position = UDim2.new(0, 5, 0, 0)
BackBtn.BackgroundTransparency = 1
BackBtn.Text = "< Back"
BackBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
BackBtn.Font = Enum.Font.GothamBold
BackBtn.TextSize = 13
BackBtn.ZIndex = 10
BackBtn.Parent = SettingsTopBar

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -150, 1, 0)
SettingsTitle.Position = UDim2.new(0, 75, 0, 0)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "Settings"
SettingsTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.TextSize = 13
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Parent = SettingsTopBar

local SettingsMinimizeBtn = Instance.new("TextButton")
SettingsMinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
SettingsMinimizeBtn.Position = UDim2.new(1, -60, 0, 0)
SettingsMinimizeBtn.BackgroundTransparency = 1
SettingsMinimizeBtn.Text = "-"
SettingsMinimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsMinimizeBtn.Font = Enum.Font.GothamBold
SettingsMinimizeBtn.TextSize = 18
SettingsMinimizeBtn.ZIndex = 10
SettingsMinimizeBtn.Parent = SettingsTopBar

local SettingsCloseBtn = Instance.new("TextButton")
SettingsCloseBtn.Size = UDim2.new(0, 30, 0, 30)
SettingsCloseBtn.Position = UDim2.new(1, -30, 0, 0)
SettingsCloseBtn.BackgroundTransparency = 1
SettingsCloseBtn.Text = "X"
SettingsCloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
SettingsCloseBtn.Font = Enum.Font.GothamBold
SettingsCloseBtn.TextSize = 14
SettingsCloseBtn.ZIndex = 10
SettingsCloseBtn.Parent = SettingsTopBar

local SettingsContent = Instance.new("Frame")
SettingsContent.Size = UDim2.new(1, 0, 1, -30)
SettingsContent.Position = UDim2.new(0, 0, 0, 30)
SettingsContent.BackgroundTransparency = 1
SettingsContent.Parent = SettingsFrame

local showPing = true
local useAlternativeMethod = false
local alternativeOriginalFire = nil
local alternativeHookedTable = nil

local function createGitHubToggle(parent, labelText, yOffset)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -20, 0, 40)
    Frame.Position = UDim2.new(0, 10, 0, yOffset)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = labelText
    Label.TextColor3 = Color3.fromRGB(220, 220, 220)
    Label.Font = Enum.Font.GothamBold
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -52, 0.5, -10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleBtn.Text = ""
    ToggleBtn.Parent = Frame
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10) -- Полностью скругленный
    ToggleCorner.Parent = ToggleBtn

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 14, 0, 14)
    Indicator.Position = UDim2.new(0, 3, 0.5, -7)
    Indicator.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = ToggleBtn
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(0, 4) w
    IndicatorCorner.Parent = Indicator

    return ToggleBtn, Indicator
end

local PingToggleBtn, PingIndicator = createGitHubToggle(SettingsContent, "Show Ping Remotes", 15)
local AltMethodToggleBtn, AltMethodIndicator = createGitHubToggle(SettingsContent, "Alternative Method (getgc)", 65)

local function updateToggleVisual(btn, indicator, state)
    local targetBtnColor = state and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(35, 35, 35)
    local targetIndicatorColor = state and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(150, 150, 150)
    local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

    TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {BackgroundColor3 = targetBtnColor}):Play()
    TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {BackgroundColor3 = targetIndicatorColor, Position = targetPos}):Play()
end

local function applyHoverEffect(obj, defaultCol, hoverCol, prop)
    prop = prop or "BackgroundColor3"
    obj.MouseEnter:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {[prop] = hoverCol}):Play()
    end)
    obj.MouseLeave:Connect(function()
        TweenService:Create(obj, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {[prop] = defaultCol}):Play()
    end)
end

applyHoverEffect(MinimizeBtn, Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 255, 255), "TextColor3")
applyHoverEffect(CloseBtn, Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 80, 80), "TextColor3")
applyHoverEffect(SettingsMinimizeBtn, Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 255, 255), "TextColor3")
applyHoverEffect(SettingsCloseBtn, Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 80, 80), "TextColor3")
applyHoverEffect(BackBtn, Color3.fromRGB(200, 200, 200), Color3.fromRGB(255, 255, 255), "TextColor3")
applyHoverEffect(CopyBtn, Color3.fromRGB(30, 30, 30), Color3.fromRGB(45, 45, 45))

SettingsBtn.MouseEnter:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Rotation = 45, ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
SettingsBtn.MouseLeave:Connect(function()
    TweenService:Create(SettingsBtn, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Rotation = 0, ImageColor3 = Color3.fromRGB(200, 200, 200)}):Play()
end)

local function showSettings()
    SettingsFrame.Position = UDim2.new(1, 0, 0, 0)
    SettingsFrame.Visible = true
    TweenService:Create(SettingsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(ContentHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Position = UDim2.new(-1, 0, 0, 30)}):Play()
end

local function hideSettings()
    TweenService:Create(SettingsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Position = UDim2.new(1, 0, 0, 0)}):Play()
    TweenService:Create(ContentHolder, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Position = UDim2.new(0, 0, 0, 30)}):Play()
    task.wait(0.3)
    SettingsFrame.Visible = false
end

SettingsBtn.Activated:Connect(showSettings)
BackBtn.Activated:Connect(hideSettings)

local dragging, dragStart, startPos

local function isMouseOverButton(button)
    local mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local x, y = mouse.X, mouse.Y
    local absPos = button.AbsolutePosition
    local absSize = button.AbsoluteSize
    return x >= absPos.X and x <= absPos.X + absSize.X and y >= absPos.Y and y <= absPos.Y + absSize.Y
end

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isMouseOverButton(MinimizeBtn) or isMouseOverButton(CloseBtn) or isMouseOverButton(SettingsBtn) or 
           isMouseOverButton(SettingsMinimizeBtn) or isMouseOverButton(SettingsCloseBtn) or isMouseOverButton(BackBtn) then
            return
        end
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end

TopBar.InputBegan:Connect(onInputBegan)
SettingsTopBar.InputBegan:Connect(onInputBegan)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local isMinimized = false
local function toggleMinimize()
    isMinimized = not isMinimized
    local targetSize = isMinimized and UDim2.new(0, 650, 0, 30) or UDim2.new(0, 650, 0, 400)
    ContentHolder.Visible = not isMinimized
    if SettingsFrame.Visible then
        SettingsFrame.Visible = false
    end
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingStyle.Out), {Size = targetSize}):Play()
end

MinimizeBtn.Activated:Connect(toggleMinimize)
SettingsMinimizeBtn.Activated:Connect(toggleMinimize)

local function closeGui()
    local fadeTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingStyle.In), {Size = UDim2.new(0, 650, 0, 0)})
    fadeTween:Play()
    fadeTween.Completed:Connect(function()
        ScreenGui:Destroy()
    end)
end

CloseBtn.Activated:Connect(closeGui)
SettingsCloseBtn.Activated:Connect(closeGui)

local currentCopyCode = ""
CopyBtn.Activated:Connect(function()
    if currentCopyCode ~= "" then
        setclipboard(currentCopyCode)
        CopyBtn.Text = "Code copied!"
        task.wait(1.5)
        CopyBtn.Text = "Copy Code Only"
    end
end)

local LogQueue = {}
local MAX_LOGS = 150

local function AddLogToUI(entry)
    local LogFrame = Instance.new("TextButton")
    LogFrame.Size = UDim2.new(1, 0, 0, 25)
    LogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LogFrame.Text = ""
    LogFrame.Parent = LeftPanel
    Instance.new("UICorner", LogFrame).CornerRadius = UDim.new(0, 4)

    local methodLabel, methodColor
    local displayName

    if entry.type == "Packet" then
        methodLabel = "PKT"
        methodColor = Color3.fromRGB(130, 130, 130)
        displayName = entry.name .. " [" .. entry.id .. "]"
    else
        methodLabel = entry.method == "FireServer" and "FIRE" or "INVK"
        methodColor = entry.method == "FireServer" and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(170, 170, 170)
        displayName = tostring(entry.remote.Name)
    end

    local MethodLbl = Instance.new("TextLabel", LogFrame)
    MethodLbl.Size = UDim2.new(0, 40, 1, 0); MethodLbl.Position = UDim2.new(0, 5, 0, 0)
    MethodLbl.BackgroundTransparency = 1
    MethodLbl.Text = methodLabel
    MethodLbl.TextColor3 = methodColor
    MethodLbl.Font = Enum.Font.Code; MethodLbl.TextSize = 11; MethodLbl.TextXAlignment = Enum.TextXAlignment.Left

    local NameLbl = Instance.new("TextLabel", LogFrame)
    NameLbl.Size = UDim2.new(1, -50, 1, 0); NameLbl.Position = UDim2.new(0, 45, 0, 0)
    NameLbl.BackgroundTransparency = 1; NameLbl.Text = displayName; NameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
    NameLbl.Font = Enum.Font.Code; NameLbl.TextSize = 11; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
    NameLbl.TextTruncate = Enum.TextTruncate.AtEnd

    applyHoverEffect(LogFrame, Color3.fromRGB(20, 20, 20), Color3.fromRGB(30, 30, 30))

    LogFrame.Activated:Connect(function()
        if entry.type == "Packet" then
            local uiText, copyCode = generatePacketDetails(entry.name, entry.id, entry.args)
            CodeText.Text = uiText
            currentCopyCode = copyCode
        else
            local uiText, copyCode = generateRemoteDetails(entry.remote, entry.method, entry.args)
            CodeText.Text = uiText
            currentCopyCode = copyCode
        end
    end)

    if #LeftPanel:GetChildren() > MAX_LOGS + 1 then
        for i, child in ipairs(LeftPanel:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy(); break end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if #LogQueue > 0 then
        local data = table.remove(LogQueue, 1)
        pcall(AddLogToUI, data)
    end
end)

local trueOriginalNamecall
local oldNamecall

local namecallHook = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
        local args = {...}
        local blacklist = {"UpdateMouse", "Heartbeat", "Move", "Mouse"} 
        local isSpam = false
        for _, name in ipairs(blacklist) do
            if string.find(self.Name, name) then isSpam = true break end
        end
        if not isSpam and (showPing or not string.find(self.Name, "Ping")) then
            table.insert(LogQueue, {
                type = "Remote",
                remote = self,
                method = method,
                args = args
            })
        end
    end
    
    if oldNamecall then
        return oldNamecall(self, ...)
    else
        local mt = getrawmetatable and getrawmetatable(game)
        local orig = mt and mt.__namecall
        if orig then
            return orig(self, ...)
        end
    end
end)

if hookmetamethod then
    trueOriginalNamecall = hookmetamethod(game, "__namecall", namecallHook)
    oldNamecall = trueOriginalNamecall
else
    CodeText.Text = "// [ERROR] hookmetamethod is not supported on this executor."
end

PingToggleBtn.Activated:Connect(function()
    showPing = not showPing
    updateToggleVisual(PingToggleBtn, PingIndicator, showPing)
end)

AltMethodToggleBtn.Activated:Connect(function()
    useAlternativeMethod = not useAlternativeMethod
    updateToggleVisual(AltMethodToggleBtn, AltMethodIndicator, useAlternativeMethod)
    
    if useAlternativeMethod then
        local foundTable = nil
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "Type") == "Packet" and rawget(v, "Fire") then
                foundTable = v
                break
            end
        end
        if foundTable then
            alternativeOriginalFire = foundTable.Fire
            alternativeHookedTable = foundTable
            foundTable.Fire = function(self, ...)
                local args = {...}
                local name = tostring(self.Name)
                local id = tostring(self.Id)
                if showPing or not string.find(name, "Ping") then
                    table.insert(LogQueue, {
                        type = "Packet",
                        name = name,
                        id = id,
                        args = args
                    })
                end
                return alternativeOriginalFire(self, ...)
            end
            if trueOriginalNamecall then
                pcall(function()
                    hookmetamethod(game, "__namecall", trueOriginalNamecall)
                end)
            end
            CodeText.Text = "// Alternate method activated (PacketTable hooked)"
        else
            useAlternativeMethod = false
            updateToggleVisual(AltMethodToggleBtn, AltMethodIndicator, false)
            CodeText.Text = "// [ERROR] PacketTable not found. Alternative method cannot be enabled."
        end
    else
        if alternativeHookedTable and alternativeOriginalFire then
            alternativeHookedTable.Fire = alternativeOriginalFire
            alternativeHookedTable = nil
            alternativeOriginalFire = nil
        end
        if hookmetamethod then
            pcall(function()
                oldNamecall = hookmetamethod(game, "__namecall", namecallHook)
            end)
        end
        CodeText.Text = "// Alternate method disabled, standard hook restored"
    end
end)

updateToggleVisual(PingToggleBtn, PingIndicator, showPing)
updateToggleVisual(AltMethodToggleBtn, AltMethodIndicator, useAlternativeMethod)
