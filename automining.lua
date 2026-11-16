-- CRYSTAL AUTO MINING + MBG FLOATING PANEL

-- Mining logic retained: safe teleport, 3 hits per crystal, HP verification.

-- Equip before teleport; trigger mining on arrival while respecting the tool cooldown.



local Players = game:GetService("Players")

local CoreGui = game:GetService("CoreGui")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")

local UserInputService = game:GetService("UserInputService")



local player = Players.LocalPlayer

local folder = workspace:WaitForChild("MapContent"):WaitForChild("Crystals")

local guiParent = (gethui and gethui()) or CoreGui



-- SETTINGS

local DISTANCE = 2.5

local ROOT_HEIGHT = 3

local HIT_DELAY = 1.6

local PICKAXE_COOLDOWN = 1.5 -- cooldown lokal Basic Pickaxe

local TELEPORT_SETTLE = 0.05 -- jeda minimum setelah teleport

local EQUIP_SETTLE = 0.25 -- equip dilakukan sebelum teleport

local NEXT_CRYSTAL_DELAY = 0.5 -- jeda setelah crystal terakhir selesai

local HP_REQUIRED = 3



local BRAND_ICON = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/MBGLogo.jpeg"



local running = false

local noAnimation = false

local animationConnection

local pendingSell = false

local sellBusy = false

local autoSellRunning = false

local autoSellBusy = false

local destroyed = false

local lastPickaxeActivateAt = -math.huge



local old = guiParent:FindFirstChild("CrystalAutoMining")

if old then old:Destroy() end



-- SELL REMOTE

local SellCrystal = ReplicatedStorage

    :WaitForChild("Events")

    :WaitForChild("RemoteFunction")

    :WaitForChild("SellCrystal")



-- CHARACTER / HP / TOOL

local function getCharacter()

    local char = player.Character or player.CharacterAdded:Wait()

    return char, char:WaitForChild("HumanoidRootPart"), char:WaitForChild("Humanoid")

end



local function getHP(crystal)

    if not crystal or not crystal.Parent then return 0 end

    for _, obj in ipairs(crystal:GetDescendants()) do

        if obj:IsA("TextLabel") then

            local hp = obj.Text:match("HP:%s*(%d+)")

            if hp then return tonumber(hp) end

        end

    end

    return nil

end



local function getPickaxe()

    local char = player.Character

    local backpack = player:FindFirstChildOfClass("Backpack")

    local tool = char and char:FindFirstChild("Basic Pickaxe")

    if not tool and backpack then tool = backpack:FindFirstChild("Basic Pickaxe") end

    return tool

end



-- Riwayat berdasarkan posisi spawn, bukan Instance yang bisa dibuat ulang.
local REVISIT_COOLDOWN = 90
local POSITION_BUCKET_SIZE = 4
local lastMinedAtByPosition = {}

local function getPositionKey(crystal)
    local p = crystal.Position
    return string.format(
        "%d:%d:%d",
        math.floor(p.X / POSITION_BUCKET_SIZE + 0.5),
        math.floor(p.Y / POSITION_BUCKET_SIZE + 0.5),
        math.floor(p.Z / POSITION_BUCKET_SIZE + 0.5)
    )
end

