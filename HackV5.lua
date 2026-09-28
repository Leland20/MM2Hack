local Venyx = loadstring(game:HttpGet("https://raw.githubusercontent.com/Leland20/source2/main/source2.lua"))()
local UI = Venyx.new({
    title = "Leland Hack",
    theme = {
        Background = Color3.fromRGB(24, 24, 24),
        Glow = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(10, 10, 10),
        LightContrast = Color3.fromRGB(20, 20, 20),
        DarkContrast = Color3.fromRGB(14, 14, 14),
        TextColor = Color3.fromRGB(255, 255, 255)
    }
})

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- ==================== NEUES POPUP MIT ABLAUF-BALKEN ====================
local TweenService = game:GetService("TweenService")

local notifyGui = Instance.new("ScreenGui")
notifyGui.Name = "LelandNotify"
notifyGui.ResetOnSpawn = false
notifyGui.DisplayOrder = 1000
pcall(function()
    notifyGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not notifyGui.Parent then
    notifyGui.Parent = player:WaitForChild("PlayerGui")
end

local notifyHolder = Instance.new("Frame")
notifyHolder.BackgroundTransparency = 1
notifyHolder.AnchorPoint = Vector2.new(1, 1)
notifyHolder.Position = UDim2.new(1, -15, 1, -15)
notifyHolder.Size = UDim2.new(0, 260, 1, -30)
notifyHolder.Parent = notifyGui

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.Padding = UDim.new(0, 8)
notifyLayout.Parent = notifyHolder

local function Notify(title, text, duration)
    duration = duration or 5

    local box = Instance.new("TextButton")
    box.Size = UDim2.new(1, 0, 0, 70)
    box.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    box.BorderSizePixel = 0
    box.AutoButtonColor = false
    box.Text = ""
    box.ClipsDescendants = true
    box.Parent = notifyHolder

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = box

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 12, 0, 8)
    titleLabel.Size = UDim2.new(1, -24, 0, 18)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Text = tostring(title)
    titleLabel.Parent = box

    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 12, 0, 28)
    textLabel.Size = UDim2.new(1, -24, 0, 30)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 13
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.TextWrapped = true
    textLabel.Text = tostring(text)
    textLabel.Parent = box

    -- Ablauf-Balken unten
    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0, 1)
    barBg.Position = UDim2.new(0, 0, 1, 0)
    barBg.Size = UDim2.new(1, 0, 0, 5)
    barBg.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    barBg.BorderSizePixel = 0
    barBg.Parent = box

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(140, 60, 200)
    bar.BorderSizePixel = 0
    bar.Parent = barBg

    local closed = false
    local function close()
        if closed then return end
        closed = true
        box:Destroy()
    end

    box.MouseButton1Click:Connect(close) -- Klick = sofort schließen

    TweenService:Create(bar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    task.delay(duration, close)
end

-- Ersetzt das alte Venyx-Popup: alle UI:Notify(...) Aufrufe nutzen jetzt das neue (10 Sek.)
function UI:Notify(data)
    Notify(data.title or "Info", data.text or "", 10)
end
-- ==================== ENDE POPUP ====================

local PlayerPage = UI:addPage({ title = "Player", icon = 7992557358 })
local MovementSection = PlayerPage:addSection({ title = "Movement" })

local GravityValue = 196.2
local SpeedValue = 16
local JumpValue = 50

local function applyMovementSettings()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = SpeedValue
            humanoid.JumpPower = JumpValue
        end
    end
    workspace.Gravity = GravityValue
end

MovementSection:addSlider({
    title = "Gravity",
    default = 196.2,
    min = 0,
    max = 500,
    callback = function(value)
        GravityValue = value
        workspace.Gravity = GravityValue
    end
})

MovementSection:addSlider({
    title = "Walk Speed",
    default = 16,
    min = 0,
    max = 100,
    callback = function(value)
        SpeedValue = value
        applyMovementSettings()
    end
})

MovementSection:addSlider({
    title = "Jump Power",
    default = 50,
    min = 0,
    max = 200,
    callback = function(value)
        JumpValue = value
        applyMovementSettings()
    end
})

player.CharacterAdded:Connect(function()
    wait(0.5)
    applyMovementSettings()
end)
applyMovementSettings()

local BoostSection = PlayerPage:addSection({ title = "Jump Boost" })

local boostEnabled = false
local boostSpeed = 75
local boostListener = nil
local originalSpeed = 16
local isBoosting = false
local boostHeartbeat = nil

local function setupBoostListener()
    if boostListener then 
        boostListener:Disconnect() 
        boostListener = nil 
    end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    boostListener = humanoid.Jumping:Connect(function()
        if not boostEnabled then return end
        if isBoosting then return end
        
        isBoosting = true
        originalSpeed = humanoid.WalkSpeed
        humanoid.WalkSpeed = boostSpeed
    end)
end

local function startBoostHeartbeat()
    if boostHeartbeat then return end
    boostHeartbeat = runService.Heartbeat:Connect(function()
        if not boostEnabled then return end
        if not isBoosting then return end
        
        local char = player.Character
        if not char then return end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        
        if not humanoid or not rootPart then return end
        
        local velocity = rootPart.AssemblyLinearVelocity
        if humanoid.FloorMaterial ~= Enum.Material.Air and math.abs(velocity.Y) < 0.5 then
            humanoid.WalkSpeed = originalSpeed
            isBoosting = false
        end
    end)
end

local function stopBoostHeartbeat()
    if boostHeartbeat then
        boostHeartbeat:Disconnect()
        boostHeartbeat = nil
    end
end

player.CharacterAdded:Connect(function()
    task.wait(0.5)
    isBoosting = false
    originalSpeed = 16
    if boostEnabled then
        setupBoostListener()
        startBoostHeartbeat()
    end
end)

BoostSection:addToggle({
    title = "Boost on Jump (75 speed)",
    callback = function(value)
        boostEnabled = value
        if value then
            setupBoostListener()
            startBoostHeartbeat()
        else
            if boostListener then 
                boostListener:Disconnect() 
                boostListener = nil 
            end
            stopBoostHeartbeat()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and isBoosting then
                    hum.WalkSpeed = originalSpeed
                    isBoosting = false
                end
            end
        end
    end
})

task.wait(1)
if boostEnabled then
    setupBoostListener()
    startBoostHeartbeat()
end

-- ==================== NOCLIP & FLY ====================
local MoveSection = PlayerPage:addSection({ title = "Noclip & Fly" })

-- ---------- NOCLIP ----------
local noclipEnabled = false
local noclipConnection = nil

local function startNoclip()
    if noclipConnection then return end
    noclipConnection = runService.Stepped:Connect(function()
        local char = player.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

local function stopNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local noclipToggle = MoveSection:addToggle({
    title = "Noclip",
    callback = function(value)
        noclipEnabled = value
        if value then startNoclip() else stopNoclip() end
    end
})

-- ---------- FLY ----------
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil
local flyBV, flyBG = nil, nil
local flyUp, flyDown = false, false

local function stopFly()
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function startFly()
    stopFly()
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then return end

    humanoid.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBG.P = 9e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root

    flyConnection = runService.RenderStepped:Connect(function()
        if not flyEnabled or not root.Parent then return end
        local cam = workspace.CurrentCamera

        -- Bewegung relativ zur Kamera (funktioniert auch mit Handy-Joystick)
        local moveDir = humanoid.MoveDirection
        local velocity = Vector3.zero
        if moveDir.Magnitude > 0 then
            local localDir = cam.CFrame:VectorToObjectSpace(moveDir)
            velocity = (cam.CFrame.LookVector * -localDir.Z) + (cam.CFrame.RightVector * localDir.X)
        end

        -- Hoch / Runter
        if flyUp then velocity = velocity + Vector3.new(0, 1, 0) end
        if flyDown then velocity = velocity - Vector3.new(0, 1, 0) end

        if velocity.Magnitude > 0 then
            velocity = velocity.Unit * flySpeed
        end

        flyBV.Velocity = velocity
        flyBG.CFrame = cam.CFrame
    end)
end

-- Tasten: Leertaste = hoch, Linke Strg / Linke Shift = runter
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.LeftShift then
        flyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.LeftShift then
        flyDown = false
    end
end)

local flyToggle = MoveSection:addToggle({
    title = "Fly",
    callback = function(value)
        flyEnabled = value
        if value then startFly() else stopFly() end
    end
})

-- Hotkeys: C = Fly, X = Noclip
local function setFly(value)
    flyEnabled = value
    if value then startFly() else stopFly() end
    pcall(function() MoveSection:updateToggle(flyToggle, nil, value) end)
    Notify("Fly", value and "Fly aktiviert (C)" or "Fly deaktiviert (C)", 10)
end

local function setNoclip(value)
    noclipEnabled = value
    if value then startNoclip() else stopNoclip() end
    pcall(function() MoveSection:updateToggle(noclipToggle, nil, value) end)
    Notify("Noclip", value and "Noclip aktiviert (X)" or "Noclip deaktiviert (X)", 10)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.C then
        setFly(not flyEnabled)
    elseif input.KeyCode == Enum.KeyCode.X then
        setNoclip(not noclipEnabled)
    end
end)

