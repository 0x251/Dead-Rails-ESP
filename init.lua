local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local PlaceName = game:GetService("AssetService"):GetGamePlacesAsync(game.GameId):GetCurrentPage()[1].Name
local LocalPlayer = Players.LocalPlayer

getfenv().getgenv().PlaceName = PlaceName

local Window
local Esp
local ESPCache = {}
local ItemCache = {}

local PlayerESP = {
    Enabled = false,
    Color = Color3.new(1, 1, 1),
    Font = Enum.Font.SourceSansBold,
    TextSize = 18,
    ShowDistance = true,
    ShowHealth = true
}

local CharmsESP = {
    Enabled = false,
    Color = Color3.new(1, 0, 0),
    FillTransparency = 0.5,
    OutlineTransparency = 0,
    DepthMode = "AlwaysOnTop"
}

local ItemESP = {
    Enabled = false,
    Color = Color3.new(0, 1, 0),
    FillTransparency = 0.3,
    OutlineTransparency = 0
}

local SpeedSpoof = {
    Enabled = false,
    Value = 16,
    MoveConnection = nil
}

local function CreateMainWindow()
    Rayfield:Notify({
        Title = "UNIX Loaded",
        Content = "ESP features activated for "..PlaceName,
        Duration = 6.5,
        Image = "eye"
    })

    Window = Rayfield:CreateWindow({
        Name = "U N I X - " .. PlaceName,
        LoadingTitle = "U N I X - " .. PlaceName,
        LoadingSubtitle = "by 0x251",
        Theme = "Default",
        DisableRayfieldPrompts = true,
        DisableBuildWarnings = true,
        ConfigurationSaving = {
            Enabled = true,
            FileName = "UNIX-" .. PlaceName
        },
    })

    Esp = Window:CreateTab("ESP", "eye")
end

