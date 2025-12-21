local Client = game.Players.LocalPlayer
local Replicated = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local UIS = game:GetService("UserInputService")
local Rod = ""
local TeleportSport = workspace:FindFirstChild("world"):WaitForChild("spawns"):WaitForChild("TpSpots")

local FlyConnection = nil
local InputBeganConn = nil
local InputEndedConn = nil
local bv, bg

local function Equip(path)
    if Client.Backpack:FindFirstChild(tostring(path)) then
        local found = Client.Backpack:FindFirstChild(tostring(path))
        if found then
            Client.Character.Humanoid:EquipTool(found)
        end
    end
end

local function Unequip()
    if Client.Character and Client.Character.Humanoid then
        Client.Character.Humanoid:UnequipTools()
    end
end

local function walkTo(destination, value)
    local character = Client.Character or Client.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    local path = PathfindingService:CreatePath({
        AgentCanJump = true,
        AgentJumpHeight = 2,
        AgentHeight = 6,
    })

    local success = pcall(function()
        path:ComputeAsync(rootPart.Position, destination)
    end)

    if success and path.Status == Enum.PathStatus.Success then
        if value then
            for _, wp in ipairs(path:GetWaypoints()) do
                if _G["StopWalking"] then return end
                if humanoid.Health <= 0 then break end

                local finished = false
                local conn
                conn = humanoid.MoveToFinished:Connect(function()
                    finished = true
                    if conn then conn:Disconnect() end
                end)

                humanoid:MoveTo(wp.Position)

                if wp.Action == Enum.PathWaypointAction.Jump then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end

                repeat task.wait() until finished or _G["StopWalking"]
                if _G["StopWalking"] then return end
            end
        end
    else
        warn("路径查找失败:", path.Status)
    end
end

if workspace.PlayerStats[Client.Name] and workspace.PlayerStats[Client.Name].T[Client.Name] then
    local rodStat = workspace.PlayerStats[Client.Name].T[Client.Name].Stats:FindFirstChild("rod")
    if rodStat then
        Rod = rodStat.Value
        rodStat.Changed:Connect(function(newValue)
            Rod = newValue 
        end)
    end
end

local d = {}
local st = {}
for i,v in pairs(require(game:GetService("ReplicatedStorage").shared.modules.library.fish).Rarities) do 
    table.insert(d,v)
end
for i,v in pairs(require(game:GetService("ReplicatedStorage").shared.modules.library.fish)) do 
    st[i] = v
end

do 
    if Client.PlayerGui:FindFirstChild("Roblox/Fluent") then  Client.PlayerGui:FindFirstChild("Roblox/Fluent"):Destroy() end 
    if Client.PlayerGui:FindFirstChild("ScreenGuis") then  Client.PlayerGui.ScreenGuis:Destroy() end
end

do
    local GC = getconnections or get_signal_cons
    if GC then
        for i,v in ipairs(GC(Client.Idled)) do 
            if v["Disable"] then 
                v["Disable"](v) 
            elseif v["Disconnect"] then 
                v["Disconnect"](v) 
            end 
        end
    else
        Client.Idled:Connect(function() 
            VirtualUser:CaptureController() 
            VirtualUser:ClickButton2(Vector2.new()) 
        end)
    end
end

local mainFolder = "旧冬"
local path = mainFolder.."/Fisch"
local ConfigName = path.."/"..Client.Name.."-config.json"

local DefaultSettings = {
    ATF = false,
    EFW = false,
    TSP = false,
    ENF = false,
    ZoneFarming = "Mosslurker",
    FarmingMode = "Normal",
    DisableNotify = false,
    Rarities = d[1] or "Common",
    SellMethod = "Sell with Rarity",
    delayfishsell = 1,
    EnabledSelling = false,
    TreasureMap = false,
    ATR = false,
    ADR = false,
    AAR = false,
    AKR = false,
    APR = false,
    AutoCompleteSecondSea = false,
    WhiteScreen = false,
    INFOXY = false,
    Fly = false
}

local Settings = {}

