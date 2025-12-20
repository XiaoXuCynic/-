local HttpService = cloneref(game:GetService("HttpService"))

local isfunctionhooked = clonefunction(isfunctionhooked)

if isfunctionhooked(game.HttpGet) or isfunctionhooked(getnamecallmethod) or isfunctionhooked(request) then
    return
end

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/windui(2).lua"))()

WindUI.TransparencyValue = 0.3
WindUI:SetTheme("Light")

local function gradient(text, startColor, endColor)
    local result = ""
    for i = 1, #text do
        local t = (i - 1) / (#text - 1)  
        
        local r = math.floor((startColor.R + (endColor.R - startColor.R) * t) * 255)
        local g = math.floor((startColor.G + (endColor.G - startColor.G) * t) * 255)
        local b = math.floor((startColor.B + (endColor.B - startColor.B) * t) * 255)
        
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>', r, g, b, text:sub(i, i))
    end
    return result
end

local Window = WindUI:CreateWindow({
    Title = "ReapX 被遗弃", 
    Icon = "star", 
    Author = "By 秋山", 
    Folder = "WindUI_ReapX", 
    Size = UDim2.fromOffset(400, 250), 
    Background = "rbxassetid://92357198122176",
    Theme = "Light", 
    
    User = {
        Enabled = true, 
        Anonymous = false, 
        Callback = function() 
            WindUI:Notify({
                Title = "信息",
                Content = "你的信息",
                Duration = 3
            })
        end
    },
    SideBarWidth = 170, 
    ScrollBarEnabled = false 
})

local Tabs = {
    Game = Window:Section({ Title = "面板", Icon = "crown" ,Opened = true })
}

local TabHandles = {
    FWQ1Settings = Tabs.Game:Tab({ Title = "体力功能", Icon = "crown" }),
    ESPFeatures = Tabs.Game:Tab({ Title = "ESP功能", Icon = "eye" }),
    CombatFeatures = Tabs.Game:Tab({ Title = "主要功能", Icon = "swords" })
}

WindUI:Notify({Title = "ReapX", Content = "已打开", Duration = 3}) task.wait(0.1)
WindUI:Notify({Title = "作者秋山", Content = "请勿倒卖脚本", Duration = 3})

local sprintModule = nil
local infinityStaminaActive = false
local defaultMaxStamina = 100
local defaultSprintSpeed = 20
local defaultStaminaGain = 10
local defaultStaminaDrain = 5
local maxStaminaValue = defaultMaxStamina
local sprintSpeedValue = defaultSprintSpeed
local staminaGainValue = defaultStaminaGain
local staminaDrainValue = defaultStaminaDrain

local function findSprintModule()
    if not game:GetService("Players").LocalPlayer then return end
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then return end
    
    for _, child in ipairs(character:GetDescendants()) do
        if child:IsA("ModuleScript") and child.Name == "SprintModule" then
            local success, module = pcall(function()
                return require(child)
            end)
            if success and module then
                return module
            end
        end
    end
    return nil
end

task.spawn(function()
    repeat
        sprintModule = findSprintModule()
        task.wait(1)
    until sprintModule or not wait(10)
end)

local function EnableInfinityStamina()
    if sprintModule then
        pcall(function()
            local originalStamina = sprintModule.Stamina
            infinityStaminaActive = true
            while infinityStaminaActive and sprintModule do
                sprintModule.Stamina = maxStaminaValue
                task.wait(0.1)
            end
        end)
    end
end

local function DisableInfinityStamina()
    infinityStaminaActive = false
end

local GeneralSection = TabHandles.FWQ1Settings:Section({Title = "体力功能", Opened = true})

GeneralSection:Toggle({
    Title = "无限体力",
    Default = false,
    Callback = function(state)
        if state then
            EnableInfinityStamina()
        else
            DisableInfinityStamina()
        end
    end
})

GeneralSection:Slider({
    Title = "最大体力",
    Step = 1,
    Value = {Min = 1, Max = 500, Default = maxStaminaValue},
    Suffix = " 点",
    Callback = function(val)
        maxStaminaValue = tonumber(val) or defaultMaxStamina
        if sprintModule then
            pcall(function()
                sprintModule.MaxStamina = maxStaminaValue
                if not infinityStaminaActive and sprintModule.Stamina > maxStaminaValue then
                    sprintModule.Stamina = maxStaminaValue
                end
            end)
        end
    end
})

GeneralSection:Slider({
    Title = "冲刺速度",
    Step = 1,
    Value = {Min = 1, Max = 40, Default = sprintSpeedValue},
    Suffix = " 速",
    Callback = function(val)
        sprintSpeedValue = tonumber(val) or defaultSprintSpeed
        if sprintModule then
            pcall(function()
                sprintModule.SprintSpeed = sprintSpeedValue
            end)
        end
    end
})

GeneralSection:Slider({
    Title = "体力恢复",
    Step = 1,
    Value = {Min = 1, Max = 500, Default = staminaGainValue},
    Suffix = " /秒",
    Callback = function(val)
        staminaGainValue = tonumber(val) or defaultStaminaGain
        if sprintModule then
            pcall(function()
                sprintModule.StaminaGain = staminaGainValue
            end)
        end
    end
})

GeneralSection:Slider({
    Title = "体力消耗",
    Step = 1,
    Value = {Min = 0, Max = 100, Default = staminaDrainValue},
    Suffix = " /秒",
    Callback = function(val)
        staminaDrainValue = tonumber(val) or defaultStaminaDrain
        if sprintModule then
            pcall(function()
                sprintModule.StaminaDrain = staminaDrainValue
            end)
        end
    end
})

local ESPGeneralSection = TabHandles.ESPFeatures:Section({Title = "ESP功能", Opened = true})

local espKillerActive = false
local killerHighlights = {}
local killerEspThread

local function clearKillerHighlights()
    for _, h in ipairs(killerHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    killerHighlights = {}
end

local function createKillerHighlight(model)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    table.insert(killerHighlights, highlight)
end

local function updateKillerESP()
    clearKillerHighlights()
    local killersFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers")
    if not killersFolder then return end
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:IsA("Model") and killer:FindFirstChild("HumanoidRootPart") then
            createKillerHighlight(killer)
        end
    end
end

ESPGeneralSection:Toggle({
    Title = "透视杀手",
    Default = false,
    Callback = function(state)
        espKillerActive = state
        if espKillerActive then
            killerEspThread = task.spawn(function()
                while espKillerActive do
                    updateKillerESP()
                    task.wait(5)
                end
            end)
        else
            if killerEspThread then
                task.cancel(killerEspThread)
                killerEspThread = nil
            end
            clearKillerHighlights()
        end
    end
})

local espSurvivorActive = false
local survivorHighlights = {}
local survivorEspThread

local function clearSurvivorHighlights()
    for _, h in ipairs(survivorHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    survivorHighlights = {}
end

local function createSurvivorHighlight(model)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(0, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model
    table.insert(survivorHighlights, highlight)
end

local function updateSurvivorESP()
    clearSurvivorHighlights()
    local survivorsFolder = workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Survivors")
    if not survivorsFolder then return end
    for _, survivor in ipairs(survivorsFolder:GetChildren()) do
        if survivor:IsA("Model") and survivor:FindFirstChild("HumanoidRootPart") then
            createSurvivorHighlight(survivor)
        end
    end
end

ESPGeneralSection:Toggle({
    Title = "透视幸存者",
    Default = false,
    Callback = function(state)
        espSurvivorActive = state
        if espSurvivorActive then
            survivorEspThread = task.spawn(function()
                while espSurvivorActive do
                    updateSurvivorESP()
                    task.wait(5)
                end
            end)
        else
            if survivorEspThread then
                task.cancel(survivorEspThread)
                survivorEspThread = nil
            end
            clearSurvivorHighlights()
        end
    end
})

local espEnabledMedkit = false
local espEnabledBloxy = false

local function clearESP(name)
    for _, item in ipairs(workspace:GetDescendants()) do
        if item.Name == name and (item:IsA("BasePart") or item:IsA("Model")) then
            local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart")
            if part and part:FindFirstChild("ItemHighlight") then
                part.ItemHighlight:Destroy()
            end
        end
    end
end

local function updateESP()
    for _, item in ipairs(workspace:GetDescendants()) do
        local part = nil
        if item:IsA("BasePart") then
            part = item
        elseif item:IsA("Model") then
            part = item:FindFirstChildWhichIsA("BasePart")
        end

        if part then
            if item.Name == "Medkit" and espEnabledMedkit and not part:FindFirstChild("ItemHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ItemHighlight"
                highlight.FillColor = Color3.fromRGB(255, 105, 180)
                highlight.OutlineColor = Color3.fromRGB(255, 105, 180)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = part:IsA("Model") and item or part
                highlight.Parent = part
            elseif item.Name == "BloxyCola" and espEnabledBloxy and not part:FindFirstChild("ItemHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ItemHighlight"
                highlight.FillColor = Color3.fromRGB(0, 150, 255)
                highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Adornee = part:IsA("Model") and item or part
                highlight.Parent = part
            end
        end
    end
end

local medkitEspThread = nil
local bloxyEspThread = nil

ESPGeneralSection:Toggle({
    Title = "透视医疗包",
    Default = false,
    Callback = function(state)
        espEnabledMedkit = state
        if espEnabledMedkit then
            medkitEspThread = task.spawn(function()
                while espEnabledMedkit do
                    updateESP()
                    task.wait(2)
                end
            end)
        else
            if medkitEspThread then
                task.cancel(medkitEspThread)
                medkitEspThread = nil
            end
            clearESP("Medkit")
        end
    end
})

ESPGeneralSection:Toggle({
    Title = "透视饮料",
    Default = false,
    Callback = function(state)
        espEnabledBloxy = state
        if espEnabledBloxy then
            bloxyEspThread = task.spawn(function()
                while espEnabledBloxy do
                    updateESP()
                    task.wait(2)
                end
            end)
        else
            if bloxyEspThread then
                task.cancel(bloxyEspThread)
                bloxyEspThread = nil
            end
            clearESP("BloxyCola")
        end
    end
})

local espGeneratorsActive = false
local generatorHighlights = {}
local generatorEspThread

local function clearGeneratorHighlights()
    for _, h in ipairs(generatorHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    generatorHighlights = {}
end

local function createGeneratorHighlight(target)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = target
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.6
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target
    table.insert(generatorHighlights, highlight)
end

local function updateGeneratorESP()
    clearGeneratorHighlights()
    for _, item in ipairs(workspace:GetDescendants()) do
        if item.Name:find("Generator") then
            if (item:IsA("Model") and item.PrimaryPart) or item:IsA("BasePart") then
                createGeneratorHighlight(item)
            end
        end
    end
end

ESPGeneralSection:Toggle({
    Title = "透视发电机",
    Default = false,
    Callback = function(state)
        espGeneratorsActive = state
        if espGeneratorsActive then
            generatorEspThread = task.spawn(function()
                while espGeneratorsActive do
                    updateGeneratorESP()
                    task.wait(20)
                end
            end)
        else
            if generatorEspThread then
                task.cancel(generatorEspThread)
                generatorEspThread = nil
            end
            clearGeneratorHighlights()
        end
    end
})

local CombatSection = TabHandles.CombatFeatures:Section({Title = "自动格挡", Opened = true})

local currentMode = "Normal"
local monitorDuration = 0.6
local zoneVisibility = 0.4
local zoneLength = 12
local zoneWidth = 6
local runZoneBoost = 4
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function updateZonesVisibility()
end

CombatSection:Dropdown({
    Title = "自动格挡1",
    Values = {"Normal", "Normal+Anti Bait"},
    Value = "Normal",
    Multi = false,
    AllowNone = false,
    Callback = function(choice)
        currentMode = choice
        updateZonesVisibility()
    end
})

CombatSection:Slider({
    Title = "攻击验证时长",
    Step = 0.1,
    Value = {Min = 0.1, Max = 2.0, Default = 0.6},
    Suffix = " 秒",
    Callback = function(val)
        monitorDuration = val
    end
})

CombatSection:Slider({
    Title = "区域可见度",
    Step = 1,
    Value = {Min = 0, Max = 10, Default = 6},
    Suffix = "/10",
    Callback = function(val)
        zoneVisibility = 1 - (val / 10)
        updateZonesVisibility()
    end
})

CombatSection:Slider({
    Title = "区域长度",
    Step = 0.1,
    Value = {Min = 1, Max = 30, Default = 12},
    Suffix = " 米",
    Callback = function(val)
        zoneLength = val
    end
})

CombatSection:Slider({
    Title = "区域宽度",
    Step = 0.1,
    Value = {Min = 1, Max = 15, Default = 6},
    Suffix = " 米",
    Callback = function(val)
        zoneWidth = val
    end
})

CombatSection:Slider({
    Title = "区域推进 (延迟补偿)",
    Step = 1,
    Value = {Min = 0, Max = 10, Default = 4},
    Suffix = " 米",
    Callback = function(val)
        runZoneBoost = val
    end
})

local AutoPunchSection = TabHandles.CombatFeatures:Section({Title = "自动拳击", Opened = true})

local autoPunchOn = false
local flingPunchOn = false
local flingPower = 5000000
local aimPunch = true
local hiddenfling = false

local punchConnection = nil
local flingConnection = nil

local function startFlingLoop()
    if flingConnection then return end
    flingConnection = RunService.Heartbeat:Connect(function()
        if hiddenfling then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity
                hrp.Velocity = vel * flingPower + Vector3.new(0, flingPower, 0)
                task.wait()
                hrp.Velocity = vel
                task.wait()
                hrp.Velocity = vel + Vector3.new(0, 0.1, 0)
            end
        end
    end)
end

local function stopFlingLoop()
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
end

local function punchFlingCycle()
    task.spawn(function()
        while flingPunchOn do
            hiddenfling = true
            task.wait(3)
            hiddenfling = false
            task.wait(1)
        end
    end)
end

local function predictPosition(targetRoot, myPing)
    local velocity = targetRoot.Velocity
    local latency = myPing / 1000
    local lookVec = targetRoot.CFrame.LookVector * 5
    local predicted = targetRoot.Position + (velocity * latency) + lookVec
    return predicted
end

local function startAutoPunch()
    startFlingLoop()
    if flingPunchOn then
        punchFlingCycle()
    end

    punchConnection = RunService.Heartbeat:Connect(function()
        local myChar = LocalPlayer.Character
        if not myChar then return end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainUI")
        local punchBtn = gui and gui.AbilityContainer and gui.AbilityContainer:FindFirstChild("Punch")
        local charges = punchBtn and punchBtn:FindFirstChild("Charges")

        if not (punchBtn and charges and charges.Text == "1") then return end

        local killersFolder = workspace.Players and workspace.Players.Killers
        if killersFolder then
            for _, killer in ipairs(killersFolder:GetChildren()) do
                local root = killer:FindFirstChild("HumanoidRootPart")
                if root and (root.Position - myRoot.Position).Magnitude <= 12 then
                    if aimPunch then
                        local ping = math.max(LocalPlayer:GetNetworkPing() * 1000, 50)
                        local predictedPos = predictPosition(root, ping)

                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, predictedPos)
                        task.delay(1, function()
                            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                local forward = myRoot.CFrame.LookVector
                                myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + forward)
                            end
                        end)
                    end

                    for _, conn in ipairs(getconnections(punchBtn.MouseButton1Click)) do
                        pcall(function() conn:Fire() end)
                    end
                    return
                end
            end
        end

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root and (root.Position - myRoot.Position).Magnitude <= 10 then
                    if aimPunch then
                        local ping = math.max(LocalPlayer:GetNetworkPing() * 1000, 50)
                        local predictedPos = predictPosition(root, ping)

                        myRoot.CFrame = CFrame.lookAt(myRoot.Position, predictedPos)
                        task.delay(1, function()
                            if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                                local forward = myRoot.CFrame.LookVector
                                myRoot.CFrame = CFrame.lookAt(myRoot.Position, myRoot.Position + forward)
                            end
                        end)
                    end

                    for _, conn in ipairs(getconnections(punchBtn.MouseButton1Click)) do
                        pcall(function() conn:Fire() end)
                    end
                    break
                end
            end
        end
    end)
end

local function stopAutoPunch()
    if punchConnection then
        punchConnection:Disconnect()
        punchConnection = nil
    end
    stopFlingLoop()
    hiddenfling = false
end

AutoPunchSection:Toggle({
    Title = "自动拳击+投掷 (Shiftlock下无效)",
    Default = false,
    Callback = function(state)
        autoPunchOn = state
        if state then
            startAutoPunch()
        else
            stopAutoPunch()
        end
    end
})

AutoPunchSection:Toggle({
    Title = "显示聊天窗",
    Default = false,
    Callback = function(state)
        if state then
            game.TextChatService.ChatWindowConfiguration.Enabled = true
        else
            game.TextChatService.ChatWindowConfiguration.Enabled = false    
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local config = {
    BlockDistance = 15,
    ScanInterval = 0.05,
    BlockCooldown = 0.5,
    DebugMode = true,
    TargetSoundIds = {
        "rbxassetid://102228729296384",
        "rbxassetid://140242176732868",
        "rbxassetid://12222216",
        "rbxassetid://86174610237192",
        "rbxassetid://101199185291628",
        "rbxassetid://95079963655241",
        "rbxassetid://112809109188560"
    }
}

local RemoteEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Network"):WaitForChild("RemoteEvent")
local lastBlockTime = 0
local combatConnection = nil

local function HasTargetSound(character)
    if not character then return false end

    local function checkSoundFolder(folder)
        for _, sound in ipairs(folder:GetDescendants()) do
            if sound:IsA("Sound") then
                for _, targetId in ipairs(config.TargetSoundIds) do
                    if sound.SoundId == targetId then
                        if config.DebugMode then
                            print("Audio detected:", sound:GetFullName(), "ID:", sound.SoundId)
                        end
                        return true
                    end
                end
            end
        end
        return false
    end

    return checkSoundFolder(character:FindFirstChild("HumanoidRootPart") or character) or checkSoundFolder(character)
end

local function GetKillersInRange()
    local killers = {}
    local killersFolder = workspace:FindFirstChild("Killers") or (workspace:FindFirstChild("Players") and workspace.Players:FindFirstChild("Killers"))
    if not killersFolder then return killers end

    local myCharacter = LocalPlayer.Character
    if not myCharacter or not myCharacter:FindFirstChild("HumanoidRootPart") then return killers end

    local myPos = myCharacter.HumanoidRootPart.Position

    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer:FindFirstChild("HumanoidRootPart") then
            local distance = (killer.HumanoidRootPart.Position - myPos).Magnitude
            if distance <= config.BlockDistance then
                table.insert(killers, killer)
            end
        end
    end

    return killers
end

local function PerformBlock()
    if os.clock() - lastBlockTime >= config.BlockCooldown then
        RemoteEvent:FireServer("UseActorAbility", "Block")
        lastBlockTime = os.clock()
        if config.DebugMode then
            print("Block performed at:", os.clock())
        end
    end
end

local function CheckConditions()
    local killers = GetKillersInRange()
    for _, killer in ipairs(killers) do
        if HasTargetSound(killer) then
            PerformBlock()
            break
        end
    end
end

local function Initialize()
end

local function CombatLoop()
    pcall(CheckConditions)
end

AutoPunchSection:Toggle({
    Title = "自动格挡2",
    Default = false,
    Callback = function(state)
        if state then
            Initialize()
            combatConnection = RunService.Stepped:Connect(CombatLoop)
        else
            if combatConnection then
                combatConnection:Disconnect()
                combatConnection = nil
            end
        end
    end
})

_G.AutoGeneratorDelay = 1.5

AutoPunchSection:Slider({
    Title = "修机间隔",
    Step = 0.5,
    Value = {Min = 1.5, Max = 12, Default = 1.5},
    Suffix = " 秒",
    Callback = function(v)
        _G.AutoGeneratorDelay = v
    end
})

local autoRepairConnection = nil
local autoRepairToggle = false
local teleportInterval = 15

local function getValidGenerators()
    local validGenerators = {}
    local mapParent = workspace:FindFirstChild("Map")
    if mapParent then
        local ingame = mapParent:FindFirstChild("Ingame")
        if ingame then
            local generatorFolder = ingame:FindFirstChild("Map")
            if generatorFolder then
                for _, g in ipairs(generatorFolder:GetChildren()) do
                    if g.Name == "Generator" and g:FindFirstChild("Progress") and g.Progress.Value < 100 then
                        table.insert(validGenerators, g)
                    end
                end
            end
        end
    end
    return validGenerators
end

local function getNearestGenerator()
    local validGenerators = getValidGenerators()
    local closest, shortest = nil, math.huge
    local player = game.Players.LocalPlayer
    if player and player.Character and player.Character.PrimaryPart then
        local pos = player.Character.PrimaryPart.Position
        for _, g in ipairs(validGenerators) do
            local part = g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
            if part then
                local dist = (part.Position - pos).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = g
                end
            end
        end
    end
    return closest
end

local function getGeneratorCFrame(generator)
    local TC = nil
    if generator:IsA("Model") then
        if generator.PrimaryPart then
            TC = generator.PrimaryPart.CFrame
        else
            for _, part in ipairs(generator:GetDescendants()) do
                if part:IsA("BasePart") then
                    TC = part.CFrame
                    break
                end
            end
        end
    elseif generator:IsA("BasePart") then
        TC = generator.CFrame
    end
    return TC and (TC * CFrame.new(0, 3, 0)) or nil
end

local function teleportToOne()
    local player = game.Players.LocalPlayer
    local target = getNearestGenerator()
    if not target then
        WindUI:Notify({Title = "信息", Content = "没有可用的发电机", Duration = 3})
        return
    end
    local cf = getGeneratorCFrame(target)
    if cf and player.Character and player.Character.PrimaryPart then
        player.Character:SetPrimaryPartCFrame(cf)
    end
end

local autoRepairNoClip = nil
local autoRepairActive = false
_G.REP = 2

local RepairSection = TabHandles.CombatFeatures:Section({Title = "修理功能", Opened = true})

RepairSection:Toggle({
    Title = "单次传送修机",
    Default = false,
    Callback = function(state)
        if state then
            teleportToOne()
            task.wait(0.1)
            WindUI:Notify({Title = "信息", Content = "已传送至最近发电机", Duration = 3})
        end
    end
})

RepairSection:Toggle({
    Title = "传送修机（每15秒传送一次）",
    Default = false,
    Callback = function(state)
        local player = game.Players.LocalPlayer
        local char = player.Character
        local runService = game:GetService("RunService")

        if state then
            autoRepairActive = true
            autoRepairNoClip = runService.Stepped:Connect(function()
                if char then
                    for _, v in pairs(char:GetDescendants()) do
                        if v:IsA("BasePart") then
                            v.CanCollide = false
                        end
                    end
                end
            end)

            autoRepairConnection = task.spawn(function()
                while autoRepairActive do
                    teleportToOne()
                    task.wait(teleportInterval)
                end
            end)
        else
            autoRepairActive = false
            if autoRepairNoClip then
                autoRepairNoClip:Disconnect()
                autoRepairNoClip = nil
            end
            if autoRepairConnection then
                task.cancel(autoRepairConnection)
                autoRepairConnection = nil
            end
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = true
                    end
                end
            end
        end
    end
})

RepairSection:Slider({
    Title = "传送间隔(秒)",
    Step = 1,
    Value = {Min = 1, Max = 30, Default = 15},
    Suffix = " 秒",
    Callback = function(value)
        teleportInterval = value
        WindUI:Notify({Title = "信息", Content = "传送间隔已设置为 " .. value .. " 秒", Duration = 3})
    end
})

RepairSection:Slider({
    Title = "修理发电机时间(秒）",
    Step = 1,
    Value = {Min = 2, Max = 30, Default = 2},
    Suffix = " 秒",
    Callback = function(value)
        _G.REP = value
    end
})

RepairSection:Toggle({
    Title = "修理暴力发电机",
    Default = false,
    Callback = function(state)
        local BTE = state

        local function RepairGenerators()
            local map = workspace:FindFirstChild("Map")
            local ingame = map and map:FindFirstChild("Ingame")
            local currentMap = ingame and ingame:FindFirstChild("Map")

            if currentMap then
                for _, obj in ipairs(currentMap:GetChildren()) do
                    if obj.Name == "Generator" and obj:FindFirstChild("Progress") and obj.Progress.Value < 100 then
                        local remote = obj:FindFirstChild("Remotes") and obj.Remotes:FindFirstChild("RE")
                        if remote then
                            remote:FireServer()
                        end
                    end
                end
            end
        end

        if state then
            task.spawn(function()
                while BTE do
                    RepairGenerators()
                    task.wait(_G.REP or 2)
                end
            end)
        else
            WindUI:Notify({Title = "信息", Content = "已关闭暴力修理发电机", Duration = 3})
        end
    end
})

local autoGR = false
RepairSection:Toggle({
    Title = "自动修理发电机",
    Default = false,
    Callback = function(state)
        autoGR = state

        if state then
            WindUI:Notify({Title = "信息", Content = "自动修理发电机已开启", Duration = 3})
            task.spawn(function()
                local player = Players.LocalPlayer
                
                while autoGR do
                    task.wait(_G.REP)
                    if not autoGR then break end
                    
                    if not player.Character then break end
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp then break end
                    
                    local map = workspace:FindFirstChild("Map")
                    local mapRoot = map and map:FindFirstChild("Ingame") and map.Ingame:FindFirstChild("Map")
                    if not mapRoot then break end
                    
                    local playerPos = hrp.Position
                    local closest, minDist = nil, math.huge
                    
                    for _, g in ipairs(mapRoot:GetChildren()) do
                        if g.Name == "Generator" 
                        and g:FindFirstChild("Progress") 
                        and g.Progress.Value < 100
                        and g:FindFirstChild("Main")
                        then
                            local distance = (g.Main.Position - playerPos).Magnitude
                            if distance < minDist then
                                minDist, closest = distance, g
                            end
                        end
                    end
                    
                    if closest then
                        local remotes = closest:FindFirstChild("Remotes")
                        local re = remotes and remotes:FindFirstChild("RE")
                        if re then
                            re:FireServer()
                        end
                    end
                end
            end)
        else
            WindUI:Notify({Title = "信息", Content = "自动修理已关闭", Duration = 3})
        end
    end
})

local mxj = false
RepairSection:Toggle({
    Title = "一键修理",
    Default = false,
    Callback = function(state)
        mxj = state

        if state then
            task.spawn(function()
                while mxj do
                    task.wait(6.5)

                    local map = workspace:FindFirstChild("Map")
                    local ingame = map and map:FindFirstChild("Ingame")
                    local currentMap = ingame and ingame:FindFirstChild("Map")

                    if currentMap then
                        local closestGenerator, closestDistance = nil, math.huge
                        local player = game:GetService("Players").LocalPlayer
                        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

                        if root then
                            local playerPos = root.Position
                            for _, g in ipairs(currentMap:GetChildren()) do
                                if g.Name == "Generator" and g:FindFirstChild("Progress") and g.Progress.Value < 100 then
                                    local mainPart = g:FindFirstChild("Main")
                                    if mainPart then
                                        local distance = (mainPart.Position - playerPos).Magnitude
                                        if distance < closestDistance then
                                            closestDistance = distance
                                            closestGenerator = g
                                        end
                                    end
                                end
                            end

                            if closestGenerator and closestGenerator:FindFirstChild("Remotes") and closestGenerator.Remotes:FindFirstChild("RE") then
                                closestGenerator.Remotes.RE:FireServer()
                            end
                        end
                    end
                end
            end)
        else
            WindUI:Notify({Title = "信息", Content = "已关闭一键修理功能", Duration = 3})
        end
    end
})