local function refreshTargets()
    local targets = {}
    local now = os.clock()
    local seenPositions = {}

    -- Tetap scan folder Crystal yang dipakai versi terbaik.
    for _, crystal in ipairs(folder:GetChildren()) do
        if crystal:IsA("BasePart")
            and crystal.Transparency < 0.95
            and crystal:IsDescendantOf(workspace)
            and getHP(crystal) ~= nil
            and getHP(crystal) > 0 then

            local key = getPositionKey(crystal)
            if not seenPositions[key] then
                seenPositions[key] = true
                table.insert(targets, {
                    part = crystal,
                    positionKey = key,
                    lastVisit = lastMinedAtByPosition[key] or 0
                })
            end
        end
    end

    -- Utamakan lokasi yang belum ditambang dalam masa cooldown.
    local fresh, recent = {}, {}
    for _, item in ipairs(targets) do
        if now - item.lastVisit >= REVISIT_COOLDOWN then
            table.insert(fresh, item)
        else
            table.insert(recent, item)
        end
    end

    -- Acak target fresh. Jika semuanya recent, pilih yang paling lama ditambang.
    for i = #fresh, 2, -1 do
        local j = math.random(i)
        fresh[i], fresh[j] = fresh[j], fresh[i]
    end
    table.sort(recent, function(a, b)
        return a.lastVisit < b.lastVisit
    end)

    local chosen = (#fresh > 0) and fresh or recent
    local result = {}
    for _, item in ipairs(chosen) do
        table.insert(result, {
            part = item.part,
            positionKey = item.positionKey
        })
    end
    return result
end

-- SAFE TELEPORT POSITION

local function checkGround(position, target, character)

    local params = RaycastParams.new()

    params.FilterType = Enum.RaycastFilterType.Exclude

    params.FilterDescendantsInstances = {character, folder}

    params.RespectCanCollide = true



    local offsets = {

        Vector3.new(0, 0, 0), Vector3.new(1, 0, 0),

        Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1),

        Vector3.new(0, 0, -1)

    }



    local centerGround

    for i, offset in ipairs(offsets) do

        local origin = Vector3.new(

            position.X + offset.X, target.Position.Y + 30,

            position.Z + offset.Z

        )

        local result = workspace:Raycast(origin, Vector3.new(0, -150, 0), params)

        if not result or result.Normal.Y < 0.65 then return nil end

        if math.abs(result.Position.Y - target.Position.Y) > (target.Size.Y / 2 + 7) then

            return nil

        end

        if i == 1 then

            centerGround = result.Position.Y

        elseif math.abs(result.Position.Y - centerGround) > 3 then

            return nil

        end

    end

    return centerGround

end



local function getSafePosition(target, character, root)

    local directions = {

        Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),

        Vector3.new(0, 0, 1), Vector3.new(0, 0, -1)

    }

    local candidates = {}

    for _, direction in ipairs(directions) do

        local offset = Vector3.new(

            direction.X * (target.Size.X / 2 + DISTANCE),

            0,

            direction.Z * (target.Size.Z / 2 + DISTANCE)

        )

        local worldPosition = target.CFrame:PointToWorldSpace(offset)

        local groundY = checkGround(worldPosition, target, character)

        if groundY then

            table.insert(candidates, Vector3.new(

                worldPosition.X, groundY + ROOT_HEIGHT, worldPosition.Z

            ))

        end

    end

    table.sort(candidates, function(a, b)

        return (a - root.Position).Magnitude < (b - root.Position).Magnitude

    end)

    return candidates[1]

end



-- GUI

local gui = Instance.new("ScreenGui")

gui.Name = "CrystalAutoMining"

gui.ResetOnSpawn = false

gui.Parent = guiParent



local frame = Instance.new("Frame")

frame.Size = UDim2.fromOffset(300, 325)

frame.Position = UDim2.new(0.5, -150, 0.65, 0)

frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)

frame.BorderSizePixel = 0

frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)



local topBar = Instance.new("Frame")

topBar.Size = UDim2.new(1, 0, 0, 36)

topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

topBar.BorderSizePixel = 0

topBar.Parent = frame

Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)



local topFix = Instance.new("Frame")

topFix.Size = UDim2.new(1, 0, 0, 8)

topFix.Position = UDim2.new(0, 0, 1, -8)

topFix.BackgroundColor3 = topBar.BackgroundColor3

topFix.BorderSizePixel = 0

topFix.Parent = topBar



local title = Instance.new("TextLabel")

title.Size = UDim2.new(1, -85, 1, 0)

title.Position = UDim2.fromOffset(10, 0)

title.BackgroundTransparency = 1

title.Text = "CRYSTAL AUTO MINING"

title.TextColor3 = Color3.new(1, 1, 1)

title.Font = Enum.Font.GothamBold

title.TextSize = 13

title.TextXAlignment = Enum.TextXAlignment.Left

title.Parent = topBar



local function makeWindowButton(text, xOffset, color)

    local b = Instance.new("TextButton")

    b.Size = UDim2.fromOffset(28, 22)

    b.Position = UDim2.new(1, xOffset, 0.5, -11)

    b.BackgroundColor3 = color

    b.Text = text

    b.TextColor3 = Color3.new(1, 1, 1)

    b.Font = Enum.Font.GothamBold

    b.TextSize = 12

    b.BorderSizePixel = 0

    b.Parent = topBar

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)

    return b

end



