local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local RAW_URL = "https://raw.githubusercontent.com/0arabic/TpPlayer/main/obfuscated_script-1787422096714.lua"

--- МОДУЛЬ АВТО-ОНОВЛЕННЯ З GITHUB ---
task.spawn(function()
    local successCurrent, currentCode = pcall(function() return game:HttpGet(RAW_URL) end)
    if not successCurrent then return end
    
    while task.wait(15) do
        local successNew, newCode = pcall(function() return game:HttpGet(RAW_URL) end)
        if successNew and newCode ~= currentCode then
            local pGui = localPlayer:FindFirstChild("PlayerGui")
            if pGui and pGui:FindFirstChild("FollowGui") then
                pGui.FollowGui:Destroy()
            end
            loadstring(newCode)()
            break
        end
    end
end)

--- ЗМІННІ НАЛАШТУВАНЬ ---
local isFollowing = false
local selectedPlayer = nil
local moveSpeed = 20
local triggerDistance = 150
local maxTravelSpeed = 60
local stopDistance = 3.5

local espEnabled = false
local espHighlights = {}
local espBillboardGuis = {}

local antiRagdollEnabled = false

--- ІНТЕРФЕЙС (GUI) ---
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FollowGui"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 210, 0, 285)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Text = " Follow & ESP Menu"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", mainFrame)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -30, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(0.9, 0, 0, 16)
statusLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
statusLabel.Text = "IDLE"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.BackgroundTransparency = 1
statusLabel.TextScaled = true

local playerBox = Instance.new("TextBox", mainFrame)
playerBox.Size = UDim2.new(0.9, 0, 0, 22)
playerBox.Position = UDim2.new(0.05, 0, 0.19, 0)
playerBox.PlaceholderText = "Username..."
playerBox.Text = ""
playerBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playerBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Size = UDim2.new(0.9, 0, 0, 22)
speedBox.Position = UDim2.new(0.05, 0, 0.28, 0)
speedBox.PlaceholderText = "Base Speed: 20"
speedBox.Text = "20"
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local distBox = Instance.new("TextBox", mainFrame)
distBox.Size = UDim2.new(0.9, 0, 0, 22)
distBox.Position = UDim2.new(0.05, 0, 0.37, 0)
distBox.PlaceholderText = "Trigger Dist: 150"
distBox.Text = "150"
distBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local maxSpeedBox = Instance.new("TextBox", mainFrame)
maxSpeedBox.Size = UDim2.new(0.9, 0, 0, 22)
maxSpeedBox.Position = UDim2.new(0.05, 0, 0.46, 0)
maxSpeedBox.PlaceholderText = "Max Travel Speed: 60"
maxSpeedBox.Text = "60"
maxSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
maxSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 24)
toggleBtn.Position = UDim2.new(0.05, 0, 0.56, 0)
toggleBtn.Text = "START"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local espBtn = Instance.new("TextButton", mainFrame)
espBtn.Size = UDim2.new(0.9, 0, 0, 24)
espBtn.Position = UDim2.new(0.05, 0, 0.68, 0)
espBtn.Text = "ESP: OFF"
espBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local antiRagdollBtn = Instance.new("TextButton", mainFrame)
antiRagdollBtn.Size = UDim2.new(0.9, 0, 0, 24)
antiRagdollBtn.Position = UDim2.new(0.05, 0, 0.80, 0)
antiRagdollBtn.Text = "Anti-Ragdoll: OFF"
antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
antiRagdollBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Перетягування вікна
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then updateDrag(input) end
end)

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    statusLabel.Visible = not isMinimized
    playerBox.Visible = not isMinimized
    speedBox.Visible = not isMinimized
    distBox.Visible = not isMinimized
    maxSpeedBox.Visible = not isMinimized
    toggleBtn.Visible = not isMinimized
    espBtn.Visible = not isMinimized
    antiRagdollBtn.Visible = not isMinimized
    mainFrame.Size = isMinimized and UDim2.new(0, 210, 0, 30) or UDim2.new(0, 210, 0, 285)
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

-- Оновлення значень
local function updateSettings()
    moveSpeed = math.clamp(tonumber(speedBox.Text) or 20, 1, 100)
    triggerDistance = math.clamp(tonumber(distBox.Text) or 150, 10, 10000)
    maxTravelSpeed = math.clamp(tonumber(maxSpeedBox.Text) or 60, 1, 120)
end

speedBox:GetPropertyChangedSignal("Text"):Connect(updateSettings)
distBox:GetPropertyChangedSignal("Text"):Connect(updateSettings)
maxSpeedBox:GetPropertyChangedSignal("Text"):Connect(updateSettings)

local function findMatchingPlayer(nameText)
    local text = string.lower(nameText)
    if text == "" then return nil end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localPlayer then
            local uName = string.lower(p.Name)
            local dName = string.lower(p.DisplayName)
            if string.find(uName, "^" .. text) or string.find(dName, "^" .. text) then
                return p
            end
        end
    end
    return nil
end