MoveSection:addSlider({
    title = "Fly Speed",
    default = 50,
    min = 10,
    max = 300,
    callback = function(value)
        flySpeed = value
    end
})

-- Nach Respawn wieder aktivieren
player.CharacterAdded:Connect(function()
    task.wait(0.6)
    if flyEnabled then startFly() end
end)
-- ==================== ENDE NOCLIP & FLY ====================

-- ==================== INVISIBILITY ====================
local InvisSection = PlayerPage:addSection({ title = "Invisibility" })

local invisEnabled = false
local invisSeat = nil

-- Nur den Sitz entfernen (z. B. beim Respawn)
local function clearInvisSeat()
    if invisSeat then
        invisSeat:Destroy()
        invisSeat = nil
    end
end

-- Wieder sichtbar werden, ohne Respawn
local function disableInvis()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local pos = root and root.CFrame

    clearInvisSeat()

    if root and pos then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = pos + Vector3.new(0, 3, 0)
    end
    if hum then
        hum.Sit = false
        hum.PlatformStand = flyEnabled -- Fly nicht kaputt machen
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

local function enableInvis()
    clearInvisSeat()
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not root or not torso then return false end

    local savedCF = root.CFrame

    local seat = Instance.new("Seat")
    seat.Name = "InvisSeat"
    seat.Anchored = false
    seat.CanCollide = false
    seat.Transparency = 1
    seat.Position = Vector3.new(0, -400, 0) -- weit weg im Void
    seat.Parent = workspace

    local weld = Instance.new("Weld")
    weld.Part0 = seat
    weld.Part1 = torso
    weld.Parent = seat

    task.wait()
    seat.CFrame = savedCF
    invisSeat = seat
    return true