local minimizeButton = makeWindowButton("—", -58, Color3.fromRGB(60, 60, 60))

local exitButton = makeWindowButton("✕", -28, Color3.fromRGB(200, 50, 50))



local function makeButton(text, y, color)

    local b = Instance.new("TextButton")

    b.Size = UDim2.new(1, -20, 0, 35)

    b.Position = UDim2.fromOffset(10, y)

    b.Text = text

    b.BackgroundColor3 = color

    b.TextColor3 = Color3.new(1, 1, 1)

    b.TextSize = 13

    b.Font = Enum.Font.GothamBold

    b.BorderSizePixel = 0

    b.Parent = frame

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

    return b

end



local noAnimButton = makeButton("NO ANIMATION: OFF", 45, Color3.fromRGB(75, 75, 90))

local onButton = makeButton("ON MINING", 85, Color3.fromRGB(35, 150, 75))

local offButton = makeButton("OFF MINING", 125, Color3.fromRGB(160, 45, 45))

local sellButton = makeButton("SELL MANUAL", 165, Color3.fromRGB(20, 125, 55))

local autoSellButton = makeButton("AUTO SELL: OFF", 205, Color3.fromRGB(75, 75, 90))



local status = Instance.new("TextLabel")

status.Size = UDim2.new(1, -20, 0, 20)

status.Position = UDim2.fromOffset(10, 287)

status.BackgroundTransparency = 1

status.TextColor3 = Color3.fromRGB(220, 220, 220)

status.TextSize = 11

status.Font = Enum.Font.Gotham

status.Text = "READY"

status.Parent = frame



-- WEBHOOK AUTO SELL: gaya label + kolom mengikuti WEBHOOK SECRET FISH MBG.

-- Panah membuka/menutup kolom; URL tetap tersimpan saat kolom disembunyikan.

local webhookHeader = Instance.new("TextButton")

webhookHeader.Name = "WebhookAutoSellHeader"

webhookHeader.Size = UDim2.new(1, -20, 0, 16)

webhookHeader.Position = UDim2.fromOffset(10, 237)

webhookHeader.BackgroundTransparency = 1

webhookHeader.BorderSizePixel = 0

webhookHeader.Text = "💎 Webhook Auto Sell"

webhookHeader.TextColor3 = Color3.fromRGB(130, 130, 130)

webhookHeader.Font = Enum.Font.Gotham

webhookHeader.TextSize = 10

webhookHeader.TextXAlignment = Enum.TextXAlignment.Left

webhookHeader.Parent = frame



local webhookArrow = Instance.new("TextLabel")

webhookArrow.Name = "Arrow"

webhookArrow.Size = UDim2.fromOffset(18, 16)

webhookArrow.Position = UDim2.new(1, -18, 0, 0)

webhookArrow.BackgroundTransparency = 1

webhookArrow.Text = "▼"

webhookArrow.TextColor3 = Color3.fromRGB(130, 130, 130)

webhookArrow.Font = Enum.Font.GothamBold

webhookArrow.TextSize = 9

webhookArrow.Parent = webhookHeader



local webhookInput = Instance.new("TextBox")

webhookInput.Name = "AutoSellWebhookURL"

webhookInput.Size = UDim2.new(1, -20, 0, 28)

webhookInput.Position = UDim2.fromOffset(10, 255)

webhookInput.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

webhookInput.TextColor3 = Color3.fromRGB(220, 220, 220)

webhookInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)

webhookInput.PlaceholderText = "Paste webhook auto sell..."

webhookInput.Text = ""

webhookInput.TextSize = 10

webhookInput.Font = Enum.Font.Gotham

webhookInput.ClearTextOnFocus = false

webhookInput.BorderSizePixel = 0

webhookInput.TextXAlignment = Enum.TextXAlignment.Left

webhookInput.ClipsDescendants = true

webhookInput.Parent = frame

Instance.new("UICorner", webhookInput).CornerRadius = UDim.new(0, 6)

local webhookInputPadding = Instance.new("UIPadding")

webhookInputPadding.PaddingLeft = UDim.new(0, 8)

webhookInputPadding.PaddingRight = UDim.new(0, 8)

webhookInputPadding.Parent = webhookInput



local webhookExpanded = true

