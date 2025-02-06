local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer
local Event = ReplicatedStorage:WaitForChild("event")
local Trainer = require(ReplicatedStorage:WaitForChild("trainer"))
local Events = require(Player:WaitForChild("PlayerGui"):WaitForChild("framework"):WaitForChild("events"))

local Beys = Workspace:WaitForChild("beyblades")
local Battles = Workspace:WaitForChild("battles")
local Specials = Workspace:WaitForChild("specials")

local HttpService = game:GetService("HttpService")
local StartTime = tick() -- Marca o tempo inicial de execução do script
local ServerURL = "http://https://395e-170-83-227-131.ngrok-free.app/submit_data" -- Substitua pelo IP correto do seu servidor
-- Criar GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 2
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "Menu Principal"
Title.TextSize = 18
Title.Font = Enum.Font.SourceSansBold
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Parent = MainFrame

local Tabs = {"Torre", "RANKS", "Info"}
local CurrentTab = nil
local TabButtons = {}
local TabFrames = {}

for i, tabName in ipairs(Tabs) do
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0.33, -2, 0, 35)
    Button.Position = UDim2.new((i - 1) * 0.33, (i - 1) * 2, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = tabName
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.SourceSansBold
    Button.Parent = MainFrame
    TabButtons[tabName] = Button

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 1, -90)
    Frame.Position = UDim2.new(0, 5, 0, 80)
    Frame.BackgroundTransparency = 1
    Frame.Visible = false
    Frame.Parent = MainFrame
    TabFrames[tabName] = Frame

    Button.MouseButton1Click:Connect(function()
        if CurrentTab then
            TabFrames[CurrentTab].Visible = false
        end
        CurrentTab = tabName
        TabFrames[tabName].Visible = true
    end)
end

CurrentTab = "Torre"
TabFrames["Torre"].Visible = true

-- ABA TORRE: AutoFarm da Torre
local TorreFrame = TabFrames["Torre"]

local StartButton = Instance.new("TextButton")
StartButton.Size = UDim2.new(0.8, 0, 0, 50)
StartButton.Position = UDim2.new(0.1, 0, 0.1, 0)
StartButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
StartButton.Text = "Ativar AutoFarm"
StartButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StartButton.Parent = TorreFrame

local LoopEnabled = false

StartButton.MouseButton1Click:Connect(function()
    LoopEnabled = not LoopEnabled
    StartButton.Text = LoopEnabled and "Desativar AutoFarm" or "Ativar AutoFarm"
end)

local HighestFloorLabel = Instance.new("TextLabel")
HighestFloorLabel.Size = UDim2.new(0.8, 0, 0, 50)
HighestFloorLabel.Position = UDim2.new(0.1, 0, 0.3, 0)
HighestFloorLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HighestFloorLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
HighestFloorLabel.TextScaled = true
HighestFloorLabel.Text = "Andar mais alto: 0"
HighestFloorLabel.Parent = TorreFrame

-- Novo texto para exibir o nível do jogador
local PlayerLevelLabel = Instance.new("TextLabel")
PlayerLevelLabel.Size = UDim2.new(0.8, 0, 0, 50)
PlayerLevelLabel.Position = UDim2.new(0.1, 0, 0.45, 0) -- Posicionado abaixo do maior andar
PlayerLevelLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PlayerLevelLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PlayerLevelLabel.TextScaled = true
PlayerLevelLabel.Text = "Nível: 0"
PlayerLevelLabel.Parent = TorreFrame

local function UpdateStats()
    while true do
        task.wait(1)

        -- Atualiza o maior andar alcançado
        local Stats = Player:FindFirstChild("stats")
        if Stats then
            local TowerStats = Stats:FindFirstChild("tower")
            if TowerStats then
                local HighestFloor = TowerStats:FindFirstChild("highest")
                if HighestFloor then
                    HighestFloorLabel.Text = "Andar mais alto: " .. HighestFloor.Value
                end
            end
        end

        -- Atualiza o nível do jogador
        local PlayerLevel = Player:FindFirstChild("stats")
        if PlayerLevel then
            local Data = PlayerLevel:FindFirstChild("data")
            if Data then
                local Level = Data:FindFirstChild("lvl")
                if Level then
                    PlayerLevelLabel.Text = "Nível: " .. Level.Value
                end
            end
        end
    end
end

task.spawn(UpdateStats)