end

local invisToggle = InvisSection:addToggle({
    title = "Invisibility",
    callback = function(value)
        invisEnabled = value
        if value then
            local ok = enableInvis()
            if not ok then
                invisEnabled = false
                UI:Notify({ title = "Invisibility", text = "Charakter nicht bereit!" })
            else
                UI:Notify({ title = "Invisibility", text = "Du bist jetzt unsichtbar." })
            end
        else
            disableInvis()
            UI:Notify({ title = "Invisibility", text = "Du bist wieder sichtbar." })
        end
    end
})

-- Nach Respawn: alten Sitz weg, bei aktivem Toggle neu setzen
player.CharacterAdded:Connect(function()
    task.wait(0.6)
    clearInvisSeat()
    if invisEnabled then enableInvis() end
end)
-- ==================== ENDE INVISIBILITY ====================

-- ==================== GODMODE ====================
local GodSection = PlayerPage:addSection({ title = "Godmode" })

local godEnabled = false
local godConn = nil
local godFF = nil

local function removeGod()
    if godConn then godConn:Disconnect() godConn = nil end
    if godFF then godFF:Destroy() godFF = nil end
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.MaxHealth = 100
        hum.Health = 100
    end
end

local function applyGod()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end

    if godConn then godConn:Disconnect() godConn = nil end
    if godFF then godFF:Destroy() godFF = nil end

    hum.MaxHealth = math.huge
    hum.Health = math.huge

    godConn = hum.HealthChanged:Connect(function()
        if godEnabled and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
    end)

    godFF = Instance.new("ForceField")
    godFF.Visible = false
    godFF.Parent = char
    return true
end

GodSection:addToggle({
    title = "Godmode",
    callback = function(value)
        godEnabled = value
        if value then
            if applyGod() then
                UI:Notify({ title = "Godmode", text = "Godmode aktiviert." })
            else
                godEnabled = false
                UI:Notify({ title = "Godmode", text = "Charakter nicht bereit!" })
            end
        else
            removeGod()
            UI:Notify({ title = "Godmode", text = "Godmode deaktiviert." })
        end
    end
})

player.CharacterAdded:Connect(function()
    task.wait(0.6)
    if godEnabled then applyGod() end
end)
-- ==================== ENDE GODMODE ====================

local CombatPage = UI:addPage({ title = "Combat", icon = 6187718252 })
local ESPSection = CombatPage:addSection({ title = "ESP Settings" })

local ESPEnabled = true
local showGun = true
local showKnife = true
local showNone = true
local GunColor = Color3.fromRGB(0, 100, 255)
local KnifeColor = Color3.fromRGB(255, 0, 0)
local NoneColor = Color3.fromRGB(0, 255, 0)
local FillTransparency = 0.5
local OutlineTransparency = 0.2

-- Vorwärtsdeklaration, damit die Toggles unten die Funktionen kennen
local clearAllESP, updateESP

ESPSection:addToggle({
    title = "Enable ESP",
    default = true,
    callback = function(value)
        ESPEnabled = value
        if not ESPEnabled then clearAllESP() else updateESP() end
    end
})

ESPSection:addToggle({
    title = "Show Gun",
    default = true,
    callback = function(value)
        showGun = value
        updateESP()
    end
})

ESPSection:addToggle({
    title = "Show Knife",
    default = true,
    callback = function(value)
        showKnife = value
        updateESP()
    end
})

ESPSection:addToggle({
    title = "Show No Weapon",
    default = true,
    callback = function(value)
        showNone = value
        updateESP()
    end
})

ESPSection:addColorPicker({
    title = "Gun Color",
    default = GunColor,
    callback = function(color)
        GunColor = color
        updateESP()
    end
})

ESPSection:addColorPicker({
    title = "Knife Color",
    default = KnifeColor,
    callback = function(color)
        KnifeColor = color
        updateESP()
    end
})

ESPSection:addColorPicker({
    title = "No Weapon Color",
    default = NoneColor,
    callback = function(color)
        NoneColor = color
        updateESP()
    end
})

ESPSection:addSlider({
    title = "Fill Transparency (%)",
    default = 50,
    min = 0,
    max = 100,
    callback = function(value)
        FillTransparency = value / 100
        updateESP()
    end
})

ESPSection:addSlider({
    title = "Outline Transparency (%)",
    default = 20,
    min = 0,
    max = 100,
    callback = function(value)
        OutlineTransparency = value / 100
        updateESP()
    end
})

local weaponCache = {}
local espObjects = {}
local espScreenGui = Instance.new("ScreenGui")
espScreenGui.Name = "ESPScreenGui"
espScreenGui.Parent = player.PlayerGui

local function updateWeaponCacheForPlayer(plr)
    if plr == player then weaponCache[plr] = nil return end
    local found = nil
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                if string.find(name, "gun") then found = "Gun" break
                elseif string.find(name, "knife") then found = "Knife" break end
            end
        end
    end
    if not found and plr.Character then
        for _, item in ipairs(plr.Character:GetChildren()) do
            if item:IsA("Tool") then
                local name = string.lower(item.Name)
                if string.find(name, "gun") then found = "Gun" break
                elseif string.find(name, "knife") then found = "Knife" break end
            end
        end
    end
    weaponCache[plr] = found
