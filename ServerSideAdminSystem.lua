-- SERVER-SIDE ADMIN & ANTI-CHEAT SYSTEM
-- Place this in ServerScriptService
-- Created for testing cheater simulation and detection

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local TeleportService = game:GetService("TeleportService")
local Chat = game:GetService("Chat")

print("=== SERVER-SIDE ADMIN SYSTEM v2.0 ===")
print("Anti-Cheat & Admin Tools Loading...")

-- Configuration
local ADMIN_USERS = {
    -- Ganti dengan Username Anda dan admin lainnya
    ["YourUsernameHere"] = true,  -- Ganti dengan username asli Anda
    ["Admin1"] = true,
    ["Admin2"] = true
}

-- Variables
local frozenPlayers = {}
local bannedPlayers = {}
local playerLogs = {}
local suspiciousActivity = {}
local remoteEvents = {}

-- Create Folder for RemoteEvents
local remoteFolder = Instance.new("Folder")
remoteFolder.Name = "AdminSystem"
remoteFolder.Parent = ReplicatedStorage

-- Create RemoteEvents
local function createRemoteEvent(name)
    local event = Instance.new("RemoteEvent")
    event.Name = name
    event.Parent = remoteFolder
    remoteEvents[name] = event
    return event
end

-- RemoteEvents
local adminPanelEvent = createRemoteEvent("AdminPanelEvent")
local freezeEvent = createRemoteEvent("FreezeEvent")
local teleportEvent = createRemoteEvent("TeleportEvent")
local kickEvent = createRemoteEvent("KickEvent")
local anticheatEvent = createRemoteEvent("AntiCheatEvent")

-- Utility Functions
local function isAdmin(player)
    return ADMIN_USERS[player.Name] or player.Name == "YourUsernameHere"  -- Ganti sesuai username Anda
end

local function logAction(admin, action, target)
    local timestamp = os.date("%X")
    local logEntry = string.format("[%s] %s %s %s", timestamp, admin, action, target or "")
    print("📋 " .. logEntry)

    if not playerLogs[admin] then
        playerLogs[admin] = {}
    end
    table.insert(playerLogs[admin], logEntry)
end

local function broadcastMessage(message, color)
    for _, player in pairs(Players:GetPlayers()) do
        local gui = player.PlayerGui:FindFirstChild("AdminNotification")
        if not gui then
            gui = Instance.new("ScreenGui")
            gui.Name = "AdminNotification"
            gui.Parent = player.PlayerGui

            local frame = Instance.new("Frame")
            frame.Name = "NotificationFrame"
            frame.Size = UDim2.new(0, 300, 0, 60)
            frame.Position = UDim2.new(1, -310, 0, 10)
            frame.BackgroundColor3 = color or Color3.fromRGB(50, 50, 50)
            frame.Parent = gui

            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = frame

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.BackgroundTransparency = 1
            label.Text = message
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 14
            label.TextWrapped = true
            label.Font = Enum.Font.SourceSans
            label.Parent = frame

            -- Auto destroy after 5 seconds
            game:GetService("Debris"):AddItem(gui, 5)
        end
    end
end

-- Server-Side Freeze System
local function freezePlayer(targetPlayer, admin)
    if targetPlayer and targetPlayer.Character then
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            -- Store original values
            frozenPlayers[targetPlayer.UserId] = {
                originalWalkSpeed = humanoid.WalkSpeed,
                originalJumpPower = humanoid.JumpPower,
                originalJumpHeight = humanoid.JumpHeight,
                originalAnchored = rootPart.Anchored,
                frozenBy = admin.Name,
                timestamp = tick()
            }

            -- Apply freeze
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            humanoid.JumpHeight = 0
            humanoid.PlatformStand = true
            rootPart.Anchored = true

            -- Create freeze effect
            local freezeEffect = Instance.new("SelectionBox")
            freezeEffect.Name = "FreezeEffect"
            freezeEffect.Adornee = rootPart
            freezeEffect.Color3 = Color3.fromRGB(0, 162, 255)
            freezeEffect.LineThickness = 0.3
            freezeEffect.Transparency = 0.5
            freezeEffect.Parent = rootPart

            logAction(admin.Name, "FROZE", targetPlayer.Name)
            broadcastMessage(targetPlayer.Name .. " has been frozen by " .. admin.Name, Color3.fromRGB(100, 100, 255))

            -- Notify target player
            freezeEvent:FireClient(targetPlayer, true)

            return true
        end
    end
    return false
end