do 
    if not isfolder(mainFolder) then
        makefolder(mainFolder)
    end

    if not isfolder(path) then
        makefolder(path)
    end

    if isfile(ConfigName) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(ConfigName))
        end)

        if success and type(result) == "table" then
            Settings = result
        else
            Settings = DefaultSettings
        end
    else
        Settings = DefaultSettings
        writefile(ConfigName, HttpService:JSONEncode(Settings))
    end

    for key, value in pairs(DefaultSettings) do
        if Settings[key] == nil then
            Settings[key] = value
        end
    end
end

function saveConfig()
    if not isfolder(path) then
        makefolder(path)
    end
    writefile(ConfigName, HttpService:JSONEncode(Settings))
end

local Threads = {}
local func = {}

function Threads.FastForEach(array, callback, yieldEvery)
    yieldEvery = yieldEvery or 10
    for i = 1, #array do
        callback(array[i], i)
        if i % yieldEvery == 0 then
            RunService.Heartbeat:Wait()
        end 
    end
end

func['ATF'] = function()
    while _G.ATF do task.wait()
        pcall(function() 
            local character = Client.Character
            if not character then return end
            
            local rodTool = character:FindFirstChild(Rod)
            if not rodTool and Client.Backpack:FindFirstChild(Rod) then 
                Equip(Rod)
                task.wait(0.1)
                rodTool = character:FindFirstChild(Rod)
            end
            
            if rodTool then
                local shakeUI = Client.PlayerGui:FindFirstChild("shakeui")
                local casted = rodTool.values.casted.Value
                
                if not shakeUI and not casted then
                    rodTool.events.cast:FireServer(100,1)
                    task.wait(0.2)
                    
                    if rodTool:FindFirstChild("bobber") then 
                        rodTool.bobber.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0,-18,-3)
                    end
                elseif shakeUI and casted then
                    local button = shakeUI.safezone:FindFirstChild("button")
                    if button and button:IsA("ImageButton") and button.Visible then 
                        button.Size = UDim2.new(1001, 0, 1001, 0)
                        VirtualUser:Button1Down(Vector2.new(1, 1))
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(1, 1))
                    end
                end
            end
        end)
    end
end