end

local function refreshAllCache()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        updateWeaponCacheForPlayer(plr)
    end
end

local function getPlayerInfo(plr)
    local itemType = weaponCache[plr]
    if itemType == "Gun" then
        return GunColor, plr.Name .. " [Gun]", "Gun"
    elseif itemType == "Knife" then
        return KnifeColor, plr.Name .. " [Knife]", "Knife"
    else
        return NoneColor, plr.Name .. " [None]", "None"
    end
end

local function createESPForPlayer(plr)
    if espObjects[plr] then
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        if espObjects[plr].Frame then espObjects[plr].Frame:Destroy() end
        espObjects[plr] = nil
    end
    if not plr.Character then return end

    local color, displayText, itemType = getPlayerInfo(plr)
    if (itemType == "Gun" and not showGun) or
       (itemType == "Knife" and not showKnife) or
       (itemType == "None" and not showNone) then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Parent = plr.Character
    highlight.FillColor = color
    highlight.FillTransparency = FillTransparency
    highlight.OutlineColor = color
    highlight.OutlineTransparency = OutlineTransparency
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = espScreenGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = displayText
    text.TextColor3 = color
    text.TextSize = 16
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.3
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = frame

    espObjects[plr] = { Highlight = highlight, Frame = frame }
end

local function removeESPForPlayer(plr)
    if espObjects[plr] then
        if espObjects[plr].Highlight then espObjects[plr].Highlight:Destroy() end
        if espObjects[plr].Frame then espObjects[plr].Frame:Destroy() end
        espObjects[plr] = nil
    end
end

function clearAllESP()
    for plr, data in pairs(espObjects) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Frame then data.Frame:Destroy() end
    end
    espObjects = {}
    weaponCache = {}
end

function updateESP()
    if not ESPEnabled then clearAllESP() return end
    refreshAllCache()
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            if not plr.Character then
                if espObjects[plr] then removeESPForPlayer(plr) end
            else
                local _, _, itemType = getPlayerInfo(plr)
                local shouldShow = true
                if (itemType == "Gun" and not showGun) or
                   (itemType == "Knife" and not showKnife) or
                   (itemType == "None" and not showNone) then
                    shouldShow = false
                end
                if shouldShow then
                    if not espObjects[plr] then
                        createESPForPlayer(plr)
                    else
                        local oldColor = espObjects[plr].Highlight.FillColor
                        local newColor, _ = getPlayerInfo(plr)
                        if oldColor ~= newColor then
                            createESPForPlayer(plr)
                        end
                        if espObjects[plr] then
                            espObjects[plr].Highlight.FillTransparency = FillTransparency
                            espObjects[plr].Highlight.OutlineTransparency = OutlineTransparency
                        end
                    end
                else
                    if espObjects[plr] then
                        removeESPForPlayer(plr)
                    end
                end
            end
        end
    end
    for plr, _ in pairs(espObjects) do
        if not game.Players:FindFirstChild(plr.Name) then removeESPForPlayer(plr) end
    end
end

runService.RenderStepped:Connect(function()
    if not ESPEnabled then return end
    for plr, data in pairs(espObjects) do
        local frame = data.Frame
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local headPos = root.Position + Vector3.new(0, 3.5, 0)
            local screenPos, onScreen = camera:WorldToScreenPoint(headPos)
            if onScreen then
                frame.Position = UDim2.new(0, screenPos.X - 100, 0, screenPos.Y - 15)
                frame.Visible = true
            else
                frame.Visible = false
            end
        else
            frame.Visible = false
        end
    end
end)

local function espMainLoop()
    while true do wait(0.5) updateESP() end
end
coroutine.wrap(espMainLoop)()

game.Players.PlayerAdded:Connect(function(newPlayer)
    wait(0.2)
    updateESP()
    newPlayer.CharacterAdded:Connect(function()
        wait(0.3)
        if espObjects[newPlayer] then
            createESPForPlayer(newPlayer)
        else
            updateESP()
        end
    end)
end)

game.Players.PlayerRemoving:Connect(function(removedPlayer)
    removeESPForPlayer(removedPlayer)
    weaponCache[removedPlayer] = nil
end)

player.CharacterAdded:Connect(function()
    wait(0.3)
    updateESP()
end)

for _, plr in ipairs(game.Players:GetPlayers()) do
    if plr ~= player then
        plr.CharacterAdded:Connect(function()
            wait(0.3)
            if espObjects[plr] then
                createESPForPlayer(plr)
            else
                updateESP()
            end
        end)
    end
end

local GunDropSection = CombatPage:addSection({ title = "GunDrop ESP" })

local gunDropEnabled = true
local gunDropColor = Color3.fromRGB(0, 200, 255)
local gunDropObjects = {}
local gunDropListener = nil
local gunDropScreenGui = nil

local function isGunDrop(instance)
    if not instance then return false end
    local name = string.lower(instance.Name)
    return string.find(name, "gundrop") or string.find(name, "drop")
end

