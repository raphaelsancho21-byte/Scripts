local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local TweenService   = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

local lockedTarget  = nil
local isSelectMode  = false
local isGUIVisible  = true
local lockConn      = nil

local lastTarget      = nil
local memoryRemaining = 0
local MEMORY_DURATION = 5
local memoryConn      = nil

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "CamLockGUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name              = "MainFrame"
MainFrame.Size              = UDim2.new(0, 215, 0, 175)
MainFrame.Position          = UDim2.new(0.5, -107, 0, 20)
MainFrame.BackgroundColor3  = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel   = 0
MainFrame.Active            = true
MainFrame.Draggable         = true
MainFrame.Parent            = ScreenGui

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function addStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color     = color or Color3.fromRGB(60, 60, 60)
    s.Thickness = thickness or 1
    s.Parent    = parent
end

addCorner(MainFrame)
addStroke(MainFrame)

local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 32)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame
addCorner(TitleBar)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size                   = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text                   = "🎯  CamLock"
TitleLabel.TextColor3             = Color3.fromRGB(240, 240, 240)
TitleLabel.TextSize               = 14
TitleLabel.Font                   = Enum.Font.GothamBold
TitleLabel.Parent                 = TitleBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size                   = UDim2.new(1, -16, 0, 20)
StatusLabel.Position               = UDim2.new(0, 8, 0, 38)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text                   = "Status: Inativo"
StatusLabel.TextColor3             = Color3.fromRGB(160, 160, 160)
StatusLabel.TextSize               = 12
StatusLabel.Font                   = Enum.Font.Gotham
StatusLabel.TextXAlignment         = Enum.TextXAlignment.Left
StatusLabel.Parent                 = MainFrame

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size                   = UDim2.new(1, -16, 0, 20)
TargetLabel.Position               = UDim2.new(0, 8, 0, 60)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text                   = "Alvo: nenhum"
TargetLabel.TextColor3             = Color3.fromRGB(160, 160, 160)
TargetLabel.TextSize               = 12
TargetLabel.Font                   = Enum.Font.Gotham
TargetLabel.TextXAlignment         = Enum.TextXAlignment.Left
TargetLabel.Parent                 = MainFrame

local MemoryContainer = Instance.new("Frame")
MemoryContainer.Size             = UDim2.new(1, -16, 0, 26)
MemoryContainer.Position         = UDim2.new(0, 8, 0, 84)
MemoryContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MemoryContainer.BorderSizePixel  = 0
MemoryContainer.Visible          = false
MemoryContainer.Parent           = MainFrame
addCorner(MemoryContainer, 5)
addStroke(MemoryContainer, Color3.fromRGB(80, 60, 20))

local MemoryBarBG = Instance.new("Frame")
MemoryBarBG.Size             = UDim2.new(1, 0, 1, 0)
MemoryBarBG.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MemoryBarBG.BorderSizePixel  = 0
MemoryBarBG.Parent           = MemoryContainer
addCorner(MemoryBarBG, 5)

local MemoryBar = Instance.new("Frame")
MemoryBar.Size             = UDim2.new(1, 0, 1, 0)
MemoryBar.BackgroundColor3 = Color3.fromRGB(255, 165, 30)
MemoryBar.BorderSizePixel  = 0
MemoryBar.ZIndex           = 2
MemoryBar.Parent           = MemoryBarBG
addCorner(MemoryBar, 5)

local MemoryLabel = Instance.new("TextLabel")
MemoryLabel.Size                   = UDim2.new(1, 0, 1, 0)
MemoryLabel.BackgroundTransparency = 1
MemoryLabel.Text                   = "⏱ Memória: 5.0s"
MemoryLabel.TextColor3             = Color3.fromRGB(255, 255, 255)
MemoryLabel.TextSize               = 11
MemoryLabel.Font                   = Enum.Font.GothamBold
MemoryLabel.ZIndex                 = 3
MemoryLabel.Parent                 = MemoryContainer

local LockButton = Instance.new("TextButton")
LockButton.Size             = UDim2.new(1, -16, 0, 34)
LockButton.Position         = UDim2.new(0, 8, 0, 132)
LockButton.BackgroundColor3 = Color3.fromRGB(50, 130, 60)
LockButton.BorderSizePixel  = 0
LockButton.Text             = "Selecionar Alvo"
LockButton.TextColor3       = Color3.fromRGB(255, 255, 255)
LockButton.TextSize         = 13
LockButton.Font             = Enum.Font.GothamBold
LockButton.Parent           = MainFrame
addCorner(LockButton, 6)

local FloatButton = Instance.new("TextButton")
FloatButton.Size             = UDim2.new(0, 44, 0, 44)
FloatButton.Position         = UDim2.new(1, -58, 0.5, -22)
FloatButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
FloatButton.BorderSizePixel  = 0
FloatButton.Text             = "🎯"
FloatButton.TextSize         = 22
FloatButton.ZIndex           = 10
FloatButton.Parent           = ScreenGui
addCorner(FloatButton, 10)
addStroke(FloatButton, Color3.fromRGB(70, 70, 70))

local function clearMemory()
    lastTarget      = nil
    memoryRemaining = 0
    if memoryConn then
        memoryConn:Disconnect()
        memoryConn = nil
    end
    MemoryContainer.Visible = false
    MemoryBar.Size = UDim2.new(1, 0, 1, 0)