task.spawn(function()
    while task.wait() do 
        pcall(function()
            if _G.ATF then
                local character = Client.Character
                if not character then return end
                
                local rodTool = character:FindFirstChild(Rod)
                if rodTool and rodTool:FindFirstChild("values") then
                    local biteValue = rodTool.values.bite.Value
                    
                    if _G.FarmingMode == "Normal" or _G.FarmingMode == nil then
                        if biteValue then
                            Replicated.events["reelfinished "]:FireServer(100, true)
                        end
                    elseif _G.FarmingMode == "Safe Mode" then
                        if Client.PlayerGui:FindFirstChild("reel") then
                            Client.PlayerGui.reel.bar.playerbar.Size = UDim2.new(1, 0, 1, 0)
                        end
                    elseif _G.FarmingMode == "Fast" then
                        if biteValue then
                            local humanoid = character:WaitForChild("Humanoid")
                            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                                if track.Animation.AnimationId == "rbxassetid://134146970600575" then 
                                    task.wait(0.4)
                                    Replicated.events["reelfinished "]:FireServer(100,true)
                                    if Client.PlayerGui:FindFirstChild("reel") then
                                        Client.PlayerGui.reel:Destroy()
                                    end
                                    task.wait(0.45)
                                    rodTool.events.reset:FireServer()
                                    Unequip()
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

func['EFW'] = function()
    local character = Client.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, not _G.EFW)
    end
end

func['TSP'] = function()
    while _G.TSP do task.wait()
        pcall(function()
            local character = Client.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then return end
            
            if _G.ATF and _G.PositionFarm then
                if not _G.ENF then 
                    character.HumanoidRootPart.CFrame = _G.PositionFarm
                elseif _G.ENF then 
                    local foundZone = false
                    local fishingZones = workspace:FindFirstChild("zones")
                    if fishingZones and fishingZones:FindFirstChild("fishing") then
                        for i,v in ipairs(workspace.zones.fishing:GetChildren()) do 
                            if v.Name == _G.ZoneFarming then 
                                character.HumanoidRootPart.CFrame = v.CFrame
                                foundZone = true
                                break
                            end
                        end
                    end
                    if not foundZone and _G.PositionFarm then
                        character.HumanoidRootPart.CFrame = _G.PositionFarm
                    end
                end
            end
        end)
    end
end

func['DisableNotify'] = function()
    local hud = Client.PlayerGui:FindFirstChild("hud")
    if hud and hud:FindFirstChild("safezone") and hud.safezone:FindFirstChild("announcements") then
        hud.safezone.announcements.Visible = not _G.DisableNotify
    end
end

func['EnabledSelling'] = function()
    while _G.EnabledSelling do task.wait()
        pcall(function()
            if _G.SellMethod == "Sell with Rarity" then
                for i,v in pairs(Client.Backpack:GetDescendants()) do 
                    if st[v.Name] and st[v.Name].Rarity == _G.Rarities and v:IsA("Tool") then
                        repeat task.wait()
                            Equip(v.Name)
                            Replicated:WaitForChild("events"):WaitForChild("Sell"):InvokeServer()
                            task.wait(_G.delayfishsell)
                        until not _G.EnabledSelling or not v.Parent
                    end
                end
            elseif _G.SellMethod == "Sell All" then
                Replicated:WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
                task.wait(_G.delayfishsell)
            end
        end)
    end
end

func['TreasureMap'] = function()
    while _G.TreasureMap do task.wait()
        pcall(function()
            if not Client.Character:FindFirstChild("Treasure Map") and Client.Backpack:FindFirstChild("Treasure Map") then
                repeat task.wait()
                    Equip("Treasure Map")
                until Client.Character:FindFirstChild("Treasure Map") or not _G.TreasureMap
            end
            
            if Client.Character:FindFirstChild("Treasure Map") then
                Client.Character.HumanoidRootPart.CFrame = CFrame.new(-2828.74292, 214.929657, 1520.1853,0.803240716, -2.94143767e-08, 0.595654547,2.3992726e-08, 1, 1.70273911e-08,-0.595654547, 6.14282569e-10, 0.803240716)
                
                local jackMarrow = workspace:WaitForChild("world"):WaitForChild("npcs"):WaitForChild("Jack Marrow")
                if jackMarrow then
                    local args = {
                        {
                            voice = 4,
                            idle = jackMarrow:WaitForChild("description"):WaitForChild("idle"),
                            npc = jackMarrow
                        }
                    }
                    
                    if jackMarrow:FindFirstChild("treasure") and jackMarrow.treasure:FindFirstChild("repairmap") then
                        jackMarrow.treasure.repairmap:InvokeServer(unpack(args))
                    end
                end

                if workspace.world and workspace.world:FindFirstChild("chests") then
                    for _, chest in pairs(workspace.world.chests:GetChildren()) do
                        if chest:IsA("Part") then
                            local x, y, z
                            local attributes = chest:GetAttributes()
                            
                            for attributeName, attributeValue in pairs(attributes) do
                                if attributeName == "x" then
                                    x = attributeValue
                                elseif attributeName == "y" then
                                    y = attributeValue
                                elseif attributeName == "z" then
                                    z = attributeValue
                                end
                            end

                            if x and y and z then
                                local args = {
                                    [1] = {
                                        ["y"] = y,
                                        ["x"] = x,
                                        ["z"] = z
                                    }
                                }
                                
                                Replicated:WaitForChild("events"):WaitForChild("open_treasure"):FireServer(unpack(args))
                            end
                        end
                    end
                end
            end
        end)
    end
end

func['ATR'] = function()
    while _G.ATR do task.wait()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("purchase"):FireServer("Trident Rod","Rod",1)
        end)
    end
end

func['ADR'] = function()
    while _G.ADR do task.wait()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("purchase"):FireServer("Destiny Rod","Rod",1)
        end)
    end
end

func['AAR'] = function()
    while _G.AAR do task.wait()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("purchase"):FireServer("Aurora Rod","Rod",1)
        end)
    end
end

func['AKR'] = function()  
    while _G.AKR do task.wait()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("purchase"):FireServer("Kraken Rod","Rod",1)
        end)
    end
end

func['APR'] = function()
    while _G.APR do task.wait()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("purchase"):FireServer("Poseidon Rod","Rod",1)
        end)
    end
end

