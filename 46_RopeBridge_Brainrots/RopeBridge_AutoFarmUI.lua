--[[
    Rope Bridge for Brainrots - Auto Farm UI v2
    PlaceId: 84968446824850
    Version: 2.0 - Fixed collect, fixed index, fixed stop
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- ==================== CONFIG ====================
local CONFIG = {
    AutoPlace = true,
    AutoSell = false,
    AutoIndex = true,
    MinIncome = 0,
    CollectRetries = 3,
    PromptWaitTime = 0.8,
}

-- ==================== STATE ====================
local state = {
    running = false,
    cancelled = false,
    bestName = "None",
    bestIncome = 0,
    collected = 0,
    placed = 0,
    sold = 0,
    currentAction = "Idle",
}

-- ==================== CANCEL-SAFE WAIT ====================
-- KEY FIX #3: Every wait checks if user pressed STOP
local function waitWithCancel(seconds)
    local elapsed = 0
    while elapsed < seconds do
        if state.cancelled then return true end
        task.wait(0.1)
        elapsed = elapsed + 0.1
    end
    return false
end

-- ==================== PLOT UTILS ====================
local function getMyPlot()
    for _, plot in ipairs(Workspace.Plots:GetChildren()) do
        if plot:GetAttribute("OwnerUserID") == player.UserId then
            return plot
        end
    end
    return nil
end

local function getEmptyPod(plot)
    if not plot then return nil end
    local pods = plot:FindFirstChild("Pods")
    if not pods then return nil end
    for _, pod in ipairs(pods:GetChildren()) do
        if pod:GetAttribute("BrainrotActive") ~= true then
            local base = pod:FindFirstChild("BasePart")
            if base then return pod, base.Position end
        end
    end
    return nil
end

-- ==================== HRP ====================
local function getHRP()
    local char = player.Character
    if not char then
        char = player.CharacterAdded:Wait()
    end
    return char:WaitForChild("HumanoidRootPart", 5)
end

-- ==================== SCAN ====================
local function scanBrainrots()
    local folder = Workspace:FindFirstChild("ActiveBrainrots")
    if not folder then return {} end
    local list = {}
    for _, hitbox in ipairs(folder:GetChildren()) do
        if hitbox:IsA("BasePart") then
            local inc = hitbox:GetAttribute("Income") or 0
            if inc >= CONFIG.MinIncome then
                table.insert(list, {
                    Hitbox = hitbox,
                    Name = hitbox:GetAttribute("Name") or "?",
                    Rarity = hitbox:GetAttribute("Rarity") or "Common",
                    Mutation = hitbox:GetAttribute("Mutation") or "Normal",
                    Level = hitbox:GetAttribute("Level") or 0,
                    Income = inc,
                    Pos = hitbox.Position,
                })
            end
        end
    end
    table.sort(list, function(a, b) return a.Income > b.Income end)
    return list
end

-- ==================== UI BUILD ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RBB_AutoFarm"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 440)
mainFrame.Position = UDim2.new(0, 20, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", mainFrame).Color = Color3.fromRGB(60, 60, 70)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "BRAINROT AUTO FARM v2"
title.TextColor3 = Color3.fromRGB(255, 200, 50)
title.TextSize = 17
title.Font = Enum.Font.GothamBold

local statusLabel = Instance.new("TextLabel", mainFrame)
statusLabel.Size = UDim2.new(1, -20, 0, 22)
statusLabel.Position = UDim2.new(0, 10, 0, 42)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamSemibold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

local infoBg = Instance.new("Frame", mainFrame)
infoBg.Size = UDim2.new(1, -20, 0, 155)
infoBg.Position = UDim2.new(0, 10, 0, 68)
infoBg.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
infoBg.BorderSizePixel = 0
Instance.new("UICorner", infoBg).CornerRadius = UDim.new(0, 8)

local function makeInfoRow(y, labelText, valueText, valueColor)
    local l = Instance.new("TextLabel", infoBg)
    l.Size = UDim2.new(0.55, 0, 0, 22)
    l.Position = UDim2.new(0, 10, 0, y)
    l.BackgroundTransparency = 1
    l.Text = labelText
    l.TextColor3 = Color3.fromRGB(150, 150, 150)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left

    local v = Instance.new("TextLabel", infoBg)
    v.Size = UDim2.new(0.45, -10, 0, 22)
    v.Position = UDim2.new(0.55, 0, 0, y)
    v.BackgroundTransparency = 1
    v.Text = valueText
    v.TextColor3 = valueColor or Color3.fromRGB(255, 255, 255)
    v.TextSize = 12
    v.Font = Enum.Font.GothamBold
    v.TextXAlignment = Enum.TextXAlignment.Right
    return v
end

local bestNameLabel = makeInfoRow(5, "Best Found:", "None", Color3.fromRGB(255, 200, 50))
local bestIncLabel = makeInfoRow(27, "Best Income:", "0", Color3.fromRGB(50, 255, 100))
local collectedLabel = makeInfoRow(49, "Collected:", "0", Color3.fromRGB(100, 200, 255))
local placedLabel = makeInfoRow(71, "Placed:", "0", Color3.fromRGB(100, 200, 255))
local soldLabel = makeInfoRow(93, "Sold:", "0", Color3.fromRGB(255, 100, 100))
local currentActionLabel = makeInfoRow(115, "Action:", "Waiting...", Color3.fromRGB(200, 200, 200))
local indexLabel = makeInfoRow(137, "Index Claims:", "0", Color3.fromRGB(255, 150, 255))

-- Toggles
local togglesY = 230
local function makeToggle(text, default, callback)
    local f = Instance.new("Frame", mainFrame)
    f.Size = UDim2.new(1, -20, 0, 26)
    f.Position = UDim2.new(0, 10, 0, togglesY)
    f.BackgroundTransparency = 1
    togglesY = togglesY + 28

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.7, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 200)
    l.TextSize = 12
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 44, 0, 20)
    btn.Position = UDim2.new(1, -44, 0.5, -10)
    btn.BackgroundColor3 = default and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

    local on = default
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.BackgroundColor3 = on and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        btn.Text = on and "ON" or "OFF"
        callback(on)
    end)
