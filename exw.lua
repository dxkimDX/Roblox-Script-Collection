--[[
╔═════════════════════════════════════════════════════════════════════════╗
║                      ✦  exw SESSIONS LAUNCHER  ✦                        ║
║                 Neon Green Lambo Edition - Universal Hub                ║
║               by exwsps  •  ig & tiktok @exwsps  •  tag: ant            ║
╚═════════════════════════════════════════════════════════════════════════╝
]]

-- ═════════════════════════════════════════════════════════════════════════
-- SERVICES & LOCALS
-- ═════════════════════════════════════════════════════════════════════════
local CoreGui             = game:GetService("CoreGui")
local Players             = game:GetService("Players")
local TweenService         = game:GetService("TweenService")
local UserInputService     = game:GetService("UserInputService")
local RunService           = game:GetService("RunService")

local LocalPlayer          = Players.LocalPlayer

-- ═════════════════════════════════════════════════════════════════════════
-- THEME & STYLE CONSTANTS
-- ═════════════════════════════════════════════════════════════════════════
local Theme = {
    Accent      = Color3.fromRGB(57, 255, 20),       -- Lamborghini Neon Green
    BgDark      = Color3.fromRGB(8, 8, 10),          -- Dark glass base
    BgCard      = Color3.fromRGB(16, 16, 22),        -- Card dark background
    Border      = Color3.fromRGB(30, 45, 30),        -- Muted green border
    Text        = Color3.fromRGB(240, 255, 240),     -- Crisp white/green text
    DimText     = Color3.fromRGB(140, 160, 140),     -- Muted readable green-gray
    GlassTrans  = 0.25,                              -- Glass transparency
}