webhookHeader.MouseButton1Click:Connect(function()

    webhookExpanded = not webhookExpanded

    webhookInput.Visible = webhookExpanded

    webhookArrow.Text = webhookExpanded and "▼" or "▶"

end)



-- NO ANIMATION

local function stopMiningAnimations()

    local char = player.Character

    if not char then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")

    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do

        if track.Name:lower():find("mining") then

            track:Stop(0)

        end

    end

end



local function setNoAnimation(enabled)

    noAnimation = enabled

    if animationConnection then

        animationConnection:Disconnect()

        animationConnection = nil

    end



    if enabled then

        local char = player.Character

        local humanoid = char and char:FindFirstChildOfClass("Humanoid")

        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

        if animator then

            animationConnection = animator.AnimationPlayed:Connect(function(track)

                if noAnimation and track.Name:lower():find("mining") then

                    track:Stop(0)

                end

            end)

            stopMiningAnimations()

        end

    end



    noAnimButton.Text = enabled and "NO ANIMATION: ON" or "NO ANIMATION: OFF"

    noAnimButton.BackgroundColor3 = enabled

        and Color3.fromRGB(25, 130, 140)

        or Color3.fromRGB(75, 75, 90)

end



-- FLOATING MBG LOGO (same branding and dimensions as MBG Webhook)

local floatLogo = Instance.new("ImageButton")

floatLogo.Name = "MBGLogo"

floatLogo.Size = UDim2.fromOffset(68, 68)

floatLogo.Position = UDim2.new(0, 20, 0, 90)

floatLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

floatLogo.ScaleType = Enum.ScaleType.Crop

floatLogo.BorderSizePixel = 0

floatLogo.ZIndex = 5

floatLogo.Parent = gui

Instance.new("UICorner", floatLogo).CornerRadius = UDim.new(0, 7)



local logoImage = BRAND_ICON

local getAsset = getcustomasset or getsynasset

local requestFunc = (syn and syn.request) or (http and http.request)

    or http_request or (fluxus and fluxus.request) or request



if getAsset and writefile and requestFunc then

    local cachePath = "MBGLogo_cache.jpeg"

    local ok, assetUri = pcall(function()

        if not (isfile and isfile(cachePath)) then

            local response = requestFunc({Url = BRAND_ICON, Method = "GET"})

            if not response or (response.StatusCode and response.StatusCode >= 400)

                or type(response.Body) ~= "string" or #response.Body == 0 then

                error("Unduhan logo gagal")

            end

            writefile(cachePath, response.Body)

        end

        return getAsset(cachePath)

    end)

    if ok and type(assetUri) == "string" then

        logoImage = assetUri

    else

        warn("[MBG] Logo lokal tidak tersedia:", assetUri)

    end

end

floatLogo.Image = logoImage



local floatStroke = Instance.new("UIStroke")

floatStroke.Color = Color3.fromRGB(50, 50, 50)

floatStroke.Thickness = 2

floatStroke.Parent = floatLogo



local floatStatusDot = Instance.new("Frame")

floatStatusDot.Size = UDim2.fromOffset(18, 18)

floatStatusDot.Position = UDim2.new(1, -18, 1, -18)

floatStatusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)

floatStatusDot.BorderSizePixel = 0

floatStatusDot.ZIndex = 6

floatStatusDot.Parent = floatLogo

Instance.new("UICorner", floatStatusDot).CornerRadius = UDim.new(1, 0)



local dotStroke = Instance.new("UIStroke")

dotStroke.Color = Color3.fromRGB(20, 20, 20)

dotStroke.Thickness = 2

dotStroke.Parent = floatStatusDot



local function setFloatStatus(active)

    floatStatusDot.BackgroundColor3 = active

        and Color3.fromRGB(0, 220, 100)

        or Color3.fromRGB(255, 60, 60)

    floatStroke.Color = active

        and Color3.fromRGB(0, 220, 100)

        or Color3.fromRGB(50, 50, 50)

end



-- DRAG FLOATING LOGO + CLICK TO RESTORE

local floatDragging, floatMoved = false, false

local floatDragStart, floatStartPos



floatLogo.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1

        or input.UserInputType == Enum.UserInputType.Touch then

        floatDragging = true

        floatMoved = false

        floatDragStart = input.Position

        floatStartPos = floatLogo.Position

    end

end)