local function getGunDropPosition(instance)
    local primary = instance:FindFirstChild("PrimaryPart")
    if primary then return primary.Position end
    local part = instance:FindFirstChildOfClass("BasePart")
    if part then return part.Position end
    if instance:IsA("BasePart") then return instance.Position end
    for _, child in ipairs(instance:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
    return nil
end

local function createGunDropESP(instance)
    if gunDropObjects[instance] then return end
    if not instance or not instance.Parent then return end

    local pos = getGunDropPosition(instance)
    if not pos then return end

    if not gunDropScreenGui then
        gunDropScreenGui = Instance.new("ScreenGui")
        gunDropScreenGui.Name = "GunDropESP_Overlay"
        gunDropScreenGui.Parent = player.PlayerGui
        gunDropScreenGui.ResetOnSpawn = false
    end

    local highlight = Instance.new("Highlight")
    highlight.Parent = instance
    highlight.FillColor = gunDropColor
    highlight.FillTransparency = 0.4
    highlight.OutlineColor = gunDropColor
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 150, 0, 25)
    frame.BackgroundTransparency = 1
    frame.Parent = gunDropScreenGui

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.Text = "GunDrop"
    text.TextColor3 = gunDropColor
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.TextStrokeTransparency = 0.3
    text.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    text.TextXAlignment = Enum.TextXAlignment.Center
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.Parent = frame

    gunDropObjects[instance] = { Highlight = highlight, Frame = frame }

    instance.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            if gunDropObjects[instance] then
                local data = gunDropObjects[instance]
                if data.Highlight then data.Highlight:Destroy() end
                if data.Frame then data.Frame:Destroy() end
                gunDropObjects[instance] = nil
            end
        end
    end)
end

local function scanGunDrops()
    if not gunDropEnabled then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isGunDrop(obj) then
            createGunDropESP(obj)
        end
    end
end

local function startGunDropListener()
    if gunDropListener then return end
    gunDropListener = workspace.DescendantAdded:Connect(function(obj)
        if gunDropEnabled and isGunDrop(obj) then
            createGunDropESP(obj)
        end
    end)
end

local function stopGunDropListener()
    if gunDropListener then
        gunDropListener:Disconnect()
        gunDropListener = nil
    end
end

local function clearGunDropESP()
    for obj, data in pairs(gunDropObjects) do
        if data.Highlight then data.Highlight:Destroy() end
        if data.Frame then data.Frame:Destroy() end
    end
    gunDropObjects = {}
    if gunDropScreenGui then
        gunDropScreenGui:Destroy()
        gunDropScreenGui = nil
    end
end

GunDropSection:addToggle({
    title = "Enable GunDrop ESP",
    callback = function(value)
        gunDropEnabled = value
        if value then
            scanGunDrops()
            startGunDropListener()
        else
            clearGunDropESP()
            stopGunDropListener()
        end
    end
})

GunDropSection:addColorPicker({
    title = "GunDrop Color",
    default = gunDropColor,
    callback = function(color)
        gunDropColor = color
        for obj, data in pairs(gunDropObjects) do
            if data.Highlight then
                data.Highlight.FillColor = gunDropColor
                data.Highlight.OutlineColor = gunDropColor
            end
            if data.Frame and data.Frame:FindFirstChildOfClass("TextLabel") then
                data.Frame:FindFirstChildOfClass("TextLabel").TextColor3 = gunDropColor
            end
        end
    end
})

local function teleportToGunDropAndBack()
    local foundObjects = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isGunDrop(obj) then
            table.insert(foundObjects, obj)
        end
    end
    if #foundObjects == 0 then
        UI:Notify({ title = "GunDrop", text = "No GunDrop found!", duration = 2 })
        return
    end
    local targetObj = foundObjects[1]
    local targetPos = getGunDropPosition(targetObj)
    if not targetPos then
        UI:Notify({ title = "GunDrop", text = "GunDrop has no valid part!", duration = 2 })
        return
    end
    local char = player.Character
    if not char then
        UI:Notify({ title = "GunDrop", text = "Your character is not ready!", duration = 2 })
        return
    end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        UI:Notify({ title = "GunDrop", text = "No HumanoidRootPart!", duration = 2 })
        return
    end
    local originalCF = rootPart.CFrame
    rootPart.CFrame = CFrame.new(targetPos)
    task.wait(0.05)
    rootPart.CFrame = originalCF
    UI:Notify({ title = "GunDrop", text = "Quick teleport done!", duration = 1 })
end

GunDropSection:addButton({
    title = "Quick Teleport to GunDrop (and back)",
    callback = teleportToGunDropAndBack
})

local function updateGunDropPositions()
    if not gunDropEnabled then return end
    for obj, data in pairs(gunDropObjects) do
        local frame = data.Frame
        if not frame then continue end
        if not obj or not obj.Parent then
            frame.Visible = false
            continue
        end
        local pos = getGunDropPosition(obj)
        if not pos then
            frame.Visible = false
            continue
        end
        local screenPos, onScreen = camera:WorldToScreenPoint(pos)
        if onScreen then
            frame.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - 15)
            frame.Visible = true
        else
            frame.Visible = false
        end
    end
end

runService.RenderStepped:Connect(updateGunDropPositions)

local AimbotSection = CombatPage:addSection({ title = "Aimbot Settings" })

local aimbotEnabled = true
local aimSmoothness = 0.3
local aimbotConnection = nil

local function hasKnife(plr)
    if plr == player then return false end
    local char = plr.Character
    if not char then return false end
    
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "knife") then
            return true
        end
    end
    
    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and string.find(string.lower(item.Name), "knife") then
                return true
            end
        end
    end
    return false
end