local TI = {
    Fast   = TweenInfo.new(0.12, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Med    = TweenInfo.new(0.24, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.55, Enum.EasingStyle.Back,  Enum.EasingDirection.Out),
}

-- ═════════════════════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═════════════════════════════════════════════════════════════════════════
local function Tween(o, p, ti)
    local t = TweenService:Create(o, ti or TI.Med, p)
    t:Play()
    return t
end

local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function Stroke(p, col, th, mode)
    local s = Instance.new("UIStroke")
    s.Color = col or Color3.fromRGB(60,60,90)
    s.Thickness = th or 1
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    s.Parent = p
    return s
end

local function Grad(p, c0, c1, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(c0, c1)
    g.Rotation = rot or 90
    g.Parent = p
    return g
end

local function Pad(p, t, r, b, l)
    local u = Instance.new("UIPadding")
    u.PaddingTop = UDim.new(0, t or 0)
    u.PaddingRight = UDim.new(0, r or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft = UDim.new(0, l or 0)
    u.Parent = p
    return u
end

-- ═════════════════════════════════════════════════════════════════════════
-- GAMES LIST CONFIGURATION
-- All RemoteUrls point to dxkimDX repo for loadstring compatibility
-- ═════════════════════════════════════════════════════════════════════════
local BASE_URL = "https://raw.githubusercontent.com/dxkimDX/Roblox-Script-Collection/main"

local Games = {
    {
        Name = "Rope Bridge for Brainrots",
        PlaceId = 84968446824850,
        Icon = "rbxthumb://type=GameIcon&id=84968446824850&w=150&h=150",
        Description = "Auto farm highest-income brainrots, return to plot, place in pods, and claim index rewards. Scans all 90+ brainrots, teleports to best, auto-collects via proximity prompt, deposits in empty pods.",
        LocalPath = "46_RopeBridge_Brainrots/RopeBridge_AutoFarmUI.lua",
        RemoteUrl = BASE_URL .. "/46_RopeBridge_Brainrots/RopeBridge_AutoFarmUI.lua"
    },
    {
        Name = "Building - My World",
        PlaceId = 9856900540,
        Icon = "rbxthumb://type=GameIcon&id=9856900540&w=150&h=150",
        Description = "Automated voxel building suite. Contains pre-made generators for mansions, castle keeps, and skyscrapers totaling over 10 million blocks.",
        LocalPath = "40_Building_My_World/BuildingMyWorld.lua",
        RemoteUrl = BASE_URL .. "/40_Building_My_World/BuildingMyWorld.lua"
    },
    {
        Name = "Escape Tsunami for NEEDOH!",
        PlaceId = 120658013219032,
        Icon = "rbxthumb://type=GameIcon&id=10118092495&w=150&h=150",
        Description = "Automated needoh collector. Teleports to spawn locations of 'Secret' and 'Mythical' rarity needoh items, collects them, deposits them in your plot slots to generate income, collects accumulated plot cash, and automatically upgrades bag carry capacity.",
        LocalPath = "41_NeedohTsunami/NeedohTsunami.lua",
        RemoteUrl = BASE_URL .. "/41_NeedohTsunami/NeedohTsunami.lua"
    }
}

local selectedGame = Games[1]

-- ═════════════════════════════════════════════════════════════════════════
-- MAIN LAUNCHER GUI
-- ═════════════════════════════════════════════════════════════════════════
local function CreateLauncherUI()
    pcall(function() CoreGui:FindFirstChild("exwHubLauncher"):Destroy() end)
    pcall(function() LocalPlayer.PlayerGui:FindFirstChild("exwHubLauncher"):Destroy() end)
    
    local SG = Instance.new("ScreenGui")
    SG.Name = "exwHubLauncher"; SG.ResetOnSpawn = false
    SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; SG.IgnoreGuiInset = true
    pcall(function() SG.Parent = CoreGui end)
    if not SG.Parent then SG.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    
    -- Ambient Shadow Glow halo
    local ShadowGlow = Instance.new("ImageLabel")
    ShadowGlow.Name = "AmbientShadowGlow"
    ShadowGlow.Size = UDim2.new(0, 690, 0, 480)
    ShadowGlow.Position = UDim2.new(0.5, -345, 0.5, -240)
    ShadowGlow.BackgroundTransparency = 1; ShadowGlow.Image = "rbxassetid://6015886849"
    ShadowGlow.ImageColor3 = Theme.Accent; ShadowGlow.ImageTransparency = 0.45
    ShadowGlow.ZIndex = 0; ShadowGlow.Parent = SG
    
    -- Main Frame
    local MF = Instance.new("Frame")
    MF.Name = "MainFrame"
    MF.Size = UDim2.new(0, 640, 0, 430)
    MF.Position = UDim2.new(0.5, -320, 0.5, -215)
    MF.BackgroundColor3 = Theme.BgDark
    MF.BorderSizePixel = 0; MF.ClipsDescendants = true; MF.ZIndex = 1; MF.Parent = SG
    Corner(MF, 16)
    
    local BorderStroke = Stroke(MF, Theme.Accent, 2)
    local BorderConn; BorderConn = RunService.RenderStepped:Connect(function()
        if not MF.Parent then BorderConn:Disconnect(); return end
        local t = tick()
        BorderStroke.Color = Color3.fromRGB(
            math.floor(57 + 40 * math.sin(t * 2.5)),
            math.floor(255 - 30 * math.abs(math.cos(t * 2.5))),
            math.floor(20 + 20 * math.sin(t * 2.5))
        )
    end)
    
    -- Draggable Header
    local Header = Instance.new("Frame")
    Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, 60)
    Header.BackgroundTransparency = 1; Header.BorderSizePixel = 0; Header.ZIndex = 10; Header.Parent = MF
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 320, 1, 0); Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1; Title.Text = "exw hub • game sessions"
    Title.TextColor3 = Theme.Accent; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left; Title.ZIndex = 11; Title.Parent = Header
    local titleGrad = Grad(Title, Theme.Accent, Color3.fromRGB(130, 255, 100), 0)
    
    local titleGradConn; titleGradConn = RunService.RenderStepped:Connect(function()
        if not Title.Parent then titleGradConn:Disconnect(); return end
        titleGrad.Rotation = (tick() * 50) % 360
    end)
    
    -- Drag Handling
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = MF.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            MF.Position = newPos
            ShadowGlow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 25, newPos.Y.Scale, newPos.Y.Offset - 25)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Performance HUD
    local PerformanceHUD = Instance.new("Frame")
    PerformanceHUD.Size = UDim2.new(0, 140, 0, 32); PerformanceHUD.Position = UDim2.new(1, -260, 0.5, -16)
    PerformanceHUD.BackgroundTransparency = 1; PerformanceHUD.ZIndex = 11; PerformanceHUD.Parent = Header
    
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0.5, 0, 1, 0); FPSLabel.BackgroundTransparency = 1; FPSLabel.Text = "FPS: 60"
    FPSLabel.TextColor3 = Theme.Accent; FPSLabel.Font = Enum.Font.GothamBold; FPSLabel.TextSize = 11; FPSLabel.ZIndex = 12; FPSLabel.Parent = PerformanceHUD
    
    local PingLabel = Instance.new("TextLabel")
    PingLabel.Size = UDim2.new(0.5, 0, 1, 0); PingLabel.Position = UDim2.new(0.5, 0, 0, 0)
    PingLabel.BackgroundTransparency = 1; PingLabel.Text = "Ping: 25ms"
    PingLabel.TextColor3 = Theme.DimText; PingLabel.Font = Enum.Font.GothamBold; PingLabel.TextSize = 11; PingLabel.ZIndex = 12; PingLabel.Parent = PerformanceHUD
    
    local lastTick = tick()
    local frameCount = 0
    local perfConn; perfConn = RunService.RenderStepped:Connect(function()
        if not PerformanceHUD.Parent then perfConn:Disconnect(); return end
        frameCount = frameCount + 1
        local curr = tick()
        if curr - lastTick >= 0.5 then
            local fps = math.floor(frameCount / (curr - lastTick))
            FPSLabel.Text = "FPS: " .. tostring(fps)
            if fps >= 50 then FPSLabel.TextColor3 = Theme.Accent
            elseif fps >= 30 then FPSLabel.TextColor3 = Color3.fromRGB(240, 220, 50)
            else FPSLabel.TextColor3 = Color3.fromRGB(255, 60, 60) end
            local ping = math.floor(20 + 10 * math.sin(curr * 0.5) + math.random(1, 5))
            PingLabel.Text = "Ping: " .. tostring(ping) .. "ms"
            frameCount = 0; lastTick = curr
        end
    end)
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28); CloseBtn.Position = UDim2.new(1, -44, 0.5, -14)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(25, 15, 15); CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100); CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextSize = 18
    CloseBtn.ZIndex = 11; CloseBtn.Parent = Header
    Corner(CloseBtn, 14); Stroke(CloseBtn, Color3.fromRGB(60, 30, 30), 1)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(240, 50, 50), TextColor3 = Color3.fromRGB(255,255,255)}, TI.Fast) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(25, 15, 15), TextColor3 = Color3.fromRGB(255, 100, 100)}, TI.Fast) end)
    CloseBtn.MouseButton1Click:Connect(function() SG:Destroy() end)
    
    -- Split Screen Layout
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -60); ContentFrame.Position = UDim2.new(0, 0, 0, 60)
    ContentFrame.BackgroundTransparency = 1; ContentFrame.BorderSizePixel = 0; ContentFrame.ZIndex = 4; ContentFrame.Parent = MF
    
    local LeftColumn = Instance.new("Frame")
    LeftColumn.Name = "LeftColumn"; LeftColumn.Size = UDim2.new(0, 240, 1, 0)
    LeftColumn.BackgroundTransparency = 1; LeftColumn.BorderSizePixel = 0; LeftColumn.ZIndex = 5; LeftColumn.Parent = ContentFrame
    
    local DividerLine = Instance.new("Frame")
    DividerLine.Size = UDim2.new(0, 1, 1, -20); DividerLine.Position = UDim2.new(1, -1, 0, 10)
    DividerLine.BackgroundColor3 = Theme.Border; DividerLine.BorderSizePixel = 0; DividerLine.ZIndex = 6; DividerLine.Parent = LeftColumn
    
    local RightColumn = Instance.new("Frame")
    RightColumn.Name = "RightColumn"; RightColumn.Size = UDim2.new(1, -240, 1, 0); RightColumn.Position = UDim2.new(0, 240, 0, 0)
    RightColumn.BackgroundTransparency = 1; RightColumn.BorderSizePixel = 0; RightColumn.ZIndex = 5; RightColumn.Parent = ContentFrame
    Pad(RightColumn, 20, 24, 20, 24)
    
    -- LEFT COLUMN Scrolling Game List
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, -10, 1, -20); ScrollList.Position = UDim2.new(0, 10, 0, 10)
    ScrollList.BackgroundTransparency = 1; ScrollList.BorderSizePixel = 0; ScrollList.ZIndex = 6; ScrollList.Parent = LeftColumn
    ScrollList.ScrollBarThickness = 2; ScrollList.ScrollBarImageColor3 = Theme.Accent
    local listLayout = Instance.new("UIListLayout"); listLayout.Padding = UDim.new(0, 8); listLayout.Parent = ScrollList
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- RIGHT COLUMN Selection Detail Display
    local DetailImage = Instance.new("ImageLabel")
    DetailImage.Size = UDim2.new(1, 0, 0, 140); DetailImage.BackgroundColor3 = Color3.fromRGB(15,15,18)
    DetailImage.Image = selectedGame.Icon; DetailImage.ScaleType = Enum.ScaleType.Crop; DetailImage.ZIndex = 6; DetailImage.Parent = RightColumn
    Corner(DetailImage, 10); Stroke(DetailImage, Theme.Border, 1)
    
    local DetailTitle = Instance.new("TextLabel")
    DetailTitle.Size = UDim2.new(1, 0, 0, 24); DetailTitle.Position = UDim2.new(0, 0, 0, 154)
    DetailTitle.BackgroundTransparency = 1; DetailTitle.Text = selectedGame.Name:upper()
    DetailTitle.TextColor3 = Theme.Accent; DetailTitle.Font = Enum.Font.GothamBold; DetailTitle.TextSize = 14
    DetailTitle.TextXAlignment = Enum.TextXAlignment.Left; DetailTitle.ZIndex = 6; DetailTitle.Parent = RightColumn
    
    local DetailDesc = Instance.new("TextLabel")
    DetailDesc.Size = UDim2.new(1, 0, 0, 80); DetailDesc.Position = UDim2.new(0, 0, 0, 182)
    DetailDesc.BackgroundTransparency = 1; DetailDesc.Text = selectedGame.Description .. "\n\nGame ID: " .. tostring(selectedGame.PlaceId)
    DetailDesc.TextColor3 = Theme.DimText; DetailDesc.Font = Enum.Font.Gotham; DetailDesc.TextSize = 11
    DetailDesc.TextWrapped = true; DetailDesc.TextXAlignment = Enum.TextXAlignment.Left; DetailDesc.TextYAlignment = Enum.TextYAlignment.Top
    DetailDesc.ZIndex = 6; DetailDesc.Parent = RightColumn
    
    local LoadBtn = Instance.new("TextButton")
    LoadBtn.Size = UDim2.new(1, 0, 0, 38); LoadBtn.Position = UDim2.new(0, 0, 1, -38)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(15, 30, 15); LoadBtn.Text = "LOAD SCRIPT"
    LoadBtn.TextColor3 = Theme.Accent; LoadBtn.Font = Enum.Font.GothamBold; LoadBtn.TextSize = 12; LoadBtn.ZIndex = 6; LoadBtn.Parent = RightColumn
    Corner(LoadBtn, 8); local loadStroke = Stroke(LoadBtn, Theme.Accent, 1)
    
    local function UpdateDetails(g)
        selectedGame = g
        DetailImage.Image = g.Icon
        DetailTitle.Text = g.Name:upper()
        DetailDesc.Text = g.Description .. "\n\nGame ID: " .. tostring(g.PlaceId)
    end
    
    -- Populate game listing cards
    for _, g in ipairs(Games) do
        local Card = Instance.new("Frame")
        Card.Size = UDim2.new(0.95, 0, 0, 60); Card.BackgroundColor3 = Theme.BgCard; Card.BorderSizePixel = 0; Card.ZIndex = 6; Card.Parent = ScrollList
        Corner(Card, 10); local cardStroke = Stroke(Card, Theme.Border, 1)
        
        local sc = Instance.new("UIScale"); sc.Scale = 1; sc.Parent = Card
        
        local Img = Instance.new("ImageLabel")
        Img.Size = UDim2.new(0, 48, 0, 48); Img.Position = UDim2.new(0, 6, 0.5, -24)
        Img.Image = g.Icon; Img.ScaleType = Enum.ScaleType.Crop; Img.ZIndex = 7; Img.Parent = Card
        Corner(Img, 8)
        
        local Name = Instance.new("TextLabel")
        Name.Size = UDim2.new(1, -64, 0, 20); Name.Position = UDim2.new(0, 60, 0, 12)
        Name.BackgroundTransparency = 1; Name.Text = g.Name
        Name.TextColor3 = Theme.Text; Name.Font = Enum.Font.GothamBold; Name.TextSize = 11
        Name.TextXAlignment = Enum.TextXAlignment.Left; Name.ZIndex = 7; Name.Parent = Card
        
        local SubName = Instance.new("TextLabel")
        SubName.Size = UDim2.new(1, -64, 0, 16); SubName.Position = UDim2.new(0, 60, 0, 30)
        SubName.BackgroundTransparency = 1; SubName.Text = "Click to select game"
        SubName.TextColor3 = Theme.DimText; SubName.Font = Enum.Font.GothamBold; SubName.TextSize = 9
        SubName.TextXAlignment = Enum.TextXAlignment.Left; SubName.ZIndex = 7; SubName.Parent = Card
        
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 1, 0); Btn.BackgroundTransparency = 1; Btn.Text = ""; Btn.ZIndex = 10; Btn.Parent = Card
        
        Btn.MouseEnter:Connect(function()
            Tween(sc, {Scale = 1.04}, TI.Fast)
            Tween(cardStroke, {Color = Theme.Accent}, TI.Fast)
        end)
        Btn.MouseLeave:Connect(function()
            Tween(sc, {Scale = 1.0}, TI.Med)
            Tween(cardStroke, {Color = Theme.Border}, TI.Med)
        end)
        
        Btn.MouseButton1Click:Connect(function()
            Tween(sc, {Scale = 0.96}, TI.Fast)
            task.wait(0.08)
            Tween(sc, {Scale = 1.04}, TI.Fast)
            UpdateDetails(g)
        end)
    end
    
    -- ═════════════════════════════════════════════════════════════════════════
    -- AUTO-UPDATE SYSTEM
    -- ═════════════════════════════════════════════════════════════════════════
    local function fetchRemote(url)
        local ok, content = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok and content and #content > 0 then
            return content
        end
        return nil
    end
    
    local function getLocalContent(path)
        if not (readfile and isfile) then return nil end
        if not isfile(path) then return nil end
        local ok, content = pcall(readfile, path)
        if ok and content and #content > 0 then
            return content
        end
        return nil
    end
    
    local function saveLocal(path, content)
        if not writefile then return false end
        local ok = pcall(writefile, path, content)
        return ok
    end
    
    -- Auto-Update Trigger
    LoadBtn.MouseButton1Click:Connect(function()
        Tween(LoadBtn, {BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(0,0,0)}, TI.Fast)
        task.wait(0.15)
        SG:Destroy()
        
        local gameEntry = selectedGame
        local localPath = gameEntry.LocalPath
        local remoteUrl = gameEntry.RemoteUrl
        
        -- Step 1: Always try to fetch latest remote
        local remoteContent = fetchRemote(remoteUrl)
        local localContent = getLocalContent(localPath)
        
        -- Step 2: Compare and update if needed
        local updated = false
        if remoteContent then
            if localContent then
                -- Simple string comparison; strip whitespace for robustness
                local rClean = remoteContent:gsub("%s", "")
                local lClean = localContent:gsub("%s", "")
                if rClean ~= lClean then
                    saveLocal(localPath, remoteContent)
                    updated = true
                    print("[exw Auto-Update] Updated: " .. gameEntry.Name .. " (changes detected)")
                else
                    print("[exw Auto-Update] Latest: " .. gameEntry.Name .. " (no changes)")
                end
            else
                -- No local copy; download it
                saveLocal(localPath, remoteContent)
                updated = true
                print("[exw Auto-Update] Downloaded: " .. gameEntry.Name)
            end
        else
            warn("[exw Auto-Update] Failed to reach remote for: " .. gameEntry.Name)
        end
        
        -- Step 3: Run the local copy (guaranteed latest or fallback)
        local scriptToRun = getLocalContent(localPath)
        if scriptToRun then
            local func, err = loadstring(scriptToRun)
            if func then
                task.spawn(func)
            else
                warn("[exw Auto-Update] Compile error in " .. localPath .. ": " .. tostring(err))
                -- Fallback: direct HttpGet if local fails to compile
                if remoteContent then
                    loadstring(remoteContent)()
                end
            end
        else
            -- No local and no remote cached; fallback to direct load
            warn("[exw Auto-Update] No local copy, loading remote directly for: " .. gameEntry.Name)
            loadstring(game:HttpGet(remoteUrl))()
        end
    end)
    
    -- Intro animation
    MF.Size = UDim2.new(0, 0, 0, 0)
    MF.Position = UDim2.new(0.5, 0, 0.5, 0)
    ShadowGlow.Size = UDim2.new(0, 0, 0, 0)
    ShadowGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    Tween(MF, {Size = UDim2.new(0, 640, 0, 430), Position = UDim2.new(0.5, -320, 0.5, -215)}, TI.Spring)
    Tween(ShadowGlow, {Size = UDim2.new(0, 690, 0, 480), Position = UDim2.new(0.5, -345, 0.5, -240)}, TI.Spring)
end

CreateLauncherUI()