floatLogo.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1

        or input.UserInputType == Enum.UserInputType.Touch then

        floatDragging = false

        if not floatMoved then frame.Visible = not frame.Visible end

    end

end)



UserInputService.InputChanged:Connect(function(input)

    if floatDragging and (

        input.UserInputType == Enum.UserInputType.MouseMovement

        or input.UserInputType == Enum.UserInputType.Touch

    ) then

        local delta = input.Position - floatDragStart

        if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then

            floatMoved = true

        end

        floatLogo.Position = UDim2.new(

            floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,

            floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y

        )

    end

end)



-- DRAG PANEL BY HEADER

local panelDragging, panelDragStart, panelStartPos = false, nil, nil

topBar.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        panelDragging = true

        panelDragStart = input.Position

        panelStartPos = frame.Position

    end

end)

topBar.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 then

        panelDragging = false

    end

end)

UserInputService.InputChanged:Connect(function(input)

    if panelDragging and input.UserInputType == Enum.UserInputType.MouseMovement then

        local delta = input.Position - panelDragStart

        frame.Position = UDim2.new(

            panelStartPos.X.Scale, panelStartPos.X.Offset + delta.X,

            panelStartPos.Y.Scale, panelStartPos.Y.Offset + delta.Y

        )

    end

end)



-- WAIT

local function waitActive(seconds)

    local elapsed = 0

    while elapsed < seconds do

        if not running then return false end

        task.wait(0.05)

        elapsed += 0.05

    end

    return running

end



-- ACTIVATE PICKAXE: one immediate attempt, then at most one cooldown retry.

-- The supplied Basic Pickaxe LocalScript has a 1.5s local lock; calls during

-- that lock are ignored. This queues the next valid activation without spam.

local function activatePickaxe()

    if not running then return false end



    local now = os.clock()

    local elapsed = now - lastPickaxeActivateAt

    if elapsed < PICKAXE_COOLDOWN then

        -- Attempt immediately after teleport; if the tool is still locked,

        -- wait only for its known remaining cooldown and activate once.

        local remaining = PICKAXE_COOLDOWN - elapsed

        if remaining > 0 and not waitActive(remaining) then return false end

    end



    if not running then return false end

    local tool = getPickaxe()

    if not tool then return false end



    tool:Activate()

    lastPickaxeActivateAt = os.clock()

    if noAnimation then stopMiningAnimations() end

    return true

end



-- MINE ONE CRYSTAL: equip before teleport so the first valid hit can fire

