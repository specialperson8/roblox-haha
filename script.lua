-- Client-Side Freeze System untuk Testing Exploit Executor
-- Script ini hanya akan bekerja di sisi client (visual effect only)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variabel global
local frozenPlayers = {}
local gui = nil
local commandBar = nil
local isVisible = true

print("=== CLIENT-SIDE FREEZE SYSTEM v1.0 ===")
print("Created for testing purposes only")
print("Press F1 to toggle GUI visibility")

-- Function untuk membuat GUI
local function createGUI()
    -- Hapus GUI lama jika ada
    if gui then gui:Destroy() end

    -- Buat ScreenGui
    gui = Instance.new("ScreenGui")
    gui.Name = "FreezeSystemGUI"
    gui.ResetOnSpawn = false

    -- Cek apakah CoreGui bisa diakses
    local success = pcall(function()
        gui.Parent = CoreGui
    end)

    if not success then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Frame utama
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Parent = gui
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0, 50, 0, 50)
    mainFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true

    -- Corner untuk frame utama
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = mainFrame
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Parent = titleBar
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "Client-Side Freeze System v1.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.SourceSansBold

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Parent = titleBar
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "×"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextSize = 18
    closeButton.Font = Enum.Font.SourceSansBold

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeButton

    -- Minimize button
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Name = "MinimizeButton"
    minimizeButton.Parent = titleBar
    minimizeButton.Size = UDim2.new(0, 30, 0, 30)
    minimizeButton.Position = UDim2.new(1, -60, 0, 0)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 193, 7)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    minimizeButton.TextSize = 16
    minimizeButton.Font = Enum.Font.SourceSansBold

    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeButton

    -- Command bar
    commandBar = Instance.new("TextBox")
    commandBar.Name = "CommandBar"
    commandBar.Parent = mainFrame
    commandBar.Size = UDim2.new(1, -20, 0, 30)
    commandBar.Position = UDim2.new(0, 10, 0, 40)
    commandBar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    commandBar.BorderSizePixel = 0
    commandBar.PlaceholderText = "Enter command here... (type 'help' for commands)"
    commandBar.Text = ""
    commandBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    commandBar.TextSize = 12
    commandBar.Font = Enum.Font.SourceSans

    local commandCorner = Instance.new("UICorner")
    commandCorner.CornerRadius = UDim.new(0, 4)
    commandCorner.Parent = commandBar

    -- Scroll frame untuk players
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "PlayerList"
    scrollFrame.Parent = mainFrame
    scrollFrame.Size = UDim2.new(1, -20, 1, -160)
    scrollFrame.Position = UDim2.new(0, 10, 0, 80)
    scrollFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 6
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)

    local scrollCorner = Instance.new("UICorner")
    scrollCorner.CornerRadius = UDim.new(0, 4)
    scrollCorner.Parent = scrollFrame

    -- Layout untuk player list
    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = scrollFrame
    listLayout.SortOrder = Enum.SortOrder.Name
    listLayout.Padding = UDim.new(0, 2)

    -- Info label
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Parent = mainFrame
    infoLabel.Size = UDim2.new(1, -20, 0, 60)
    infoLabel.Position = UDim2.new(0, 10, 1, -70)
    infoLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    infoLabel.BorderSizePixel = 0
    infoLabel.Text = "Commands: freeze [player], unfreeze [player], freezeall, unfreezeall\nHotkeys: F = Freeze nearest, G = Unfreeze all, F1 = Toggle GUI"
    infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    infoLabel.TextSize = 10
    infoLabel.TextWrapped = true
    infoLabel.Font = Enum.Font.SourceSans

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 4)
    infoCorner.Parent = infoLabel

    return mainFrame, scrollFrame
end

