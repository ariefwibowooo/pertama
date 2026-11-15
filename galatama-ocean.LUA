-- ============================================================
-- M B G | GALATAMA ONLY
-- Hanya memantau enam ikan berpoin, menghitung mutasi dari nama ikan
-- yang dikirim game, mengirim detail ikan secret dan leaderboard ke dua webhook terpisah.
-- ============================================================

local HttpService    = game:GetService("HttpService")
local Players        = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local SCRIPT_ACTIVE = false
local GalatamaChatConnection = nil
local WEBHOOK_SECRET = ""
local WEBHOOK_LEADERBOARD = ""
local CONFIG_FILE = "MBG_Galatama_Config.json"
local BRAND_ICON = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/MBGLogo.jpeg"
local BRAND_NAME = "MAIN BARENG GENGZZZ"
local BRAND_LINK = "https://www.tiktok.com/@mainbarenggengz"

-- MEMBER LIST dari webhookutama.lua.txt (username/display -> Discord ID).
local MemberList = {
    { username = "bowojan821",       display = "TALON",                id = "219002813806673930" },
    { username = "strawvxntae",      display = "berry",                id = {"1472281518704693349", "219002813806673930"} },
    { username = "aangdul",          display = "Jiikakamulasatu",      id = "248297103971975169" },
    { username = "aangdulre",        display = "VermiOnie",            id = "248297103971975169" },
    { username = "Yokatsusu",        display = "Yoka",                 id = "1393227652806086676" },
    { username = "CoklatttSusuuuu",  display = "Yokanyawit",           id = "1393227652806086676" },
    { username = "starryipi",        display = "ipii",                 id = {"1318926237963391017", "219002813806673930"} },
    { username = "Chihiro_Lily",     display = "Ivy",                  id = {"1318926237963391017", "219002813806673930"} },
    { username = "konagaa",          display = "konagaa",              id = "573600670741954568" },
    { username = "heartymatcha1511", display = "gadis",                id = "760811175503593474" },
    { username = "Mahafii_11",       display = "Yunno",                id = "1032602143363960833" },
    { username = "notericarl",       display = "notericarl",           id = "760811175503593474" },
    { username = "CheeseBrgr7",      display = "bas",                  id = "1437068504456237116" },
    { username = "ItsMe_Nonaaa",     display = "vionique",             id = {"1377239165699231805", "1292331079734132740"} },
    { username = "nonna_naksecret1", display = "ALTNONA2",             id = {"1377239165699231805", "1292331079734132740"} },
    { username = "nonna_naksecret2", display = "ALTNONA3",             id = {"1377239165699231805", "1292331079734132740"} },
    { username = "yowpiaw",          display = "piyapiyopoyo",         id = "1377239165699231805" },
    { username = "flaycassey",       display = "Chizuenao",            id = "1377239165699231805" },
    { username = "Naxel200",         display = "Naxel20",              id = "248297103971975169" },
    { username = "Naxelll20",        display = "Naxelll20",            id = "248297103971975169" },
    { username = "nomxel20",        display = "nomxel20",             id = "248297103971975169" },
    { username = "Cabebandot",      display = "Hakari",                id = "444135915636391939" },
    { username = "Refrain_13",      display = "Ren",                   id = "1465026039666184263" },
    { username = "cizukeik999",     display = "cizukeik999",           id = "760811175503593474" },
    { username = "sweetyavocad0",   display = "Merraki",               id = "760811175503593474" },
    { username = "zzezestt",        display = "vessel",                 id = "1111713588520956005" },
    { username = "nonnaimup",       display = "NONA",                  id = {"1377239165699231805", "1292331079734132740"} },
    { username = "awrindu",         display = "Awrinndu",              id = {"1438450607349567488", "219002813806673930"} },
    { username = "Mie_ayam2802",    display = "Xyrooo",                id = {"893896145544282164", "219002813806673930"} },
    { username = "Cherryy0_0i",     display = "viii",                  id = "1454391668793938013" },
    { username = "Rens_1395",       display = "Rens",                  id = "1465026039666184263" },
    { username = "sumeringa",       display = "sumeringa",             id = "697060056163942430" },
    { username = "NolanMcatee",     display = "NolanMKC",              id = "1554445890142478399" },
    { username = "adultzy03",       display = "Arsya",                 id = "1514162263563698226" },
    { username = "Aris_syam",       display = "ARIS",                  id = "219002813806673930" },
    { username = "yann02026",       display = "Yann",                  id = "1477349802483257404" },
    { username = "makin2545",       display = "makin2545",             id = "1132125111508541493" },
    { username = "naurakori54",     display = "MICO",                  id = "444135915636391939" },
    { username = "Pacarparksungjin",display = "NIA",                   id = "1132125111508541493" },
    { username = "kakcyn",          display = "kakcyn",                id = "429815854692040717" },
    { username = "USERROBLOX",      display = "NAMA",                  id = "1032602143363960833" },
}