local function SetupESPTab()
    
    local function CreatePlayerESPControls()
        Esp:CreateSection("Player ESP Settings")
        Esp:CreateToggle({
            Name = "Enable Player ESP",
            CurrentValue = false,
            Flag = "PlayerESPEnabled",
            Callback = function(Value)
                PlayerESP.Enabled = Value
                for _, espData in pairs(ESPCache) do
                    if espData.billboard then
                        espData.billboard.Enabled = Value
                    end
                end
            end
        })

        Esp:CreateColorPicker({
            Name = "Text Color",
            Color = PlayerESP.Color,
            Flag = "PlayerESPColor",
            Callback = function(Value)
                PlayerESP.Color = Value
            end
        })

        Esp:CreateSlider({
            Name = "Text Size",
            Range = {10, 24},
            Increment = 1,
            Suffix = "px",
            CurrentValue = 18,
            Flag = "PlayerESPSize",
            Callback = function(Value)
                PlayerESP.TextSize = Value
            end
        })
    end

    local function CreateDisplayOptions()
        Esp:CreateSection("Display Options")
        Esp:CreateToggle({
            Name = "Show Distance",
            CurrentValue = true,
            Flag = "PlayerESPDistance",
            Callback = function(Value)
                PlayerESP.ShowDistance = Value
            end
        })

        Esp:CreateToggle({
            Name = "Show Health",
            CurrentValue = true,
            Flag = "PlayerESPHealth",
            Callback = function(Value)
                PlayerESP.ShowHealth = Value
            end
        })
    end

    local function CreateCharmsControls()
        Esp:CreateSection("Visual Settings")
        Esp:CreateToggle({
            Name = "Charms ESP",
            CurrentValue = false,
            Flag = "CharmsESPEnabled",
            Callback = function(Value)
                CharmsESP.Enabled = Value
                for _, espData in pairs(ESPCache) do
                    if espData.highlight then
                        espData.highlight.Enabled = Value
                        espData.highlight.DepthMode = CharmsESP.DepthMode
                    end
                end
            end
        })

        Esp:CreateColorPicker({
            Name = "Charms Color",
            Color = CharmsESP.Color,
            Flag = "CharmsESPColor",
            Callback = function(Value)
                CharmsESP.Color = Value
                for _, espData in pairs(ESPCache) do
                    if espData.highlight then
                        espData.highlight.FillColor = Value
                        espData.highlight.OutlineColor = Value
                    end
                end
            end
        })

        Esp:CreateDropdown({
            Name = "Outline Mode",
            Options = {"Solid", "Neon", "Classic"},
            CurrentValue = "Solid",
            Flag = "CharmsOutlineMode",
            Callback = function(Value)
                for _, espData in pairs(ESPCache) do
                    if espData.highlight then
                        if Value == "Neon" then
                            espData.highlight.OutlineTransparency = 0
                            espData.highlight.FillTransparency = 0.2
                        elseif Value == "Classic" then
                            espData.highlight.OutlineTransparency = 0.5
                        end
                    end
                end
            end
        })

        Esp:CreateSlider({
            Name = "Fill Transparency",
            Range = {0, 1},
            Increment = 0.1,
            CurrentValue = 0.5,
            Flag = "CharmsFill",
            Callback = function(Value)
                CharmsESP.FillTransparency = Value
                for _, espData in pairs(ESPCache) do
                    if espData.highlight then
                        espData.highlight.FillTransparency = Value
                    end
                end
            end
        })

        Esp:CreateSlider({
            Name = "Outline Transparency",
            Range = {0, 1},
            Increment = 0.1,
            CurrentValue = 0,
            Flag = "CharmsOutline",
            Callback = function(Value)
                CharmsESP.OutlineTransparency = Value
                for _, espData in pairs(ESPCache) do
                    if espData.highlight then
                        espData.highlight.OutlineTransparency = Value
                    end
                end
            end
        })

        Esp:CreateSection("Advanced Charms")

        Esp:CreateToggle({
            Name = "Pulse Effect",
            CurrentValue = false,
            Flag = "CharmsPulse",
            Callback = function(Value)
                CharmsESP.PulseEnabled = Value
            end
        })

        Esp:CreateSlider({
            Name = "Pulse Speed",
            Range = {1, 10},
            Increment = 1,
            CurrentValue = 5,
            Flag = "CharmsPulseSpeed",
            Callback = function(Value)
                CharmsESP.PulseSpeed = Value
            end
        })

        Esp:CreateToggle({
            Name = "Dynamic Glow",
            CurrentValue = false,
            Flag = "CharmsGlow",
            Callback = function(Value)
                CharmsESP.GlowEnabled = Value
                for _, espData in pairs(ESPCache) do
                    if espData.highlight then
                        espData.highlight.FillTransparency = Value and 0.8 or CharmsESP.FillTransparency
                    end
                end
            end
        })
    end

    local function CreateItemESPControls()
        Esp:CreateSection("Item ESP Settings")
        
        Esp:CreateToggle({
            Name = "Enable Item ESP",
            CurrentValue = false,
            Flag = "ItemESPEnabled",
            Callback = function(Value)
                ItemESP.Enabled = Value
                for _, item in pairs(ItemCache) do
                    if item.highlight then
                        item.highlight.Enabled = Value
                    end
                end
            end
        })

        Esp:CreateColorPicker({
            Name = "Item Color",
            Color = ItemESP.Color,
            Flag = "ItemESPColor",
            Callback = function(Value)
                ItemESP.Color = Value
                for _, item in pairs(ItemCache) do
                    if item.highlight then
                        item.highlight.FillColor = Value
                        item.highlight.OutlineColor = Value
                    end
                end
            end
        })

        Esp:CreateSlider({
            Name = "Item Fill Transparency",
            Range = {0, 1},
            Increment = 0.1,
            CurrentValue = 0.3,
            Flag = "ItemFill",
            Callback = function(Value)
                ItemESP.FillTransparency = Value
                for _, item in pairs(ItemCache) do
                    if item.highlight then
                        item.highlight.FillTransparency = Value
                    end
                end
            end
        })

        Esp:CreateSlider({
            Name = "Item Outline Transparency",
            Range = {0, 1},
            Increment = 0.1,
            CurrentValue = 0,
            Flag = "ItemOutline",
            Callback = function(Value)
                ItemESP.OutlineTransparency = Value
                for _, item in pairs(ItemCache) do
                    if item.highlight then
                        item.highlight.OutlineTransparency = Value
                    end
                end
            end
        })

        Esp:CreateToggle({
            Name = "Show Name",
            CurrentValue = false,
            Flag = "ItemShowName",
            Callback = function(Value)
                ItemESP.ShowName = Value
            end
        })

        Esp:CreateToggle({
            Name = "Show Distance",
            CurrentValue = false,
            Flag = "ItemShowDistance",
            Callback = function(Value)
                ItemESP.ShowDistance = Value
            end
        })

        Esp:CreateToggle({
            Name = "Proximity Collection",
            CurrentValue = false,
            Flag = "ItemSuckEnabled",
            Callback = function(Value)
                print("DETECTED LOL")
            end
        })
    end

    CreatePlayerESPControls()
    CreateDisplayOptions()
    CreateCharmsControls()
    CreateItemESPControls()