end

makeToggle("Auto Place in Pods", CONFIG.AutoPlace, function(v) CONFIG.AutoPlace = v end)
makeToggle("Auto Sell (not place)", CONFIG.AutoSell, function(v) CONFIG.AutoSell = v end)
makeToggle("Auto Claim Index", CONFIG.AutoIndex, function(v) CONFIG.AutoIndex = v end)

-- Start/Stop
local startBtn = Instance.new("TextButton", mainFrame)
startBtn.Size = UDim2.new(1, -20, 0, 40)
startBtn.Position = UDim2.new(0, 10, 0, 360)
startBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
startBtn.Text = "START AUTO FARM"
startBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
startBtn.TextSize = 16
startBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0, 10)

-- Min income
local minF = Instance.new("Frame", mainFrame)
minF.Size = UDim2.new(1, -20, 0, 24)
minF.Position = UDim2.new(0, 10, 0, 410)
minF.BackgroundTransparency = 1

local minL = Instance.new("TextLabel", minF)
minL.Size = UDim2.new(0.5, 0, 1, 0)
minL.BackgroundTransparency = 1
minL.Text = "Min Income:"
minL.TextColor3 = Color3.fromRGB(150, 150, 150)
minL.TextSize = 12
minL.Font = Enum.Font.Gotham
minL.TextXAlignment = Enum.TextXAlignment.Left

local minBox = Instance.new("TextBox", minF)
minBox.Size = UDim2.new(0.5, -5, 1, 0)
minBox.Position = UDim2.new(0.5, 5, 0, 0)
minBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
minBox.Text = "0"
minBox.TextColor3 = Color3.fromRGB(255, 255, 255)
minBox.TextSize = 12
minBox.Font = Enum.Font.Gotham
minBox.ClearTextOnFocus = false
Instance.new("UICorner", minBox).CornerRadius = UDim.new(0, 6)
minBox.FocusLost:Connect(function()
    local n = tonumber(minBox.Text)
    if n then CONFIG.MinIncome = n end
end)

-- Drag
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
mainFrame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)
mainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- ==================== UPDATE UI ====================
local function fmtMoney(n)
    if n >= 1e12 then return string.format("%.2fT", n/1e12)
    elseif n >= 1e9 then return string.format("%.2fB", n/1e9)
    elseif n >= 1e6 then return string.format("%.2fM", n/1e6)
    elseif n >= 1e3 then return string.format("%.2fK", n/1e3)
    else return tostring(math.floor(n)) end
end

