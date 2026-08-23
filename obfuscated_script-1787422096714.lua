local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local isFollowing = false
local selectedPlayer = nil
local moveSpeed = 20
local triggerDistance = 150
local maxTravelSpeed = 120
local activeTween = nil

local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "FollowGui"
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 210, 0, 210)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, -30, 0, 30)
title.Text = " Follow Menu"
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
statusLabel.Position = UDim2.new(0.05, 0, 0.16, 0)
statusLabel.Text = "IDLE"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.BackgroundTransparency = 1
statusLabel.TextScaled = true

local playerBox = Instance.new("TextBox", mainFrame)
playerBox.Size = UDim2.new(0.9, 0, 0, 24)
playerBox.Position = UDim2.new(0.05, 0, 0.26, 0)
playerBox.PlaceholderText = "Username..."
playerBox.Text = ""
playerBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
playerBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local speedBox = Instance.new("TextBox", mainFrame)
speedBox.Size = UDim2.new(0.9, 0, 0, 24)
speedBox.Position = UDim2.new(0.05, 0, 0.40, 0)
speedBox.PlaceholderText = "Base Speed: 20"
speedBox.Text = "20"
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local distBox = Instance.new("TextBox", mainFrame)
distBox.Size = UDim2.new(0.9, 0, 0, 24)
distBox.Position = UDim2.new(0.05, 0, 0.54, 0)
distBox.PlaceholderText = "Trigger Dist: 150"
distBox.Text = "150"
distBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
distBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local maxSpeedBox = Instance.new("TextBox", mainFrame)
maxSpeedBox.Size = UDim2.new(0.9, 0, 0, 24)
maxSpeedBox.Position = UDim2.new(0.05, 0, 0.68, 0)
maxSpeedBox.PlaceholderText = "Max Travel Speed: 120"
maxSpeedBox.Text = "120"
maxSpeedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
maxSpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)

local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.9, 0, 0, 26)
toggleBtn.Position = UDim2.new(0.05, 0, 0.83, 0)
toggleBtn.Text = "START"
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
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
    mainFrame.Size = isMinimized and UDim2.new(0, 210, 0, 30) or UDim2.new(0, 210, 0, 210)
    minimizeBtn.Text = isMinimized and "+" or "-"
end)

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
        local target = findMatchingPlayer(playerBox.Text)
        
        moveSpeed = math.clamp(tonumber(speedBox.Text) or 20, 1, 500)
        triggerDistance = math.clamp(tonumber(distBox.Text) or 150, 10, 10000)
        maxTravelSpeed = math.clamp(tonumber(maxSpeedBox.Text) or 120, 1, 500)
        
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
        if activeTween then
            activeTween:Cancel()
            activeTween = nil
        end
        toggleBtn.Text = "START"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        title.Text = " Follow Menu"
        statusLabel.Text = "IDLE"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end)

task.spawn(function()
    while task.wait(0.15) do
        if isFollowing and selectedPlayer and selectedPlayer.Character then
            local myChar = localPlayer.Character
            local targetChar = selectedPlayer.Character
            
            if myChar and targetChar then
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                
                if myRoot and targetRoot then
                    local targetCFrame = targetRoot.CFrame * CFrame.new(0, 0, 1.5)
                    local distance = (myRoot.Position - targetCFrame.Position).Magnitude
                    
                    if distance > 1 then
                        local currentSpeed = moveSpeed
                        
                        if distance > triggerDistance then
                            currentSpeed = maxTravelSpeed
                            statusLabel.Text = "FAST TRAVEL"
                            statusLabel.TextColor3 = Color3.fromRGB(255, 40, 40)
                        else
                            statusLabel.Text = "Here"
                            statusLabel.TextColor3 = Color3.fromRGB(50, 255, 50)
                        end
                        
                        local timeToReach = distance / currentSpeed
                        local tInfo = TweenInfo.new(timeToReach, Enum.EasingStyle.Linear)
                        
                        if activeTween then
                            activeTween:Cancel()
                        end
                        
                        activeTween = TweenService:Create(myRoot, tInfo, {CFrame = targetCFrame})
                        activeTween:Play()
                    end
                end
            end
        end
    end
end)