local function GetGalatamaMention(playerName)
    if not playerName then return "" end
    local lower = string.lower((tostring(playerName):gsub("^%s+", ""):gsub("%s+$", "")))
    for _, member in ipairs(MemberList) do
        if lower == string.lower(member.username or "")
        or lower == string.lower(member.display or "") then
            if type(member.id) == "table" then
                local mentions = {}
                for _, discordId in ipairs(member.id) do
                    table.insert(mentions, "<@" .. tostring(discordId) .. ">")
                end
                return table.concat(mentions, " ")
            elseif member.id and tostring(member.id) ~= "" then
                return "<@" .. tostring(member.id) .. ">"
            end
        end
    end
    return ""
end

-- DATABASE NAMA IKAN LOKAL: sumber nama/rareness manual seperti GALATAMAWB awal.
-- Database ini hanya untuk mengenali nama dan kategori; tidak otomatis memberi poin.
local SecretFishList = {
    "Crystal Crab", "Orca", "Zombie Shark", "Zombie Megalodon", "Dead Zombie Shark",
    "Blob Shark", "Ghost Shark", "Skeleton Narwhal", "Ghost Worm Fish", "Worm Fish",
    "Megalodon", "1x1x1x1 Comet Shark", "Bloodmoon Whale", "Lochness Monster",
    "Monster Shark", "Eerie Shark", "Great Whale", "Frostborn Shark", "Thin Armored Shark",
    "Scare", "Queen Crab", "King Crab", "Cryoshade Glider", "Panther Eel",
    "Giant Squid", "Depthseeker Ray", "Robot Kraken", "Mosasaur Shark", "King Jelly",
    "Bone Whale", "Elshark Gran Maja", "Elpirate Gran Maja", "Ancient Whale",
    "Gladiator Shark", "Ancient Lochness Monster", "Talon Serpent", "Hacker Shark",
    "ElRetro Gran Maja", "Strawberry Choc Megalodon", "Krampus Shark",
    "Emerald Winter Whale", "Winter Frost Shark", "Icebreaker Whale", "Leviathan",
    "Pirate Megalodon", "Viridis Lurker", "Cursed Kraken", "Ancient Magma Whale",
    "Rainbow Comet Shark", "Love Nessie", "Broken Heart Nessie",
    "Mutant Runic Koi", "Ketupat Whale", "Cosmic Mutant Shark", "Strawberry Orca",
    "Bonemaw Tyrant", "Dawnbringer Betta",
    -- Forgotten Tier
    "Sea Eater", "Thunderzilla", "Iridesca",
}

local ForgottenList = {
    "Sea Eater", "Thunderzilla", "Iridesca",
}

local FishChanceData = {
    ["Crystal Crab"] = "1 in 750K", ["Orca"] = "1 in 1.5M",
    ["Zombie Shark"] = "1 in 250K", ["Zombie Megalodon"] = "1 in 4M",
    ["Dead Zombie Shark"] = "1 in 500K", ["Blob Shark"] = "1 in 250K",
    ["Ghost Shark"] = "1 in 500K", ["Skeleton Narwhal"] = "1 in 600K",
    ["Ghost Worm Fish"] = "1 in 1M", ["Worm Fish"] = "1 in 3M",
    ["Megalodon"] = "1 in 4M", ["1x1x1x1 Comet Shark"] = "1 in 4M",
    ["Bloodmoon Whale"] = "1 in 5M", ["Lochness Monster"] = "1 in 3M",
    ["Monster Shark"] = "1 in 2.5M", ["Eerie Shark"] = "1 in 250K",
    ["Great Whale"] = "1 in 900K", ["Frostborn Shark"] = "1 in 500K",
    ["Thin Armored Shark"] = "1 in 300K", ["Scare"] = "1 in 3M",
    ["Queen Crab"] = "1 in 800K", ["King Crab"] = "1 in 1.2M",
    ["Cryoshade Glider"] = "1 in 450K", ["Panther Eel"] = "1 in 750K",
    ["Giant Squid"] = "1 in 800K", ["Depthseeker Ray"] = "1 in 1.2M",
    ["Robot Kraken"] = "1 in 3.5M", ["Mosasaur Shark"] = "1 in 800K",
    ["King Jelly"] = "1 in 1.5M", ["Bone Whale"] = "1 in 2M",
    ["Elshark Gran Maja"] = "1 in 4M", ["Elpirate Gran Maja"] = "1 in 4M",
    ["ElRetro Gran Maja"] = "1 in 4M", ["Ancient Whale"] = "1 in 2.75M",
    ["Gladiator Shark"] = "1 in 1M", ["Ancient Lochness Monster"] = "1 in 3M",
    ["Talon Serpent"] = "1 in 3M", ["Hacker Shark"] = "1 in 2M",
    ["Strawberry Choc Megalodon"] = "1 in 4M", ["Krampus Shark"] = "1 in 1M",
    ["Emerald Winter Whale"] = "1 in 1.5M", ["Winter Frost Shark"] = "1 in 3M",
    ["Icebreaker Whale"] = "1 in 4M", ["Cursed Kraken"] = "1 in 3M",
    ["Pirate Megalodon"] = "1 in 4M", ["Leviathan"] = "1 in 5M",
    ["Viridis Lurker"] = "1 in 1.4M", ["Ancient Magma Whale"] = "1 in 5M",
    ["Mutant Runic Koi"] = "1 in ??", ["Cosmic Mutant Shark"] = "1 in 2M",
    ["Strawberry Orca"] = "1 in 3M", ["Bonemaw Tyrant"] = "1 in 2.5M",
    ["Sea Eater"] = "1 in 25M", ["Thunderzilla"] = "1 in 30M",
    ["Iridesca"] = "1 in 25M", ["Dawnbringer Betta"] = "1 in 1.25M",
}