-- Function untuk update player list
local function updatePlayerList(scrollFrame)
    -- Hapus semua children kecuali UIListLayout
    for _, child in pairs(scrollFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    -- Tambahkan setiap player
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerFrame = Instance.new("Frame")
            playerFrame.Name = player.Name
            playerFrame.Parent = scrollFrame
            playerFrame.Size = UDim2.new(1, -10, 0, 25)
            playerFrame.BackgroundColor3 = frozenPlayers[player.UserId] and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(50, 50, 50)
            playerFrame.BorderSizePixel = 0

            local playerCorner = Instance.new("UICorner")
            playerCorner.CornerRadius = UDim.new(0, 3)
            playerCorner.Parent = playerFrame

            local nameLabel = Instance.new("TextLabel")
            nameLabel.Name = "NameLabel"
            nameLabel.Parent = playerFrame
            nameLabel.Size = UDim2.new(1, -80, 1, 0)
            nameLabel.Position = UDim2.new(0, 5, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name .. (frozenPlayers[player.UserId] and " [FROZEN]" or "")
            nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            nameLabel.TextSize = 12
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.Font = Enum.Font.SourceSans

            local freezeButton = Instance.new("TextButton")
            freezeButton.Name = "FreezeButton"
            freezeButton.Parent = playerFrame
            freezeButton.Size = UDim2.new(0, 35, 0, 20)
            freezeButton.Position = UDim2.new(1, -70, 0, 2.5)
            freezeButton.BackgroundColor3 = frozenPlayers[player.UserId] and Color3.fromRGB(40, 167, 69) or Color3.fromRGB(220, 53, 69)
            freezeButton.BorderSizePixel = 0
            freezeButton.Text = frozenPlayers[player.UserId] and "Unfreeze" or "Freeze"
            freezeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            freezeButton.TextSize = 8
            freezeButton.Font = Enum.Font.SourceSans

            local freezeCorner = Instance.new("UICorner")
            freezeCorner.CornerRadius = UDim.new(0, 3)
            freezeCorner.Parent = freezeButton

            local gotoButton = Instance.new("TextButton")
            gotoButton.Name = "GotoButton"
            gotoButton.Parent = playerFrame
            gotoButton.Size = UDim2.new(0, 30, 0, 20)
            gotoButton.Position = UDim2.new(1, -35, 0, 2.5)
            gotoButton.BackgroundColor3 = Color3.fromRGB(0, 123, 255)
            gotoButton.BorderSizePixel = 0
            gotoButton.Text = "Goto"
            gotoButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            gotoButton.TextSize = 8
            gotoButton.Font = Enum.Font.SourceSans

            local gotoCorner = Instance.new("UICorner")
            gotoCorner.CornerRadius = UDim.new(0, 3)
            gotoCorner.Parent = gotoButton

            -- Button events
            freezeButton.MouseButton1Click:Connect(function()
                if frozenPlayers[player.UserId] then
                    unfreezePlayer(player)
                else
                    freezePlayer(player)
                end
            end)

            gotoButton.MouseButton1Click:Connect(function()
                teleportToPlayer(player)
            end)
        end
    end

    -- Update canvas size
    local listLayout = scrollFrame:FindFirstChild("UIListLayout")
    if listLayout then
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
    end
end

-- Function untuk freeze player (client-side only)
function freezePlayer(player)
    if player and player.Character then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            -- Simpan nilai asli
            if not frozenPlayers[player.UserId] then
                frozenPlayers[player.UserId] = {
                    originalWalkSpeed = humanoid.WalkSpeed,
                    originalJumpPower = humanoid.JumpPower,
                    originalAnchored = rootPart.Anchored
                }
            end

            -- Freeze (hanya visual di client)
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            rootPart.Anchored = true

            -- Set PlatformStand
            humanoid.PlatformStand = true

            print("🧊 Frozen " .. player.Name .. " (CLIENT-SIDE ONLY)")
            return true
        end
    end
    return false
end

-- Function untuk unfreeze player
function unfreezePlayer(player)
    if player and player.Character and frozenPlayers[player.UserId] then
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            local originalData = frozenPlayers[player.UserId]

            -- Restore nilai asli
            humanoid.WalkSpeed = originalData.originalWalkSpeed or 16
            humanoid.JumpPower = originalData.originalJumpPower or 50
            rootPart.Anchored = originalData.originalAnchored or false
            humanoid.PlatformStand = false

            frozenPlayers[player.UserId] = nil

            print("🔥 Unfrozen " .. player.Name)
            return true
        end
    end
    return false
end

-- Function untuk teleport ke player
function teleportToPlayer(player)
    if player and player.Character and LocalPlayer.Character then
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        if targetRoot and myRoot then
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 0, 3)
            print("📍 Teleported to " .. player.Name)
            return true
        end
    end
    return false
end

-- Function untuk mencari player terdekat
local function findNearestPlayer()
    local nearestPlayer = nil
    local shortestDistance = math.huge
    local myCharacter = LocalPlayer.Character

    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then
        return nil
    end

    local myPosition = myCharacter.HumanoidRootPart.Position

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - myPosition).Magnitude
            if distance < shortestDistance then
                shortestDistance = distance
                nearestPlayer = player
            end
        end
    end

    return nearestPlayer
end

