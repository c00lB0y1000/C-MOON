local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Создаем видимые всем части
local function createVisiblePart()
    local part = Instance.new("Part")
    part.Anchored = false
    part.CanCollide = false
    part.Transparency = 0.7
    part.Color = Color3.fromRGB(255, 100, 100)
    part.Size = Vector3.new(5, 5, 5)
    part.Material = Enum.Material.Neon
    
    -- Делаем часть физически управляемой нашим клиентом
    part.Parent = workspace
    if part:IsA("BasePart") then
        local networkOwner = Player
        pcall(function()
            part:SetNetworkOwner(networkOwner)
        end)
    end
    
    return part
end

-- Эффект гравитационного переворота (C-Moon основная способность)
local function gravityFlipEffect(targetPosition)
    local parts = {}
    
    -- Создаем кольцо эффекта
    for i = 1, 12 do
        local part = createVisiblePart()
        part.Shape = Enum.PartType.Ball
        part.Position = targetPosition + Vector3.new(0, 5, 0)
        table.insert(parts, part)
    end
    
    -- Анимация эффекта
    local duration = 2
    local startTime = time()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = time() - startTime
        if elapsed > duration then
            connection:Disconnect()
            for _, part in ipairs(parts) do
                part:Destroy()
            end
            return
        end
        
        local progress = elapsed / duration
        local radius = 10 * progress
        local height = 5 * (1 - progress)
        
        for i, part in ipairs(parts) do
            local angle = math.rad(i * 30)
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            part.Position = targetPosition + Vector3.new(x, height, z)
            part.Size = Vector3.new(3, 3, 3) * (1 - progress)
        end
    end)
end

-- Эффект гравитационного толчка
local function gravityPushEffect()
    local center = HumanoidRootPart.Position
    local part = createVisiblePart()
    part.Shape = Enum.PartType.Cylinder
    part.Size = Vector3.new(1, 10, 10)
    part.Position = center
    
    local duration = 1.5
    local startTime = time()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local elapsed = time() - startTime
        if elapsed > duration then
            connection:Disconnect()
            part:Destroy()
            return
        end
        
        local progress = elapsed / duration
        part.Size = Vector3.new(1, 10 + 20 * progress, 10 + 20 * progress)
        part.Transparency = 0.7 + 0.3 * progress
    end)
end

-- Управление способностями
local abilities = {
    {
        name = "Gravity Flip",
        key = Enum.KeyCode.Q,
        cooldown = 8,
        ready = true,
        action = function()
            local target = HumanoidRootPart.Position + HumanoidRootPart.CFrame.LookVector * 20
            gravityFlipEffect(target)
        end
    },
    {
        name = "Gravity Push",
        key = Enum.KeyCode.E,
        cooldown = 4,
        ready = true,
        action = gravityPushEffect
    }
}

-- Обработка ввода
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    for _, ability in ipairs(abilities) do
        if input.KeyCode == ability.key and ability.ready then
            ability.ready = false
            ability.action()
            
            -- Перезарядка
            task.delay(ability.cooldown, function()
                ability.ready = true
                print(ability.name.." ready!")
            end)
        end
    end
end)

-- Визуальные эффекты персонажа (постоянные)
local function setupCharacterEffects()
    -- Создаем ауру вокруг персонажа
    local aura = Instance.new("Part")
    aura.Name = "CMoonAura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(10, 10, 10)
    aura.Transparency = 0.9
    aura.Color = Color3.fromRGB(255, 150, 150)
    aura.Material = Enum.Material.Neon
    aura.Anchored = false
    aura.CanCollide = false
    aura.Parent = Character
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HumanoidRootPart
    weld.Part1 = aura
    weld.Parent = aura
    
    -- Делаем видимым для всех
    if aura:IsA("BasePart") then
        pcall(function()
            aura:SetNetworkOwner(nil) -- Это сделает часть видимой для всех
        end)
    end
    
    -- Анимируем ауру
    RunService.Heartbeat:Connect(function()
        aura.Size = Vector3.new(10 + math.sin(time() * 3) * 2, 10 + math.cos(time() * 3) * 2, 10)
    end)
end

-- Инициализация
Character:WaitForChild("Humanoid").Died:Connect(function()
    workspace:FindFirstChild("CMoonAura"):Destroy()
end)

setupCharacterEffects()
print("C-Moon powers activated! Use Q and E")