-- Hanya enam ikan ini yang dapat menghasilkan skor Galatama.
local GalatamaFishPoints = {
    ["Blob Shark"]        = 100,
    ["Ghost Shark"]       = 100,
    ["Skeleton Narwhal"]  = 100,
    ["Worm Fish"]         = 100,
    ["Dawnbringer Betta"] = 200,
    ["Megalodon"]         = 9999999,
}

local GALATAMA_MUTATION_BONUS = 50
local GalatamaStats = {}
local FishImageCache = {}
local FishCompositeCache = {}

-- Database gambar ikan diambil langsung dari ModuleScript Items milik game.
local AutoFishDBLower = {}
local function BuildAutoFishDatabase()
    local items = ReplicatedStorage:FindFirstChild("Items")
    if not items then
        warn("[M B G Fish] Folder ReplicatedStorage.Items tidak ditemukan.")
        return
    end

    local count = 0
    for _, inst in ipairs(items:GetDescendants()) do
        if inst:IsA("ModuleScript") then
            local ok, result = pcall(require, inst)
            if ok and type(result) == "table" and type(result.Data) == "table"
                and type(result.Data.Name) == "string" and result.Data.Name ~= "" then
                local icon = result.Data.Icon
                if type(icon) == "string" and icon ~= "" then
                    AutoFishDBLower[string.lower(result.Data.Name)] = {
                        Name = result.Data.Name,
                        Icon = icon,
                        ImageURL = nil,
                    }
                    count = count + 1
                end
            end
        end
    end
    print(string.format("[M B G Fish] Database gambar ikan: %d", count))
end