-- Command system
local function processCommand(command)
    local args = command:lower():split(" ")
    local cmd = args[1]

    if cmd == "help" then
        print("=== COMMANDS ===")
        print("freeze [playername] - Freeze specific player")
        print("unfreeze [playername] - Unfreeze specific player") 
        print("freezeall - Freeze all players")
        print("unfreezeall - Unfreeze all players")
        print("goto [playername] - Teleport to player")
        print("clear - Clear console")
        print("list - List all players")

    elseif cmd == "freeze" and args[2] then
        local targetPlayer = Players:FindFirstChild(args[2])
        if targetPlayer then
            freezePlayer(targetPlayer)
        else
            print("❌ Player '" .. args[2] .. "' not found!")
        end

    elseif cmd == "unfreeze" and args[2] then
        local targetPlayer = Players:FindFirstChild(args[2])
        if targetPlayer then
            unfreezePlayer(targetPlayer)
        else
            print("❌ Player '" .. args[2] .. "' not found!")
        end

    elseif cmd == "freezeall" then
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                if freezePlayer(player) then
                    count = count + 1
                end
            end
        end
        print("🧊 Frozen " .. count .. " players")

    elseif cmd == "unfreezeall" then
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if unfreezePlayer(player) then
                count = count + 1
            end
        end
        print("🔥 Unfrozen " .. count .. " players")

    elseif cmd == "goto" and args[2] then
        local targetPlayer = Players:FindFirstChild(args[2])
        if targetPlayer then
            teleportToPlayer(targetPlayer)
        else
            print("❌ Player '" .. args[2] .. "' not found!")
        end

    elseif cmd == "list" then
        print("=== PLAYER LIST ===")
        for _, player in pairs(Players:GetPlayers()) do
            local status = frozenPlayers[player.UserId] and " [FROZEN]" or ""
            print(player.Name .. status)
        end

    elseif cmd == "clear" then
        -- Clear console (untuk beberapa executor)
        for i = 1, 50 do
            print("")
        end

    else
        print("❌ Unknown command. Type 'help' for command list.")
    end
end

-- Buat GUI
local mainFrame, scrollFrame = createGUI()

-- Event handlers
local closeButton = mainFrame.TitleBar.CloseButton
local minimizeButton = mainFrame.TitleBar.MinimizeButton

closeButton.MouseButton1Click:Connect(function()
    if gui then
        gui:Destroy()
    end
end)

minimizeButton.MouseButton1Click:Connect(function()
    isVisible = not isVisible
    mainFrame.Visible = isVisible
end)

-- Command bar event
commandBar.FocusLost:Connect(function(enterPressed)
    if enterPressed and commandBar.Text ~= "" then
        processCommand(commandBar.Text)
        commandBar.Text = ""
    end
end)

-- Hotkeys
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.F then
            -- Freeze nearest player
            local nearestPlayer = findNearestPlayer()
            if nearestPlayer then
                if frozenPlayers[nearestPlayer.UserId] then
                    unfreezePlayer(nearestPlayer)
                else
                    freezePlayer(nearestPlayer)
                end
            else
                print("❌ No nearby players found!")
            end

        elseif input.KeyCode == Enum.KeyCode.G then
            -- Unfreeze all
            local count = 0
            for _, player in pairs(Players:GetPlayers()) do
                if unfreezePlayer(player) then
                    count = count + 1
                end
            end
            if count > 0 then
                print("🔥 Unfrozen " .. count .. " players")
            end

        elseif input.KeyCode == Enum.KeyCode.F1 then
            -- Toggle GUI visibility
            isVisible = not isVisible
            if gui then
                gui.Enabled = isVisible
            end

        elseif input.KeyCode == Enum.KeyCode.H and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            -- Ctrl+H untuk help
            processCommand("help")
        end
    end
end)

-- Update player list setiap detik
local lastUpdate = 0
RunService.Heartbeat:Connect(function()
    if tick() - lastUpdate > 1 then
        if gui and gui.Parent and scrollFrame then
            updatePlayerList(scrollFrame)
        end
        lastUpdate = tick()
    end
end)

-- Events untuk player join/leave
Players.PlayerAdded:Connect(function(player)
    wait(1)
    if scrollFrame then
        updatePlayerList(scrollFrame)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    frozenPlayers[player.UserId] = nil
    if scrollFrame then
        updatePlayerList(scrollFrame)
    end
end)

-- Initial update
wait(1)
updatePlayerList(scrollFrame)

print("✅ Client-Side Freeze System loaded successfully!")
print("📋 GUI created and ready to use")
print("⚠️  Remember: This only affects your client view!")