func['AutoCompleteSecondSea'] = function()
    while _G.AutoCompleteSecondSea do task.wait()
        pcall(function()
            local playerStats = workspace.PlayerStats[Client.Name]
            if playerStats and playerStats.T[Client.Name] then
                local stats = playerStats.T[Client.Name].Stats
                if stats.level.Value >= 251 and not stats:FindFirstChild("access_second_sea") then 
                    local targetCFrame = CFrame.new(1536.48218, -1692.60022, 6309.69141, 0.998875737, 8.67497789e-08, 0.0474047363, -8.52820321e-08, 1, -3.29845555e-08, -0.0474047363, 2.89047009e-08, 0.998875737)
                    
                    if (targetCFrame.Position - Client.Character.HumanoidRootPart.Position).Magnitude > 1000 then
                        Client.Character.HumanoidRootPart.CFrame = targetCFrame
                        task.wait(1)
                    end
                    
                    if workspace:FindFirstChild("CryptOfTheGreenOne") then
                        local crypt = workspace.CryptOfTheGreenOne
                        if crypt:FindFirstChild("IntroGate") and crypt.IntroGate:FindFirstChild("1") then
                            local gateCFrame = CFrame.new(1518.30371, -1670.94446, 6054.79883, 0, 0, 1, 0, 1, 0, -1, 0, 0)
                            
                            if crypt.IntroGate["1"].Door.CFrame ~= gateCFrame then
                                local brotherSilas = crypt:FindFirstChild("CthuluNPCs"):FindFirstChild("Brother Silas")
                                if brotherSilas then
                                    local success = brotherSilas:FindFirstChild("SilasesWarningDialog"):FindFirstChild("opengate"):InvokeServer({voice = 2, idle = brotherSilas.description.idle, npc = brotherSilas})
                                    if not success then 
                                        game:GetService("ReplicatedStorage"):WaitForChild("packages"):WaitForChild("Net"):WaitForChild("RF/AppraiseAnywhere/HaveValidFish"):InvokeServer()
                                        brotherSilas.SilasesWarningDialog.opengate:InvokeServer()
                                    end
                                end
                            end
                        end
                    end
                    
                    local endCFrame = CFrame.new(1536.69995, -1695.37805, 5896.61523, 1, 0, 0, 0, -1, 0, 0, 0, -1)
                    if (endCFrame.Position - Client.Character.HumanoidRootPart.Position).Magnitude > 5 then
                        walkTo(endCFrame.Position, _G.AutoCompleteSecondSea)
                    end
                end
            end
        end)
    end
end

func['WhiteScreen'] = function()
    RunService:Set3dRenderingEnabled(not _G.WhiteScreen)
end

func['INFOXY'] = function()
    if Client.Character and Client.Character:FindFirstChild("Resources") then
        local resources = Client.Character.Resources
        if resources:FindFirstChild("oxygen") then
            resources.oxygen.Enabled = not _G.INFOXY
        end
    end
end

func['Fly'] = function()
    if _G.Fly then
        local character = Client.Character or Client.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        if not hrp:FindFirstChild("Velocity") then
            bv = Instance.new("BodyVelocity")
            bv.Name = "Velocity"
            bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
            bv.Velocity = Vector3.zero
            bv.P = 1250
            bv.Parent = hrp
        else
            bv = hrp:FindFirstChild("Velocity")
        end

        if not hrp:FindFirstChild("Gyro") then
            bg = Instance.new("BodyGyro")
            bg.Name = "Gyro"
            bg.MaxTorque = Vector3.new(1, 1, 1) * math.huge
            bg.P = 3000
            bg.CFrame = hrp.CFrame
            bg.Parent = hrp
        else
            bg = hrp:FindFirstChild("Gyro")
        end

        local control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
        local speed = 100

        if InputBeganConn then InputBeganConn:Disconnect() end
        if InputEndedConn then InputEndedConn:Disconnect() end
        if FlyConnection then FlyConnection:Disconnect() end

        InputBeganConn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            local key = input.KeyCode
            if key == Enum.KeyCode.W then control.F = 1 end
            if key == Enum.KeyCode.S then control.B = 1 end
            if key == Enum.KeyCode.A then control.L = 1 end
            if key == Enum.KeyCode.D then control.R = 1 end
            if key == Enum.KeyCode.Space then control.U = 1 end
            if key == Enum.KeyCode.LeftControl then control.D = 1 end
        end)

        InputEndedConn = UIS.InputEnded:Connect(function(input)
            local key = input.KeyCode
            if key == Enum.KeyCode.W then control.F = 0 end
            if key == Enum.KeyCode.S then control.B = 0 end
            if key == Enum.KeyCode.A then control.L = 0 end
            if key == Enum.KeyCode.D then control.R = 0 end
            if key == Enum.KeyCode.Space then control.U = 0 end
            if key == Enum.KeyCode.LeftControl then control.D = 0 end
        end)

        FlyConnection = RunService.RenderStepped:Connect(function()
            if not _G.Fly or not hrp or not hrp.Parent then return end

            local cam = workspace.CurrentCamera
            local moveVec = cam.CFrame.LookVector * (control.F - control.B)
                        + cam.CFrame.RightVector * (control.R - control.L)
                        + Vector3.new(0, 0.1, 0) * (control.U - control.D)

            bv.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * speed or Vector3.zero
            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
        end)

    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if InputBeganConn then InputBeganConn:Disconnect() InputBeganConn = nil end
        if InputEndedConn then InputEndedConn:Disconnect() InputEndedConn = nil end
        if FlyConnection then FlyConnection:Disconnect() FlyConnection = nil end
    end