local function Trim(value)
    return (tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

local CLOUDINARY_CLOUD_NAME = "pd5qqwr4"
local CLOUDINARY_WATERMARK_ID = "D3770010-C528-4FA2-B72B-98C0D25646B5"

local function GetRequestFunc()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or (fluxus and fluxus.request)
        or request
end

local function Base64EncodeUrl(url)
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

local function GetRobloxFishImageUrl(baseName)
    local key = string.lower(tostring(baseName or ""))
    local entry = AutoFishDBLower[key]
    if not entry then return nil end
    if entry.ImageURL then return entry.ImageURL end

    local assetId = tostring(entry.Icon or ""):match("%d+")
    if not assetId then return nil end
    local requestFunc = GetRequestFunc()
    if not requestFunc then return nil end

    local ok, response = pcall(function()
        return requestFunc({
            Url = "https://thumbnails.roblox.com/v1/assets?assetIds=" .. assetId
                .. "&size=420x420&format=Png&isCircular=false",
            Method = "GET",
            Headers = { ["Content-Type"] = "application/json" },
        })
    end)
    if not ok or type(response) ~= "table" then return nil end
    local raw = response.Body or response.body
    if not raw or raw == "" then return nil end

    local decodedOk, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
    if not decodedOk or type(decoded) ~= "table" or type(decoded.data) ~= "table" then return nil end
    local imageUrl = decoded.data[1] and decoded.data[1].imageUrl
    if imageUrl and imageUrl ~= "" then
        entry.ImageURL = imageUrl
        return imageUrl
    end
    return nil
end

local function GetFishImageURL(baseName)
    if FishCompositeCache[baseName] then return FishCompositeCache[baseName] end
    local fishUrl = GetRobloxFishImageUrl(baseName)
    if not fishUrl then return nil end

    local encodedFish = Base64EncodeUrl(fishUrl)
    if not encodedFish then
        warn("[M B G Fish] Base64 encoder tidak tersedia; memakai thumbnail Roblox tanpa watermark.")
        return fishUrl
    end

    -- Cloudinary mengambil thumbnail Roblox secara remote dan menambahkan watermark MBG.
    local compositeUrl = "https://res.cloudinary.com/" .. CLOUDINARY_CLOUD_NAME
        .. "/image/upload/c_fill,w_420,h_420"
        .. "/l_fetch:" .. encodedFish
        .. "/c_fit,w_360,h_360/fl_layer_apply,g_center"
        .. "/" .. CLOUDINARY_WATERMARK_ID
    FishCompositeCache[baseName] = compositeUrl
    return compositeUrl
end

pcall(BuildAutoFishDatabase)

local function StripTags(value)
    return (tostring(value or ""):gsub("<[^>]->", ""))
end

local function FormatPoints(value)
    local n = tonumber(value) or 0
    local str = tostring(math.floor(n))
    local result = str:reverse():gsub("(%d%d%d)", "%1."):reverse()
    if result:sub(1, 1) == "." then result = result:sub(2) end
    return result
end

local function ParseChat(rawMsg)
    local msg = StripTags(rawMsg)
    msg = msg:gsub("^%[Server%]:%s*", "")
    local playerName, fishFull, weight = msg:match("^(.-) obtained an? (.-) %(([%d%.%a]+ ?kg)%)")
    if not playerName then
        playerName, fishFull = msg:match("^(.-) obtained an? (.+)")
        weight = "N/A"
    end
    if not playerName or not fishFull then return nil end

    playerName = playerName:match("%[%a+%]:%s*(.+)") or playerName
    playerName = Trim(playerName)
    weight = weight and Trim(weight) or "N/A"
    fishFull = fishFull:match("^(.-)%s+with a 1 in") or fishFull
    fishFull = fishFull:match("^(.-)%s*[!%.]?$") or fishFull
    fishFull = Trim(fishFull)
    return { player = playerName, fish = fishFull, weight = weight }
end

-- Tidak menggunakan MutasiList. Semua teks di luar nama dasar ikan dianggap
-- qualifier/mutasi yang diberikan game. Big dan Shiny dikecualikan dari bonus.
local function DetectGalatamaFish(fishFull)
    local original = Trim(fishFull)
    local lower = original:lower()
    local bestName, bestStart, bestEnd

    -- Nama dasar hanya dicocokkan terhadap SecretFishList lokal, bukan auto fish DB.
    for _, baseName in ipairs(SecretFishList) do
        local startAt, endAt = lower:find(baseName:lower(), 1, true)
        if startAt then
            local before = lower:sub(1, startAt - 1)
            local after = lower:sub(endAt + 1)
            local beforeBoundary = before == "" or before:match("[%s%p]$")
            local afterBoundary = after == "" or after:match("^[%s%p]")
            if beforeBoundary and afterBoundary and (not bestName or #baseName > #bestName) then
                bestName, bestStart, bestEnd = baseName, startAt, endAt
            end
        end
    end

    if not bestName then return nil end

    local prefix = original:sub(1, bestStart - 1)
    local suffix = original:sub(bestEnd + 1)
    local qualifiers = Trim((prefix .. " " .. suffix):gsub("[%p]", " "):gsub("%s+", " "))
    local bonusWords = {}
    for word in qualifiers:gmatch("%S+") do
        local lowerWord = word:lower()
        if lowerWord ~= "big" and lowerWord ~= "shiny" then
            table.insert(bonusWords, word)
        end
    end

    local mutationLabel = #bonusWords > 0 and table.concat(bonusWords, " ") or nil
    local bonus = mutationLabel and GALATAMA_MUTATION_BONUS or 0
    local rarity = "Secret"
    for _, forgottenName in ipairs(ForgottenList) do
        if forgottenName:lower() == bestName:lower() then
            rarity = "Forgotten"
            break
        end
    end
    return bestName, mutationLabel, bonus, original, rarity, FishChanceData[bestName] or "Tidak tersedia"
end

local function GetGalatamaKey(playerName, userId)
    if userId then return tostring(userId) end
    return "name:" .. playerName:lower()
end

local function AddGalatamaPoints(playerName, userId, fishName, basePoints, mutationLabel, bonus)
    local key = GetGalatamaKey(playerName, userId)
    if not GalatamaStats[key] then
        GalatamaStats[key] = { name = playerName, totalPoints = 0, catches = {} }
    end

    local entry = GalatamaStats[key]
    entry.name = playerName
    local added = basePoints + (bonus or 0)
    entry.totalPoints = entry.totalPoints + added

    if not entry.catches[fishName] then
        entry.catches[fishName] = { count = 0, totalPoints = 0 }
    end
    entry.catches[fishName].count = entry.catches[fishName].count + 1
    entry.catches[fishName].totalPoints = entry.catches[fishName].totalPoints + added
    return entry.totalPoints, added
end

local function PostGalatamaWebhook(webhookUrl, embed)
    if not webhookUrl or webhookUrl == "" then
        warn("[M B G Galatama] Webhook tujuan belum diisi.")
        return
    end

    local requestFunc = GetRequestFunc()
    if not requestFunc then
        warn("[M B G Galatama] Executor tidak menyediakan fungsi request.")
        return
    end

    local body = {
        username = "GALATAMA",
        avatar_url = BRAND_ICON,
        content = embed.mention and embed.mention ~= "" and embed.mention or nil,
        allowed_mentions = { parse = { "users" } },
        embeds = {{
            color = embed.color or 16766720,
            title = embed.title,
            description = embed.description,
            fields = embed.fields or {},
            thumbnail = embed.image_url and { url = embed.image_url } or nil,
            footer = { text = "M B G • Galatama" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            author = {
                name = BRAND_NAME,
                url = BRAND_LINK,
                icon_url = BRAND_ICON,
            },
        }},
    }

    local ok, err = pcall(function()
        requestFunc({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode(body),
        })
    end)
    if not ok then warn("[M B G Galatama] Gagal mengirim webhook: " .. tostring(err)) end
end

local function SendGalatamaCatch(data, fishName, mutationLabel, bonus, totalNow, added, rarity, chance)
    local basePoints = GalatamaFishPoints[fishName]
    local mutationText = mutationLabel or "Tidak ada"
    local pointsText
    if bonus > 0 then
        pointsText = "+" .. FormatPoints(added) .. " (" .. FormatPoints(basePoints)
            .. " dasar + " .. FormatPoints(bonus) .. " bonus mutasi)"
    else
        pointsText = "+" .. FormatPoints(added) .. " (tanpa bonus mutasi)"
    end

    local fishImageUrl = GetFishImageURL(fishName)

    PostGalatamaWebhook(WEBHOOK_SECRET, {
        mention = GetGalatamaMention(data.player),
        title = "POIN GALATAMA",
        color = 16711680, -- merah terang (#FF0000), mengikuti warna Mitos di MBG utama
        image_url = fishImageUrl,
        fields = {
            { name = "<a:arrow:1549879103350640650> Pemain", value = "**" .. data.player .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Ikan", value = "**" .. data.fish .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Rarity", value = "**" .. tostring(rarity or "Secret") .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Berat", value = "**" .. data.weight .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Mutasi", value = "**" .. mutationText .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Chance", value = "🎲 **" .. tostring(chance or "Tidak tersedia") .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Poin Didapat", value = "**" .. pointsText .. "**", inline = false },
            { name = "<a:arrow:1549879103350640650> Total Poin Pemain", value = "**" .. FormatPoints(totalNow) .. "**", inline = false },
        },
    })
end

local function BuildGalatamaRulesText()
    local sorted = {}
    for name, points in pairs(GalatamaFishPoints) do
        table.insert(sorted, { name = name, points = points })
    end
    table.sort(sorted, function(a, b)
        if a.points == b.points then return a.name < b.name end
        return a.points > b.points
    end)

    local rows = { "**DAFTAR IKAN YANG MENDAPAT POIN**" }
    for _, item in ipairs(sorted) do
        table.insert(rows, "• " .. item.name .. " — " .. FormatPoints(item.points) .. " poin")
    end
    table.insert(rows, "**Bonus mutasi:** +" .. FormatPoints(GALATAMA_MUTATION_BONUS)
        .. " poin (Big & Shiny tidak mendapat bonus)")
    return table.concat(rows, "\n")
end

local function SendGalatamaStartAnnouncement()
    local fishRows = {}
    local sorted = {}
    for fishName, points in pairs(GalatamaFishPoints) do
        table.insert(sorted, { name = fishName, points = points })
    end
    table.sort(sorted, function(a, b)
        if a.points == b.points then return a.name < b.name end
        return a.points > b.points
    end)

    for _, item in ipairs(sorted) do
        table.insert(fishRows, "• **" .. item.name .. "** — " .. FormatPoints(item.points) .. " poin")
    end

    PostGalatamaWebhook(WEBHOOK_LEADERBOARD, {
        title = "🟢 GALATAMA RESMI DIMULAI!",
        description = "Kompetisi Galatama MBG telah dimulai. Perhitungan poin sekarang aktif!\n\n"
            .. "**DAFTAR IKAN YANG MENDAPAT POIN**\n" .. table.concat(fishRows, "\n")
            .. "\n\n**BONUS MUTASI**\nMutasi yang terdeteksi: +" .. FormatPoints(GALATAMA_MUTATION_BONUS)
            .. " poin. Big dan Shiny tidak mendapatkan bonus mutasi."
            .. "\n\nSelain list di atas tidak akan terhitung poin.",
        color = 5763719,
    })
end

local function SendGalatamaLeaderboard(finalScore)
    local entries = {}
    for _, stats in pairs(GalatamaStats) do
        if (stats.totalPoints or 0) > 0 then
            local fishRows = {}
            for fishName, catch in pairs(stats.catches) do
                table.insert(fishRows, fishName .. " x" .. catch.count)
            end
            table.sort(fishRows)
            table.insert(entries, {
                name = stats.name,
                points = stats.totalPoints,
                catches = #fishRows > 0 and table.concat(fishRows, "\n") or "-",
            })
        end
    end

    table.sort(entries, function(a, b) return a.points > b.points end)
    local fields = {}
    local medals = { "🥇", "🥈", "🥉" }
    for i, entry in ipairs(entries) do
        if i > 5 then break end
        table.insert(fields, {
            name = (medals[i] or ("#" .. i)) .. " " .. entry.name
                .. " — " .. FormatPoints(entry.points) .. " poin",
            value = entry.catches,
            inline = false,
        })
    end
    if #fields == 0 then
        table.insert(fields, { name = "Belum ada poin", value = "Belum ada ikan Galatama yang tercatat.", inline = false })
    end

    -- Pesan penutup ditempatkan paling bawah setelah daftar 5 pemain teratas.
    if finalScore then
        table.insert(fields, {
            name = "📢 STATUS KOMPETISI",
            value = "Kompetisi telah diakhiri. Berikut juara dan total ikan yang diperoleh selama Galatama.",
            inline = false,
        })
    end

    local leaderboardDescription = BuildGalatamaRulesText()
    if finalScore then leaderboardDescription = nil end

    PostGalatamaWebhook(WEBHOOK_LEADERBOARD, {
        title = finalScore and "🏁 GALATAMA BERAKHIR — SCORE AKHIR" or "🏆 LEADERBOARD GALATAMA",
        description = leaderboardDescription,
        color = 5763719, -- hijau sama seperti pengumuman START GALATAMA
        fields = fields,
    })
end

local function CheckAndSend(rawMsg)
    if not SCRIPT_ACTIVE then return end
    if not tostring(rawMsg):lower():find("obtained", 1, true) then return end

    local data = ParseChat(rawMsg)
    if not data then return end

    local fishName, mutationLabel, bonus, _, rarity, chance = DetectGalatamaFish(data.fish)
    if not fishName then return end -- Nama harus ada di database lokal.
    if not GalatamaFishPoints[fishName] then return end -- Secret lain dikenali, tetapi tidak dihitung/dikirim.

    local target = Players:FindFirstChild(data.player)
    local userId = target and target.UserId or nil
    local totalNow, added = AddGalatamaPoints(
        data.player, userId, fishName, GalatamaFishPoints[fishName], mutationLabel, bonus
    )

    -- Megalodon menjadi pemicu akhir: hentikan monitoring sebelum mengirim
    -- notifikasi tangkapan, agar pesan ikan berikutnya tidak diproses.
    local isFinalFish = fishName == "Megalodon"
    if isFinalFish then
        SCRIPT_ACTIVE = false
        if GalatamaChatConnection then
            pcall(function() GalatamaChatConnection:Disconnect() end)
            GalatamaChatConnection = nil
        end
    end

    SendGalatamaCatch(data, fishName, mutationLabel, bonus, totalNow, added, rarity, chance)

    -- Setelah notifikasi Megalodon, kirim score akhir otomatis satu kali.
    if isFinalFish then
        SendGalatamaLeaderboard(true)
    end
end

local function HookChat()
    -- Putuskan koneksi lama bila Galatama dihentikan lalu dimulai kembali.
    if GalatamaChatConnection then
        pcall(function() GalatamaChatConnection:Disconnect() end)
        GalatamaChatConnection = nil
    end

    if not TextChatService then
        warn("[M B G Galatama] TextChatService tidak tersedia. Monitoring dibatalkan agar tidak memakai jalur chat yang tidak memiliki pemeriksaan sumber pesan.")
        return false
    end

    local ok, connection = pcall(function()
        return TextChatService.MessageReceived:Connect(function(msg)
            -- Meniru filter penting dari GALATAMAWB awal:
            -- hanya proses pesan sistem/server yang TextSource-nya nil.
            -- Pesan chat pemain biasa diabaikan.
            if not SCRIPT_ACTIVE or not msg or msg.TextSource ~= nil then return end
            if type(msg.Text) ~= "string" or msg.Text == "" then return end
            CheckAndSend(msg.Text)
        end)
    end)

    if ok and connection then
        GalatamaChatConnection = connection
        print("[M B G Galatama] Filter pesan sistem aktif (TextSource == nil).")
        return true
    end

    warn("[M B G Galatama] Gagal memasang filter TextChatService; tidak menggunakan fallback chat lama karena tidak memiliki pemeriksaan TextSource yang sama.")
    return false
end

local function SaveConfig()
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({ webhook_secret = WEBHOOK_SECRET, webhook_leaderboard = WEBHOOK_LEADERBOARD }))
    end)
end

local function LoadConfig()
    if not (readfile and isfile) then return nil end
    local ok, result = pcall(function()
        if not isfile(CONFIG_FILE) then return nil end
        return HttpService:JSONDecode(readfile(CONFIG_FILE))
    end)
    return ok and result or nil
end

-- ============================================================
-- UI: dua webhook terpisah (secret fish dan leaderboard).
-- ============================================================

local function CreateUI()
    local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
    local old = guiParent:FindFirstChild("MBG_GalatamaOnly")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MBG_GalatamaOnly"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = guiParent

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 330)
    frame.Position = UDim2.new(0.5, -170, 0.5, -165)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(0, 170, 110)
    stroke.Thickness = 1.5

    local top = Instance.new("TextLabel")
    top.Size = UDim2.new(1, -20, 0, 35)
    top.Position = UDim2.new(0, 10, 0, 5)
    top.BackgroundTransparency = 1
    top.Text = "M B G  |  GALATAMA ONLY"
    top.TextColor3 = Color3.fromRGB(245, 245, 245)
    top.Font = Enum.Font.GothamBold
    top.TextSize = 14
    top.Parent = frame

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.new(0, 28, 0, 25)
    minimize.Position = UDim2.new(1, -34, 0, 8)
    minimize.BackgroundColor3 = Color3.fromRGB(55, 65, 65)
    minimize.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimize.Text = "—"
    minimize.Font = Enum.Font.GothamBold
    minimize.TextSize = 16
    minimize.Parent = frame
    Instance.new("UICorner", minimize).CornerRadius = UDim.new(0, 6)

    local restore = Instance.new("TextButton")
    restore.Size = UDim2.new(0, 118, 0, 34)
    restore.Position = UDim2.new(0, 14, 0, 120)
    restore.BackgroundColor3 = Color3.fromRGB(0, 130, 90)
    restore.TextColor3 = Color3.fromRGB(255, 255, 255)
    restore.Text = "M B G  |  BUKA UI"
    restore.Font = Enum.Font.GothamBold
    restore.TextSize = 10
    restore.Visible = false
    restore.Parent = gui
    Instance.new("UICorner", restore).CornerRadius = UDim.new(0, 8)

    minimize.MouseButton1Click:Connect(function()
        frame.Visible = false
        restore.Visible = true
    end)
    restore.MouseButton1Click:Connect(function()
        restore.Visible = false
        frame.Visible = true
    end)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 20)
    status.Position = UDim2.new(0, 10, 0, 38)
    status.BackgroundTransparency = 1
    status.Text = "● Tidak aktif"
    status.TextColor3 = Color3.fromRGB(220, 90, 90)
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = frame

    local labelSecret = Instance.new("TextLabel")
    labelSecret.Size = UDim2.new(1, -24, 0, 18)
    labelSecret.Position = UDim2.new(0, 12, 0, 65)
    labelSecret.BackgroundTransparency = 1
    labelSecret.Text = "Webhook 1 • INFO SECRET FISH"
    labelSecret.TextColor3 = Color3.fromRGB(170, 170, 170)
    labelSecret.Font = Enum.Font.Gotham
    labelSecret.TextSize = 11
    labelSecret.TextXAlignment = Enum.TextXAlignment.Left
    labelSecret.Parent = frame

    local inputSecret = Instance.new("TextBox")
    inputSecret.Size = UDim2.new(1, -24, 0, 30)
    inputSecret.Position = UDim2.new(0, 12, 0, 85)
    inputSecret.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    inputSecret.TextColor3 = Color3.fromRGB(240, 240, 240)
    inputSecret.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    inputSecret.PlaceholderText = "Webhook untuk detail ikan secret..."
    inputSecret.Text = ""
    inputSecret.ClearTextOnFocus = false
    inputSecret.Font = Enum.Font.Gotham
    inputSecret.TextSize = 10
    inputSecret.TextXAlignment = Enum.TextXAlignment.Left
    inputSecret.Parent = frame
    Instance.new("UICorner", inputSecret).CornerRadius = UDim.new(0, 6)
    local secretPad = Instance.new("UIPadding", inputSecret)
    secretPad.PaddingLeft = UDim.new(0, 8)
    secretPad.PaddingRight = UDim.new(0, 8)

    local labelBoard = Instance.new("TextLabel")
    labelBoard.Size = UDim2.new(1, -24, 0, 18)
    labelBoard.Position = UDim2.new(0, 12, 0, 119)
    labelBoard.BackgroundTransparency = 1
    labelBoard.Text = "Webhook 2 • LEADERBOARD + START/END"
    labelBoard.TextColor3 = Color3.fromRGB(170, 170, 170)
    labelBoard.Font = Enum.Font.Gotham
    labelBoard.TextSize = 11
    labelBoard.TextXAlignment = Enum.TextXAlignment.Left
    labelBoard.Parent = frame

    local inputBoard = Instance.new("TextBox")
    inputBoard.Size = UDim2.new(1, -24, 0, 30)
    inputBoard.Position = UDim2.new(0, 12, 0, 139)
    inputBoard.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
    inputBoard.TextColor3 = Color3.fromRGB(240, 240, 240)
    inputBoard.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    inputBoard.PlaceholderText = "Webhook untuk leaderboard dan status..."
    inputBoard.Text = ""
    inputBoard.ClearTextOnFocus = false
    inputBoard.Font = Enum.Font.Gotham
    inputBoard.TextSize = 10
    inputBoard.TextXAlignment = Enum.TextXAlignment.Left
    inputBoard.Parent = frame
    Instance.new("UICorner", inputBoard).CornerRadius = UDim.new(0, 6)
    local boardPad = Instance.new("UIPadding", inputBoard)
    boardPad.PaddingLeft = UDim.new(0, 8)
    boardPad.PaddingRight = UDim.new(0, 8)

    local save = Instance.new("TextButton")
    save.Size = UDim2.new(1, -24, 0, 27)
    save.Position = UDim2.new(0, 12, 0, 176)
    save.BackgroundColor3 = Color3.fromRGB(55, 65, 65)
    save.TextColor3 = Color3.fromRGB(240, 240, 240)
    save.Text = "SIMPAN KEDUA WEBHOOK"
    save.Font = Enum.Font.GothamBold
    save.TextSize = 10
    save.Parent = frame
    Instance.new("UICorner", save).CornerRadius = UDim.new(0, 6)

    local leaderboard = Instance.new("TextButton")
    leaderboard.Size = UDim2.new(1, -24, 0, 27)
    leaderboard.Position = UDim2.new(0, 12, 0, 208)
    leaderboard.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    leaderboard.TextColor3 = Color3.fromRGB(240, 240, 240)
    leaderboard.Text = "KIRIM LEADERBOARD"
    leaderboard.Font = Enum.Font.GothamBold
    leaderboard.TextSize = 10
    leaderboard.Parent = frame
    Instance.new("UICorner", leaderboard).CornerRadius = UDim.new(0, 6)

    local start = Instance.new("TextButton")
    start.Size = UDim2.new(1, -24, 0, 32)
    start.Position = UDim2.new(0, 12, 0, 240)
    start.BackgroundColor3 = Color3.fromRGB(0, 155, 95)
    start.TextColor3 = Color3.fromRGB(255, 255, 255)
    start.Text = "START GALATAMA"
    start.Font = Enum.Font.GothamBold
    start.TextSize = 11
    start.Parent = frame
    Instance.new("UICorner", start).CornerRadius = UDim.new(0, 6)

    local finish = Instance.new("TextButton")
    finish.Size = UDim2.new(1, -24, 0, 32)
    finish.Position = UDim2.new(0, 12, 0, 277)
    finish.BackgroundColor3 = Color3.fromRGB(175, 55, 55)
    finish.TextColor3 = Color3.fromRGB(255, 255, 255)
    finish.Text = "AKHIRI GALATAMA • KIRIM SCORE AKHIR"
    finish.Font = Enum.Font.GothamBold
    finish.TextSize = 9
    finish.Parent = frame
    Instance.new("UICorner", finish).CornerRadius = UDim.new(0, 6)

    local saved = LoadConfig()
    if saved then
        inputSecret.Text = saved.webhook_secret or ""
        inputBoard.Text = saved.webhook_leaderboard or ""
        WEBHOOK_SECRET = saved.webhook_secret or ""
        WEBHOOK_LEADERBOARD = saved.webhook_leaderboard or ""
    end

    save.MouseButton1Click:Connect(function()
        local secretUrl = Trim(inputSecret.Text)
        local boardUrl = Trim(inputBoard.Text)
        local validSecret = secretUrl:find("discord.com/api/webhooks", 1, true) ~= nil
        local validBoard = boardUrl:find("discord.com/api/webhooks", 1, true) ~= nil
        if not validSecret or not validBoard then
            save.Text = "ISI KEDUA WEBHOOK DENGAN VALID"
            task.wait(1.3)
            save.Text = "SIMPAN KEDUA WEBHOOK"
            return
        end
        WEBHOOK_SECRET = secretUrl
        WEBHOOK_LEADERBOARD = boardUrl
        SaveConfig()
        save.Text = "TERSIMPAN"
        task.wait(1)
        save.Text = "SIMPAN KEDUA WEBHOOK"
    end)

    leaderboard.MouseButton1Click:Connect(function()
        if WEBHOOK_LEADERBOARD == "" then
            WEBHOOK_LEADERBOARD = Trim(inputBoard.Text)
        end
        if WEBHOOK_LEADERBOARD:find("discord.com/api/webhooks", 1, true) then
            SendGalatamaLeaderboard()
        end
    end)

    start.MouseButton1Click:Connect(function()
        if SCRIPT_ACTIVE then return end
        local secretUrl = Trim(inputSecret.Text)
        local boardUrl = Trim(inputBoard.Text)
        if not secretUrl:find("discord.com/api/webhooks", 1, true)
        or not boardUrl:find("discord.com/api/webhooks", 1, true) then
            start.Text = "ISI KEDUA WEBHOOK"
            task.wait(1.3)
            start.Text = "START GALATAMA"
            return
        end
        WEBHOOK_SECRET = secretUrl
        WEBHOOK_LEADERBOARD = boardUrl
        SaveConfig()
        GalatamaStats = {}
        SCRIPT_ACTIVE = true
        inputSecret.TextEditable = false
        inputBoard.TextEditable = false
        status.Text = "● Galatama aktif"
        status.TextColor3 = Color3.fromRGB(0, 220, 120)
        start.Text = "MONITORING AKTIF"
        local hooked = HookChat()
        if not hooked then
            SCRIPT_ACTIVE = false
            inputSecret.TextEditable = true
            inputBoard.TextEditable = true
            status.Text = "● Filter chat gagal dipasang"
            status.TextColor3 = Color3.fromRGB(235, 90, 90)
            start.Text = "START GALATAMA"
            return
        end
        SendGalatamaStartAnnouncement()
    end)

    finish.MouseButton1Click:Connect(function()
        if not SCRIPT_ACTIVE then
            finish.Text = "GALATAMA BELUM DIMULAI"
            task.wait(1.2)
            finish.Text = "AKHIRI GALATAMA • KIRIM SCORE AKHIR"
            return
        end
        SCRIPT_ACTIVE = false
        if GalatamaChatConnection then
            pcall(function() GalatamaChatConnection:Disconnect() end)
            GalatamaChatConnection = nil
        end
        status.Text = "● Galatama selesai"
        status.TextColor3 = Color3.fromRGB(235, 170, 70)
        start.Text = "GALATAMA SELESAI"
        finish.Text = "SCORE AKHIR TERKIRIM"
        SendGalatamaLeaderboard(true)
        inputSecret.TextEditable = true
        inputBoard.TextEditable = true
    end)

    -- Drag panel untuk desktop dan mobile.
    local dragging, dragStart, startPos
    top.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1
        or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = inputObj.Position
            startPos = frame.Position
        end
    end)
    top.InputEnded:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1
        or inputObj.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inputObj)
        if dragging and (inputObj.UserInputType == Enum.UserInputType.MouseMovement
        or inputObj.UserInputType == Enum.UserInputType.Touch) then
            local delta = inputObj.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local ok, err = pcall(CreateUI)
if not ok then warn("[M B G Galatama] UI error: " .. tostring(err)) end