local function unfreezePlayer(targetPlayer, admin)
    if targetPlayer and targetPlayer.Character and frozenPlayers[targetPlayer.UserId] then
        local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
        local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            local frozenData = frozenPlayers[targetPlayer.UserId]

            -- Restore original values
            humanoid.WalkSpeed = frozenData.originalWalkSpeed
            humanoid.JumpPower = frozenData.originalJumpPower
            humanoid.JumpHeight = frozenData.originalJumpHeight
            humanoid.PlatformStand = false
            rootPart.Anchored = frozenData.originalAnchored

            -- Remove freeze effect
            local freezeEffect = rootPart:FindFirstChild("FreezeEffect")
            if freezeEffect then
                freezeEffect:Destroy()
            end

            frozenPlayers[targetPlayer.UserId] = nil

            logAction(admin.Name, "UNFROZE", targetPlayer.Name)
            broadcastMessage(targetPlayer.Name .. " has been unfrozen by " .. admin.Name, Color3.fromRGB(100, 255, 100))

            -- Notify target player
            freezeEvent:FireClient(targetPlayer, false)

            return true
        end
    end
    return false
end

-- Anti-Cheat Detection System
local function detectSuspiciousActivity(player)
    if not player.Character then return end

    local humanoid = player.Character:FindFirstChild("Humanoid")
    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart then return end

    -- Initialize tracking data
    if not suspiciousActivity[player.UserId] then
        suspiciousActivity[player.UserId] = {
            speedViolations = 0,
            positionChecks = {},
            lastPosition = rootPart.Position,
            lastCheck = tick()
        }
    end

    local data = suspiciousActivity[player.UserId]
    local currentTime = tick()
    local timeDiff = currentTime - data.lastCheck

    if timeDiff > 0.1 then -- Check every 100ms
        -- Speed check
        if humanoid.WalkSpeed > 50 then
            data.speedViolations = data.speedViolations + 1
            warn("⚠️ SPEED HACK DETECTED: " .. player.Name .. " (Speed: " .. humanoid.WalkSpeed .. ")")

            if data.speedViolations > 5 then
                freezePlayer(player, {Name = "SYSTEM"})
                broadcastMessage("🚨 " .. player.Name .. " detected using speed hacks!", Color3.fromRGB(255, 100, 100))
            end
        end

        -- Teleportation/Fly detection
        local distance = (rootPart.Position - data.lastPosition).Magnitude
        local maxAllowedDistance = (humanoid.WalkSpeed + 50) * timeDiff -- Allow some margin

        if distance > maxAllowedDistance and distance > 100 then
            warn("⚠️ TELEPORT/FLY DETECTED: " .. player.Name .. " (Distance: " .. math.floor(distance) .. ")")
            broadcastMessage("🚨 " .. player.Name .. " detected teleporting/flying!", Color3.fromRGB(255, 100, 100))

            -- Optional: Auto-freeze suspicious players
            -- freezePlayer(player, {Name = "SYSTEM"})
        end

        -- Update tracking data
        data.lastPosition = rootPart.Position
        data.lastCheck = currentTime
    end
end