toggleBtn.MouseButton1Click:Connect(function()
    isFollowing = not isFollowing
    if isFollowing then
        updateSettings()
        local target = findMatchingPlayer(playerBox.Text)
        if target then
            selectedPlayer = target
            toggleBtn.Text = "STOP"
            toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
            title.Text = " Following: " .. target.Name
        else
            isFollowing = false
            title.Text = " Player Not Found!"
            statusLabel.Text = "NOT FOUND"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    else
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        title.Text = " Follow & ESP Menu"
        statusLabel.Text = "IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

antiRagdollBtn.MouseButton1Click:Connect(function()
    antiRagdollEnabled = not antiRagdollEnabled
    if antiRagdollEnabled then
        antiRagdollBtn.Text = "Anti-Ragdoll: ON"
        antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        antiRagdollBtn.Text = "Anti-Ragdoll: OFF"
        antiRagdollBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

--- ESP МОДУЛЬ ---
local function removeESP(player)
    if espHighlights[player] then espHighlights[player]:Destroy() espHighlights[player] = nil end
    if espBillboardGuis[player] then espBillboardGuis[player]:Destroy() espBillboardGuis[player] = nil end
end

local function applyESP(player)
    if player == localPlayer then return end
    removeESP(player)
    
    local function createVisuals(character)
        if not character or not espEnabled then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillColor = Color3.fromRGB(255, 50, 50)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Adornee = character
        highlight.Parent = character
        espHighlights[player] = highlight
        
        local head = character:WaitForChild("Head", 3)
        if head then
            local bbGui = Instance.new("BillboardGui")
            bbGui.Name = "ESPNameTag"
            bbGui.Size = UDim2.new(0, 100, 0, 16)
            bbGui.StudsOffset = Vector3.new(0, 2.0, 0)
            bbGui.AlwaysOnTop = true
            bbGui.Adornee = head
            
            local nameLabel = Instance.new("TextLabel", bbGui)
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.DisplayName .. " (@" .. player.Name .. ")"
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 12
            nameLabel.TextScaled = false
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextStrokeTransparency = 0.2
            nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            
            bbGui.Parent = head
            espBillboardGuis[player] = bbGui
        end
    end
    
    if player.Character then createVisuals(player.Character) end
    player.CharacterAdded:Connect(function(char) task.wait(0.5) createVisuals(char) end)
end

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    if espEnabled then
        espBtn.Text = "ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
    else
        espBtn.Text = "ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        for p, _ in pairs(espHighlights) do removeESP(p) end
    end
end)

Players.PlayerAdded:Connect(function(p) if espEnabled then applyESP(p) end end)
Players.PlayerRemoving:Connect(function(p) removeESP(p) end)

--- SAFE ANTI-RAGDOLL МОДУЛЬ (БЕЗ ТЕЛЕПОРТІВ НА СПАВН) ---
local function applyAntiRagdoll(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not root then return end

    humanoid.StateChanged:Connect(function(_, newState)
        if antiRagdollEnabled then
            if newState == Enum.HumanoidStateType.Ragdoll 
               or newState == Enum.HumanoidStateType.Physics 
               or newState == Enum.HumanoidStateType.FallingDown then
                
                -- Плавний підйом без різких реакцій для античита
                task.wait(0.1)
                humanoid.PlatformStand = false
                if root and root.Parent then
                    root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.2
                end
            end
        end
    end)
end

if localPlayer.Character then applyAntiRagdoll(localPlayer.Character) end
localPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    applyAntiRagdoll(char)
end)

--- БЕЗПЕЧНИЙ ЦИКЛ РУХУ ---
RunService.Heartbeat:Connect(function()
    if not isFollowing or not selectedPlayer or not selectedPlayer.Character then return end

    local myChar = localPlayer.Character
    local targetChar = selectedPlayer.Character
    if not myChar or not targetChar then return end

    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChild("Humanoid")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar:FindFirstChild("Humanoid")
    
    if not myRoot or not targetRoot or not myHumanoid or not targetHumanoid then return end

    -- Захист: зупиняємось, якщо ціль у Ragdoll або померла
    local targetState = targetHumanoid:GetState()
    if targetHumanoid.Health <= 0 or targetState == Enum.HumanoidStateType.Ragdoll or targetState == Enum.HumanoidStateType.Physics or targetState == Enum.HumanoidStateType.FallingDown then
        statusLabel.Text = "TARGET RAGDOLLED"
        statusLabel.TextColor3 = Color3.fromRGB(255, 170, 0)
        myHumanoid:MoveTo(myRoot.Position)
        return
    end

    -- Замок висоти Y
    local targetPos = targetRoot.Position + (targetRoot.CFrame.LookVector * -2.5)
    targetPos = Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z)

    local distance = (myRoot.Position - targetPos).Magnitude

    if distance <= stopDistance then
        statusLabel.Text = "ARRIVED"
        statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
        myHumanoid:MoveTo(myRoot.Position)
        return
    end

    local currentSpeed = moveSpeed
    if distance > triggerDistance then
        currentSpeed = maxTravelSpeed
        statusLabel.Text = "FAST TRAVEL"
        statusLabel.TextColor3 = Color3.fromRGB(255, 40, 40)
    else
        statusLabel.Text = "FOLLOWING"
        statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
    end

    myHumanoid.WalkSpeed = currentSpeed
    myHumanoid:MoveTo(targetPos)
end)
