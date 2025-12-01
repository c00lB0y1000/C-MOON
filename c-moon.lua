print("🔍 ПОИСК ВСЕХ CLICKDETECTOR (ОСОБО TRASH)")
print("=" .. string.rep("=", 70))

-- Создадим тестовый trash для проверки
local testTrash = Instance.new("Part")
testTrash.Name = "TestTrashCan"
testTrash.Position = Vector3.new(0, 5, 0)
testTrash.Anchored = true
local testDetector = Instance.new("ClickDetector")
testDetector.Parent = testTrash
testTrash.Parent = workspace
print("✅ Создал тестовый TrashCan с ClickDetector")
print("")

-- Функция получения пути
function getPath(obj)
    local parts = {}
    local current = obj
    
    while current and current ~= game do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    
    return table.concat(parts, " > ")
end

-- Ищем ВСЕ ClickDetector
local allDetectors = {}
local trashDetectors = {}
local otherDetectors = {}

print("🔍 Сканирую Workspace...")
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("ClickDetector") then
        local parent = obj.Parent
        local path = getPath(parent)
        local nameLower = parent.Name:lower()
        local pathLower = path:lower()
        
        local detectorInfo = {
            detector = obj,
            parent = parent,
            path = path,
            name = parent.Name,
            type = parent.ClassName
        }
        
        table.insert(allDetectors, detectorInfo)
        
        -- Проверяем если связано с trash/мусоркой
        if nameLower:find("trash") or 
           nameLower:find("garbage") or 
           nameLower:find("bin") or
           nameLower:find("мусор") or
           pathLower:find("trash") or
           pathLower:find("garbage") or
           pathLower:find("bin") then
            
            detectorInfo.isTrash = true
            table.insert(trashDetectors, detectorInfo)
        else
            table.insert(otherDetectors, detectorInfo)
        end
    end
end

-- Выводим результаты
print("")
print("📊 РЕЗУЛЬТАТЫ ПОИСКА:")
print("=" .. string.rep("=", 70))
print("Всего ClickDetector: " .. #allDetectors)
print("Связанных с мусоркой: " .. #trashDetectors)
print("Остальных: " .. #otherDetectors)
print("")

-- Сначала показываем trash-детекторы
if #trashDetectors > 0 then
    print("🗑️  CLICKDETECTOR СВЯЗАННЫЕ С МУСОРКОЙ:")
    print("-" .. string.rep("-", 60))
    
    for i, data in ipairs(trashDetectors) do
        print(string.format("%02d. 🗑️  %s [%s]", i, data.name, data.type))
        print("   📁 " .. data.path)
        
        -- Автоматически кликаем на первый trash
        if i == 1 then
            print("   🖱️ Автоматически кликаю...")
            data.detector:MouseClick()
            print("   ✅ Клик выполнен!")
        end
        
        print("")
    end
else
    print("❌ Не найдено ClickDetector связанных с мусоркой")
    print("")
end

-- Затем показываем остальные
if #otherDetectors > 0 then
    print("📦 ОСТАЛЬНЫЕ CLICKDETECTOR:")
    print("-" .. string.rep("-", 60))
    
    for i, data in ipairs(otherDetectors) do
        print(string.format("%02d. 📦 %s [%s]", i, data.name, data.type))
        print("   📁 " .. data.path)
        print("")
    end
end

-- Если ничего не найдено
if #allDetectors == 0 then
    print("😞 ClickDetector не найдены вообще!")
    print("")
    print("📁 Что есть в Workspace:")
    for i, obj in ipairs(workspace:GetChildren()) do
        print(string.format("   %02d. %s [%s]", i, obj.Name, obj.ClassName))
    end
end

-- Убираем тестовый trash через 10 секунд
delay(10, function()
    if workspace:FindFirstChild("TestTrashCan") then
        workspace.TestTrashCan:Destroy()
        print("🧹 Убрал тестовый TrashCan")
    end
end)
