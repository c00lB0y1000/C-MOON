-- Локальный скрипт для C-Moon способностей (видимых всем)
local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- Создаем визуальные элементы, которые будут видны всем
local function createGlobalEffects()
    -- Эффект ауры C-Moon (видимый всем)
    local aura = Instance.new("Part")
    aura.Name = "CMoonAura"
    aura.Shape = Enum.PartType.Ball
    aura.Size = Vector3.new(12, 12, 12)
    aura.Transparency = 0.85
    aura.Color = Color3.fromRGB(180, 70, 200)
    aura.Material = Enum.Material.Neon
    aura.Anchored = false
    aura.CanCollide = false
    aura.Parent = Character

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = HumanoidRootPart
    weld.Part1 = aura
    weld.Parent = aura

    -- Эффект гравитационных волн
    local gravityWave = Instance.new("Part")
    gravityWave.Name = "GravityWave"
    gravityWave.Size = Vector3.new(1, 1, 1)
    gravityWave.Transparency = 1
    gravityWave.CanCollide = false
    gravityWave.Anchored = false
    gravityWave.Parent = Character
    
    local waveWeld = Instance.new("WeldConstraint")
    waveWeld.Part0 = HumanoidRootPart
    waveWeld.Part1 = gravityWave
    waveWeld.Parent = gravityWave
    
    -- Создаем ParticleEmitter внутри невидимой части
    local emitter = Instance.new("ParticleEmitter")
    emitter.Lifetime = NumberRange.new(1.5)
    emitter.Rate = 30
    emitter.Speed = NumberRange.new(5)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 2),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Color = ColorSequence.new(Color3.fromRGB(180, 70, 200))
    emitter.LightEmission = 0.8
    emitter.Texture = "rbxassetid://242527987"
    emitter.Parent = gravityWave
    emitter.Enabled = false
    
    return aura, gravityWave, emitter
end

-- Инициализация эффектов
local aura, gravityWave, gravityEmitter = createGlobalEffects()

-- Анимация ауры
local auraTween
local function animateAura()
    while true do
        auraTween = TweenService:Create(
            aura,
            TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            {Size = Vector3.new(15, 15, 15)}
        )
        auraTween:Play()
        wait(1.5)
    end
end

coroutine.wrap(animateAura)()

-- Способность 1: Гравитационный толчок (видимый всем)
local function gravityPush()
    -- Активируем эмиттер для визуального эффекта
    gravityEmitter.Enabled = true
    
    -- Расширяем эффект (видно всем через изменение размера)
    local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quint)
    local expandTween = TweenService:Create(
        gravityEmitter,
        tweenInfo,
        {Speed = NumberRange.new(20), Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 5),
            NumberSequenceKeypoint.new(1, 0)
        })}
    )
    expandTween:Play()
    
    -- Ждем и возвращаем к нормальному состоянию
    wait(0.8)
    local resetTween = TweenService:Create(
        gravityEmitter,
        TweenInfo.new(0.5),
        {Speed = NumberRange.new(5), Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 2),
            NumberSequenceKeypoint.new(1, 0)
        })}
    )
    resetTween:Play()
    
    wait(0.5)
    gravityEmitter.Enabled = false
end

-- Способность 2: Гравитационный переворот (видимый всем)
local function gravityFlip()
    -- Изменение свойств персонажа (видно всем)
    local originalColor = aura.Color
    local originalSize = aura.Size
    
    -- Мигание ауры
    for i = 1, 3 do
        local tween = TweenService:Create(
            aura,
            TweenInfo.new(0.15),
            {Color = Color3.fromRGB(255, 50, 50), Size = Vector3.new(18, 18, 18)}
        )
        tween:Play()
        wait(0.15)
        tween = TweenService:Create(
            aura,
            TweenInfo.new(0.15),
            {Color = originalColor, Size = originalSize}
        )
        tween:Play()
        wait(0.15)
    end
    
    -- Эффект переворота
    gravityEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 50, 50))
    gravityEmitter.Enabled = true
    
    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back)
    local flipTween = TweenService:Create(
        gravityEmitter,
        tweenInfo,
        {Speed = NumberRange.new(30), Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 3),
            NumberSequenceKeypoint.new(0.5, 8),
            NumberSequenceKeypoint.new(1, 0)
        })}
    )
    flipTween:Play()
    
    wait(1)
    gravityEmitter.Enabled = false
    gravityEmitter.Color = ColorSequence.new(Color3.fromRGB(180, 70, 200))
end

-- Управление способностями
local abilities = {
    {
        name = "Gravity Push",
        key = Enum.KeyCode.E,
        cooldown = 4,
        ready = true,
        action = gravityPush
    },
    {
        name = "Gravity Flip",
        key = Enum.KeyCode.Q,
        cooldown = 8,
        ready = true,
        action = gravityFlip
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
            end)
        end
    end
end)

-- Убираем эффекты при смерти
Character:WaitForChild("Humanoid").Died:Connect(function()
    if aura then aura:Destroy() end
    if gravityWave then gravityWave:Destroy() end
    if auraTween then auraTween:Cancel() end
end)

print("C-Moon powers activated! Use Q and E")