local function getClosestKnifePlayer()
    local closest = nil
    local closestDist = math.huge
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr ~= player and hasKnife(plr) then
            local char = plr.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid and humanoid.Health > 0 then
                    local pos = hrp.Position
                    local screenPos, onScreen = camera:WorldToScreenPoint(pos)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = pos
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function aimbotLoop()
    if not aimbotEnabled then return end
    local target = getClosestKnifePlayer()
    if target then
        local currentCF = camera.CFrame
        local targetCF = CFrame.lookAt(currentCF.Position, target)
        camera.CFrame = currentCF:Lerp(targetCF, aimSmoothness)
    end
end

local function startAimbot()
    if aimbotConnection then 
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    aimbotConnection = runService.Heartbeat:Connect(aimbotLoop)
end

local function stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        startAimbot()
    else
        stopAimbot()
    end
end

AimbotSection:addToggle({
    title = "Enable Aimbot (Press E)",
    default = true,
    callback = function(value)
        aimbotEnabled = value
        if value then
            startAimbot()
        else
            stopAimbot()
        end
    end
})

-- Fix: Venyx-Slider arbeiten mit ganzen Zahlen -> 1-100, intern durch 100 teilen
-- Je höher der Wert, desto stärker klebt die Kamera am Spieler
AimbotSection:addSlider({
    title = "Aim Stärke (%)",
    default = 30,
    min = 1,
    max = 100,
    callback = function(value)
        aimSmoothness = value / 100
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleAimbot()
    end
end)

local VisualsPage = UI:addPage({ title = "Visuals", icon = 15330618083 })
local CursorSection = VisualsPage:addSection({ title = "Cursor" })

local cursorEnabled = false
local defaultIcon = player:GetMouse().Icon

CursorSection:addToggle({
    title = "Custom Cursor",
    callback = function(value)
        cursorEnabled = value
        player:GetMouse().Icon = value and "rbxassetid://11232270732" or defaultIcon
    end
})

local EffectsSection = VisualsPage:addSection({ title = "Remove Effects" })

local effectsEnabled = false
local effectsConnection = nil

local function removeAllEffects()
    local lighting = game:GetService("Lighting")
    for _, child in ipairs(lighting:GetChildren()) do
        if child:IsA("Atmosphere") or child:IsA("BloomEffect") or child:IsA("ColorCorrectionEffect") or
           child:IsA("SunRaysEffect") or child:IsA("DepthOfFieldEffect") or child:IsA("BlurEffect") then
            pcall(function() child:Destroy() end)
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
           obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Attachment") then
            pcall(function() obj:Destroy() end)
        end
    end
end

local function startCleanup()
    if effectsConnection then return end
    removeAllEffects()
    effectsConnection = workspace.DescendantAdded:Connect(function(obj)
        if effectsEnabled then
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or
               obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Attachment") then
                pcall(function() obj:Destroy() end)
            end
        end
    end)
end

local function stopCleanup()
    if effectsConnection then
        effectsConnection:Disconnect()
        effectsConnection = nil
    end
end

EffectsSection:addToggle({
    title = "Remove All Effects",
    callback = function(value)
        effectsEnabled = value
        if value then startCleanup() else stopCleanup() end
    end
})

local FogSection = VisualsPage:addSection({ title = "Fog" })

local fogEnabled = false
local fogEnd = 500
local fogColor = Color3.fromRGB(140, 60, 200)
local fogHeartbeat = nil

local function applyFog()
    local lighting = game:GetService("Lighting")
    if fogEnabled then
        lighting.FogEnd = fogEnd
        lighting.FogStart = 0
        lighting.Brightness = 0.8
        lighting.FogColor = fogColor
    else
        lighting.FogEnd = 1000
        lighting.FogStart = 0
        lighting.Brightness = 1
        lighting.FogColor = Color3.fromRGB(255, 255, 255)
    end
end

local function startFogLoop()
    if fogHeartbeat then return end
    fogHeartbeat = runService.Heartbeat:Connect(function()
        if fogEnabled then
            local lighting = game:GetService("Lighting")
            lighting.FogColor = fogColor
            lighting.FogEnd = fogEnd
        end
    end)
end

local function stopFogLoop()
    if fogHeartbeat then
        fogHeartbeat:Disconnect()
        fogHeartbeat = nil
    end
end

FogSection:addToggle({
    title = "Enable Fog",
    callback = function(value)
        fogEnabled = value
        if value then
            applyFog()
            startFogLoop()
        else
            stopFogLoop()
            applyFog()
        end
    end
})

FogSection:addSlider({
    title = "Fog Distance",
    default = 500,
    min = 100,
    max = 2000,
    callback = function(value)
        fogEnd = value
        if fogEnabled then game:GetService("Lighting").FogEnd = fogEnd end
    end
})

FogSection:addColorPicker({
    title = "Fog Color",
    default = fogColor,
    callback = function(color)
        fogColor = color
        if fogEnabled then game:GetService("Lighting").FogColor = fogColor end
    end
})

local TransSection = VisualsPage:addSection({ title = "Transparency" })

local transEnabled = false
local selfTrans = 0.5
local otherTrans = 0.8
local transConnections = {}

local function applyTransToChar(char, trans)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = trans
        end
    end
    local conn = char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = trans
        end
    end)
    return conn
end