end

local function SetupItemESP()
    local runtimeItems = workspace:FindFirstChild("RuntimeItems")
    if not runtimeItems then
        Rayfield:Notify({
            Title = "Item ESP Error",
            Content = "RuntimeItems not found in workspace",
            Duration = 6.5,
            Image = "error"
        })
        return
    end

    local coreGui = game:GetService("CoreGui")
    local function CreateInstance(className, props)
        local obj = Instance.new(className)
        for prop, value in pairs(props) do
            obj[prop] = value
        end
        return obj
    end

    local function CreateItemHighlight(item)
        local highlight = CreateInstance("Highlight", {
            FillColor = ItemESP.Color,
            OutlineColor = ItemESP.Color,
            FillTransparency = ItemESP.FillTransparency,
            OutlineTransparency = ItemESP.OutlineTransparency,
            Adornee = item,
            Enabled = ItemESP.Enabled,
            Parent = item
        })

        local billboard = CreateInstance("BillboardGui", {
            Adornee = item,
            Size = UDim2.fromOffset(200, 50),
            StudsOffset = Vector3.new(0, 2.5, 0),
            AlwaysOnTop = true,
            ResetOnSpawn = false,
            Enabled = ItemESP.Enabled,
            Parent = coreGui
        })

        local textLabel = CreateInstance("TextLabel", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            TextColor3 = ItemESP.Color,
            TextSize = 14,
            Font = Enum.Font.SourceSansBold,
            Parent = billboard
        })

        local entry = {
            highlight = highlight,
            billboard = billboard,
            textLabel = textLabel,
            connection = item.AncestryChanged:Connect(function()
                if not item.Parent then
                    highlight:Destroy()
                    billboard:Destroy()
                    ItemCache[item] = nil
                end
            end)
        }

        entry.renderConnection = RunService.RenderStepped:Connect(function()
            if not ItemESP.Enabled or not item.Parent then
                billboard.Enabled = false
                return
            end

            billboard.Enabled = true
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            
            local infoParts = {}
            if ItemESP.ShowName then
                infoParts[1] = item.Name
            end
            if ItemESP.ShowDistance and rootPart then
                local distance = (rootPart.Position - item:GetPivot().Position).Magnitude
                infoParts[#infoParts + 1] = string.format("[%dm]", math.floor(distance))
            end
            
            textLabel.Text = table.concat(infoParts, " ")
            textLabel.TextColor3 = ItemESP.Color
        end)

        ItemCache[item] = entry
    end

    local function ProcessChild(child)
        if child:IsA("Model") then
            CreateItemHighlight(child)
        end
    end

    for _, child in pairs(runtimeItems:GetChildren()) do
        ProcessChild(child)
    end

    runtimeItems.ChildAdded:Connect(ProcessChild)
end

local function InitializeESP()
    SetupItemESP()
    
    local function CreateESPComponents(player)
        if player == LocalPlayer then return end
        
        local success, character = pcall(function()
            return player.Character or player.CharacterAdded:Wait()
        end)
        if not success or not character then return end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoidRootPart or not humanoid then return end

        local head = character:FindFirstChild("Head")
        if not head then return end

        local function createInstance(className, properties)
            local instance = Instance.new(className)
            for property, value in pairs(properties) do
                instance[property] = value
            end
            return instance
        end

        local billboard = createInstance("BillboardGui", {
            Adornee = head,
            Size = UDim2.new(0, 200, 0, 50),
            StudsOffset = Vector3.new(0, 2.5, 0),
            AlwaysOnTop = true,
            ResetOnSpawn = false,
            Enabled = PlayerESP.Enabled,
            Parent = game:GetService("CoreGui")
        })

        local textLabel = createInstance("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            TextColor3 = PlayerESP.Color,
            TextSize = PlayerESP.TextSize,
            Font = PlayerESP.Font,
            Parent = billboard
        })

        local highlight = createInstance("Highlight", {
            Adornee = character,
            FillColor = CharmsESP.Color,
            OutlineColor = CharmsESP.Color,
            FillTransparency = CharmsESP.FillTransparency,
            OutlineTransparency = CharmsESP.OutlineTransparency,
            DepthMode = CharmsESP.DepthMode,
            Enabled = CharmsESP.Enabled,
            Parent = character
        })

        return {
            billboard = billboard,
            textLabel = textLabel,
            highlight = highlight,
            humanoid = humanoid,
            rootPart = humanoidRootPart
        }
    end

    local function UpdateESP(espData, player)
        return RunService.RenderStepped:Connect(function()
            if not PlayerESP.Enabled and not CharmsESP.Enabled then return end
            
            local isValid = espData.rootPart and espData.humanoid and espData.humanoid.Health > 0
            local billboardVisible = isValid and PlayerESP.Enabled
            local highlightVisible = isValid and CharmsESP.Enabled

            if espData.billboard then
                espData.billboard.Enabled = billboardVisible
            end
            if espData.highlight then
                espData.highlight.Enabled = highlightVisible
                if CharmsESP.PulseEnabled then
                    local pulse = math.sin(tick() * CharmsESP.PulseSpeed) * 0.5 + 0.5
                    espData.highlight.FillColor = Color3.new(
                        CharmsESP.Color.R * pulse,
                        CharmsESP.Color.G * pulse,
                        CharmsESP.Color.B * pulse
                    )
                    espData.highlight.OutlineColor = espData.highlight.FillColor
                end
            end

            if billboardVisible and espData.textLabel and LocalPlayer.Character then
                local rootPos = espData.rootPart.Position
                local localRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not localRoot then return end
                
                local distance = (localRoot.Position - rootPos).Magnitude
                local infoParts = { player.Name }
                
                if PlayerESP.ShowDistance then
                    table.insert(infoParts, string.format("[%dm]", math.floor(distance)))
                end
                if PlayerESP.ShowHealth and espData.humanoid then
                    table.insert(infoParts, string.format("[%dhp]", math.floor(espData.humanoid.Health)))
                end
                
                espData.textLabel.Text = table.concat(infoParts, " ")
                espData.textLabel.TextColor3 = PlayerESP.Color
                espData.textLabel.TextSize = PlayerESP.TextSize
            end
        end)
    end

    local function CleanupPlayer(player)
        if not ESPCache[player] then return end
        
        if ESPCache[player].connection then
            ESPCache[player].connection:Disconnect()
        end
        if ESPCache[player].billboard then
            ESPCache[player].billboard:Destroy()
        end
        if ESPCache[player].highlight then
            ESPCache[player].highlight:Destroy()
        end
        
        ESPCache[player] = nil
    end

    local function ManagePlayerESP(player)
        if player == LocalPlayer or ESPCache[player] then return end
        
        local function HandleCharacterAdded(character)
            CleanupPlayer(player)
            
            local espData = CreateESPComponents(player)
            if not espData then return end
            
            espData.connection = UpdateESP(espData, player)
            ESPCache[player] = espData

            local function HandleCharacterRemoval()
                CleanupPlayer(player)
            end

            if espData.humanoid then
                espData.humanoid.Died:Connect(HandleCharacterRemoval)
            end
            player.CharacterRemoving:Connect(HandleCharacterRemoval)
        end

        if player.Character then
            HandleCharacterAdded(player.Character)
        end
        player.CharacterAdded:Connect(HandleCharacterAdded)
    end

    local function PlayerCheckLoop()
        for _, player in ipairs(Players:GetPlayers()) do
            if not ESPCache[player] and player ~= LocalPlayer then
                task.spawn(ManagePlayerESP, player)
            end
        end
    end

    Players.PlayerAdded:Connect(ManagePlayerESP)
    Players.PlayerRemoving:Connect(CleanupPlayer)

    while true do
        PlayerCheckLoop()
        task.wait(2)
    end
end

CreateMainWindow()
SetupESPTab()
InitializeESP()