-- immediately on arrival (subject only to the pickaxe's built-in cooldown).

local function mineOneCrystal(target)
    if not running or not target or not target.Parent then return false end

    local initialHP = getHP(target)
    if not initialHP or initialHP <= 0 then return false end

    local character, root, humanoid = getCharacter()
    local tool = getPickaxe()
    if not tool then
        status.Text = "Basic Pickaxe tidak ditemukan"
        return false
    end

    if tool.Parent ~= character then
        humanoid:EquipTool(tool)
        if not waitActive(EQUIP_SETTLE) then return false end
        character = player.Character or character
        character, root, humanoid = getCharacter()
    end

    local destination = getSafePosition(target, character, root)
    if not destination then
        status.Text = "Lokasi tidak aman - skip"
        return false
    end

    root.CFrame = CFrame.lookAt(
        destination,
        Vector3.new(target.Position.X, destination.Y, target.Position.Z)
    )
    status.Text = "Teleport selesai - menyiapkan 3 hit"
    if not waitActive(TELEPORT_SETTLE) then return false end

    -- Jangan pindah hanya karena label HP terlambat diperbarui.
    -- Kirim 3 aktivasi berurutan dengan jeda sesuai cooldown pickaxe.
    for hit = 1, 3 do
        if not running then return false end
        if not target.Parent then
            status.Text = "Crystal sudah hilang"
            return true
        end

        local currentHP = getHP(target)
        if currentHP and currentHP <= 0 then
            status.Text = "Crystal selesai"
            return true
        end

        status.Text = "Mining crystal - hit " .. hit .. "/3"
        if not activatePickaxe() then
            status.Text = "Pickaxe belum siap - mining dihentikan"
            return false
        end

        if hit < 3 then
            if not waitActive(HIT_DELAY) then return false end
            -- HP boleh terlambat berubah; jangan membatalkan rangkaian hit.
            if not target.Parent then
                status.Text = "Crystal selesai"
                return true
            end
            local observedHP = getHP(target)
            if observedHP and observedHP <= 0 then
                status.Text = "Crystal selesai"
                return true
            end
        else
            task.wait(NEXT_CRYSTAL_DELAY)
            status.Text = "3 hit dikirim - lanjut target berikutnya"
            return true
        end
    end

    return false
end



-- MAIN MINING LOOP

local function miningLoop()

    while running do

        local targets = refreshTargets()

        if #targets == 0 then

            status.Text = "Menunggu Crystal HP 3"

            if not waitActive(1.5) then break end

        else

            local found = false

            for _, targetInfo in ipairs(targets) do

                if not running then break end

                local target = targetInfo.part

                if target and target.Parent and getHP(target) == HP_REQUIRED then

                    found = true

                    local completed = mineOneCrystal(target)
                    if completed then
                        -- Catat setelah rangkaian mining selesai, bukan sebelum mulai.
                        lastMinedAtByPosition[targetInfo.positionKey] = os.clock()
                    end
                    break

                end

            end

            if not found and not waitActive(0.5) then break end

        end

    end

    if not destroyed then

        status.Text = "MINING OFF"

        onButton.Text = "ON MINING"

        setFloatStatus(false)

    end

end



-- SELL MANUAL: tetap dua tahap (check lalu confirm)

sellButton.MouseButton1Click:Connect(function()

    if sellBusy then return end

    sellBusy = true



    if not pendingSell then

        status.Text = "Memeriksa hasil penjualan..."

        local success, cash, bonus, total = pcall(function()

            return SellCrystal:InvokeServer("CheckCrystal", "Sell All")

        end)



        if not success then

            status.Text = "Gagal memeriksa penjualan"

            warn("Sell check error:", cash)

            sellBusy = false

            return

        end



        if cash and bonus and total then

            pendingSell = true

            sellButton.Text = "CONFIRM MANUAL SELL"

            status.Text = "Cash " .. tostring(cash)

                .. " | Bonus " .. tostring(bonus)

                .. " | Crystal " .. tostring(total)

        else

            status.Text = "Tidak ada Crystal untuk dijual"

        end

        sellBusy = false

        return

    end



    status.Text = "Memproses penjualan manual..."

    local success, result = pcall(function()

        return SellCrystal:InvokeServer("SellCrystal", "Sell All")

    end)



    pendingSell = false

    sellButton.Text = "SELL MANUAL"

    if success then

        status.Text = "Penjualan manual dikirim"

    else

        status.Text = "Penjualan manual gagal"

        warn("Manual sell error:", result)

    end

    sellBusy = false

end)



-- AUTO SELL WEBHOOK (format embed MBG)

-- Webhook URL diisi melalui kolom GUI. Thumbnail memakai avatar headshot Roblox.

-- Avatar Roblox + watermark MBG melalui Cloudinary (mengikuti WEBHOOK MBG Fish It).

local CLOUDINARY_CLOUD_NAME = "pd5qqwr4"

local CLOUDINARY_WATERMARK_ID = "D3770010-C528-4FA2-B72B-98C0D25646B5"



local function base64EncodeUrl(url)

    local ok, result = pcall(function()

        if syn and syn.crypt and syn.crypt.base64 and syn.crypt.base64.encode then

            return syn.crypt.base64.encode(url)

        end

        if crypt and crypt.base64 and crypt.base64encode then

            return crypt.base64encode(url)

        end

        if base64 and base64.encode then

            return base64.encode(url)

        end

        error("Base64 encoder unavailable")

    end)

    return ok and result or nil

end



local function getAvatarThumbnail()

    if not requestFunc then return nil end



    local ok, response = pcall(function()

        return requestFunc({

            Url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="

                .. tostring(player.UserId)

                .. "&size=420x420&format=Png&isCircular=false",

            Method = "GET",

            Headers = {["Content-Type"] = "application/json"},

        })

    end)

    if not ok or type(response) ~= "table" then return nil end



    local raw = response.Body or response.body

    if not raw or raw == "" then return nil end



    local decodedOK, decoded = pcall(function()

        return HttpService:JSONDecode(raw)

    end)

    if not decodedOK or type(decoded) ~= "table"

        or type(decoded.data) ~= "table" or not decoded.data[1] then

        return nil

    end



    local avatarUrl = decoded.data[1].imageUrl

    if not avatarUrl or avatarUrl == "" then return nil end



    local encodedAvatar = base64EncodeUrl(avatarUrl)

    if not encodedAvatar then

        warn("[M B G Avatar] Base64 encoder tidak tersedia, fallback ke avatar Roblox.")

        return avatarUrl

    end



    -- Watermark MBG sebagai background/base, avatar Roblox sebagai overlay/front.

    -- Pola URL ini disamakan dengan GetAvatarUrlById pada WEBHOOK MBG Fish It.

    return "https://res.cloudinary.com/" .. CLOUDINARY_CLOUD_NAME

        .. "/image/upload/c_fill,w_420,h_420"

        .. "/l_fetch:" .. encodedAvatar

        .. "/c_fill,w_420,h_420/fl_layer_apply"

        .. "/" .. CLOUDINARY_WATERMARK_ID

end



-- Game ini menyimpan saldo utama pada profile.Uang, bukan leaderstats.

-- TopBar game mengambilnya melalui PlayerList:InvokeServer("GetFullProfile", LocalPlayer).

local PlayerListRemote = ReplicatedStorage:WaitForChild("Events")

    :WaitForChild("RemoteFunction"):WaitForChild("PlayerList")



local function getCurrentMoney()

    local ok, profile = pcall(function()

        return PlayerListRemote:InvokeServer("GetFullProfile", player)

    end)

    if ok and type(profile) == "table" and profile.Uang ~= nil then

        return profile.Uang

    end



    -- Fallback bila profile remote sementara gagal.

    local leaderstats = player:FindFirstChild("leaderstats")

    if leaderstats then

        for _, obj in ipairs(leaderstats:GetDescendants()) do

            if (obj:IsA("IntValue") or obj:IsA("NumberValue") or obj:IsA("StringValue"))

                and ({cash=true,money=true,coins=true,coin=true,gold=true,duit=true,currency=true,balance=true})[obj.Name:lower()] then

                return obj.Value

            end

        end

    end

    return nil

end



local function parseGameNumber(value)

    if type(value) == "number" then return value end

    if type(value) ~= "string" then return tonumber(value) end

    local cleaned = value:gsub("[^%d,%.%-]", "")

    -- Tampilan game memakai titik sebagai pemisah ribuan (contoh 383.554).

    cleaned = cleaned:gsub("%.", ""):gsub(",", ".")

    return tonumber(cleaned)

end



local function formatRupiah(value)

    local number = tonumber(value)

    if not number then return tostring(value or "Tidak terbaca") end



    local rounded = math.floor(number + 0.5)

    local formatted = tostring(rounded):reverse():gsub("(%d%d%d)", "%1."):reverse()

    if formatted:sub(1, 1) == "." then

        formatted = formatted:sub(2)

    end

    return "Rp " .. formatted

end



local function sendAutoSellWebhook(cash, bonus, crystalTotal)

    local url = (webhookInput.Text or ""):match("^%s*(.-)%s*$")

    if url == "" then

        warn("[Crystal Auto Sell] Webhook URL belum diisi; notifikasi dilewati.")

        return

    end

    if not requestFunc then

        warn("[Crystal Auto Sell] Executor tidak menyediakan request function.")

        return

    end



    local cashNumber = parseGameNumber(cash)

    local bonusNumber = parseGameNumber(bonus)

    local saleMoney = (cashNumber and bonusNumber) and (cashNumber + bonusNumber) or nil



    -- Tunggu server menyelesaikan update saldo, lalu baca profile Uang dari server.

    task.wait(1)

    local currentMoney = getCurrentMoney()

    local avatarUrl = getAvatarThumbnail()



    local embed = {

        title = "💎 CRYSTAL AUTO SELL BERHASIL",

        description = "Penjualan crystal otomatis berhasil diproses.",

        color = 3066993,

        fields = {

            {

                name = "💰 TOTAL DUIT SAAT INI",

                value = "**" .. (currentMoney ~= nil and formatRupiah(currentMoney) or "Tidak terbaca dari client") .. "**",

                inline = false,

            },

            {

                name = "🪙 HASIL PENJUALAN SAAT INI",

                value = "**" .. (saleMoney and formatRupiah(saleMoney) or "Tidak tersedia") .. "**",

                inline = false,

            },

            {

                name = "📦 ITEM YANG TERJUAL",

                value = "**" .. tostring(crystalTotal) .. " Crystal**",

                inline = true,

            },

            {

                name = "💵 CASH",

                value = formatRupiah(cashNumber or cash),

                inline = true,

            },

            {

                name = "🎁 BONUS",

                value = formatRupiah(bonusNumber or bonus),

                inline = true,

            },

        },

        footer = { text = "Crystal Auto Mining • M B G" },

        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),

    }



    if avatarUrl and avatarUrl ~= "" then

        embed.thumbnail = { url = avatarUrl }

    end



    local body = {

        username = "M B G • Auto Mining Indo Hangout",

        embeds = {embed},

    }



    task.spawn(function()

        local ok, result = pcall(function()

            return requestFunc({

                Url = url,

                Method = "POST",

                Headers = {["Content-Type"] = "application/json"},

                Body = HttpService:JSONEncode(body),

            })

        end)



        if not ok then

            warn("[Crystal Auto Sell] Webhook gagal dikirim:", result)

        elseif type(result) == "table" then

            local statusCode = result.StatusCode or result.status_code

            if statusCode and (statusCode < 200 or statusCode >= 300) then

                warn("[Crystal Auto Sell] Discord response:", statusCode, result.Body or result.body)

            end

        end

    end)