end

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Yenixs/GUI/refs/heads/main/FLUENT"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

do 
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local UICorner = Instance.new("UICorner")
    local ImageButton = Instance.new("ImageButton")

    ScreenGui.Name = "ScreenGuis"
    ScreenGui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
    ScreenGui.ResetOnSpawn = false

    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.700
    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.474052399, 0, 0.046491228, 0)
    Frame.Size = UDim2.new(0.0340000018, 0, 0.0700000003, 0)

    UICorner.Parent = Frame

    ImageButton.Parent = Frame
    ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ImageButton.BackgroundTransparency = 1.000
    ImageButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ImageButton.BorderSizePixel = 0
    ImageButton.Position = UDim2.new(-0.0250000004, 0, -0.027777778, 0)
    ImageButton.Size = UDim2.new(1.1, 0, 1.1, 0)
    ImageButton.Image = "rbxassetid://103816145608946"

    ImageButton.MouseButton1Click:Connect(function()
        local fluentGui = game:GetService("Players").LocalPlayer.PlayerGui["Roblox/Fluent"]
        if fluentGui and fluentGui:FindFirstChild("Main") then
            fluentGui.Main.Visible = not fluentGui.Main.Visible
        end
    end)
end 

local Window = Fluent:CreateWindow({
    Title = "旧冬 - 钓鱼脚本",
    SubTitle = "深海钓鱼模拟器",
    TabWidth = 160,
    Size = UDim2.fromOffset(490, 360),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl 
})

local Tabs = {
    Lobby = Window:AddTab({ Title = "通用设置", Icon = "globe" }),
    ItemAndQuest = Window:AddTab({ Title = "物品 & 任务", Icon = "hammer" }),
    Miscellaneous = Window:AddTab({ Title = "其他功能", Icon = "box" }),
    Settings = Window:AddTab({ Title = "设置", Icon = "settings" })
}

local Options = Fluent.Options

local function Dropdown(tab, title, values, default, callback)
    local dropdown = tab:AddDropdown(title, {
        Title = title,
        Values = values,
        Multi = false,
        Default = default
    })
    dropdown:OnChanged(callback)
    return dropdown
end

local function Toggle(tab, title, settings)
    local toggle = tab:AddToggle(title, { 
        Title = title, 
        Default = Settings[settings] 
    })
    toggle:OnChanged(function(value)
        Settings[settings] = value
        _G[settings] = value
        saveConfig()
        if func[settings] then
            task.spawn(func[settings])
        end
    end)	
    return toggle
end