local function UpdateHighestFloor()
    while true do
        task.wait(1)
        local Stats = Player:FindFirstChild("stats")
        if Stats then
            local TowerStats = Stats:FindFirstChild("tower")
            if TowerStats then
                local HighestFloor = TowerStats:FindFirstChild("highest")
                if HighestFloor then
                    HighestFloorLabel.Text = "Andar mais alto: " .. HighestFloor.Value
                end
            end
        end
    end
end

task.spawn(UpdateHighestFloor)

function GetBey()
    local Bey = Beys:FindFirstChild(Player.Name)
    if Bey and Bey.PrimaryPart then
        return Bey
    end
    return nil
end

Battles.ChildRemoved:Connect(function(A_1)
    if A_1 and A_1.Name == Player.Name .. "_Target" then
        task.wait(1)
        if LoopEnabled then
            Event:FireServer("BattleTower")
        end
    end
end)

Events.TrainerBattleResult = function() task.wait() if Trainer and type(Trainer.close) == "function" then Trainer.close() end end

RunService.Heartbeat:Connect(function()
    if not LoopEnabled then return end

    local Bey = GetBey()
    if not Bey then return end

    local Enemy = Beys:FindFirstChild(Player.Name .. "_Target")
    if Enemy then
        local Humanoid = Enemy:FindFirstChildOfClass("Humanoid")
        if Humanoid and Humanoid.Health > 0 then
            Humanoid.Health = 0
        end
    end
end)

local TeleportButton = Instance.new("TextButton")
TeleportButton.Size = UDim2.new(0.8, 0, 0, 50)
TeleportButton.Position = UDim2.new(0.1, 0, 0.5, 50)
TeleportButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
TeleportButton.Text = "Ir para a Torre"
TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
TeleportButton.Parent = TorreFrame

TeleportButton.MouseButton1Click:Connect(function()
    local npcs = Workspace:FindFirstChild("npcs")
    if npcs then
        local Tower = npcs:FindFirstChild("battletower")
        if Tower and Tower.PrimaryPart then
            Player.Character:MoveTo(Tower.PrimaryPart.Position)
        else
            warn("Torre não encontrada ou sem PrimaryPart!")
        end
    else
        warn("Pasta NPCs não encontrada!")
    end
end)

local Players = game:GetService("Players")

-- ABA RANKS
local RanksFrame = TabFrames["RANKS"]

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- Será ajustado dinamicamente
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Parent = RanksFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5) -- Espaçamento entre os itens

local function CreatePlayerItem(player)
    local rankValue = player:FindFirstChild("rank")
    local PlayerRank = "Desconhecido"

    if rankValue and rankValue:IsA("StringValue") then
        PlayerRank = rankValue.Value
    end

    local Item = Instance.new("TextLabel")
    Item.Size = UDim2.new(1, 0, 0, 30)
    Item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Item.Text = player.Name .. " | Rank: " .. PlayerRank
    Item.TextSize = 16
    Item.Font = Enum.Font.SourceSans
    Item.TextColor3 = Color3.fromRGB(255, 255, 255)
    Item.Parent = ScrollFrame

    return Item
end

local function UpdatePlayerList()
    -- Limpa os itens antigos
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    -- Adiciona cada jogador ao leaderboard
    for _, player in pairs(Players:GetPlayers()) do
        CreatePlayerItem(player)
    end

    -- Ajusta a altura do ScrollFrame dinamicamente
    local itemCount = #Players:GetPlayers()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, itemCount * 35) -- Ajusta para caber todos os itens
end

-- Atualiza quando um jogador entra ou sai do jogo
Players.PlayerAdded:Connect(UpdatePlayerList)
Players.PlayerRemoving:Connect(UpdatePlayerList)

-- Atualiza a lista inicial
UpdatePlayerList()

local Ranks = {
    {name = "Unranked", level = 1},
    {name = "Bronze I", level = 15},
    {name = "Bronze II", level = 45},
    {name = "Bronze III", level = 70},
    {name = "Silver I", level = 100},
    {name = "Silver II", level = 150},
    {name = "Silver III", level = 200},
    {name = "Gold I", level = 275},
    {name = "Gold II", level = 350},
    {name = "Gold III", level = 400},
    {name = "Platinum I", level = 485},
    {name = "Platinum II", level = 650},
    {name = "Platinum III", level = 735},
    {name = "Diamond I", level = 850},
    {name = "Diamond II", level = 995},
    {name = "Diamond III", level = 1250},
    {name = "Mystic I", level = 1400},
    {name = "Mystic II", level = 1575},
    {name = "Mystic III", level = 1750},
    {name = "Eternal I", level = 2000},
    {name = "Eternal II", level = 2350},
    {name = "Eternal III", level = 2555},
    {name = "Champion I", level = 2700},
    {name = "Champion II", level = 2995},
    {name = "Champion III", level = 3500},
    {name = "Grand Champion", level = 4000},
    {name = "God I", level = 5000},
    {name = "God II", level = 6000},
    {name = "God III", level = 8500},
    {name = "Guardian I", level = 10000},
    {name = "Guardian II", level = 12000},
    {name = "Guardian III", level = 15000},
    {name = "Avatar", level = 20000}
}

