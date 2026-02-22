-- 修复版本：添加等待和错误处理
local function loadUI()
    -- 添加重试机制
    local maxRetries = 3
    local WindUI = nil
    
    for i = 1, maxRetries do
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end)
        
        if success and result then
            WindUI = result
            break
        else
            warn("加载失败，尝试第 " .. i .. " 次重试...")
            task.wait(1)
        end
    end
    
    if not WindUI then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "错误",
            Text = "UI加载失败，请检查网络",
            Duration = 5
        })
        return
    end
    
    -- 等待UI初始化
    task.wait(1)
    
    -- 基本设置
    WindUI.TransparencyValue = 0.2
    WindUI:SetTheme("Dark")
    
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
    
    -- 弹窗
    pcall(function()
        WindUI:Popup({
            Title = "旧冬v6.0",
            Icon = "sparkles",
            Content = "SunkenBoat And TBW 联合出品",
            Buttons = {
                {
                    Title = "开始使用",
                    Icon = "arrow-right",
                    Variant = "Primary",
                    Callback = function() end
                }
            }
        })
    end)
    
    -- 创建主窗口
    local Window = pcall(function()
        return WindUI:CreateWindow({
            Title = "旧冬v6.0 [重做]",
            Icon = "crown",
            Author = "作者:小徐 | 维护:TBW.TEAM",
            Folder = "旧冬",
            Size = UDim2.fromOffset(580, 490),
            Theme = "Dark",
            Background = "https://raw.githubusercontent.com/XiaoXuCynic/UI-Picture/refs/heads/main/Screenshot_20260211_112829_com.ss.android.ugc.aweme.png",
            User = {
                Enabled = true,
                Anonymous = false,
                Callback = function()
                    WindUI:Notify({
                        Title = "用户资料",
                        Content = "您点击了用户资料",
                        Duration = 3
                    })
                end
            },
            Acrylic = true,
            HideSearchBar = false,
            SideBarWidth = 200
        })
    end)
    
    if type(Window) ~= "table" then
        warn("窗口创建失败")
        return
    end
    
    -- 标签
    pcall(function()
        Window:Tag({
            Title = "v6.0",
            Color = Color3.fromHex("#30ff6a")
        })
        Window:Tag({
            Title = "Sunken & TBW",
            Color = Color3.fromHex("#315dff")
        })
    end)
    
    local TimeTag = Window:Tag({
        Title = "--:--",
        Radius = 0,
        Color = WindUI:Gradient({
            ["0"]   = { Color = Color3.fromHex("#FF0F7B"), Transparency = 0 },
            ["100"] = { Color = Color3.fromHex("#F89B29"), Transparency = 0 },
        }, {
            Rotation = 45,
        }),
    })
    
    local hue = 0
    
    -- 彩虹效果和时间
    task.spawn(function()
        while task.wait(0.06) do
            local now = os.date("*t")
            local hours = string.format("%02d", now.hour)
            local minutes = string.format("%02d", now.min)
            
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            
            pcall(function()
                TimeTag:SetTitle(hours .. ":" .. minutes)
            end)
        end
    end)
    
    pcall(function()
        Window:CreateTopbarButton("theme-switcher", "moon", function()
            WindUI:SetTheme(WindUI:GetCurrentTheme() == "Dark" and "Light" or "Dark")
            WindUI:Notify({
                Title = "主题切换",
                Content = "已切换为："..WindUI:GetCurrentTheme(),
                Duration = 2
            })
        end, 990)
    end)
    
    -- 创建 Sections
    local Tabs = {
        Main = Window:Section({ Title = "通用", Opened = true }),
        Settings = Window:Section({ Title = "主题更改", Opened = false }),
        Utilities = Window:Section({ Title = "配置文件", Opened = false }),
        FE = Window:Section({ Title = "FE功能", Opened = false }),
        Sunken = Window:Section({ Title = "脚本工具", Opened = false }),
        ESP = Window:Section({ Title = "ESP功能", Opened = false }),
        Server = Window:Section({ Title = "服务器脚本", Opened = false }),
    }
    
    -- 创建 Tabs
    local TabHandles = {
        Elements = Tabs.Main:Tab({ Title = "通用", Icon = "layout-grid", Desc = "UI 元素" }),
        Appearance = Tabs.Settings:Tab({ Title = "外观", Icon = "brush" }),
        Config = Tabs.Utilities:Tab({ Title = "配置管理", Icon = "settings" }),
        Planet = Tabs.FE:Tab({ Title = "FE脚本", Icon = "moon" }),
        Tool = Tabs.Sunken:Tab({ Title = "脚本工具", Icon = "play" }),
        esp = Tabs.ESP:Tab({ Title = "ESP", Icon = "eye" }),
        Biphase = Tabs.Server:Tab({ Title = "服务器脚本", Icon = "play" }),
    }
    
    -- 通用功能
    local ElementsMainSection = TabHandles.Elements:Section({
        Title = "通用功能",
        Icon = "crown",
    })
    
    ElementsMainSection:Paragraph({
        Title = "旧冬脚本交流群",
        Desc = "群号:1081649265",
        Image = "component",
        ImageSize = 20,
        Color = Color3.fromHex("#30ff6a"),
    })
    
    local toggleState = false
    local featureToggle = ElementsMainSection:Toggle({
        Title = "杀戮光环",
        Value = false,
        Callback = function(state) 
            if state then
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local localPlayer = Players.LocalPlayer
                
                if not _G.killAuraConfig then
                    _G.killAuraConfig = {
                        isRunning = true,
                        connection = nil
                    }
                else
                    _G.killAuraConfig.isRunning = true
                end
                
                if _G.killAuraConfig.connection then
                    _G.killAuraConfig.connection:Disconnect()
                    _G.killAuraConfig.connection = nil
                end
                
                _G.killAuraConfig.connection = RunService.Heartbeat:Connect(function()
                    if not _G.killAuraConfig or not _G.killAuraConfig.isRunning then
                        return
                    end
                    
                    local localCharacter = localPlayer.Character
                    if not localCharacter then return end
                    
                    local humanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
                    local humanoid = localCharacter:FindFirstChildOfClass("Humanoid")
                    
                    if not humanoidRootPart or not humanoid or humanoid.Health <= 0 then return end
                    
                    local tool = localCharacter:FindFirstChildOfClass("Tool")
                    if not tool then return end
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= localPlayer then
                            local targetChar = player.Character
                            if targetChar then
                                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
                                
                                if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                                    local distance = (humanoidRootPart.Position - targetRoot.Position).Magnitude
                                    if distance < 20 then
                                        if tool:IsA("Tool") then
                                            tool:Activate()
                                            task.wait(0.1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            else
                if _G.killAuraConfig then
                    _G.killAuraConfig.isRunning = false
                    if _G.killAuraConfig.connection then
                        _G.killAuraConfig.connection:Disconnect()
                        _G.killAuraConfig.connection = nil
                    end
                end
            end
            
            WindUI:Notify({
                Title = "功能状态",
                Content = state and "杀戮光环已启用" or "杀戮光环已禁用",
                Icon = state and "check" or "x",
                Duration = 2
            })
        end
    })
    
    local SpeedSlider = ElementsMainSection:Slider({
        Title = "速度",
        Min = 16,
        Max = 400,
        Default = 16,
        Value = 16,
        Increment = 1,
        Callback = function(value)
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = value
                end
            end
        end
    })
    
    local JumpSlider = ElementsMainSection:Slider({
        Title = "跳跃高度",
        Min = 50,
        Max = 200,
        Default = 50,
        Value = 50,
        Increment = 1,
        Callback = function(value)
            local player = game.Players.LocalPlayer
            if player and player.Character then
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.JumpPower = value
                end
            end
        end
    })
    
    local AntiSwingToggle = ElementsMainSection:Toggle({
        Title = "防甩",
        Value = false,
        Callback = function(state)
            if state then
                local Services = setmetatable({}, {__index = function(Self, Index)
                    local NewService = game:GetService(Index)
                    if NewService then
                        Self[Index] = NewService
                    end
                    return NewService
                end})
    
                local LocalPlayer = Services.Players.LocalPlayer
                _G.flyOffEnabled = true
                _G.flyOffConnections = _G.flyOffConnections or {}
    
                local function PlayerAdded(Player)
                    if Player == LocalPlayer then return end
                    
                    local Detected = false
                    local Character
                    local PrimaryPart
    
                    local function CharacterAdded(NewCharacter)
                        Character = NewCharacter
                        repeat
                            task.wait()
                            PrimaryPart = NewCharacter:FindFirstChild("HumanoidRootPart")
                        until PrimaryPart
                        Detected = false
                    end
    
                    CharacterAdded(Player.Character or Player.CharacterAdded:Wait())
                    
                    local conn = Player.CharacterAdded:Connect(CharacterAdded)
                    table.insert(_G.flyOffConnections, conn)
                    
                    local heartbeatConn = Services.RunService.Heartbeat:Connect(function()
                        if not _G.flyOffEnabled then
                            heartbeatConn:Disconnect()
                            return
                        end
                        
                        if (Character and Character:IsDescendantOf(workspace)) and (PrimaryPart and PrimaryPart:IsDescendantOf(Character)) then
                            if PrimaryPart.AssemblyAngularVelocity.Magnitude > 50 or PrimaryPart.AssemblyLinearVelocity.Magnitude > 100 then
                                if Detected == false then
                                    game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
                                        Text = "Fling Exploit Detected Player : "..tostring(Player);
                                        Color = Color3.fromRGB(255, 200, 0);
                                    })
                                end
                                Detected = true
                                for i,v in ipairs(Character:GetDescendants()) do
                                    if v:IsA("BasePart") then
                                        v.CanCollide = false
                                        v.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                        v.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                        v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                                    end
                                end
                                PrimaryPart.CanCollide = false
                                PrimaryPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                                PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                PrimaryPart.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0)
                            end
                        end
                    end)
                    table.insert(_G.flyOffConnections, heartbeatConn)
                end
    
                for i,v in ipairs(Services.Players:GetPlayers()) do
                    if v ~= LocalPlayer then
                        PlayerAdded(v)
                    end
                end
                
                local playerAddedConn = Services.Players.PlayerAdded:Connect(PlayerAdded)
                table.insert(_G.flyOffConnections, playerAddedConn)
            else
                _G.flyOffEnabled = false
                if _G.flyOffConnections then
                    for _, conn in ipairs(_G.flyOffConnections) do
                        conn:Disconnect()
                    end
                    _G.flyOffConnections = {}
                end
            end
        end
    })
    
    local FlyButton = ElementsMainSection:Button({
        Title = "旧冬飞行V1",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/QiuShan-UX/UnicoX/main/%E9%A3%9E%E8%A1%8C%E7%A4%BA%E4%BE%8B.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "飞行脚本已加载",
                    Icon = "check",
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 2
                })
            end
        end
    })    
    
    local BREAKToggle = ElementsMainSection:Toggle({
        Title = "启用穿墙",
        Desc = "穿墙",
        Value = false,
        Callback = function(state)
            if state then
                _G.Noclip = true
                if _G.NoclipConnection then
                    _G.NoclipConnection:Disconnect()
                end
                _G.NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                    if _G.Noclip then
                        local character = game.Players.LocalPlayer.Character
                        if character then
                            for _, part in pairs(character:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                end
                            end
                        end
                    else
                        if _G.NoclipConnection then
                            _G.NoclipConnection:Disconnect()
                            _G.NoclipConnection = nil
                        end
                    end
                end)
            else
                _G.Noclip = false
                if _G.NoclipConnection then
                    _G.NoclipConnection:Disconnect()
                    _G.NoclipConnection = nil
                end
            end
        end
    })
    
    local NightViToggle = ElementsMainSection:Toggle({
        Title = "启用夜视",
        Desc = "夜视",
        Value = false,
        Callback = function(state)
            local Lighting = game:GetService("Lighting")
            if state then
                _G.originalAmbient = Lighting.Ambient
                _G.originalOutdoorAmbient = Lighting.OutdoorAmbient
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            else
                if _G.originalAmbient then
                    Lighting.Ambient = _G.originalAmbient
                else
                    Lighting.Ambient = Color3.new(0, 0, 0)
                end
                
                if _G.originalOutdoorAmbient then
                    Lighting.OutdoorAmbient = _G.originalOutdoorAmbient
                else
                    Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                end
            end
        end
    })
    
    local InfinjumpToggle = ElementsMainSection:Toggle({
        Title = "启用无限跳",
        Desc = "无限跳",
        Value = false,
        Callback = function(state)
            _G.InfiniteJumpEnabled = state
            
            if _G.InfiniteJumpConnection then
                _G.InfiniteJumpConnection:Disconnect()
                _G.InfiniteJumpConnection = nil
            end
            
            if state then
                _G.InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    if _G.InfiniteJumpEnabled then
                        local player = game.Players.LocalPlayer
                        local character = player.Character
                        if character then
                            local humanoid = character:FindFirstChildOfClass("Humanoid")
                            if humanoid then
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end
                        end
                    end
                end)
            end
        end
    })
    
    local displayToggle = ElementsMainSection:Toggle({
        Title = "启用人物显示",
        Desc = "人物显示",
        Value = false,
        Callback = function(state)
            if state then
                local Players = game:GetService("Players")
                local localPlayer = Players.LocalPlayer
                
                if not _G.espBoxes then
                    _G.espBoxes = {}
                    _G.espConnections = {}
                end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer then
                        local function createESP(char)
                            if char and char:FindFirstChild("HumanoidRootPart") then
                                if _G.espBoxes[player.Name] then
                                    pcall(function() _G.espBoxes[player.Name]:Destroy() end)
                                end
                                
                                local box = Instance.new("BoxHandleAdornment")
                                box.Adornee = char.HumanoidRootPart
                                box.AlwaysOnTop = true
                                box.ZIndex = 10
                                box.Size = Vector3.new(4, 6, 4)
                                box.Color3 = Color3.fromRGB(255, 0, 0)
                                box.Transparency = 0.5
                                box.Parent = char.HumanoidRootPart
                                
                                _G.espBoxes[player.Name] = box
                            end
                        end
                        
                        if player.Character then
                            createESP(player.Character)
                        end
                        
                        _G.espConnections[player.Name] = player.CharacterAdded:Connect(function(char)
                            task.wait(1)
                            createESP(char)
                        end)
                    end
                end
            else
                if _G.espBoxes then
                    for _, box in pairs(_G.espBoxes) do
                        pcall(function() box:Destroy() end)
                    end
                    _G.espBoxes = {}
                end
                if _G.espConnections then
                    for _, conn in pairs(_G.espConnections) do
                        conn:Disconnect()
                    end
                    _G.espConnections = {}
                end
            end
        end
    })
    
    local godModeToggle = ElementsMainSection:Toggle({
        Title = "启用无敌",
        Desc = "小概率bug",
        Value = false,
        Callback = function(state)
            if state then
                local character = game.Players.LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        _G.originalMaxHealth = humanoid.MaxHealth
                        _G.originalHealth = humanoid.Health
                        humanoid.MaxHealth = 9e9
                        humanoid.Health = 9e9
                    end
                end
            else
                if _G.originalMaxHealth then
                    local character = game.Players.LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.MaxHealth = _G.originalMaxHealth
                            humanoid.Health = math.min(_G.originalHealth or 100, _G.originalMaxHealth)
                        end
                    end
                    _G.originalMaxHealth = nil
                    _G.originalHealth = nil
                end
            end
        end
    })
    
    local KillToggle = ElementsMainSection:Button({
        Title = "自杀",
        Icon = "bell",
        Callback = function()
            local character = game.Players.LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        end
    })
    
    local fpsToggle = ElementsMainSection:Toggle({
        Title = "显示FPS",
        Desc = "显示FPS",
        Value = false,
        Callback = function(state)
            if state then
                local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
                
                local oldFpsGui = playerGui:FindFirstChild("FPSGui")
                if oldFpsGui then
                    oldFpsGui:Destroy()
                end
                
                local fpsGui = Instance.new("ScreenGui")
                fpsGui.Name = "FPSGui"
                fpsGui.ResetOnSpawn = false
                fpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                fpsGui.DisplayOrder = 999
                fpsGui.Parent = playerGui
                
                local fpsLabel = Instance.new("TextLabel")
                fpsLabel.Name = "FPSLabel"
                fpsLabel.Size = UDim2.new(0, 100, 0, 30)
                fpsLabel.Position = UDim2.new(0.85, 0, 0.02, 0)
                fpsLabel.BackgroundTransparency = 0.7
                fpsLabel.BackgroundColor3 = Color3.new(0, 0, 0)
                fpsLabel.Font = Enum.Font.SourceSansBold
                fpsLabel.Text = "FPS: 0"
                fpsLabel.TextSize = 18
                fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                fpsLabel.TextStrokeTransparency = 0.5
                fpsLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
                fpsLabel.Parent = fpsGui
                
                local lastTime = tick()
                local frameCount = 0
                
                _G.fpsConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    frameCount = frameCount + 1
                    local currentTime = tick()
                    if currentTime - lastTime >= 1 then
                        local fps = frameCount
                        fpsLabel.Text = "FPS: " .. fps
                        frameCount = 0
                        lastTime = currentTime
                    end
                end)
            else
                if _G.fpsConnection then
                    _G.fpsConnection:Disconnect()
                    _G.fpsConnection = nil
                end
                local playerGui = game.Players.LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    local fpsGui = playerGui:FindFirstChild("FPSGui")
                    if fpsGui then
                        fpsGui:Destroy()
                    end
                end
            end
        end
    })
    
    -- 外观设置
    local AppearanceSection = TabHandles.Appearance:Section({
        Title = "外观设置",
        Icon = "crown",
    })
    
    AppearanceSection:Paragraph({
        Title = "自定义界面",
        Desc = "个性化你的体验",
        Image = "palette",
        ImageSize = 20,
        Color = "White"
    })
    
    local themes = {}
    for themeName, _ in pairs(WindUI:GetThemes()) do
        table.insert(themes, themeName)
    end
    table.sort(themes)
    
    local canchangetheme = true
    local canchangedropdown = true
    
    local themeDropdown = AppearanceSection:Dropdown({
        Title = "选择主题",
        Values = themes,
        Value = "Dark",
        Callback = function(theme)
            canchangedropdown = false
            WindUI:SetTheme(theme)
            WindUI:Notify({
                Title = "主题已应用",
                Content = theme,
                Icon = "palette",
                Duration = 2
            })
            canchangedropdown = true
        end
    })
    
    local transparencySlider = AppearanceSection:Slider({
        Title = "窗口透明度",
        Min = 0,
        Max = 1,
        Default = 0.2,
        Value = 0.2,
        Increment = 0.1,
        Callback = function(value)
            WindUI.TransparencyValue = tonumber(value)
            Window:ToggleTransparency(tonumber(value) > 0)
        end
    })
    
    local ThemeToggle = AppearanceSection:Toggle({
        Title = "启用深色模式",
        Desc = "使用深色配色方案",
        Value = true,
        Callback = function(state)
            if canchangetheme then
                WindUI:SetTheme(state and "Dark" or "Light")
            end
            if canchangedropdown then
                themeDropdown:Select(state and "Dark" or "Light")
            end
        end
    })
    
    WindUI:OnThemeChange(function(theme)
        canchangetheme = false
        ThemeToggle:Set(theme == "Dark")
        canchangetheme = true
    end)
    
    AppearanceSection:Button({
        Title = "创建新主题",
        Icon = "plus",
        Callback = function()
            Window:Dialog({
                Title = "创建新主题",
                Content = "此功能即将推出！",
                Buttons = {
                    {
                        Title = "确定",
                        Variant = "Primary"
                    }
                }
            })
        end
    })
    
    -- 配置管理
    local ConfigSection = TabHandles.Config:Section({
        Title = "配置管理",
        Icon = "crown",
    })
    
    ConfigSection:Paragraph({
        Title = "配置管理器",
        Desc = "保存和加载你的设置",
        Image = "save",
        ImageSize = 20,
        Color = "White"
    })
    
    local configName = "默认配置"
    local configFile = nil
    local MyPlayerData = {
        name = "玩家1",
        level = 1,
        inventory = { "配置1", "配置2", "配置3" }
    }
    
    ConfigSection:Input({
        Title = "配置名称",
        Value = configName,
        Callback = function(value)
            configName = value or "默认配置"
        end
    })
    
    local ConfigManager = Window.ConfigManager
    if ConfigManager then
        ConfigManager:Init(Window)
        
        ConfigSection:Button({
            Title = "保存配置",
            Icon = "save",
            Variant = "Primary",
            Callback = function()
                configFile = ConfigManager:CreateConfig(configName)
                
                configFile:Register("featureToggle", featureToggle)
                configFile:Register("themeDropdown", themeDropdown)
                configFile:Register("transparencySlider", transparencySlider)
                
                configFile:Set("playerData", MyPlayerData)
                configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
                
                if configFile:Save() then
                    WindUI:Notify({ 
                        Title = "保存成功", 
                        Content = "已保存为："..configName,
                        Icon = "check",
                        Duration = 3
                    })
                else
                    WindUI:Notify({ 
                        Title = "错误", 
                        Content = "保存配置失败",
                        Icon = "x",
                        Duration = 3
                    })
                end
            end
        })
    
        ConfigSection:Button({
            Title = "加载配置",
            Icon = "folder",
            Callback = function()
                configFile = ConfigManager:CreateConfig(configName)
                local loadedData = configFile:Load()
                
                if loadedData then
                    if loadedData.playerData then
                        MyPlayerData = loadedData.playerData
                    end
                    
                    local lastSave = loadedData.lastSave or "未知"
                    WindUI:Notify({ 
                        Title = "加载成功", 
                        Content = "已加载："..configName.."\n上次保存："..lastSave,
                        Icon = "refresh-cw",
                        Duration = 5
                    })
                    
                    ConfigSection:Paragraph({
                        Title = "玩家数据",
                        Desc = string.format("名称：%s\n等级：%d\n物品栏：%s", 
                            MyPlayerData.name, 
                            MyPlayerData.level, 
                            table.concat(MyPlayerData.inventory, ", "))
                    })
                else
                    WindUI:Notify({ 
                        Title = "错误", 
                        Content = "加载配置失败",
                        Icon = "x",
                        Duration = 3
                    })
                end
            end
        })
    else
        ConfigSection:Paragraph({
            Title = "配置管理器不可用",
            Desc = "此功能需要 ConfigManager",
            Image = "alert-triangle",
            ImageSize = 20,
            Color = "White"
        })
    end
    
    local footerSection = Window:Section({ Title = "WindUI " .. WindUI.Version })
    ConfigSection:Paragraph({
        Title = "WindUi github库链接",
        Desc = "github.com/Footagesus/WindUI",
        Image = "github",
        ImageSize = 20,
        Color = "Grey",
        Buttons = {
            {
                Title = "复制链接",
                Icon = "copy",
                Variant = "Tertiary",
                Callback = function()
                    setclipboard("https://github.com/Footagesus/WindUI")
                    WindUI:Notify({
                        Title = "已复制！",
                        Content = "GitHub 链接已复制到剪贴板",
                        Duration = 2
                    })
                end
            }
        }
    })
    
    -- FE脚本
    local PlanetSection = TabHandles.Planet:Section({
        Title = "FE脚本",
        Icon = "crown",
    })
    
    local PButton = PlanetSection:Button({
        Title = "FE翻墙",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/ScpGuest666/Random-Roblox-script/refs/heads/main/Roblox%20WallHop%20V4%20script', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "FE翻墙脚本",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local LButton = PlanetSection:Button({
        Title = "FE爬行",
        Icon = "crown",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/0Ben1/fe/main/obf_vZDX8j5ggfAf58QhdJ59BVEmF6nmZgq4Mcjt2l8wn16CiStIW2P6EkNc605qv9K4.lua.txt', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "FE爬行脚本",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local AButton = PlanetSection:Button({
        Title = "FE杀手",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://pastefy.ga/d7sogwNS/raw', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "FE杀手脚本",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local NToggle = PlanetSection:Toggle({
        Title = "FE R15隐身",
        Desc = "R15隐身功能",
        Value = false,
        Callback = function(state)
            if state then
                local removeNametags = false
    
                local plr = game:GetService("Players").LocalPlayer
                local character = plr.Character
                if not character then return end
                
                local hrp = character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                local old = hrp.CFrame
    
                if not character:FindFirstChild("LowerTorso") or character.PrimaryPart ~= hrp then
                    WindUI:Notify({
                        Title = "FE隐身",
                        Content = "不支持非R15角色",
                        Duration = 3
                    })
                    return
                end
    
                if removeNametags then
                    local tag = hrp:FindFirstChildOfClass("BillboardGui")
                    if tag then tag:Destroy() end
    
                    hrp.ChildAdded:Connect(function(item)
                        if item:IsA("BillboardGui") then
                            task.wait()
                            item:Destroy()
                        end
                    end)
                end
    
                local newroot = character.LowerTorso.Root:Clone()
                hrp.Parent = workspace
                character.PrimaryPart = hrp
                character:MoveTo(Vector3.new(old.X, 9e9, old.Z))
                hrp.Parent = character
                task.wait(0.5)
                newroot.Parent = hrp
                hrp.CFrame = old
                
                WindUI:Notify({
                    Title = "FE隐身",
                    Content = "R15隐身已启用",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "FE隐身",
                    Content = "R15隐身已禁用",
                    Duration = 3
                })
            end
        end
    })
    
    local EButton = PlanetSection:Button({
        Title = "FE踢",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/ZhenX21/FE-Kick-Ban-Script/main/source', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "FE踢脚本",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local A2Button = PlanetSection:Button({
        Title = "FE闪回",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://mscripts.vercel.app/scfiles/reverse-script.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "FE闪回脚本",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local FORButton = PlanetSection:Button({
        Title = "FE被遗弃角色",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/CyberNinja103/brodwa/refs/heads/main/ForsakationHub', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "FE被遗弃角色脚本",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    -- 脚本工具
    local ToolSection = TabHandles.Tool:Section({
        Title = "脚本工具",
        Icon = "crown",
    })
    
    local dexv3Button = ToolSection:Button({
        Title = "DexV3 无汉化",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "Dex",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local DexCNButton = ToolSection:Button({
        Title = "汉化Dex",
        Icon = "play",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/Xingyan777/roblox/refs/heads/main/bex.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "汉化Dex",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local CNDEX = ToolSection:Button({
        Title = "汉化spy",
        Icon = "star",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/Finaloutcome/plz/refs/heads/main/sp3hu.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "汉化spy",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local httpsButton = ToolSection:Button({
        Title = "抓包https spy",
        Icon = "moon",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/BS58dL/BS/refs/heads/main/请多多支持BS脚本系列.Lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "抓包https spy",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local CNdExButton = ToolSection:Button({
        Title = "汉化spy2",
        Icon = "zap",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/spy%E6%B1%89%E5%8C%96%20(1).txt', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "汉化spy2",
                    Icon = "star",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    -- ESP功能
    local espSection = TabHandles.esp:Section({
        Title = "通用ESP",
        Icon = "eye",
    })
    
    local ESPMainToggle = espSection:Toggle({
        Title = "启用ESP",
        Value = false,
        Callback = function(state)
            _G.ESPEnabled = state
            
            if state then
                WindUI:Notify({
                    Title = "ESP状态",
                    Content = "ESP已启用",
                    Icon = "eye",
                    Duration = 2
                })
            else
                WindUI:Notify({
                    Title = "ESP状态",
                    Content = "ESP已禁用",
                    Icon = "eye-off",
                    Duration = 2
                })
            end
        end
    })
    
    local ESPBoxToggle = espSection:Toggle({
        Title = "方框ESP",
        Desc = "显示玩家方框",
        Value = false,
        Callback = function(state)
            _G.ESPBox = state
            WindUI:Notify({
                Title = "方框ESP",
                Content = state and "已开启" or "已关闭",
                Duration = 1.5
            })
        end
    })
    
    local ESPNameToggle = espSection:Toggle({
        Title = "显示名字",
        Desc = "显示玩家名字",
        Value = false,
        Callback = function(state)
            _G.ESPName = state
            WindUI:Notify({
                Title = "名字显示",
                Content = state and "已开启" or "已关闭",
                Duration = 1.5
            })
        end
    })
    
    local ESPHealthToggle = espSection:Toggle({
        Title = "显示血量",
        Desc = "显示玩家血量",
        Value = false,
        Callback = function(state)
            _G.ESPHealth = state
            WindUI:Notify({
                Title = "血量显示",
                Content = state and "已开启" or "已关闭",
                Duration = 1.5
            })
        end
    })
    
    local ESPDistanceToggle = espSection:Toggle({
        Title = "显示距离",
        Desc = "显示玩家距离",
        Value = false,
        Callback = function(state)
            _G.ESPDistance = state
            WindUI:Notify({
                Title = "距离显示",
                Content = state and "已开启" or "已关闭",
                Duration = 1.5
            })
        end
    })
    
    local ESPTeamCheckToggle = espSection:Toggle({
        Title = "队伍检测",
        Desc = "过滤队友",
        Value = false,
        Callback = function(state)
            _G.ESPTeamCheck = state
            WindUI:Notify({
                Title = "队伍检测",
                Content = state and "已开启" or "已关闭",
                Duration = 1.5
            })
        end
    })
    
    local ESPNameColorButton = espSection:Button({
        Title = "名字颜色",
        Icon = "palette",
        Callback = function()
            WindUI:Notify({
                Title = "颜色设置",
                Content = "当前颜色: 白色 (默认)",
                Duration = 2
            })
        end
    })
    
    local ESPMaxDistanceSlider = espSection:Slider({
        Title = "最大距离",
        Min = 50,
        Max = 1000,
        Default = 200,
        Value = 200,
        Increment = 10,
        Callback = function(value)
            _G.ESPMaxDistance = value
        end
    })
    
    local ESPRefreshButton = espSection:Button({
        Title = "刷新ESP",
        Icon = "refresh-cw",
        Callback = function()
            WindUI:Notify({
                Title = "ESP",
                Content = "ESP已刷新",
                Duration = 1.5
            })
        end
    })
    
    local ESPTestButton = espSection:Button({
        Title = "测试ESP",
        Icon = "test-pipe",
        Callback = function()
            local playerCount = #game.Players:GetPlayers()
            WindUI:Notify({
                Title = "ESP测试",
                Content = "当前在线玩家: " .. playerCount .. " 人",
                Duration = 2
            })
        end
    })
    
    -- 服务器脚本
    local BiphaseSection = TabHandles.Biphase:Section({
        Title = "服务器脚本",
        Icon = "crown",
    })
    
    local NiGHTButton = BiphaseSection:Button({
        Title = "森林中的99夜",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%2099Night99%E5%A4%9C.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "旧冬99夜",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local EndlessButton = BiphaseSection:Button({
        Title = "无尽现实",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Endless%20reality%E6%97%A0%E5%B0%BD%E7%8E%B0%E5%AE%9E.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "无尽现实脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local DoorsButton = BiphaseSection:Button({
        Title = "Doors",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBWDoors.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "Doors脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local EvadeButton = BiphaseSection:Button({
        Title = "躲避",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Evade%20%E8%BA%B2%E9%81%BF.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "躲避脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local hanbaoButton = BiphaseSection:Button({
        Title = "紧急汉堡",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Emergency%20Burger%E7%B4%A7%E6%80%A5%E6%B1%89%E5%A0%A1.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "紧急汉堡脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local sevenButton = BiphaseSection:Button({
        Title = "在超市生活7天",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Live%20for%20seven%20days%E5%9C%A8%E8%B6%85%E5%B8%82%E7%94%9F%E5%AD%98%E4%B8%83%E5%A4%A9.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "超市生活脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local PowerButton = BiphaseSection:Button({
        Title = "停电",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Power%20failure%E5%81%9C%E7%94%B5.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "停电脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local InkButton = BiphaseSection:Button({
        Title = "墨水游戏",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Ink%20Game%E5%A2%A8%E6%B0%B4%E6%B8%B8%E6%88%8F.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "墨水脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local sakenButton = BiphaseSection:Button({
        Title = "被遗弃",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBWForsaken.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "被遗弃脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local tsbButton = BiphaseSection:Button({
        Title = "最强战场(tsb)",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20The%20strongest%20battlefield%20%E6%9C%80%E5%BC%BA%E6%88%98%E5%9C%BA.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "最强战场脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local ViolentButton = BiphaseSection:Button({
        Title = "暴力区",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Violent%20Zone%E6%9A%B4%E5%8A%9B%E5%8C%BA.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "暴力区脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local DemonologyButton = BiphaseSection:Button({
        Title = "恶魔学",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/%E6%81%B6%E9%AD%94%E5%AD%A6.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "恶魔学脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local WarTycoonButton = BiphaseSection:Button({
        Title = "战争大亨",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/%E6%88%98%E4%BA%89%E5%A4%A7%E4%BA%A8.lua", true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "战争大亨脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local growButton = BiphaseSection:Button({
        Title = "点击加载种植花园",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/%E7%A7%8D%E6%A4%8D.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "种植花园脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local WantedButton = BiphaseSection:Button({
        Title = "通缉",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/Old-Winter-Script/refs/heads/main/TBW%20Wanted%E9%80%9A%E7%BC%89.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "通缉脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local LegendButton = BiphaseSection:Button({
        Title = "力量传奇",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Legend%20of%20Power%E5%8A%9B%E9%87%8F%E4%BC%A0%E5%A5%87.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "力量传奇脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local CopycatButton = BiphaseSection:Button({
        Title = "模仿者",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Copycat%E6%A8%A1%E4%BB%BF%E8%80%85.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "模仿者脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local KurButton = BiphaseSection:Button({
        Title = "死铁轨",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Dead%20Rail%20%E6%AD%BB%E9%93%81%E8%BD%A8.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "死铁轨脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local CrButton = BiphaseSection:Button({
        Title = "犯罪",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20commit%20%E7%8A%AF%E7%BD%AA.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "犯罪脚本",
                    Icon = "sword",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local LiJianButton = BiphaseSection:Button({
        Title = "凹凸世界",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Concave-convex%20world%E5%87%B9%E5%87%B8%E4%B8%96%E7%95%8C.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "凹凸世界脚本",
                    Icon = "crown",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    local XingXingButton = BiphaseSection:Button({
        Title = "感染微笑",
        Icon = "bell",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/XiaoXuCynic/OldWinter-XiaoXu-TheBigWave-Guild/refs/heads/main/TBW%20Infected%20smile%E6%84%9F%E6%9F%93%E5%BE%AE%E7%AC%91.lua', true))()
            end)
            
            if success then
                WindUI:Notify({
                    Title = "已启用",
                    Content = "感染微笑脚本",
                    Icon = "bell",
                    Duration = 3
                })
            else
                WindUI:Notify({
                    Title = "加载失败",
                    Content = "请检查网络连接",
                    Icon = "x",
                    Duration = 3
                })
            end
        end
    })
    
    Window:OnClose(function()
        print("窗口已关闭")
        
        if ConfigManager and configFile then
            configFile:Set("playerData", MyPlayerData)
            configFile:Set("lastSave", os.date("%Y-%m-%d %H:%M:%S"))
            configFile:Save()
            print("配置在关闭时自动保存")
        end
    end)
    
    Window:OnDestroy(function()
        print("窗口已销毁")
    end)
    
    return true
end

-- 执行加载
local success = pcall(loadUI)
if not success then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "错误",
        Text = "UI加载失败，请重试",
        Duration = 5
    })
end