local function applyAllTrans()
    if not transEnabled then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            local c = plr.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                        p.Transparency = 0
                    end
                end
            end
        end
        return
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do
        local c = plr.Character
        if c then
            local t = (plr == player) and selfTrans or otherTrans
            applyTransToChar(c, t)
        end
    end
end

local function setupTransListeners()
    for _, conn in ipairs(transConnections) do conn:Disconnect() end
    transConnections = {}
    local function onPlayerAdded(plr)
        local function onCharAdded(char)
            if transEnabled then
                local t = (plr == player) and selfTrans or otherTrans
                local conn = applyTransToChar(char, t)
                table.insert(transConnections, conn)
            end
        end
        if plr.Character then onCharAdded(plr.Character) end
        local conn = plr.CharacterAdded:Connect(onCharAdded)
        table.insert(transConnections, conn)
    end
    for _, plr in ipairs(game.Players:GetPlayers()) do onPlayerAdded(plr) end
    local conn = game.Players.PlayerAdded:Connect(onPlayerAdded)
    table.insert(transConnections, conn)
end

TransSection:addToggle({
    title = "Enable Transparency",
    callback = function(value)
        transEnabled = value
        if value then
            setupTransListeners()
            applyAllTrans()
        else
            for _, conn in ipairs(transConnections) do conn:Disconnect() end
            transConnections = {}
            applyAllTrans()
        end
    end
})

TransSection:addSlider({
    title = "Self Transparency (%)",
    default = 50,
    min = 0,
    max = 100,
    callback = function(value)
        selfTrans = value / 100
        if transEnabled then applyAllTrans() end
    end
})

TransSection:addSlider({
    title = "Others Transparency (%)",
    default = 80,
    min = 0,
    max = 100,
    callback = function(value)
        otherTrans = value / 100
        if transEnabled then applyAllTrans() end
    end
})

local CameraSection = VisualsPage:addSection({ title = "Camera" })

CameraSection:addSlider({
    title = "Field of View (FOV)",
    default = 70,
    min = 1,
    max = 120,
    callback = function(value)
        workspace.CurrentCamera.FieldOfView = value
    end
})

local MonoSection = VisualsPage:addSection({ title = "Monochrome" })

local monochromeEnabled = false
local monochromeData = {}
local monochromeListener = nil

local function isPartPartOfPlayer(part)
    local model = part:FindFirstAncestorOfClass("Model")
    if model and game.Players:GetPlayerFromCharacter(model) then
        return true
    end
    return false
end

local function rgbToDarkGray(color)
    local gray = (color.R + color.G + color.B) / 3
    local dark = gray * 0.25
    return Color3.new(dark, dark, dark)
end

local function applyMonochromeToPart(part)
    if not part:IsA("BasePart") then return end
    if isPartPartOfPlayer(part) then return end
    if not monochromeData[part] then
        monochromeData[part] = {
            Color = part.Color,
            Material = part.Material
        }
    end
    local darkColor = rgbToDarkGray(part.Color)
    part.Color = darkColor
    part.Material = Enum.Material.Plastic
end

local function restorePart(part)
    if monochromeData[part] then
        part.Color = monochromeData[part].Color
        part.Material = monochromeData[part].Material
        monochromeData[part] = nil
    end
end

local function applyMonochromeToAll()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            applyMonochromeToPart(obj)
        end
    end
end

local function restoreAll()
    for part, data in pairs(monochromeData) do
        if part and part.Parent then
            part.Color = data.Color
            part.Material = data.Material
        end
    end
    monochromeData = {}
end

local function toggleMonochrome(value)
    monochromeEnabled = value
    if value then
        applyMonochromeToAll()
        if monochromeListener then monochromeListener:Disconnect() end
        monochromeListener = workspace.DescendantAdded:Connect(function(obj)
            if monochromeEnabled and obj:IsA("BasePart") and not isPartPartOfPlayer(obj) then
                applyMonochromeToPart(obj)
            end
        end)
    else
        if monochromeListener then
            monochromeListener:Disconnect()
            monochromeListener = nil
        end
        restoreAll()
    end
end

MonoSection:addToggle({
    title = "Enable Monochrome (dark gray/black)",
    callback = function(value)
        toggleMonochrome(value)
    end
})

-- ==================== ABOUT TAB ====================
local AboutInfo = {
    Creator = "Leland",
    Version = "v1.2.0",            -- <- bei jedem Update ändern
    Updated = "28.09.2026",        -- <- Datum des letzten Updates
    Game    = "Murder Mystery 2",
    Discord = "discord.gg/rSkMxB5bx7"
}

local AboutPage = UI:addPage({ title = "About", icon = 7992557358 })

-- Info-Abschnitt
local InfoSection = AboutPage:addSection({ title = "Info" })

local function infoLine(text)
    InfoSection:addButton({
        title = text,
        callback = function() end -- reine Anzeige
    })
end

infoLine("Name: Leland Hack")
infoLine("Erstellt von: " .. AboutInfo.Creator)
infoLine("Version: " .. AboutInfo.Version)
infoLine("Letztes Update: " .. AboutInfo.Updated)
infoLine("Spiel: " .. AboutInfo.Game)

-- Features-Abschnitt
local FeatureSection = AboutPage:addSection({ title = "Features" })

local function featureLine(text)
    FeatureSection:addButton({
        title = text,
        callback = function() end
    })
end