-- Função para determinar o Rank atual e o próximo
local function GetPlayerRank(level)
    local currentRank = Ranks[1]  -- Começa no menor rank (Unranked)
    local nextRank = nil

    for i = 1, #Ranks do
        if level >= Ranks[i].level then
            currentRank = Ranks[i] -- Atualiza o rank atual
        else
            nextRank = Ranks[i] -- O primeiro que for maior que o level atual é o próximo rank
            break
        end
    end

    return currentRank, nextRank
end

-- Criar a aba Info
local InfoFrame = TabFrames["Info"]

local RankLabel = Instance.new("TextLabel")
RankLabel.Size = UDim2.new(0.9, 0, 0, 50)
RankLabel.Position = UDim2.new(0.05, 0, 0.1, 0)
RankLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
RankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RankLabel.TextScaled = true
RankLabel.Parent = InfoFrame

local NextRankLabel = Instance.new("TextLabel")
NextRankLabel.Size = UDim2.new(0.9, 0, 0, 50)
NextRankLabel.Position = UDim2.new(0.05, 0, 0.3, 0)
NextRankLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
NextRankLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
NextRankLabel.TextScaled = true
NextRankLabel.Parent = InfoFrame

local LevelsNeededLabel = Instance.new("TextLabel")
LevelsNeededLabel.Size = UDim2.new(0.9, 0, 0, 50)
LevelsNeededLabel.Position = UDim2.new(0.05, 0, 0.5, 0)
LevelsNeededLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LevelsNeededLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LevelsNeededLabel.TextScaled = true
LevelsNeededLabel.Parent = InfoFrame

local function UpdateRankInfo()
    while true do
        task.wait(1)

        local Stats = Player:FindFirstChild("stats")
        if Stats then
            local Data = Stats:FindFirstChild("data")
            if Data then
                local Level = Data:FindFirstChild("lvl")
                if Level then
                    local currentRank, nextRank = GetPlayerRank(Level.Value)

                    RankLabel.Text = "RANK ATUAL: " .. currentRank.name
                    if nextRank then
                        NextRankLabel.Text = "Próximo RANK: " .. nextRank.name
                        LevelsNeededLabel.Text = "Falta " .. (nextRank.level - Level.Value) .. " levels para o próximo RANK."
                    else
                        NextRankLabel.Text = "Você já está no rank máximo!"
                        LevelsNeededLabel.Text = ""
                    end
                end
            end
        end
    end
end

task.spawn(UpdateRankInfo)

local function GetPlayerStats()
    local stats = Player:FindFirstChild("stats")
    if not stats then return nil end

    local level = stats:FindFirstChild("level") and stats.level.Value or 0
    local towerStats = stats:FindFirstChild("tower")
    local highestFloor = towerStats and towerStats:FindFirstChild("highest") and towerStats.highest.Value or 0

    local rankValue = Player:FindFirstChild("rank")
    local rank = rankValue and rankValue:IsA("StringValue") and rankValue.Value or "Desconhecido"

    local xp = stats:FindFirstChild("xp") and stats.xp.Value or 0
    local xpNext = stats:FindFirstChild("xpNext") and stats.xpNext.Value or 100 -- Valor padrão caso não exista

    local timeRunning = tick() - StartTime -- Tempo de execução do script

    return {
        username = Player.Name,
        level = level,
        highest_floor = highestFloor,
        rank = rank,
        xp = xp,
        xp_next = xpNext,
        time_running = math.floor(timeRunning) -- Tempo arredondado
    }
end

local function SendDataToServer()
    local playerStats = GetPlayerStats()
    if not playerStats then return end

    local success, response = pcall(function()
        return HttpService:PostAsync(ServerURL, HttpService:JSONEncode(playerStats), Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("Falha ao enviar dados para o servidor:", response)
    end
end

-- Enviar dados a cada 30 segundos
while true do
    SendDataToServer()
    task.wait(5)
end

task.spawn(SendDataToServer)