end



-- AUTO SELL: check + sell langsung, tanpa tombol konfirmasi; interval 60 detik

local function autoSellOnce()

    if autoSellBusy then return end

    autoSellBusy = true



    local checkOK, cash, bonus, total = pcall(function()

        return SellCrystal:InvokeServer("CheckCrystal", "Sell All")

    end)



    if not checkOK then

        warn("Auto sell check error:", cash)

        status.Text = "Auto Sell: gagal memeriksa"

        autoSellBusy = false

        return

    end



    if cash and bonus and total then

        local sellOK, result = pcall(function()

            return SellCrystal:InvokeServer("SellCrystal", "Sell All")

        end)

        if sellOK then

            status.Text = "Auto Sell berhasil | Crystal: " .. tostring(total)

            sendAutoSellWebhook(cash, bonus, total)

        else

            status.Text = "Auto Sell gagal"

            warn("Auto sell error:", result)

        end

    else

        status.Text = "Auto Sell: belum ada Crystal"

    end



    autoSellBusy = false

end



autoSellButton.MouseButton1Click:Connect(function()

    autoSellRunning = not autoSellRunning

    autoSellButton.Text = autoSellRunning and "AUTO SELL: ON" or "AUTO SELL: OFF"

    autoSellButton.BackgroundColor3 = autoSellRunning

        and Color3.fromRGB(20, 155, 45)

        or Color3.fromRGB(75, 75, 90)



    if autoSellRunning then

        status.Text = "Auto Sell aktif | interval 60 detik"

        task.spawn(function()

            while autoSellRunning and not destroyed do

                local elapsed = 0

                while elapsed < 60 and autoSellRunning and not destroyed do

                    task.wait(1)

                    elapsed += 1

                end

                if autoSellRunning and not destroyed then

                    autoSellOnce()

                end

            end

        end)

    else

        status.Text = "Auto Sell nonaktif"

    end

end)



-- BUTTONS

noAnimButton.MouseButton1Click:Connect(function()

    setNoAnimation(not noAnimation)

end)



onButton.MouseButton1Click:Connect(function()

    if running then return end

    running = true

    onButton.Text = "MINING ACTIVE"

    status.Text = "Memulai..."

    setFloatStatus(true)

    task.spawn(miningLoop)

end)



offButton.MouseButton1Click:Connect(function()

    running = false

    status.Text = "Menghentikan..."

    setFloatStatus(false)

end)



minimizeButton.MouseButton1Click:Connect(function()

    frame.Visible = false

end)



exitButton.MouseButton1Click:Connect(function()

    destroyed = true

    running = false

    autoSellRunning = false

    noAnimation = false

    if animationConnection then

        animationConnection:Disconnect()

        animationConnection = nil

    end

    gui:Destroy()

end)



player.CharacterAdded:Connect(function()

    task.wait(1)

    if noAnimation and not destroyed then

        setNoAnimation(true)

    end

end)



print("Crystal Auto Mining + MBG Floating Panel loaded")