local function updateUI()
    statusLabel.Text = state.running and "Status: RUNNING" or "Status: STOPPED"
    statusLabel.TextColor3 = state.running and Color3.fromRGB(50, 255, 100) or Color3.fromRGB(255, 100, 100)
    bestNameLabel.Text = state.bestName
    bestIncLabel.Text = fmtMoney(state.bestIncome)
    collectedLabel.Text = tostring(state.collected)
    placedLabel.Text = tostring(state.placed)
    soldLabel.Text = tostring(state.sold)
    currentActionLabel.Text = state.currentAction
end

-- ==================== KEY FIX #1: AUTO COLLECT ====================
-- Check if we actually have the brainrot tool
local function hasBrainrotTool()
    local char = player.Character
    if char then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("BytesCode") ~= nil then
                return true, child
            end
        end
    end
    for _, child in ipairs(player.Backpack:GetChildren()) do
        if child:IsA("Tool") and child:GetAttribute("BytesCode") ~= nil then
            return true, child
        end
    end
    return false, nil
end

local function tryCollect(hitbox)
    if not hitbox.Parent then return false end

    local hrp = getHRP()
    if not hrp then return false end

    -- Check we don't already have one
    local hadTool = hasBrainrotTool()

    for attempt = 1, CONFIG.CollectRetries do
        if state.cancelled then return false end
        if not hitbox.Parent then return false end

        -- Teleport ON TOP of the hitbox
        state.currentAction = "Teleporting to brainrot (try " .. attempt .. ")"
        updateUI()
        hrp.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 4, 0))

        if waitWithCancel(0.4) then return false end
        if not hitbox.Parent then return true end

        -- Find prompt
        local attach = hitbox:FindFirstChild("Attachment")
        local prompt = attach and attach:FindFirstChild("ProximityPrompt")
        if not prompt then
            state.currentAction = "No prompt found, retrying..."
            updateUI()
            if waitWithCancel(0.5) then return false end
            continue
        end

        -- KEY FIX: Use executor's fireproximityprompt for reliability
        state.currentAction = "Triggering prompt..."
        updateUI()

        local success = pcall(function()
            -- Method 1: Executor function (most reliable)
            fireproximityprompt(prompt)
        end)

        if not success then
            -- Fallback: manual input simulation
            prompt:InputHoldBegin()
            if waitWithCancel(prompt.HoldDuration + 0.3) then
                prompt:InputHoldEnd()
                return false
            end
            prompt:InputHoldEnd()
        end

        -- Wait for collection
        if waitWithCancel(CONFIG.PromptWaitTime) then return false end

        -- Verify: Check if brainrot disappeared AND we got a tool
        if not hitbox.Parent then
            -- Double-check we have the tool
            local hasTool, tool = hasBrainrotTool()
            if hasTool then
                state.currentAction = "Collected: " .. (tool:GetAttribute("Name") or "Brainrot")
                updateUI()
                return true
            else
                -- Someone else got it probably
                state.currentAction = "Brainrot gone but no tool?"
                updateUI()
                return true -- still counts as "collected" (it's gone)
            end
        end

        -- Still there? Try again
        state.currentAction = "Retrying collect..."
        updateUI()
        if waitWithCancel(0.3) then return false end
    end

    return false
end

-- ==================== PLACE / SELL ====================
local function placeBrainrotInPod()
    local plot = getMyPlot()
    if not plot then
        state.currentAction = "No plot found!"
        updateUI()
        return false
    end

    local pod, podPos = getEmptyPod(plot)
    if not pod then
        state.currentAction = "No empty pods!"
        updateUI()
        return false
    end

    state.currentAction = "Returning to plot..."
    updateUI()
    local hrp = getHRP()
    if hrp then
        hrp.CFrame = CFrame.new(podPos + Vector3.new(0, 5, 0))
    end

    if waitWithCancel(0.6) then return false end

    local basePart = pod:FindFirstChild("BasePart")
    if not basePart then return false end
    local pps = basePart:FindFirstChild("PlacePickUpSwap")
    if not pps then return false end
    local prompt = pps:FindFirstChild("PlacePickUpSwapPrompt")
    if not prompt then return false end

    state.currentAction = "Placing brainrot..."
    updateUI()

    pcall(function() fireproximityprompt(prompt) end)
    if waitWithCancel(prompt.HoldDuration + 0.5) then return false end

    state.placed = state.placed + 1
    return true
end

local function sellBrainrots()
    state.currentAction = "Selling all..."
    updateUI()
    Remotes.SellBrainrot:FireServer("All")
    if waitWithCancel(1) then return end
    state.sold = state.sold + 1
end

-- ==================== KEY FIX #2: AUTO INDEX ====================
-- Need to get server response, then fire claims
local indexClaims = 0

local function claimIndexRewards()
    if not CONFIG.AutoIndex then return end

    state.currentAction = "Checking index..."
    updateUI()

    -- Request index data
    local indexData = nil
    local connection = nil

    -- Connect listener BEFORE firing
    connection = Remotes.NewBrainrotIndex.OnClientEvent:Connect(function(data)
        indexData = data
    end)

    Remotes.NewBrainrotIndex:FireServer()

    -- Wait for response (with cancel check)
    local waited = 0
    while not indexData and waited < 3 do
        if state.cancelled then
            if connection then connection:Disconnect() end
            return
        end
        task.wait(0.2)
        waited = waited + 0.2
    end

    if connection then connection:Disconnect() end
    if not indexData then
        state.currentAction = "No index data received"
        updateUI()
        return
    end

    -- Parse and claim
    local claimsMade = 0
    for brainrotName, mutations in pairs(indexData) do
        if state.cancelled then break end
        for mutation, info in pairs(mutations) do
            if type(info) == "table" and info.Claimable == true then
                Remotes.NewBrainrotIndex.ClaimBrainrotIndex:FireServer(brainrotName, mutation)
                claimsMade = claimsMade + 1
                indexClaims = indexClaims + 1
                indexLabel.Text = tostring(indexClaims)
                state.currentAction = "Claimed: " .. brainrotName .. " (" .. mutation .. ")"
                updateUI()
                if waitWithCancel(0.3) then return end
            end
        end
    end

    if claimsMade == 0 then
        state.currentAction = "No claimable rewards"
    else
        state.currentAction = "Claimed " .. claimsMade .. " rewards!"
    end
    updateUI()
end

-- ==================== MAIN LOOP ====================
local function runCycle()
    if state.cancelled then return end

    -- Step 1: Scan
    state.currentAction = "Scanning..."
    updateUI()

    local brainrots = scanBrainrots()
    if #brainrots == 0 then
        state.currentAction = "No brainrots on map"
        updateUI()
        return
    end

    local best = brainrots[1]
    state.bestName = best.Name
    state.bestIncome = best.Income
    state.currentAction = "Target: " .. best.Name .. " (" .. fmtMoney(best.Income) .. ")"
    updateUI()

    -- Step 2: Collect
    local success = tryCollect(best.Hitbox)
    if not success then
        state.currentAction = "Failed to collect"
        updateUI()
        return
    end

    state.collected = state.collected + 1
    updateUI()
    if waitWithCancel(0.3) then return end

    -- Step 3: Place or sell
    if CONFIG.AutoSell then
        sellBrainrots()
    elseif CONFIG.AutoPlace then
        local placed = placeBrainrotInPod()
        if not placed then
            state.currentAction = "Could not place, selling instead..."
            updateUI()
            sellBrainrots()
        end
    end

    if waitWithCancel(0.3) then return end

    -- Step 4: Claim index
    if CONFIG.AutoIndex then
        claimIndexRewards()
    end
end

-- ==================== START / STOP ====================
local loopRunning = false

local function startFarm()
    if loopRunning then return end
    state.running = true
    state.cancelled = false
    loopRunning = true
    startBtn.Text = "STOP AUTO FARM"
    startBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    updateUI()

    task.spawn(function()
        while not state.cancelled do
            runCycle()
            if state.cancelled then break end
            state.currentAction = "Waiting before next cycle..."
            updateUI()
            if waitWithCancel(2) then break end
        end
        loopRunning = false
        state.running = false
        startBtn.Text = "START AUTO FARM"
        startBtn.BackgroundColor3 = Color3.fromRGB(50, 180, 50)
        state.currentAction = "Stopped"
        updateUI()
    end)
end

local function stopFarm()
    state.cancelled = true
    state.running = false
    state.currentAction = "Stopping..."
    updateUI()
    -- The loop will exit on next cancel check
end

startBtn.MouseButton1Click:Connect(function()
    if state.running then
        stopFarm()
    else
        startFarm()
    end
end)

updateUI()
print("[RBB Auto Farm v2] Loaded! Fixed: collect, index, stop.")