do 
    Fluent:Notify({
        Title = "旧冬 正在加载",
        Content = "请稍候...",
        Duration = 3
    })
    
    Tabs.Lobby:AddSection('🎣 钓鱼功能')
    Toggle(Tabs.Lobby, "自动钓鱼", "ATF")
    Toggle(Tabs.Lobby, "允许在水中钓鱼", "EFW")
    Toggle(Tabs.Lobby, "传送到保存位置", "TSP")
    Toggle(Tabs.Lobby, "启用钓鱼区域", "ENF")
    
    Dropdown(Tabs.Lobby, "钓鱼区域", {
        "Mosslurker","Whales Pool","Mushgrove Algae Pool","Golden Tide",
        "Isonade","Whale Shark","Great Hammerhead Shark","Great White Shark",
        "The Depths - Serpent","Megalodon Default","The Kraken Pool",
        "Orcas Pool","Lovestorm Eel","Forsaken Veil - Scylla"
    }, Settings.ZoneFarming, function(value)
        Settings.ZoneFarming = value
        _G.ZoneFarming = value
        saveConfig()
    end)
    
    Tabs.Lobby:AddButton({
        Title = "保存当前位置",
        Description = "将当前位置设置为钓鱼点",
        Callback = function()
            if Client.Character and Client.Character.HumanoidRootPart then
                local cf = Client.Character.HumanoidRootPart.CFrame
                Settings.PositionFarm = cf
                _G.PositionFarm = cf
                saveConfig()
                Fluent:Notify({
                    Title = "位置已保存",
                    Content = "当前位置已设置为钓鱼点",
                    Duration = 3
                })
            end
        end
    })
    
    Tabs.Lobby:AddSection('⚙️ 钓鱼设置')
    Dropdown(Tabs.Lobby, "收线模式", {
        "Normal", "Fast", "Safe Mode"
    }, Settings.FarmingMode, function(value)
        Settings.FarmingMode = value
        _G.FarmingMode = value
        saveConfig()
    end)
    
    Toggle(Tabs.Lobby, "禁用通知界面", "DisableNotify")
    
    Tabs.Lobby:AddSection('💸 出售功能')
    Dropdown(Tabs.Lobby, "选择稀有度", d, Settings.Rarities, function(value)
        Settings.Rarities = value
        _G.Rarities = value
        saveConfig()
    end)
    
    Dropdown(Tabs.Lobby, "出售方式", {
        "Sell with Rarity", "Sell All"
    }, Settings.SellMethod, function(value)
        Settings.SellMethod = value
        _G.SellMethod = value
        saveConfig()
    end)
    
    local WaitTime = Tabs.Lobby:AddSlider("出售延迟", {
        Title = "出售延迟时间",
        Description = "出售鱼的间隔时间(秒)",
        Default = Settings.delayfishsell or 1,
        Min = 0.1,
        Max = 10,
        Rounding = 1,
        Callback = function(Value)
            Settings.delayfishsell = Value
            _G.delayfishsell = Value
            saveConfig()
        end
    })
    
    Toggle(Tabs.Lobby, "启用自动出售", "EnabledSelling")
    
    Tabs.ItemAndQuest:AddSection('🗺️ 藏宝图功能')
    Toggle(Tabs.ItemAndQuest, "自动藏宝图", "TreasureMap")
    
    Tabs.ItemAndQuest:AddSection('🐟 鱼竿购买')
    Toggle(Tabs.ItemAndQuest, "自动购买三叉戟鱼竿", "ATR")
    Toggle(Tabs.ItemAndQuest, "自动购买命运鱼竿", "ADR")
    Toggle(Tabs.ItemAndQuest, "自动购买极光鱼竿", "AAR")
    Toggle(Tabs.ItemAndQuest, "自动购买海怪鱼竿", "AKR")
    Toggle(Tabs.ItemAndQuest, "自动购买波塞冬鱼竿", "APR")
    
    Tabs.ItemAndQuest:AddSection('🌏 第二海域')
    Toggle(Tabs.ItemAndQuest, "自动完成第二海域","AutoCompleteSecondSea")
    
    Tabs.Miscellaneous:AddSection('🎮 游戏功能')
    Toggle(Tabs.Miscellaneous, "启用白屏模式","WhiteScreen")
    Toggle(Tabs.Miscellaneous, "无限氧气","INFOXY")
    Toggle(Tabs.Miscellaneous, "飞行模式","Fly")
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:Load()

Window:SelectTab(1)

Fluent:Notify({
    Title = "旧冬 加载完成",
    Content = "钓鱼脚本已准备就绪",
    Duration = 3
})

for key, value in pairs(Settings) do
    _G[key] = value
    if func[key] and value then
        task.spawn(func[key])
    end
end