end

local function startMemoryCountdown(player)
    clearMemory()

    lastTarget      = player
    memoryRemaining = MEMORY_DURATION
    MemoryContainer.Visible = true

    memoryConn = RunService.RenderStepped:Connect(function(dt)
        memoryRemaining = memoryRemaining - dt

        if memoryRemaining <= 0 then
            clearMemory()
            LockButton.Text = "Selecionar Alvo"
            TweenService:Create(LockButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(50, 130, 60)}
            ):Play()
            return
        end

        local ratio = memoryRemaining / MEMORY_DURATION
        MemoryBar.Size = UDim2.new(ratio, 0, 1, 0)

        local r = 255
        local g = math.floor(math.max(30, ratio * 165))
        MemoryBar.BackgroundColor3 = Color3.fromRGB(r, g, 30)

        MemoryLabel.Text = string.format(
            "⏱ Memória: %.1fs  —  %s",
            memoryRemaining,
            lastTarget and lastTarget.Name or "?"
        )

        if not lockedTarget and not isSelectMode then
            LockButton.Text = string.format(
                "🔄  Re-Travar  [%.1fs]",
                memoryRemaining
            )
        end
    end)
end

local function updateUI()
    if lockedTarget then
        StatusLabel.Text       = "Status: 🔒 Travado"
        StatusLabel.TextColor3 = Color3.fromRGB(80, 220, 100)
        TargetLabel.Text       = "Alvo: " .. lockedTarget.Name
        TargetLabel.TextColor3 = Color3.fromRGB(90, 190, 255)
        LockButton.Text        = "🔓  Destravar"
        TweenService:Create(LockButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(180, 50, 50)}
        ):Play()

    elseif isSelectMode then
        StatusLabel.Text       = "Status: ⌛ Clique num player..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        TargetLabel.Text       = "Alvo: nenhum"
        TargetLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        LockButton.Text        = "❌  Cancelar"
        TweenService:Create(LockButton,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(140, 90, 20)}
        ):Play()

    else
        StatusLabel.Text       = "Status: Inativo"
        StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        TargetLabel.Text       = "Alvo: nenhum"
        TargetLabel.TextColor3 = Color3.fromRGB(160, 160, 160)

        if lastTarget and memoryRemaining > 0 then
            LockButton.Text = string.format(
                "🔄  Re-Travar  [%.1fs]",
                memoryRemaining
            )
            TweenService:Create(LockButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(70, 70, 190)}
            ):Play()
        else
            LockButton.Text = "Selecionar Alvo"
            TweenService:Create(LockButton,
                TweenInfo.new(0.2),
                {BackgroundColor3 = Color3.fromRGB(50, 130, 60)}
            ):Play()
        end
    end
end

local function unlock()
    local prev = lockedTarget
    lockedTarget = nil
    isSelectMode = false
    Camera.CameraType = Enum.CameraType.Custom

    if lockConn then
        lockConn:Disconnect()
        lockConn = nil
    end
  
    if prev then
        startMemoryCountdown(prev)
    end

    updateUI()
end

local function lockOnTarget(targetPlayer)
    clearMemory()

    lockedTarget = targetPlayer
    isSelectMode = false

    if lockConn then lockConn:Disconnect() end

    lockConn = RunService.RenderStepped:Connect(function()
        if not lockedTarget
        or not lockedTarget.Character
        or not lockedTarget.Character:FindFirstChild("HumanoidRootPart") then
            unlock()
            return
        end

        local char  = lockedTarget.Character
        local head  = char:FindFirstChild("Head")
        local hrp   = char:FindFirstChild("HumanoidRootPart")
        local focus = head and head.Position or hrp.Position

        Camera.CFrame = CFrame.new(Camera.CFrame.Position, focus)
    end)

    updateUI()
end

FloatButton.MouseButton1Click:Connect(function()
    isGUIVisible = not isGUIVisible
    MainFrame.Visible = isGUIVisible
    FloatButton.Text  = isGUIVisible and "🎯" or "👁"
end)

LockButton.MouseButton1Click:Connect(function()
    if lockedTarget then
        unlock()

    elseif isSelectMode then
        isSelectMode = false
        updateUI()

    else
        if lastTarget and memoryRemaining > 0 then
            if lastTarget.Character then
                lockOnTarget(lastTarget)
            else
                clearMemory()
                updateUI()
            end
        else
            isSelectMode = true
            updateUI()
        end
    end
end)

Mouse.Button1Down:Connect(function()
    if not isSelectMode then return end

    local hit = Mouse.Target
    if not hit then
        isSelectMode = false
        updateUI()
        return
    end

    local character = hit:FindFirstAncestorOfClass("Model")
    if not character then
        isSelectMode = false
        updateUI()
        return
    end

    local targetPlayer = Players:GetPlayerFromCharacter(character)

    if targetPlayer and targetPlayer ~= LocalPlayer then
        lockOnTarget(targetPlayer)
    else
        isSelectMode = false
        updateUI()
    end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    unlock()
    clearMemory()
end)

updateUI()
print("[CamLock] Iniciado — memória de 5s ativa!")