featureLine("Player: Speed, Jump, Gravity, Noclip, Fly, Invisibility, Godmode")
featureLine("Combat: Spieler-ESP, GunDrop-ESP, Aimbot")
featureLine("Visuals: Fog, Transparenz, FOV, Monochrome")

-- Steuerung-Abschnitt
local ControlSection = AboutPage:addSection({ title = "Steuerung" })

local function controlLine(text)
    ControlSection:addButton({
        title = text,
        callback = function() end
    })
end

controlLine("E = Aimbot an/aus")
controlLine("C = Fly an/aus")
controlLine("X = Noclip an/aus")
controlLine("Leertaste = Fly hoch")
controlLine("Strg / Shift = Fly runter")
controlLine("-/+ Button = Menü klein/groß")

-- Extras
local ExtraSection = AboutPage:addSection({ title = "Extras" })

if AboutInfo.Discord ~= "" then
    ExtraSection:addButton({
        title = "Discord-Link kopieren",
        callback = function()
            if setclipboard then
                setclipboard(AboutInfo.Discord)
                UI:Notify({ title = "About", text = "Discord-Link kopiert!", duration = 2 })
            else
                UI:Notify({ title = "About", text = "Dein Executor unterstützt kein Kopieren.", duration = 3 })
            end
        end
    })
end

ExtraSection:addButton({
    title = "Version kopieren",
    callback = function()
        if setclipboard then
            setclipboard("LelandHack " .. AboutInfo.Version)
            UI:Notify({ title = "About", text = "Version kopiert!", duration = 2 })
        end
    end
})
-- ==================== ENDE ABOUT TAB ====================

task.wait(0.2)

updateESP()
applyMovementSettings()

if transEnabled then applyAllTrans() end
if monochromeEnabled then toggleMonochrome(true) end
if fogEnabled then applyFog(); startFogLoop() end
if effectsEnabled then startCleanup() end
if cursorEnabled then player:GetMouse().Icon = "rbxassetid://11232270732" end
if aimbotEnabled then startAimbot() end
if gunDropEnabled then
    scanGunDrops()
    startGunDropListener()
end



-- ==================== MINIMIZE / RESTORE ====================
local CoreGui = game:GetService("CoreGui")

-- Hauptfenster von Venyx finden
local function getMainFrame()
    local container = UI.container
    if container and container:FindFirstChild("Main") then
        return container.Main
    end
    local roots = { (gethui and gethui()) or CoreGui, CoreGui, player:FindFirstChild("PlayerGui") }
    for _, root in ipairs(roots) do
        if root then
            local gui = root:FindFirstChild("Leland Hack")
            if gui and gui:FindFirstChild("Main") then
                return gui.Main
            end
        end
    end
    return nil
end

-- Runder Kreis (erscheint nur, wenn das Fenster klein gemacht wurde)
local miniGui = Instance.new("ScreenGui")
miniGui.Name = "RufuMinimizeBubble"
miniGui.ResetOnSpawn = false
miniGui.DisplayOrder = 999
miniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
    miniGui.Parent = (gethui and gethui()) or CoreGui
end)
if not miniGui.Parent then
    miniGui.Parent = player:WaitForChild("PlayerGui")
end

local bubble = Instance.new("TextButton")
bubble.Name = "Bubble"
bubble.Size = UDim2.new(0, 46, 0, 46)
bubble.Position = UDim2.new(0, 20, 0.5, -23)
bubble.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
bubble.BorderSizePixel = 0
bubble.Text = "+"
bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
bubble.TextSize = 26
bubble.Font = Enum.Font.GothamBold
bubble.AutoButtonColor = true
bubble.Active = true
bubble.Visible = false
bubble.Parent = miniGui

local bubbleCorner = Instance.new("UICorner")
bubbleCorner.CornerRadius = UDim.new(1, 0) -- voller Kreis
bubbleCorner.Parent = bubble

local bubbleStroke = Instance.new("UIStroke")
bubbleStroke.Color = Color3.fromRGB(80, 80, 80)
bubbleStroke.Thickness = 1.5
bubbleStroke.Parent = bubble

local function setMenuVisible(state)
    local main = getMainFrame()
    if main then
        main.Visible = state
    end
    bubble.Visible = not state
end

-- "-" Button direkt im Fenster (oben rechts)
local main = getMainFrame()
if main then
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "MinimizeButton"
    minBtn.AnchorPoint = Vector2.new(1, 0)
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.Position = UDim2.new(1, -10, 0, 10)
    minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    minBtn.BorderSizePixel = 0
    minBtn.Text = "-"
    minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minBtn.TextSize = 22
    minBtn.Font = Enum.Font.GothamBold
    minBtn.ZIndex = 100
    minBtn.Parent = main

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minBtn

    minBtn.MouseButton1Click:Connect(function()
        setMenuVisible(false)
    end)
else
    warn("Leland Hack: Hauptfenster nicht gefunden - '-' Button konnte nicht erstellt werden")
end

-- Kreis verschiebbar machen + Klick zum Vergrößern
local dragging, moved = false, false
local dragStart, startPos

bubble.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        moved = false
        dragStart = input.Position
        startPos = bubble.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then moved = true end
        if moved then
            bubble.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch) then
        dragging = false
        if not moved then
            setMenuVisible(true) -- nur Klick, kein Verschieben -> Fenster wieder groß
        end
    end
end)
-- ==================== ENDE MINIMIZE / RESTORE ====================