-- Admin Commands
local adminCommands = {
    freeze = function(admin, args)
        local targetName = args[1]
        if not targetName then return false, "Usage: /freeze [playername]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end

        local success = freezePlayer(targetPlayer, admin)
        return success, success and "Froze " .. targetPlayer.Name or "Failed to freeze player"
    end,

    unfreeze = function(admin, args)
        local targetName = args[1]
        if not targetName then return false, "Usage: /unfreeze [playername]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end

        local success = unfreezePlayer(targetPlayer, admin)
        return success, success and "Unfroze " .. targetPlayer.Name or "Failed to unfreeze player"
    end,

    freezeall = function(admin, args)
        local count = 0
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= admin and not isAdmin(player) then
                if freezePlayer(player, admin) then
                    count = count + 1
                end
            end
        end
        return count > 0, "Froze " .. count .. " players"
    end,

    unfreezeall = function(admin, args)
        local count = 0
        for userId, _ in pairs(frozenPlayers) do
            local player = Players:GetPlayerByUserId(userId)
            if player and unfreezePlayer(player, admin) then
                count = count + 1
            end
        end
        return count > 0, "Unfroze " .. count .. " players"
    end,

    kick = function(admin, args)
        local targetName = args[1]
        local reason = table.concat(args, " ", 2) or "No reason provided"

        if not targetName then return false, "Usage: /kick [playername] [reason]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end
        if isAdmin(targetPlayer) then return false, "Cannot kick admin!" end

        logAction(admin.Name, "KICKED", targetPlayer.Name .. " - Reason: " .. reason)
        broadcastMessage(targetPlayer.Name .. " was kicked by " .. admin.Name, Color3.fromRGB(255, 150, 100))

        targetPlayer:Kick("You have been kicked by " .. admin.Name .. "\nReason: " .. reason)
        return true, "Kicked " .. targetName
    end,

    ban = function(admin, args)
        local targetName = args[1]
        local reason = table.concat(args, " ", 2) or "No reason provided"

        if not targetName then return false, "Usage: /ban [playername] [reason]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end
        if isAdmin(targetPlayer) then return false, "Cannot ban admin!" end

        bannedPlayers[targetPlayer.UserId] = {
            name = targetPlayer.Name,
            reason = reason,
            bannedBy = admin.Name,
            timestamp = os.time()
        }

        logAction(admin.Name, "BANNED", targetPlayer.Name .. " - Reason: " .. reason)
        broadcastMessage(targetPlayer.Name .. " was banned by " .. admin.Name, Color3.fromRGB(255, 50, 50))

        targetPlayer:Kick("You have been banned from this server\nBanned by: " .. admin.Name .. "\nReason: " .. reason)
        return true, "Banned " .. targetName
    end,

    tp = function(admin, args)
        local targetName = args[1]
        if not targetName then return false, "Usage: /tp [playername]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return false, "Target player has no character"
        end
        if not admin.Character or not admin.Character:FindFirstChild("HumanoidRootPart") then
            return false, "You have no character"
        end

        admin.Character.HumanoidRootPart.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
        logAction(admin.Name, "TELEPORTED TO", targetPlayer.Name)
        return true, "Teleported to " .. targetPlayer.Name
    end,

    bring = function(admin, args)
        local targetName = args[1]
        if not targetName then return false, "Usage: /bring [playername]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            return false, "Target player has no character"
        end
        if not admin.Character or not admin.Character:FindFirstChild("HumanoidRootPart") then
            return false, "You have no character"
        end

        targetPlayer.Character.HumanoidRootPart.CFrame = admin.Character.HumanoidRootPart.CFrame + Vector3.new(5, 0, 0)
        logAction(admin.Name, "BROUGHT", targetPlayer.Name)
        return true, "Brought " .. targetPlayer.Name
    end,

    god = function(admin, args)
        local targetName = args[1] or admin.Name
        local targetPlayer = Players:FindFirstChild(targetName)

        if not targetPlayer then return false, "Player not found: " .. targetName end
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") then
            return false, "Player has no character"
        end

        local humanoid = targetPlayer.Character.Humanoid
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge

        logAction(admin.Name, "GOD MODE", targetPlayer.Name)
        return true, "God mode enabled for " .. targetPlayer.Name
    end,

    ungod = function(admin, args)
        local targetName = args[1] or admin.Name
        local targetPlayer = Players:FindFirstChild(targetName)

        if not targetPlayer then return false, "Player not found: " .. targetName end
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") then
            return false, "Player has no character"
        end

        local humanoid = targetPlayer.Character.Humanoid
        humanoid.MaxHealth = 100
        humanoid.Health = 100

        logAction(admin.Name, "UNGOD", targetPlayer.Name)
        return true, "God mode disabled for " .. targetPlayer.Name
    end,

    speed = function(admin, args)
        local targetName = args[1]
        local speed = tonumber(args[2]) or 16

        if not targetName then return false, "Usage: /speed [playername] [speed]" end

        local targetPlayer = Players:FindFirstChild(targetName)
        if not targetPlayer then return false, "Player not found: " .. targetName end
        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Humanoid") then
            return false, "Player has no character"
        end

        targetPlayer.Character.Humanoid.WalkSpeed = speed
        logAction(admin.Name, "SET SPEED", targetPlayer.Name .. " to " .. speed)
        return true, "Set " .. targetPlayer.Name .. "'s speed to " .. speed
    end,

    logs = function(admin, args)
        local targetAdmin = args[1]
        if targetAdmin and playerLogs[targetAdmin] then
            local logs = playerLogs[targetAdmin]
            local recentLogs = {}
            for i = math.max(1, #logs - 10), #logs do
                table.insert(recentLogs, logs[i])
            end
            return true, "Recent logs for " .. targetAdmin .. ":\n" .. table.concat(recentLogs, "\n")
        else
            return true, "Available admins: " .. table.concat(getAdminList(), ", ")
        end
    end,

    players = function(admin, args)
        local playerList = {}
        for _, player in pairs(Players:GetPlayers()) do
            local status = ""
            if frozenPlayers[player.UserId] then
                status = status .. "[FROZEN]"
            end
            if isAdmin(player) then
                status = status .. "[ADMIN]"
            end
            table.insert(playerList, player.Name .. " " .. status)
        end
        return true, "Players online (" .. #Players:GetPlayers() .. "):\n" .. table.concat(playerList, "\n")
    end
}

function getAdminList()
    local admins = {}
    for name, _ in pairs(ADMIN_USERS) do
        table.insert(admins, name)
    end
    return admins
end

-- Chat Command Handler
local function handleChatCommand(player, message)
    if not isAdmin(player) then return end

    if message:sub(1, 1) == "/" then
        local args = message:sub(2):split(" ")
        local command = args[1]:lower()
        table.remove(args, 1)

        if adminCommands[command] then
            local success, result = adminCommands[command](player, args)

            -- Send result to player
            local color = success and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
            adminPanelEvent:FireClient(player, "COMMAND_RESULT", {
                success = success,
                message = result,
                command = command
            })
        else
            adminPanelEvent:FireClient(player, "COMMAND_RESULT", {
                success = false,
                message = "Unknown command: " .. command .. "\nType /help for available commands",
                command = command
            })
        end
    end
end

-- Events
Players.PlayerAdded:Connect(function(player)
    -- Check if banned
    if bannedPlayers[player.UserId] then
        local banData = bannedPlayers[player.UserId]
        player:Kick("You are banned from this server\nReason: " .. banData.reason .. "\nBanned by: " .. banData.bannedBy)
        return
    end

    -- Setup admin GUI for admins
    if isAdmin(player) then
        player.CharacterAdded:Connect(function()
            wait(1)
            adminPanelEvent:FireClient(player, "SETUP_ADMIN_GUI")
        end)
    end

    -- Setup anti-cheat monitoring
    player.CharacterAdded:Connect(function()
        wait(2) -- Wait for character to fully load

        local connection
        connection = RunService.Heartbeat:Connect(function()
            if not player.Parent then
                connection:Disconnect()
                return
            end
            detectSuspiciousActivity(player)
        end)
    end)

    -- Chat handler
    player.Chatted:Connect(function(message)
        handleChatCommand(player, message)
    end)

    print("👤 " .. player.Name .. " joined the server" .. (isAdmin(player) and " [ADMIN]" or ""))
    broadcastMessage(player.Name .. " joined the server", Color3.fromRGB(100, 200, 255))
end)

Players.PlayerRemoving:Connect(function(player)
    -- Cleanup
    frozenPlayers[player.UserId] = nil
    suspiciousActivity[player.UserId] = nil

    print("👋 " .. player.Name .. " left the server")
end)

-- RemoteEvent Handlers
adminPanelEvent.OnServerEvent:Connect(function(player, action, data)
    if not isAdmin(player) then return end

    if action == "FREEZE_PLAYER" then
        local targetPlayer = Players:FindFirstChild(data.playerName)
        if targetPlayer then
            freezePlayer(targetPlayer, player)
        end

    elseif action == "UNFREEZE_PLAYER" then
        local targetPlayer = Players:FindFirstChild(data.playerName)
        if targetPlayer then
            unfreezePlayer(targetPlayer, player)
        end

    elseif action == "KICK_PLAYER" then
        local targetPlayer = Players:FindFirstChild(data.playerName)
        if targetPlayer and not isAdmin(targetPlayer) then
            targetPlayer:Kick("Kicked by " .. player.Name .. "\nReason: " .. (data.reason or "No reason"))
            logAction(player.Name, "KICKED", targetPlayer.Name)
        end

    elseif action == "GET_PLAYER_LIST" then
        local players = {}
        for _, plr in pairs(Players:GetPlayers()) do
            table.insert(players, {
                name = plr.Name,
                userId = plr.UserId,
                isAdmin = isAdmin(plr),
                isFrozen = frozenPlayers[plr.UserId] ~= nil
            })
        end
        adminPanelEvent:FireClient(player, "PLAYER_LIST_UPDATE", players)
    end
end)

print("✅ Server-Side Admin System loaded successfully!")
print("🛡️ Anti-cheat system active")
print("👨‍💼 Admins: " .. table.concat(getAdminList(), ", "))
print("📋 Use chat commands starting with '/' or use the admin GUI")
