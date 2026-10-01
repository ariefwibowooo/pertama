-- ============================================================
--  MBG Server Monitor  |  TIKTOK: @mainbarenggengz 
-- ============================================================

local HttpService                = game:GetService("HttpService")
local Players                    = game:GetService("Players")
local TextChatService            = game:GetService("TextChatService")
local ReplicatedStorage          = game:GetService("ReplicatedStorage")
local CoreGui                    = game:GetService("CoreGui")
local TweenService               = game:GetService("TweenService")
local Workspace                  = game:GetService("Workspace")

local WEBHOOK_URL                = ""
local WEBHOOK_STATS              = "" -- NOTE: dipertahankan sebagai fallback URL buat "Check Player On Server"
                                      -- kalau WEBHOOK_CHECKPLAYER kosong. Embed rekap otomatis "Server Stats"
                                      -- yang dulu numpang di sini SUDAH DIHAPUS sesuai request.
local WEBHOOK_FISH               = ""
local WEBHOOK_EVENT              = ""
local WEBHOOK_MUTASI             = ""
local WEBHOOK_CHECKPLAYER        = ""
local WEBHOOK_AVATAR             = ""
local SCRIPT_ACTIVE              = false
local MONITOR_SESSION            = 0
local SCRIPT_TERMINATED          = false
local EVENT_NOTIF_ENABLED        = true -- toggle ON/OFF khusus notifikasi Event Elemental

local EVENT_COOLDOWN_SECONDS = 3600
local ROLE_NELAYAN_ID            = "1476331948115755210"

local BRAND_NAME                 = "MAIN BARENG GENGZZZ"
local BRAND_ICON                 = "https://drive.google.com/drive-viewer/AKGpihak0k_0TwtMSfaHWEMvM7PPANThE6hqR02g2AwzIT4yzomN0cCyPd3whrquejZLlduz5AkzCyGZhute_w-qSjm6A1V1JltSyJs=w1672-h892-rw-v1?auditContext=forDisplay"
local BRAND_FOOTER_TEXT          = "M B G • Server Monitor"

local TierColors = {
    Secret                       = 1752220,
    Forgotten                    = 15263976,
    Ruby                         = 16753920,
    Legendary                    = 3407871,
    Mutasi                       = 16776960,
    Join                         = 65280,
    Leave                        = 16729344,
    NotBack                      = 16711680,
    AFK                          = 8421504,
    Mitos                        = 16711680, -- merah polos buat tier Mitos (Shiny Hammerhead Shark, Cosmic Hammerhead Shark, Cosmic Blobfish)
}

local EMOJI_NOTIF                = "<a:notif:1549879003442053140>"
local EMOJI_SEPARATOR            = "<a:arrow:1549879103350640650>"
local EMOJI_STARTER              = ":fishing_pole_and_fish:"
local EMOJI_FORGOTTEN            = "<a:wiu:1549881042150883459>"
local EMOJI_MUTASI               = "<a:mutasi:1549883545835536414>"
local EMOJI_RUBY                 = "<a:ruby:1549881667445981256>"
local EMOJI_LEGENDARY            = "<a:apibiru:1549882097039188168>"
local EMOJI_TREASURE             = "<a:treasure:1549882857445523618>"
local EMOJI_MEGALODON            = ":shark:" -- masih dipakai di EventHuntData yang di-comment (Dark/Megalodon Hunt), jaga-jaga buat reaktivasi
local EMOJI_THUNDER              = "<a:thunder:1549884036787470336>"
local EMOJI_CRYSTAL              = "<a:ruby:1549881667445981256>" -- NOTE: sama persis dgn EMOJI_RUBY, cek lagi apakah emoji crystal-nya beneran ini
local EMOJI_EVENTTAG             = "📢"
local EMOJI_JOIN                 = "<a:join:1549885686843187210>"
local EMOJI_LEAVE                = "<a:leave:1549885729017044992>"
local EMOJI_NOTBACK              = "<a:jam:1549886341817434254>"
local EMOJI_CHECK                = "🔍"
local EMOJI_LOCATION             = "📍"
local EMOJI_AFK                  = "💤"
local EMOJI_BLIZZARD             = "❄️"
local EMOJI_VOLCANO              = "🌋"
local EMOJI_STORM                = "⚡"
local SEP                        = EMOJI_SEPARATOR


-- ============================================================
--  MEMBER LIST
-- ============================================================

local MemberList = {
    { username = "bowojan821",       display = "BALJITOT",             id = "219002813806673930" },
    { username = "strawvxntae",      display = "berry",                id = {"1472281518704693349", "219002813806673930"} },
    { username = "aangdul",          display = "Jiikakamulasatu",      id = "248297103971975169" },
    { username = "aangdulre",        display = "VermiOnie",            id = "248297103971975169" },
    { username = "Yokatsusu",        display = "Yoka",                 id = "1393227652806086676" },
    { username = "CoklatttSusuuuu",  display = "Yokanyawit",           id = "1393227652806086676" },
    { username = "starryipi",        display = "ipii",                 id = "1318926237963391017" },
    { username = "Chihiro_Lily",     display = "Ivy",                  id = "1318926237963391017" },
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
    { username = "nomxel20",         display = "nomxel20",             id = "248297103971975169" },
    { username = "Cabebandot",       display = "Hakari",               id = "444135915636391939" },
    { username = "Refrain_13",       display = "Ren",                  id = "1465026039666184263" },
    { username = "cizukeik999",      display = "cizukeik999",          id = "760811175503593474" },
    { username = "sweetyavocad0",    display = "Merraki",              id = "760811175503593474" },
    { username = "zzezestt",         display = "vessel",               id = "1111713588520956005" },
    { username = "nonnaimup",        display = "NONA",                 id = {"1377239165699231805", "1292331079734132740"} },
    { username = "awrindu",          display = "Awrinndu",             id = {"1438450607349567488", "219002813806673930"} },
    { username = "Mie_ayam2802",     display = "Xyrooo",               id = {"893896145544282164", "219002813806673930"} },
    { username = "Cherryy0_0i",      display = "viii",                 id = "1454391668793938013" },
    { username = "Rens_1395",        display = "Rens",                 id = "1465026039666184263" },
    { username = "sumeringa",        display = "sumeringa",            id = "697060056163942430" },
    { username = "USERROBLOX",       display = "NAMA",                 id = "1032602143363960833" },




}

-- ============================================================
--  DATABASE
-- ============================================================

local SecretFishList = {
    "Crystal Crab", "Orca", "Zombie Shark", "Zombie Megalodon", "Dead Zombie Shark",
    "Blob Shark", "Ghost Shark", "Skeleton Narwhal", "Ghost Worm Fish", "Worm Fish",
    "Megalodon", "1x1x1x1 Comet Shark", "Bloodmoon Whale", "Lochness Monster",
    "Monster Shark", "Eerie Shark", "Great Whale", "Frostborn Shark", "Thin Armor Shark",
    "Scare", "Queen Crab", "King Crab", "Cryoshade Glider", "Panther Eel",
    "Giant Squid", "Depthseeker Ray", "Robot Kraken", "Mosasaur Shark", "King Jelly",
    "Bone Whale", "Elshark Gran Maja", "Elpirate Gran Maja", "Ancient Whale",
    "Gladiator Shark", "Ancient Lochness Monster", "Talon Serpent", "Hacker Shark",
    "ElRetro Gran Maja", "Strawberry Choc Megalodon", "Krampus Shark",
    "Emerald Winter Whale", "Winter Frost Shark", "Icebreaker Whale", "Leviathan",
    "Pirate Megalodon", "Viridis Lurker", "Cursed Kraken", "Ancient Magma Whale",
    "Rainbow Comet Shark", "Love Nessie", "Broken Heart Nessie",
    "Mutant Runic Koi", "Ketupat Whale", "Cosmic Mutant Shark", "Strawberry Orca",
    "Bonemaw Tyrant", "Deepsea Monster Axolotl", "Blocky Lochness Monster", "Aurelion",
    "Runic Enchant Stone", "Frogalloon", "Coral Whale", "Flame Tyrant", "Withering Core",
    "Sea Eater", "Thunderzilla", "Iridesca", "Frostbite Leviathan", "Fluorivane",
    "Cerulean Dragon", "Machodon", "Scorching Veinmaw", "Crystalline Behemoth",
    "Frostmoon Whale", "Crystal Goliath", "Eggy Enchant Stone", "Dark Megalodon",
    "Elemental Tempestray", "Glacial Serpent", "Caustic Maw", "Coral Reaper",
    "Sunken Hadalith", "Trench Warden", "Caeruleum Razerback", "Two-headed shark", "Ragnarex",
    "Colossal Shipwreck Crab", "Astrelle", "Moonwake Ray", "Astralune", "Starglass Guardian",
    "Pelagon", "Crimson Dreadtusk", "Riftborn Arowana", "Stormshell Brute", "Pyrocoil",
    "Wintertusk Mammofin", "Ashen Kingfish", "Tribunal Withering Core", "ELEMENTAL HYDRA", "OVERLORD HYDRA", 
    "Everbloom", "Mr Money Bags", "Shellshock X", "VeloByte", "Cenobyte.EXE",
}

local ForgottenList = {
    "ELEMENTAL HYDRA", "OVERLORD HYDRA", "Iridesca", "Frostbite Leviathan", "Fluorivane",
    "Cerulean Dragon", "Crystalline Behemoth", "Trench Warden", "Ragnarex",
    "Astralune", "Crimson Dreadtusk", "Sea Eater", "Thunderzilla", "Everbloom", "Cenobyte.EXE",
}

local MutasiList = {
    "Noob", "Fairy Dust", "Holographic", "Gemstone", "Fire", "Color Burn",
    "BloodMoon", "Binary", "Lightning", "Disco", "Festive", "Radioactive",
    "Moon Fragment", "Abyssal", "Cosmic", "Equinox", "Glitch", "Solar", "8-Bit",
    -- FIX 6: Aurora & Midnight itu mutasi beneran (sama kayak Abyssal), makanya harus tetap ada di sini.
    -- Masalahnya BUKAN di list ini, tapi di cara deteksi prefix-nya -- lihat MutasiFalsePositiveSpecies di bawah.
    "Aurora", "Midnight", "Elemental",
    -- TODO: kalo mau nambahin "Albino" tinggal masukin string-nya di sini, contoh: "Albino",
}

-- FIX 6: nama SPESIES ikan yang kebetulan diawali kata yang sama kayak nama mutasi beneran
-- (Abyssal Maw Angler, Aurora Grouper, dst). Bedanya sama FIX 4 lama: dulu whitelist ini
-- dicek pakai EXACT match ke seluruh nama ikan, jadi gagal kalau ada kata tambahan di depan
-- (contoh "STONE Aurora Manatee", "Big Aurora Narwhal" -- ada prefix mutasi/qualifier beneran
-- di depan nama spesiesnya). Sekarang FindMutasi akan MEMBUANG dulu substring nama spesies ini
-- dari teks sebelum nyari kata mutasi, jadi sisa "STONE"/"Big" itu yang dicek ke MutasiList,
-- bukan kata "Aurora"/"Abyssal"/"Midnight" yang nempel di nama spesiesnya sendiri.
local MutasiFalsePositiveSpecies = {
    "abyssal maw angler",
    "aurora grouper",
    "aurora starfish",
    "aurora narwhal",
    "aurora manatee",
    "aurora buterfly fish",
    "midnight star squid",
}

local LegendaryCrystalList = {
    "Blue Sea Dragon", "Star Snail", "Cute Dumbo", "Blossom Jelly", "Bioluminescent Octopus",
}

-- ============================================================
--  MYTHIC TIER (embed merah, terpisah dari Secret/Ruby/Legendary)
-- ============================================================
local MythicFishList = {
    "Shiny Hammerhead Shark", "Cosmic Hammerhead Shark", "Cosmic Blobfish",
    -- tinggal nambahin string baru di sini kalau nanti ada ikan mitos lain
}

local FishChanceData = {
    ["Crystal Crab"]              = "1 in 750K",
    ["Orca"]                      = "1 in 1.5M",
    ["Zombie Shark"]              = "1 in 250K",
    ["Zombie Megalodon"]          = "1 in 4M",
    ["Dead Zombie Shark"]         = "1 in 500K",
    ["Blob Shark"]                = "1 in 250K",
    ["Ghost Shark"]               = "1 in 500K",
    ["Skeleton Narwhal"]          = "1 in 600K",
    ["Ghost Worm Fish"]           = "1 in 1M",
    ["Worm Fish"]                 = "1 in 3M",
    ["Megalodon"]                 = "1 in 4M",
    ["1x1x1x1 Comet Shark"]       = "1 in 4M",
    ["Bloodmoon Whale"]           = "1 in 5M",
    ["Lochness Monster"]          = "1 in 3M",
    ["Monster Shark"]             = "1 in 2.5M",
    ["Eerie Shark"]               = "1 in 250K",
    ["Great Whale"]               = "1 in 900K",
    ["Frostborn Shark"]           = "1 in 500K",
    ["Thin Armor Shark"]          = "1 in 300K",
    ["Scare"]                     = "1 in 3M",
    ["Queen Crab"]                = "1 in 800K",
    ["King Crab"]                 = "1 in 1.2M",
    ["Cryoshade Glider"]          = "1 in 450K",
    ["Panther Eel"]               = "1 in 750K",
    ["Giant Squid"]               = "1 in 800K",
    ["Depthseeker Ray"]           = "1 in 1.2M",
    ["Robot Kraken"]              = "1 in 3.5M",
    ["Mosasaur Shark"]            = "1 in 800K",
    ["King Jelly"]                = "1 in 1.5M",
    ["Bone Whale"]                = "1 in 2M",
    ["Elshark Gran Maja"]         = "1 in 4M",
    ["Elpirate Gran Maja"]        = "1 in 4M",
    ["ElRetro Gran Maja"]         = "1 in 4M",
    ["Ancient Whale"]             = "1 in 2.75M",
    ["Gladiator Shark"]           = "1 in 1M",
    ["Ancient Lochness Monster"]  = "1 in 3M",
    ["Talon Serpent"]             = "1 in 3M",
    ["Hacker Shark"]              = "1 in 2M",
    ["Strawberry Choc Megalodon"] = "1 in 4M",
    ["Krampus Shark"]             = "1 in 1M",
    ["Emerald Winter Whale"]      = "1 in 1.5M",
    ["Winter Frost Shark"]        = "1 in 3M",
    ["Icebreaker Whale"]          = "1 in 4M",
    ["Cursed Kraken"]             = "1 in 3M",
    ["Pirate Megalodon"]          = "1 in 4M",
    ["Leviathan"]                 = "1 in 5M",
    ["Viridis Lurker"]            = "1 in 1.4M",
    ["Ancient Magma Whale"]       = "1 in 5M",
    ["Mutant Runic Koi"]          = "1 in ??",
    ["Cosmic Mutant Shark"]       = "1 in 2M",
    ["Strawberry Orca"]           = "1 in 3M",
    ["Bonemaw Tyrant"]            = "1 in 2.5M",
    ["Rainbow Comet Shark"]       = "1 in ??",
    ["Love Nessie"]               = "1 in ??",
    ["Broken Heart Nessie"]       = "1 in ??",
    ["Sea Eater"]                 = "1 in 25M",
    ["Thunderzilla"]              = "1 in 30M",
    ["Iridesca"]                  = "1 in 25M",
    ["Eggy Enchant Stone"]        = "1 in 100K",
    ["Deepsea Monster Axolotl"]   = "1 in 2M",
    ["Blocky Lochness Monster"]   = "1 in 3M",
    ["Frostbite Leviathan"]       = "1 in 12M",
    ["Aurelion"]                  = "1 in 3M",
    ["Runic Enchant Stone"]       = "1 in 700K",
    ["Frogalloon"]                = "1 in 1.5M",
    ["Fluorivane"]                = "1 in 15M",
    ["Coral Whale"]               = "1 in 2M",
    ["Flame Tyrant"]              = "1 in 5M",
    ["Cerulean Dragon"]           = "1 in 25M",
    ["Withering Core"]            = "1 in 3M",
    ["Machodon"]                  = "1 in 10M",
    ["Crystalline Behemoth"]      = "1 in 20M",
    ["Frostmoon Whale"]           = "1 in 5M",
    ["Crystal Goliath"]           = "1 in 3M",
    ["Ketupat Whale"]             = "1 in ??",
    ["Scorching Veinmaw"]         = "1 in 5M",
    ["Glacial Serpent"]           = "1 in 6M",
    ["Elemental Tempestray"]      = "1 in 1M",
    ["Dark Megalodon"]            = "1 in 8M",
    ["Caustic Maw"]               = "1 in 4M",
    ["Coral Reaper"]              = "1 in 6M",
    ["Sunken Hadalith"]           = "1 in ??",
    ["Trench Warden"]             = "1 in 15M",
    ["Caeruleum Razerback"]       = "1 in 3M",
    -- FIX (rapihkan): key ini sebelumnya "two-headed shark" (t kecil), padahal SecretFishList
    -- & FishImageURL pakai "Two-headed shark" (T besar) -- akibatnya field Chance di embed
    -- selalu nongol "Unknown" walau datanya ada, gara-gara lookup case-sensitive gak ketemu.
    ["Two-headed shark"]          = "1 in 3M",
    ["Ragnarex"]                  = "1 in 35M",
    ["Colossal Shipwreck Crab"]   = "1 in 5M",
    ["Astrelle"]                  = "1 in 6M",
    ["Moonwake Ray"]              = "1 in 5M",
    ["Astralune"]                 = "1 in 20M",
    ["Starglass Guardian"]        = "1 in 3M",
    ["Pelagon"]                   = "1 in 4.5M",
    ["Riftborn Arowana"]          = "1 in 4.5M",
    ["Crimson Dreadtusk"]         = "1 in 20M",
    ["Stormshell Brute"]          = "1 in 4M",
    ["Pyrocoil"]                  = "1 in 4M",
    ["Wintertusk Mammofin"]       = "1 in 4M",
    ["ELEMENTAL HYDRA"]           = "1 in 40M",
    ["OVERLORD HYDRA"]            = "1 in 45M",
    ["Ashen Kingfish"]            = "1 in 3.50M",
    ["Tribunal Withering Core"]   = "1 in 5M",
    ["Everbloom"]                 = "1 in 20M",
    ["Mr Money Bags"]             = "1 in 4M",
    ["VeloByte"]                  = "1 in 5M",
    ["Shellshock X"]              = "1 in 3M",
    ["Cenobyte.EXE"]              = "1 in 25M",
}

local NP = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main"

local FishImageURL = {
    ["Cenobyte.EXE"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/IMG_3205.png",
    ["Shellshock X"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/ShellshockX.PNG",
    ["next"]                     = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/NEXT.PNG",
    ["VeloByte"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/VeloByte.png",
    ["Everbloom"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Everbloom.WEBP",
    ["Mr Money Bags"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Money%20Bags.png",
    ["Frostborn Shark"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/9.png",
    ["Crystal Goliath"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/11.png",
    ["Crystalline Behemoth"]     = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/10.png",
    ["Elemental Tempestray"]     = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/13.png",
    ["Dark Megalodon"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/14.png",
    ["Withering Core"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/16.png",
    ["Flame Tyrant"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/17.png",
    ["Scorching Veinmaw"]        = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/18.png",
    ["Cerulean Dragon"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/19.png",
    ["King Crab"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/21.png",
    ["Queen Crab"]               = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/22.png",
    ["Panther Eel"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/23.png",
    ["Cryoshade Glider"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/24.png",
    ["Giant Squid"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/25.png",
    ["Depthseeker Ray"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/26.png",
    ["Robot Kraken"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/27.png",
    ["Ghost Shark"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/29.png",
    ["Skeleton Narwhal"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/30.png",
    ["Blob Shark"]               = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/31.png",
    ["Worm Fish"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/32.png",
    ["Cosmic Mutant Shark"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/33.png",
    ["Megalodon"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/34.png",
    ["Bloodmoon Whale"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/36.png",
    ["Frostmoon Whale"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/37.png",
    ["Thunderzilla"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/38.png",
    ["Thin Armor Shark"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/40.png",
    ["Scare"]                    = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/41.png",
    ["Lochness Monster"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/43.png",
    ["Ancient Magma Whale"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/44.png",
    ["Crystal Crab"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/46.png",
    ["Orca"]                     = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/47.png",
    ["Eerie Shark"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/49.png",
    ["Monster Shark"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/50.png",
    ["Eggy Enchant Stone"]       = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/52.png",
    ["Strawberry Orca"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/53.png",
    ["Iridesca"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/54.png",
    ["Frogalloon"]               = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/56.png",
    ["Blocky Lochness Monster"]  = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/57.png",
    ["Aurelion"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/58.png",
    ["Frostbite Leviathan"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/59.png",
    ["Runic Enchant Stone"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/61.png",
    ["Bonemaw Tyrant"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/00.png",
    ["Mutant Runic Koi"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/62.png",
    ["Deepsea Monster Axolotl"]  = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/63.png",
    ["Fluorivane"]               = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/64.png",
    ["Sea Eater"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/65.png",
    ["Pirate Megalodon"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/67.png",
    ["Elpirate Gran Maja"]       = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/68.png",
    ["Cursed Kraken"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/69.png",
    ["Mosasaur Shark"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/71.png",
    ["King Jelly"]               = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/72.png",
    ["Gladiator Shark"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/75.png",
    ["Ancient Lochness Monster"] = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/76.png",
    ["Elshark Gran Maja"]        = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/77.png",
    ["Viridis Lurker"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/78.png",
    ["Bone Whale"]               = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/79.png",
    ["Ancient Whale"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/80.png",
    ["Great Whale"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/82.png",
    ["Coral Whale"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/83.png",
    ["Love Nessie"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/85.png",
    ["Broken Heart Nessie"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/86.png",
    ["Leviathan"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Leviathan.png",
    ["Rainbow Comet Shark"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/RainbowComet.png",
    ["Ruby Gemstone"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Ruby.png",
    ["Glacial Serpent"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/GlacialSerpent.png",
    ["Machodon"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Machodon.png",
    ["Crystal"]                  = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/crystal.png",
    ["treasure hunt"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/treasure.png",
    ["Caustic Maw"]              = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/97.png",
    ["Aurora"]                   = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/99.png",
    ["Coral Reaper"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/CoralReaper.png",
    ["Trench Warden"]            = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/TrenchWarden.png",
    ["Caeruleum Razerback"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/CureleamBarbak.png",
    ["Two-headed shark"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/TwoHeadedShark.png",
    ["Ragnarex"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Ragnarex.png",
    ["Colossal Shipwreck Crab"]  = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/ColShipCrab.png",
    -- NOTE: nama file "Astrlele.png" ini keliatan kayak typo (harusnya "Astrelle.png"?) --
    -- cek lagi nama file yang beneran ke-upload di repo new-pisit-image, kalau salah nanti
    -- gambarnya gak muncul kayak kasus Glacial Serpent kemarin.
    ["Astrelle"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Astrelle.png",
    ["Astralune"]                = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Astralune.png",
    ["Moonwake Ray"]             = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/MoonwakeRay.png",
    ["Pelagon"]                  = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Pelagon.png",
    ["Starglass Guardian"]       = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/StarglassGuardian.png",
    ["Riftborn Arowana"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/RiftbornArowana.png",
    ["Crimson Dreadtusk"]        = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/CrimsonDreadtusk.png",
    ["Stormshell Brute"]         = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/StormshellBrute.png",
    ["Pyrocoil"]                 = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/Pyrocoil.png",
    ["Wintertusk Mammofin"]      = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/WintertuskMammofin.png",
    ["ELEMENTAL HYDRA"]          = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/ElementalHydra.png",
    ["OVERLORD HYDRA"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/OVERLORDHYDRA.png",
    ["Ashen Kingfish"]           = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/AshenKingfish.png",
    ["Tribunal Withering Core"]  = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/TribunalWitheringCore.png",
    ["Shiny Hammerhead Shark"]   = "https://raw.githubusercontent.com/bowojan8-ctrl/FISH-IT-FOTO-ANJAY-MABAR/main/ShinyHammerheadShark.png",
}


-- Helper case-insensitive buat ambil URL gambar ikan. Ini nyegah kejadian kayak bug
-- "two-headed shark" -- kalau ada typo beda huruf besar/kecil antara SecretFishList/
-- ForgottenList/dll dengan key di FishImageURL, gambar tetap ketemu selama nama dasarnya sama.
local FishImageURLLower = {}
for k, v in pairs(FishImageURL) do
    FishImageURLLower[string.lower(k)] = v
end

local function GetFishImageURL(baseName)
    if not baseName then return nil end
    return FishImageURL[baseName] or FishImageURLLower[string.lower(baseName)]
end

-- ============================================================
--  EVENT HUNT DATABASE
--  Treasure Hunt, Crystal Event, Thunderzilla Hunt, Megalodon Hunt,
--  Dark Megalodon Hunt, dan Aurora Borealis DINONAKTIFKAN.
--  Sekarang hanya Storm, Blizzard, dan Volcano yang aktif.
--  Entry lama dibiarin ke-comment biar gampang diaktifkan lagi kalau perlu.
-- ============================================================

local EventHuntData = {
    {
        textTriggers = {
            "storm elemental event event has started",
            "storm elemental event has started",
            "storm elemental event",
        },
        title        = EMOJI_STORM .. " Storm Event Dimulai!",
        description  = "Pindah lekkkkkkk " .. EMOJI_STORM,
        color        = 1146986,
        emoji        = "⚡",
        thumbUrl     = FishImageURL["Stormshell Brute"],
        isElemental  = true,
    },
    {
        textTriggers = {
            "blizzard elemental event event has started",
            "blizzard elemental event has started",
            "blizzard elemental event",
        },
        title        = EMOJI_BLIZZARD .. " Blizzard Event Dimulai!",
        description  = "Pindah lekkkkkkk " .. EMOJI_BLIZZARD,
        color        = 6530531,
        emoji        = "❄️",
        thumbUrl     = FishImageURL["Wintertusk Mammofin"],
        isElemental  = true,
    },
    {
        textTriggers = {
            "volcano elemental event event has started",
            "volcano elemental event has started",
            "volcano elemental event",
        },
        title        = EMOJI_VOLCANO .. " Volcano Event Dimulai!",
        description  = "Pindah lekkkkkkk " .. EMOJI_VOLCANO,
        color        = 16075047,
        emoji        = "🌋",
        thumbUrl     = FishImageURL["Pyrocoil"],
        isElemental  = true,
    },
    --[[ dinonaktifkan -- Treasure Hunt
    {
        textTriggers = { "treasure hunt" },
        title        = EMOJI_TREASURE .. " Treasure Hunt Dimulai!",
        description  = "katakan Peta 🗺️",
        color        = 16766720,
        emoji        = "💰",
        thumbUrl     = FishImageURL["treasure hunt"],
    },
    ]]
    --[[ dinonaktifkan -- Crystal Event
    {
        textTriggers = { "crystals have spawned", "crystals have", "crystal" },
        title        = EMOJI_CRYSTAL .. " Crystal Event Dimulai!",
        description  = "Crystal muncul gas nambang " .. EMOJI_CRYSTAL,
        color        = 1146986,
        emoji        = "💎",
        thumbUrl     = FishImageURL["Crystal"],
    },
    ]]
    --[[ dinonaktifkan -- Dark Megalodon Hunt
    {
        textTriggers = { "dark megalodon hunt", "dark megalodon" },
        title        = "🌑 Dark Megalodon Hunt Dimulai!",
        description  = "Dark Mega guys " .. EMOJI_MEGALODON,
        color        = 2303786,
        emoji        = "🌑",
        thumbUrl     = FishImageURL["Dark Megalodon"],
    },
    ]]
    --[[ dinonaktifkan -- Megalodon Hunt
    {
        textTriggers = { "megalodon hunt" },
        title        = EMOJI_MEGALODON .. " Megalodon Hunt Dimulai!",
        description  = "Mega gusy 🎣",
        color        = 3447003,
        emoji        = "🦈",
        thumbUrl     = FishImageURL["Megalodon"],
    },
    ]]
    --[[ dinonaktifkan -- Thunderzilla Hunt
    {
        textTriggers = { "thunderzilla hunt", "thunderzilla" },
        title        = EMOJI_THUNDER .. " Thunderzilla Hunt Dimulai!",
        description  = "zilla oi " .. EMOJI_THUNDER,
        color        = 16776960,
        emoji        = "⚡",
        thumbUrl     = FishImageURL["Thunderzilla"],
    },
    ]]
    --[[ dinonaktifkan -- Aurora Borealis
    {
        textTriggers = { "aurora borealis", "aurora event" },
        title        = "💫 Aurora Borealis!",
        description  = "cantiknyooo",
        color        = 9055202,
        emoji        = "💫",
        thumbUrl     = FishImageURL["Aurora"],
    },
    ]]
}

local EventCooldown = {}

-- ============================================================
--  STATE / CACHE
-- ============================================================

local MentionCache    = {}
local FishImageCache  = {}
local AvatarCache     = {}
local LeaveTimers     = {}
local PlayerStats     = {}
local PlayerNameToId  = {}
local SpawnPointCache = {} -- {name, position} hasil scan folder "!!! SPAWN LOCATIONS"

-- ============================================================
--  AFK / IDLE DETECTION (tidak memancing / gak ada catch selama 1 jam)
-- ============================================================

local AFK_THRESHOLD_SECONDS  = 3600 -- 1 jam tanpa catch dianggap idle
local AFK_CHECK_INTERVAL     = 60   -- interval scan pengecekan idle (detik)

-- ============================================================
--  SAVE CONFIG
-- ============================================================

local CONFIG_FILE = "bloxgank_config.json"

local function SaveConfig(joinUrl, fishUrl, statsUrl, eventUrl, mutasiUrl, checkplayerUrl)
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            webhook_join        = joinUrl        or "",
            webhook_fish        = fishUrl        or "",
            webhook_stats       = statsUrl       or "",
            webhook_event       = eventUrl       or "",
            webhook_mutasi      = mutasiUrl      or "",
            webhook_checkplayer = checkplayerUrl or "",
        }))
    end)
end

local function LoadConfig()
    if not readfile or not isfile then return nil end
    local ok, raw = pcall(function() return readfile(CONFIG_FILE) end)
    if not ok or not raw or raw == "" then return nil end
    local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if ok2 and type(data) == "table" then return data end
    return nil
end

-- ============================================================
--  UTILITY
-- ============================================================

local function GetRequestFunc()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or (fluxus and fluxus.request)
        or request
end

local function StripTags(str)
    return string.gsub(str, "<[^>]+>", "")
end

local function Trim(s)
    return s:match("^%s*(.-)%s*$") or s
end

-- Format angka besar jadi singkatan K/M/B (mis. 4500000 -> "4.5M"), buat embed Check Player
local function FormatNumber(n)
    n = tonumber(n)
    if not n then return "N/A" end
    local sign = n < 0 and "-" or ""
    n = math.abs(n)
    if n >= 1000000000 then return sign .. string.format("%.1fB", n / 1000000000)
    elseif n >= 1000000 then return sign .. string.format("%.1fM", n / 1000000)
    elseif n >= 1000     then return sign .. string.format("%.0fK", n / 1000)
    else return sign .. tostring(n) end
end

local function FindPlayer(name)
    local p = Players:FindFirstChild(name)
    if p then return p end
    local lower = string.lower(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if string.lower(player.Name) == lower then return player end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), lower, 1, true)
        or string.find(lower, string.lower(player.Name), 1, true) then
            return player
        end
    end
    return nil
end

-- ============================================================
--  MENTION HELPERS
-- ============================================================

local function BuildMentionCache(rbxName, rbxDisplay)
    for _, member in ipairs(MemberList) do
        local uLower = string.lower(member.username)
        local dLower = string.lower(member.display)
        if string.lower(rbxName) == uLower    or string.lower(rbxDisplay) == dLower
        or string.lower(rbxName) == dLower    or string.lower(rbxDisplay) == uLower then
            MentionCache[string.lower(rbxName)]    = member.id
            MentionCache[string.lower(rbxDisplay)] = member.id
        end
    end
end

local function GetMention(robloxName)
    if not robloxName then return "" end

    local lower = string.lower(robloxName)

    local function FormatMention(ids)
        if type(ids) == "table" then
            local mentions = {}

            for _, discordId in ipairs(ids) do
                table.insert(mentions, "<@" .. discordId .. ">")
            end

            return table.concat(mentions, " ")
        end

        return "<@" .. tostring(ids) .. ">"
    end

    if MentionCache[lower] then
        return FormatMention(MentionCache[lower])
    end

    for _, member in ipairs(MemberList) do
        if string.lower(member.username) == lower
        or string.lower(member.display) == lower then
            return FormatMention(member.id)
        end
    end

    return ""
end

-- ============================================================
--  FISH DETECTION
-- ============================================================

local function FindSecretFish(fishName)
    local lower = string.lower(fishName)
    for _, baseName in ipairs(SecretFishList) do
        if lower == string.lower(baseName) then return baseName, nil end
    end
    local bestBase, bestLen, bestMutasi = nil, 0, nil
    for _, baseName in ipairs(SecretFishList) do
        local s = string.find(lower, string.lower(baseName), 1, true)
        if s then
            local mutasi = nil
            if s > 1 then
                mutasi = fishName:sub(1, s - 1):match("^%s*(.-)%s*$")
                if mutasi == "" then mutasi = nil end
            end
            if #baseName > bestLen then
                bestLen    = #baseName
                bestBase   = baseName
                bestMutasi = mutasi
            end
        end
    end
    return bestBase, bestMutasi
end

-- FIX 3: FindMutasi sebelumnya gagal detect kalau nama mutasi ada di UJUNG string
-- (contoh fish name "Dead Zombie Shark Frozen" -> "Frozen" di ujung, afterPos jadi
-- string kosong sehingga "afterOk" dulu selalu false). Sekarang end-of-string dihitung valid juga.
local function FindMutasi(fishName)
    local lower = string.lower(fishName)

    -- FIX 6: buang dulu substring nama SPESIES (bukan exact match seluruh nama ikan lagi),
    -- supaya kata mutasi asli (Abyssal/Aurora/Midnight) yang nempel di nama spesies gak
    -- ketauan sebagai mutasi, TAPI kata di depan/belakangnya (mutasi beneran, mis. "Stone",
    -- "Fire", dst -- kalau ada) tetap bisa kedetect karena sisa teksnya tetap dicek di bawah.
    for _, species in ipairs(MutasiFalsePositiveSpecies) do
        local s = string.find(lower, species, 1, true)
        if s then
            local beforeOk = (s == 1) or (lower:sub(s - 1, s - 1) == " ")
            local afterPos = s + #species
            local afterOk  = (afterPos > #lower) or (lower:sub(afterPos, afterPos) == " ")
            if beforeOk and afterOk then
                lower = Trim((lower:sub(1, s - 1) .. " " .. lower:sub(afterPos + 1)):gsub("%s+", " "))
                break
            end
        end
    end
    if lower == "" then return nil end

    for _, mutasiName in ipairs(MutasiList) do
        local mutasiLower = string.lower(mutasiName)
        local s = string.find(lower, mutasiLower, 1, true)
        if s then
            local beforeOk = (s == 1) or (lower:sub(s - 1, s - 1) == " ")
            local afterPos = s + #mutasiLower
            local afterOk  = (afterPos > #lower) or (lower:sub(afterPos, afterPos) == " ")
            if beforeOk and afterOk then
                return mutasiName
            end
        end
    end
    return nil
end

local function FindRuby(fishName)
    local lower = string.lower(fishName)
    if string.find(lower, "ruby") and string.find(lower, "gemstone") then return "Ruby" end
    return nil
end

local function FindLegendaryCrystal(fishName)
    local lower = string.lower(fishName)
    if not string.find(lower, "crystalized") then return nil end
    for _, name in ipairs(LegendaryCrystalList) do
        if string.find(lower, string.lower(name), 1, true) then return name end
    end
    return nil
end

-- Deteksi ikan tier Mitos (contoh: Shiny Hammerhead Shark). Dikirim ke webhook secret fish
-- yang sama, tapi pakai warna embed merah polos (TierColors.Mitos) dan title tersendiri.
local function FindMythicFish(fishName)
    local lower = string.lower(fishName)
    for _, baseName in ipairs(MythicFishList) do
        if string.find(lower, string.lower(baseName), 1, true) then
            return baseName
        end
    end
    return nil
end

local function GetFishImageId(item)
    for _, desc in ipairs(item:GetDescendants()) do
        local ok, val = pcall(function()
            if desc:IsA("SpecialMesh")                               then return desc.TextureId
            elseif desc:IsA("Decal") or desc:IsA("Texture")         then return desc.Texture
            elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then return desc.Image
            end
            return nil
        end)
        if ok and val and val ~= "" and val ~= "rbxasset://" then
            local id = tostring(val):match("%d+")
            if id then return id end
        end
    end
    return nil
end

-- ============================================================
--  CHECK PLAYER ON SERVER
--  Ambil Caught & Map (lokasi) dari leaderstats tiap player,
--  plus scan Server Luck & timer sisa dari teks GUI game.
-- ============================================================

-- Cari child dengan nama tertentu di dalam sebuah container (leaderstats, dll).
local function FindValueByName(container, names)
    if not container then return nil end
    for _, n in ipairs(names) do
        local child = container:FindFirstChild(n)
        if child then return child end
    end
    return nil
end

-- Cari ke SELURUH descendant instance (bukan cuma leaderstats) buat nama yang match,
-- dipakai sebagai fallback kalau statnya ternyata gak ada di leaderstats.
local function FindValueRecursive(instance, names)
    if not instance then return nil end
    local wanted = {}
    for _, n in ipairs(names) do wanted[string.lower(n)] = true end
    for _, desc in ipairs(instance:GetDescendants()) do
        if wanted[string.lower(desc.Name)] then
            local ok = pcall(function() return desc.Value end)
            if ok then return desc end
        end
    end
    return nil
end

-- Cari value Map/Location di dalam WORKSPACE, bukan cuma di dalam Player itu sendiri.
-- Beberapa game nyimpen data per-player di folder terpisah di workspace
-- (misal workspace.PlayerName.Map), bukan di leaderstats.
local function FindPlayerValueInWorkspace(player, names)
    if not player then return nil end

    -- pola umum #1: ada folder di workspace yang namanya SAMA PERSIS kayak nama player
    local playerFolder = Workspace:FindFirstChild(player.Name)
    if playerFolder then
        local direct = FindValueByName(playerFolder, names)
        if direct then return direct end
        local nested = FindValueRecursive(playerFolder, names)
        if nested then return nested end
    end

    -- pola umum #2: scan seluruh descendant workspace, cari instance yang namanya
    -- match, TAPI cuma dianggap valid kalau salah satu leluhurnya juga ada nama playernya
    -- (biar gak ketuker sama punya player lain).
    local lowerPlayerName = string.lower(player.Name)
    local wanted = {}
    for _, n in ipairs(names) do wanted[string.lower(n)] = true end

    for _, desc in ipairs(Workspace:GetDescendants()) do
        if wanted[string.lower(desc.Name)] then
            local ok = pcall(function() return desc.Value end)
            if ok then
                local anc = desc.Parent
                while anc and anc ~= Workspace do
                    if string.lower(anc.Name) == lowerPlayerName then return desc end
                    anc = anc.Parent
                end
            end
        end
    end

    return nil
end

-- ============================================================
--  NEAREST SPAWN LOCATION (fallback lokasi player)
--  Game ini gak nge-track lokasi player lewat stat, jadi kita
--  hitung sendiri: cari SpawnLocation terdekat dari posisi
--  HumanoidRootPart player. Posisi character direplikasi ke semua
--  client jadi ini reliable, beda sama data privat semacam stat.
-- ============================================================

local SPAWN_FOLDER_NAME  = "!!! SPAWN LOCATIONS"
local SPAWN_MAX_DISTANCE = 400 -- studs, di atas ini dianggap "Unknown Area"

local function CacheSpawnLocations()
    SpawnPointCache = {}
    local folder = Workspace:FindFirstChild(SPAWN_FOLDER_NAME)
    if not folder then
        warn("[M B G DEBUG] Folder '" .. SPAWN_FOLDER_NAME .. "' tidak ditemukan di Workspace!")
        return
    end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("spawn", 1, true) then
            local lowerName = obj.Name:lower()
            local areaName

            if lowerName == "spawnlocation" or lowerName == "spawn" then
                -- struktur aslinya "!!! SPAWN LOCATIONS" > "<Nama Area>" > "SpawnLocation"
                -- (part-nya sendiri namanya generik "SpawnLocation"), jadi nama area
                -- diambil dari PARENT folder-nya, bukan dari nama part itu sendiri.
                areaName = obj.Parent and obj.Parent.Name or nil
            else
                -- fallback lama: kalau part-nya bernama "Copper Canyon SpawnLocation"
                areaName = obj.Name:gsub("%s*[Ss]pawn[Ll]ocation%s*$", "")
            end

            areaName = areaName and Trim(areaName) or nil
            if areaName and areaName ~= "" then
                table.insert(SpawnPointCache, { name = areaName, position = obj.Position })
            end
        end
    end

    print("[M B G DEBUG] CacheSpawnLocations: ketemu " .. #SpawnPointCache .. " spawn point.")
    for _, sp in ipairs(SpawnPointCache) do
        print("    [SPAWN POINT] " .. sp.name .. " @ " .. tostring(sp.position))
    end
end

-- Cari nama area terdekat dari posisi karakter player.
local function GetNearestSpawnArea(player)
    if #SpawnPointCache == 0 then return nil end
    local char = player and player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local charPos = root.Position
    local nearestName, nearestDist = nil, math.huge

    for _, sp in ipairs(SpawnPointCache) do
        local dist = (charPos - sp.position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearestName = sp.name
        end
    end

    if nearestName and nearestDist <= SPAWN_MAX_DISTANCE then
        return nearestName
    end
    return nil -- terlalu jauh dari spawn manapun, gak yakin lokasinya
end

-- Ambil nilai Caught & Map dari leaderstats player (nama stat asli:
-- Pemain / caught, dan lokasi disimpan di stat "Map").
local function GetPlayerStatsAndLocation(player)
    local caught, location = "N/A", "N/A"
    if not player then return caught, location end
    local ls = player:FindFirstChild("leaderstats")

    local caughtStat = FindValueByName(ls, { "caught", "Caught" })
    if caughtStat then caught = FormatNumber(caughtStat.Value) end

    -- Urutan pencarian Map: leaderstats -> seluruh descendant player -> workspace -> attribute -> NEAREST SPAWN (fallback terakhir)
    local locStat = FindValueByName(ls, { "Map", "map", "Location", "Zone" })
        or FindValueRecursive(player, { "Map", "map", "Location", "Zone" })
        or FindPlayerValueInWorkspace(player, { "Map", "map", "Location", "Zone" })
    if locStat then
        location = tostring(locStat.Value)
    else
        -- coba baca dari Attribute (bukan child Instance)
        local attrLoc = player:GetAttribute("Map") or player:GetAttribute("map")
            or player:GetAttribute("Location") or player:GetAttribute("Zone")
        if attrLoc ~= nil then
            location = tostring(attrLoc)
        else
            -- fallback terakhir -- game ini gak nge-track lokasi lewat stat,
            -- jadi hitung sendiri dari posisi player vs SpawnLocation terdekat.
            local nearest = GetNearestSpawnArea(player)
            if nearest then location = nearest .. " (est.)" end
        end
    end

    return caught, location
end

-- NOTE: ini scanner HEURISTIK (nebak dari pola teks), karena Server Luck &
-- End Server Luck cuma ada di GUI game (bukan value/stat). Kalau hasilnya
-- kosong/salah, cek langsung teks GUI game-nya dan sesuaikan pattern di bawah ini.
local function ScanServerLuckInfo()
    -- Server Luck ditampilkan di GUI khusus "!!! Server Luck".
    -- Prioritas pembacaan:
    -- 1) BaseCounter pada panel Server Luck -> multiplier (contoh: x8)
    -- 2) NextLuckCounter / label lain pada panel yang sama -> timer jika berupa waktu
    -- 3) fallback scan PlayerGui supaya tetap kompatibel kalau struktur GUI berubah.
    local luckValue, luckEnds = nil, nil
    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return luckValue, luckEnds end

    local function cleanText(v)
        if not v then return "" end
        local ok, result = pcall(function() return tostring(v.Text or "") end)
        return ok and result or ""
    end

    local function extractLuck(t)
        if not t or t == "" then return nil end
        -- Contoh: "x8", "x 8", "Luck x8", "Server Luck x8"
        local m = t:match("[Ll]uck%s*[:%-]?%s*[xX]%s*(%d+%.?%d*)")
            or t:match("[xX]%s*(%d+%.?%d*)%s*[Ll]uck")
            or t:match("^[xX]%s*(%d+%.?%d*)%s*$")
        return m
    end

    local function extractTimer(t)
        if not t or t == "" then return nil end
        -- Mendukung format UI seperti: 18D 9H 4M 48S / 9h 4m 48s / 4m 48s.
        local d, h, m, s = t:match("(%d+)%s*[dD]%s*(%d+)%s*[hH]%s*(%d+)%s*[mM]%s*(%d+)%s*[sS]")
        if d then return d .. "d " .. h .. "h " .. m .. "m " .. s .. "s" end

        h, m, s = t:match("(%d+)%s*[hH]%s*(%d+)%s*[mM]%s*(%d+)%s*[sS]")
        if h then return h .. "h " .. m .. "m " .. s .. "s" end

        m, s = t:match("(%d+)%s*[mM]%s*(%d+)%s*[sS]")
        if m then return m .. "m " .. s .. "s" end

        s = t:match("^(%d+)%s*[sS]$")
        if s then return s .. "s" end

        return nil
    end

    local function scanContainer(container)
        if not container then return end

        -- Multiplier paling spesifik: Visual/BaseCounter pada panel Server Luck.
        local baseCounter = container:FindFirstChild("BaseCounter", true)
        if baseCounter and (baseCounter:IsA("TextLabel") or baseCounter:IsA("TextButton")) then
            local m = extractLuck(cleanText(baseCounter))
            if m then luckValue = m end
        end

        -- Timer paling spesifik: NextLuckCounter. Hanya dipakai jika isinya memang waktu,
        -- karena di beberapa duplicate GUI nama ini bisa berisi x8/teks lain.
        local nextCounter = container:FindFirstChild("NextLuckCounter", true)
        if nextCounter and (nextCounter:IsA("TextLabel") or nextCounter:IsA("TextButton")) then
            local timer = extractTimer(cleanText(nextCounter))
            if timer then luckEnds = timer end
        end

        -- Scan seluruh TextLabel/TextButton di panel Server Luck.
        for _, v in ipairs(container:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local t = cleanText(v)
                if t ~= "" then
                    if not luckValue then
                        luckValue = extractLuck(t)
                    end
                    if not luckEnds then
                        luckEnds = extractTimer(t)
                    end
                    if luckValue and luckEnds then return end
                end
            end
        end
    end

    -- Cari GUI Server Luck yang benar, bukan duplicate GameLuckDisplayFrame
    -- yang berada di Exclusive Store.
    local serverLuckGui = pg:FindFirstChild("!!! Server Luck")
    if serverLuckGui then
        scanContainer(serverLuckGui)
    end

    -- Fallback: kalau GUI belum ditemukan/namanya berubah, scan PlayerGui.
    if not luckValue or not luckEnds then
        for _, v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                local t = cleanText(v)
                if t ~= "" then
                    if not luckValue then luckValue = extractLuck(t) end
                    if not luckEnds then luckEnds = extractTimer(t) end
                    if luckValue and luckEnds then break end
                end
            end
        end
    end

    return luckValue, luckEnds
end

local function BuildPlayerCheckDescription()
    local players = Players:GetPlayers()
    local lines = {}

    table.insert(lines, "Total player aktif: **" .. #players .. "**")
    table.insert(lines, "")

    for _, p in ipairs(players) do
        local caught, location = GetPlayerStatsAndLocation(p)
        table.insert(lines, string.format(
            "• **%s** - 🐟 Caught: %s - %s %s",
            p.Name, caught, EMOJI_LOCATION, location
        ))
    end

    table.insert(lines, "")
    local luckVal, luckEnds = ScanServerLuckInfo()
    table.insert(lines, "• **Server Luck** : x" .. (luckVal or "?"))
    table.insert(lines, "• **End Server Luck** : Ends: " .. (luckEnds or "?"))
    table.insert(lines, "")
    table.insert(lines, "Updated: " .. os.date("%d/%m/%Y %H:%M:%S"))

    return table.concat(lines, "\n")
end

-- ============================================================
--  WEBHOOK SENDERS
-- ============================================================

local function BrandAuthor()
    if BRAND_ICON ~= "" then
        return { name = BRAND_NAME, icon_url = BRAND_ICON }
    end
    return { name = BRAND_NAME }
end

local function BuildEmbed(title, description, color, fields, imageUrl, thumbUrl, footerTag, author, exactFooter, hideTimestamp)
    local footerText = exactFooter and (footerTag or "") or ((footerTag or BRAND_FOOTER_TEXT) .. " " .. os.date("%d/%m/%Y %H:%M:%S"))
    local embed = {
        title       = title,
        description = description,
        color       = color,
        fields      = fields,
        footer      = { text = footerText },
    }
    if not hideTimestamp then
        embed.timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    end
    if imageUrl then embed.image     = { url = imageUrl } end
    if thumbUrl then embed.thumbnail = { url = thumbUrl } end
    embed.author = author or BrandAuthor()
    return embed
end

local function PostWebhook(url, body, forceSend)
    -- Setelah hard-stop selesai, instance script lama tidak boleh mengirim webhook lagi.
    if SCRIPT_TERMINATED and not forceSend then return end

    local requestFunc = GetRequestFunc()
    if not requestFunc then
        warn("[M B G DEBUG] PostWebhook gagal: gak ketemu request function (syn.request/http.request/http_request/fluxus.request/request semuanya nil). Executor lo mungkin gak support salah satu dari itu.")
        return
    end
    if url == "" then
        warn("[M B G DEBUG] PostWebhook gagal: url webhook KOSONG (\"\"). Cek input webhooknya udah keisi belum pas klik START MONITORING.")
        return
    end

    -- Setiap sesi monitoring punya nomor sendiri. Kalau monitor sudah ditutup,
    -- request lama yang masih ngantri dibatalkan sebelum benar-benar dikirim.
    local sessionAtQueue = MONITOR_SESSION

    local function DoRequest()
        local ok, err = pcall(function()
            local res = requestFunc({
                Url     = url,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = HttpService:JSONEncode(body),
            })
            local status = res and (res.StatusCode or res.status_code)
            if status and (status < 200 or status >= 300) then
                warn("[M B G DEBUG] Webhook response bukan 2xx! Status: " .. tostring(status) .. " | Body: " .. tostring(res.Body or res.body))
            end
        end)
        if not ok then
            warn("[M B G DEBUG] PostWebhook ERROR pas request: " .. tostring(err))
        end
    end

    -- Stop notification HARUS dikirim walaupun SCRIPT_ACTIVE baru saja dibuat false,
    -- jadi mode forceSend sengaja langsung melakukan request.
    if forceSend then
        DoRequest()
        return
    end

    task.spawn(function()
        if not SCRIPT_ACTIVE or sessionAtQueue ~= MONITOR_SESSION then return end
        DoRequest()
    end)
end

local function BuildContent(mention, captionType)
    if not mention or mention == "" then return nil end
    local m = Trim(mention)
    if captionType == "secret" or captionType == "forgotten" then return "Hari hari bersyukur " .. m
    elseif captionType == "leave"   then return "ke disconect ya? " .. m
    elseif captionType == "join"    then return "alhamdulilah kembali " .. m
    elseif captionType == "notback" then return "lah kok ngilang " .. m
    elseif captionType == "mutasi"  then return "cek mutasinya " .. m
    elseif captionType == "afk"     then return "woy pada tidur ya " .. m
    end
    return m
end

local function SendWebhook(title, description, color, fields, imageUrl, thumbUrl, mention, captionType)
    if not SCRIPT_ACTIVE then return end
    local f = {}
    for _, v in ipairs(fields) do table.insert(f, v) end
    PostWebhook(WEBHOOK_URL, {
        username   = "M B G",
        avatar_url = WEBHOOK_AVATAR,
        content    = BuildContent(mention, captionType),
        embeds     = { BuildEmbed(title, description, color, f, imageUrl, thumbUrl) },
    })
end

-- Monitoring Start/Stop memakai Webhook Stats.
-- Kalau Webhook Stats kosong, fallback ke Webhook Join/Leave.
local function GetMonitorWebhook()
    return (WEBHOOK_STATS ~= "") and WEBHOOK_STATS or WEBHOOK_URL
end

local function SendMonitorStartedWebhook(allPlayers, names)
    local url = GetMonitorWebhook()
    if url == "" then
        warn("[M B G DEBUG] Monitor Start gagal: Webhook Stats dan Webhook Join/Leave sama-sama kosong.")
        return
    end

    PostWebhook(url, {
        username   = "M B G",
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { BuildEmbed(
            EMOJI_STARTER .. " Monitor Started",
            "Server monitor sudah aktif",
            TierColors.Join,
            {
                { name = SEP .. " Host Server",  value = "SERVER BANG ADULLLLL",                    inline = true },
                { name = SEP .. " Total Player", value = "**" .. tostring(#allPlayers) .. "** orang", inline = true },
                { name = SEP .. " Daftar Player", value = "```\n" .. table.concat(names, ", ") .. "```", inline = false },
            }
        )},
    }, true)
end

local function SendMonitorStoppedWebhook()
    local url = GetMonitorWebhook()
    if url == "" then
        warn("[M B G DEBUG] Monitor Stop gagal: Webhook Stats dan Webhook Join/Leave sama-sama kosong.")
        return
    end

    PostWebhook(url, {
        username   = "M B G",
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { { title = "🔴 Webhook off dulu, silahkan cek tas masing masing" } },
    }, true)
end

local function SendFishWebhook(title, description, color, fields, imageUrl, thumbUrl, mention, captionType)
    if not SCRIPT_ACTIVE then return end
    local url = (WEBHOOK_FISH ~= "") and WEBHOOK_FISH or WEBHOOK_URL
    if url == "" then return end
    local f = {}
    for _, v in ipairs(fields) do table.insert(f, v) end
    PostWebhook(url, {
        content = BuildContent(mention, captionType),
        embeds  = { BuildEmbed(title, description, color, f, imageUrl, thumbUrl) },
    })
end

-- Webhook khusus mutasi list, terpisah dari webhook secret fish.
-- Fallback: kalau WEBHOOK_MUTASI kosong -> pakai WEBHOOK_FISH -> kalau itu juga kosong pakai WEBHOOK_URL.
local function SendMutasiWebhook(title, description, color, fields, imageUrl, thumbUrl, mention, captionType)
    if not SCRIPT_ACTIVE then return end
    local url = (WEBHOOK_MUTASI ~= "") and WEBHOOK_MUTASI
        or ((WEBHOOK_FISH ~= "") and WEBHOOK_FISH or WEBHOOK_URL)
    if url == "" then return end
    local f = {}
    for _, v in ipairs(fields) do table.insert(f, v) end
    PostWebhook(url, {
        username   = "M B G Mutasi",
        avatar_url = WEBHOOK_AVATAR,
        content    = BuildContent(mention, captionType),
        embeds     = { BuildEmbed(title, description, color, f, imageUrl, thumbUrl, "M B G Mutasi List") },
    })
end

-- Webhook "Check Player On Server" -- kirim daftar semua player + coin + lokasi + server luck.
-- Fallback: kalau WEBHOOK_CHECKPLAYER kosong -> pakai WEBHOOK_STATS -> kalau itu juga kosong pakai WEBHOOK_URL.
local function SendPlayerCheckWebhook()
    if not SCRIPT_ACTIVE then return end
    local url = (WEBHOOK_CHECKPLAYER ~= "") and WEBHOOK_CHECKPLAYER
        or ((WEBHOOK_STATS ~= "") and WEBHOOK_STATS or WEBHOOK_URL)

    print("[M B G DEBUG] SendPlayerCheckWebhook dipanggil. WEBHOOK_CHECKPLAYER='" .. tostring(WEBHOOK_CHECKPLAYER)
        .. "' WEBHOOK_STATS='" .. tostring(WEBHOOK_STATS) .. "' WEBHOOK_URL='" .. tostring(WEBHOOK_URL)
        .. "' -> dipakai: '" .. tostring(url) .. "'")

    if url == "" then
        warn("[M B G DEBUG] SendPlayerCheckWebhook batal: gak ada webhook valid sama sekali (checkplayer/stats/join semuanya kosong).")
        return
    end

    local description = BuildPlayerCheckDescription()
    print("[M B G DEBUG] Deskripsi embed panjangnya " .. tostring(#description) .. " karakter")
    PostWebhook(url, {
        username   = "M B G",
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { BuildEmbed(
            EMOJI_CHECK .. " Check Player On Server OM BEDULLLL " ,
            description,
            TierColors.Join,
            {},
            nil, nil,
            "Youtube Premium & aplikasi premium lainnya bisa pm ke @ariefwibowooo",
            nil,
            true,
            true
        )},
    })
end

-- ============================================================
--  EVENT WEBHOOK SENDER
-- ============================================================

local function ScheduleEventEndNotification(eventData, eventStartTime)
    local endTime = eventStartTime + (60 * 60)
    local nextEventTime = eventStartTime + (3 * 60 * 60)

    task.delay(math.max(0, endTime - os.time()), function()
        if not SCRIPT_ACTIVE then return end

        local url = (WEBHOOK_EVENT ~= "") and WEBHOOK_EVENT or WEBHOOK_URL
        if url == "" then return end

        PostWebhook(url, {
            username   = "M B G Event",
            avatar_url = WEBHOOK_AVATAR,
            embeds     = { BuildEmbed(
                eventData.title:gsub("Dimulai!", "Berakhir!"),
                "⏰ Udah sejam lee, pikirkan secara logika next elemental event yang muncul",
                2303786,
                {
                    { name = SEP .. " Status",     value = "**SELESAI**", inline = true },
                    { name = SEP .. " Next Event", value = "<t:" .. tostring(nextEventTime) .. ":R>", inline = true },
                },
                nil,
                FishImageURL["next"],
                "M B G Event Monitor",
                { name = EMOJI_EVENTTAG .. " Event Hunt Alert",
                  icon_url = WEBHOOK_AVATAR ~= "" and WEBHOOK_AVATAR or nil }
            )},
        })
    end)
end

local function SendEventWebhook(eventData, rawText)
    local url = (WEBHOOK_EVENT ~= "") and WEBHOOK_EVENT or WEBHOOK_URL
    if url == "" then return end

    -- Patokan waktu = saat script pertama kali menemukan event.
    local eventStartTime = os.time()
    local endTime = eventStartTime + (60 * 60)

    PostWebhook(url, {
        username   = "M B G Event",
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { BuildEmbed(
            eventData.title,
            eventData.description,
            eventData.color,
            {
                { name = SEP .. " Host Server",  value = "SERVER BANG ADULLLLL",              inline = true },
                { name = SEP .. " Total Player", value = "**" .. tostring(#Players:GetPlayers()) .. "** orang", inline = true },
                { name = SEP .. " Berakhir Pada", value = "<t:" .. tostring(endTime) .. ":R>", inline = true },
            },
            nil,
            eventData.thumbUrl,
            "M B G Event Monitor",
            { name = EMOJI_EVENTTAG .. " Event Hunt Alert", icon_url = WEBHOOK_AVATAR ~= "" and WEBHOOK_AVATAR or nil }
        )},
    })

    if eventData.isElemental then
        ScheduleEventEndNotification(eventData, eventStartTime)
    end
end

-- ============================================================
--  AFK / IDLE WEBHOOK SENDER
--  Dikirim ke webhook JOIN/LEAVE (WEBHOOK_URL) saat player gak
--  ada catch sama sekali selama AFK_THRESHOLD_SECONDS (1 jam).
-- ============================================================

local function SendAfkWebhook(pName, mentionStr, avatarUrl)
    SendWebhook(EMOJI_AFK .. " Player Idle Terdeteksi", "Pemain ini kayaknya lagi gak mancing (gak ada catch sama sekali).", TierColors.AFK, {
        { name = SEP .. " Username", value = "**" .. pName .. "**",                          inline = true },
        { name = SEP .. " Info",     value = "Tidak ada catch selama **60 menit**",           inline = true },
    }, nil, avatarUrl, mentionStr, "afk")
end

-- ============================================================
--  EVENT DETECTION
--  Mekanisme dasar mengikuti Heaven.lua yang sudah terbukti terbaca:
--  TextLabel/TextButton -> ProcessEventText -> edge trigger OFF -> ON.
--  Bedanya, MBG tetap memakai filter khusus Elemental supaya Storm Weather
--  tidak dianggap sebagai Storm Elemental.
-- ============================================================

local _hookedLabels = {}
local LabelEventState = {}

local function MatchEventText(lower, evData)
    -- Trigger eksplisit dari EventHuntData.
    -- Untuk event Elemental, semua trigger aktif di DB mengandung "elemental",
    -- sehingga kata "storm" saja tidak pernah cukup untuk memicu webhook.
    for _, trigger in ipairs(evData.textTriggers) do
        if lower:find(trigger, 1, true) then
            if not evData.isElemental or lower:find("elemental", 1, true) then
                return true
            end
        end
    end

    -- Fallback seperti pola Heaven, tetapi dipersempit untuk Elemental.
    -- Ini menjaga toleransi terhadap perubahan kecil pada kalimat GUI tanpa
    -- membuka false-positive dari Storm Weather / cuaca biasa.
    if evData.isElemental then
        local eventName = nil
        local titleLower = evData.title:lower()

        if titleLower:find("storm", 1, true) then
            eventName = "storm"
        elseif titleLower:find("blizzard", 1, true) then
            eventName = "blizzard"
        elseif titleLower:find("volcano", 1, true) then
            eventName = "volcano"
        end

        if eventName
            and lower:find(eventName, 1, true)
            and lower:find("elemental", 1, true) then
            return true
        end
    end

    return false
end

local function ProcessEventText(text, label)
    if not SCRIPT_ACTIVE then return end
    if not EVENT_NOTIF_ENABLED then return end
    if not text or text == "" then return end

    local lower = text:lower()
    local state = LabelEventState[label]
    if not state then
        state = {}
        LabelEventState[label] = state
    end

    for _, evData in ipairs(EventHuntData) do
        local matched = MatchEventText(lower, evData)
        local wasMatched = state[evData.title] or false
        state[evData.title] = matched

        -- Edge trigger: hanya OFF -> ON yang mengirim webhook.
        if matched and not wasMatched then
            local now = os.time()
            if (now - (EventCooldown[evData.title] or 0)) >= EVENT_COOLDOWN_SECONDS then
                EventCooldown[evData.title] = now
                SendEventWebhook(evData, text)
            end
        end
    end
end

local function HookLabel(label, baselineOnly)
    if _hookedLabels[label] then return end
    _hookedLabels[label] = true

    if baselineOnly then
        -- Saat execute, event yang sudah aktif dianggap kondisi awal.
        -- Tidak mengirim ON webhook dan tidak membuat scheduler baru.
        local lower = (label.Text or ""):lower()
        local state = {}
        LabelEventState[label] = state
        for _, evData in ipairs(EventHuntData) do
            state[evData.title] = MatchEventText(lower, evData)
        end
    else
        -- Label baru setelah monitor aktif diproses langsung, mengikuti Heaven.
        ProcessEventText(label.Text, label)
    end

    label:GetPropertyChangedSignal("Text"):Connect(function()
        ProcessEventText(label.Text, label)
    end)

    label.AncestryChanged:Connect(function(_, parent)
        if not parent then
            LabelEventState[label] = nil
        end
    end)
end

local function StartEventMonitor()
    task.spawn(function()
        local pg = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
        if not pg then return end

        -- Label yang sudah ada saat execute hanya dijadikan baseline.
        for _, v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                HookLabel(v, true)
            end
        end

        -- Label yang muncul setelah monitor aktif langsung diproses seperti Heaven.
        pg.DescendantAdded:Connect(function(v)
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                task.wait(0)
                HookLabel(v, false)
            end
        end)
    end)
end

-- ============================================================
--  CHAT PARSING & DETECTION
-- ============================================================

local function ParseChat(rawMsg)
    local msg = StripTags(rawMsg)
    msg = string.gsub(msg, "^%[Server%]:%s*", "")
    local playerName, fishFull, weight = string.match(msg, "^(.-) obtained an? (.-) %(([%d%.%a]+ ?kg)%)")
    if not playerName then
        playerName, fishFull = string.match(msg, "^(.-) obtained an? (.+)")
        weight = "N/A"
    end
    if not playerName or not fishFull then return nil end
    playerName = playerName:match("%[%a+%]:%s*(.+)") or playerName
    playerName = Trim(playerName)
    weight     = weight and Trim(weight) or "N/A"
    fishFull   = fishFull:match("^(.-)%s+with a 1 in") or fishFull
    fishFull   = fishFull:match("^(.-)%s*[!%.]?$")     or fishFull
    fishFull   = Trim(fishFull)
    return { player = playerName, fish = fishFull, weight = weight }
end

local CLOUDINARY_CLOUD_NAME = "pd5qqwr4"
local CLOUDINARY_WATERMARK_ID = "D3770010-C528-4FA2-B72B-98C0D25646B5"

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

local function GetRobloxAvatarUrlById(userId)
    if not userId then return nil end

    local ok, body = pcall(function()
        return game:HttpGet(
            "https://thumbnails.roblox.com/v1/users/avatar-headshot"
            .. "?userIds=" .. tostring(userId)
            .. "&size=420x420&format=Png&isCircular=false"
        )
    end)
    if not ok then return nil end

    local decodedOk, data = pcall(function()
        return HttpService:JSONDecode(body)
    end)
    if not decodedOk or not data or not data.data or not data.data[1] then return nil end
    if data.data[1].state ~= "Completed" then return nil end

    return data.data[1].imageUrl
end

local function GetAvatarUrlById(userId)
    local avatarUrl = GetRobloxAvatarUrlById(userId)
    if not avatarUrl then return nil end

    -- Cloudinary: watermark menjadi BASE/BACKGROUND, avatar Roblox menjadi OVERLAY/FRONT.
    -- Jadi urutannya: watermark di belakang -> avatar Roblox di depan.
    -- Ini hanya dynamic fetch/transform; tidak meng-upload file avatar baru ke Cloudinary.
    local encodedAvatar = Base64EncodeUrl(avatarUrl)
    if not encodedAvatar then
        warn("[M B G Avatar] Base64 encoder tidak tersedia, fallback ke avatar Roblox.")
        return avatarUrl
    end

    local cloudinaryUrl = "https://res.cloudinary.com/" .. CLOUDINARY_CLOUD_NAME
        .. "/image/upload/c_fill,w_420,h_420"
        .. "/l_fetch:" .. encodedAvatar
        .. "/c_fill,w_420,h_420/fl_layer_apply"
        .. "/" .. CLOUDINARY_WATERMARK_ID

    return cloudinaryUrl
end

-- ============================================================
--  AFK / IDLE MONITOR LOOP
--  Scan berkala tiap AFK_CHECK_INTERVAL detik: kalau ada player
--  yang udah >= AFK_THRESHOLD_SECONDS gak pernah keluar catch-nya
--  (lastCatchTime), kirim notif SEKALI ke webhook join/leave.
--  Notif reset lagi (afkNotified = false) begitu player itu catch lagi.
-- ============================================================

local function StartAfkMonitor()
    task.spawn(function()
        while SCRIPT_ACTIVE do
            task.wait(AFK_CHECK_INTERVAL)
            if not SCRIPT_ACTIVE then break end

            local now = os.time()
            for uid, stats in pairs(PlayerStats) do
                local baseline = stats.lastCatchTime or stats.joinTime or now
                if not stats.afkNotified and (now - baseline) >= AFK_THRESHOLD_SECONDS then
                    stats.afkNotified = true

                    local player     = Players:GetPlayerByUserId(uid)
                    local pName      = (player and player.Name) or stats.name or "Unknown"
                    local avatarUrl  = AvatarCache[uid] or GetAvatarUrlById(uid)
                    local mentionStr = GetMention(pName)

                    SendAfkWebhook(pName, mentionStr, avatarUrl)
                end
            end
        end
    end)
end

local function CheckAndSend(rawMsg)
    if not SCRIPT_ACTIVE then return end
    if not string.find(string.lower(rawMsg), "obtained") then return end

    local data = ParseChat(rawMsg)
    if not data then return end

    local targetPlayer = FindPlayer(data.player)
    local uid = (targetPlayer and targetPlayer.UserId)
             or PlayerNameToId[string.lower(data.player)]
    local avatarUrl = GetAvatarUrlById(uid)

    if uid then
        if not PlayerStats[uid] then
            PlayerStats[uid] = { catchCount = 0, secretList = {}, joinTime = os.time(), name = data.player, lastCatchTime = os.time(), afkNotified = false }
        end
        PlayerStats[uid].catchCount = PlayerStats[uid].catchCount + 1
        -- Ada catch baru -> reset timer idle & flag notifikasi AFK-nya.
        PlayerStats[uid].lastCatchTime = os.time()
        PlayerStats[uid].afkNotified   = false
    end

    local legendaryBase = FindLegendaryCrystal(data.fish)
    if legendaryBase then
        local imageUrl = GetFishImageURL(legendaryBase) or (FishImageCache[legendaryBase] and (PROXY .. "/asset/" .. FishImageCache[legendaryBase]))
        SendFishWebhook(EMOJI_LEGENDARY .. " Crystalized Legendary!", "", TierColors.Legendary, {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Item",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
        }, nil, imageUrl, nil, "secret")
        return
    end

    -- Mythic tier (Shiny Hammerhead Shark, Cosmic Hammerhead Shark, Cosmic Blobfish) -- embed merah polos, dicek SEBELUM
    -- Ruby & Secret biar gak ketimpa deteksi lain.
    local mythicBase = FindMythicFish(data.fish)
    if mythicBase then
        local imageUrl = GetFishImageURL(mythicBase) or (FishImageCache[mythicBase] and (PROXY .. "/asset/" .. FishImageCache[mythicBase]))
        SendFishWebhook(EMOJI_NOTIF .. " Mythic Fish Detected!", "", TierColors.Mitos, {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Ikan",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
        }, nil, imageUrl, GetMention(data.player), "secret")
        return
    end

    local rubyBase = FindRuby(data.fish)
    if rubyBase then
        local imageUrl = GetFishImageURL(rubyBase) or (FishImageCache[rubyBase] and (PROXY .. "/asset/" .. FishImageCache[rubyBase]))
        SendFishWebhook(EMOJI_RUBY .. " Ruby Gemstone!", "", TierColors.Ruby, {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Item",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
        }, nil, imageUrl, nil, "secret")
        return
    end

    local baseName, mutasi = FindSecretFish(data.fish)
    if baseName then
        local imageUrl = GetFishImageURL(baseName) or (FishImageCache[baseName] and (PROXY .. "/asset/" .. FishImageCache[baseName]))
        local isForgotten = false
        for _, name in ipairs(ForgottenList) do
            if string.lower(baseName) == string.lower(name) then isForgotten = true; break end
        end
        if uid and PlayerStats[uid] then
            PlayerStats[uid].secretList[baseName] = (PlayerStats[uid].secretList[baseName] or 0) + 1
        end
        local chanceInfo  = FishChanceData[baseName] or "Unknown"
        local mutasiField = mutasi and (EMOJI_MUTASI .. " *" .. mutasi .. "*") or "—"
        local fields = {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Ikan",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
            { name = SEP .. " Mutasi", value = mutasiField,                  inline = true },
            { name = SEP .. " Chance", value = chanceInfo,                   inline = true },
        }
        if isForgotten then
            SendFishWebhook(EMOJI_FORGOTTEN .. " Forgotten Tier Detected!", "", TierColors.Forgotten, fields, nil, imageUrl, GetMention(data.player), "forgotten")
        else
            SendFishWebhook(EMOJI_NOTIF .. " Secret Fish Detected!", "", TierColors.Secret, fields, nil, imageUrl, GetMention(data.player), "secret")
        end
        return
    end

    -- Mutasi (di luar secret fish) dikirim ke webhook mutasi sendiri, tanpa mention.
    local mutasiDetected = FindMutasi(data.fish)
    if not mutasiDetected then return end

    if uid and PlayerStats[uid] then
        PlayerStats[uid].mutasiCount = (PlayerStats[uid].mutasiCount or 0) + 1
    end

    SendMutasiWebhook(
        EMOJI_MUTASI .. " Mutasi Terdeteksi!", "", TierColors.Mutasi,
        {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**",            inline = true },
            { name = SEP .. " Ikan",   value = "**" .. data.fish .. "**",              inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**",            inline = true },
            { name = SEP .. " Mutasi", value = EMOJI_MUTASI .. " " .. mutasiDetected,  inline = true },
        },
        nil, avatarUrl, nil, "mutasi"
    )
end

-- ============================================================
--  BACKPACK MONITOR
-- ============================================================

local function WatchBackpack(bp)
    bp.ChildAdded:Connect(function(item)
        task.wait(0.1)
        local baseName = FindSecretFish(item.Name)
        if baseName and not GetFishImageURL(baseName) and not FishImageCache[baseName] then
            local imgId = GetFishImageId(item)
            if imgId then FishImageCache[baseName] = imgId end
        end
    end)
end

local function WatchForFish(player)
    local bp = player:FindFirstChild("Backpack")
    if bp then WatchBackpack(bp) end
    player.CharacterAdded:Connect(function()
        local newBp = player:WaitForChild("Backpack", 15)
        if newBp then WatchBackpack(newBp) end
    end)
end

-- ============================================================
--  HOOK CHAT
-- ============================================================

local function HookChat()
    -- Queue khusus command !mbg supaya kalau beberapa orang mengetik hampir
    -- bersamaan, request Check Player tidak ditembak ke webhook secara serentak.
    -- Ini juga mencegah satu pesan yang terbaca lewat TextChatService + Legacy
    -- Chat terkirim dua kali.
    local checkQueue = {}
    local checkQueueRunning = false
    local lastCommandByUser = {}

    local function QueuePlayerCheck(senderUserId)
        if not SCRIPT_ACTIVE then return end

        senderUserId = tonumber(senderUserId) or 0
        local now = os.clock()

        -- TextChatService dan Legacy Chat kadang sama-sama menerima pesan yang
        -- sama. Abaikan duplicate dari pengirim yang sama dalam 1 detik.
        if senderUserId ~= 0 and lastCommandByUser[senderUserId]
            and (now - lastCommandByUser[senderUserId]) < 1 then
            return
        end
        if senderUserId ~= 0 then
            lastCommandByUser[senderUserId] = now
        end

        table.insert(checkQueue, true)
        if checkQueueRunning then return end
        checkQueueRunning = true

        task.spawn(function()
            while #checkQueue > 0 do
                table.remove(checkQueue, 1)
                if SCRIPT_ACTIVE then
                    SendPlayerCheckWebhook()
                end
                -- Beri jarak antar request agar beberapa !mbg tidak
                -- menghantam webhook dalam waktu yang sama.
                if #checkQueue > 0 then
                    task.wait(0.6)
                end
            end
            checkQueueRunning = false
        end)
    end

    local function IsCheckPlayerCommand(text)
        if not text then return false end
        text = tostring(text)
        -- Hilangkan RichText/tag yang mungkin ikut terbawa dari chat.
        text = text:gsub("<[^>]+>", "")
        text = Trim(string.lower(text))
        return text == "!mbg"
    end

    if TextChatService then
        TextChatService.MessageReceived:Connect(function(msg)
            if not msg then return end

            local text = tostring(msg.Text or "")
            if text == "" then return end

            -- Jangan lagi bergantung pada TextSource == nil. Pesan chat pemain
            -- tetap diproses untuk command, sedangkan CheckAndSend() hanya
            -- dijalankan untuk pesan yang memang berisi hasil catch.
            CheckAndSend(text)

            if IsCheckPlayerCommand(text) and SCRIPT_ACTIVE then
                local senderUserId = msg.TextSource and msg.TextSource.UserId or 0
                QueuePlayerCheck(senderUserId)
            end
        end)
    end

    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local onMessage = chatEvents:FindFirstChild("OnMessageDoneFiltering")
        if onMessage then
            onMessage.OnClientEvent:Connect(function(d)
                if not (d and d.Message) then return end

                local text = tostring(d.Message)
                if text == "" then return end

                -- Legacy Chat tetap menjadi fallback untuk detector catch.
                local lowerMsg = string.lower(text)
                if string.find(lowerMsg, "%[server%]") or string.find(lowerMsg, "obtained") then
                    CheckAndSend(text)
                end

                if IsCheckPlayerCommand(text) and SCRIPT_ACTIVE then
                    -- Legacy event tidak selalu menyediakan UserId pengirim,
                    -- jadi gunakan nama/isi pesan sebagai fallback dedupe.
                    QueuePlayerCheck(0)
                end
            end)
        end
    end
end

-- ============================================================
--  START MONITORING
-- ============================================================

local function StartMonitoring()
    CacheSpawnLocations() -- scan folder "!!! SPAWN LOCATIONS" sekali di awal monitoring

    local allPlayers = Players:GetPlayers()
    local names      = {}
    for _, p in ipairs(allPlayers) do table.insert(names, p.Name) end

    SendMonitorStartedWebhook(allPlayers, names)

    HookChat()
    StartEventMonitor()
    StartAfkMonitor() -- mulai loop deteksi idle/gak mancing (1 jam tanpa catch)

    -- NOTE: webhook "Check Player On Server" cuma kekirim kalau di-trigger manual
    -- (klik tombol CHECK PLAYER di panel, atau ketik "!MBG" di chat game).
    -- Gak ada loop auto-send / rekap otomatis lagi.

    for _, p in ipairs(allPlayers) do
        WatchForFish(p)
        AvatarCache[p.UserId]                       = GetAvatarUrlById(p.UserId)
        PlayerStats[p.UserId]                       = { catchCount = 0, secretList = {}, joinTime = os.time(), name = p.Name, lastCatchTime = os.time(), afkNotified = false }
        PlayerNameToId[string.lower(p.Name)]        = p.UserId
        PlayerNameToId[string.lower(p.DisplayName)] = p.UserId
        BuildMentionCache(p.Name, p.DisplayName)
    end

    Players.PlayerAdded:Connect(function(player)
        if not SCRIPT_ACTIVE then return end
        LeaveTimers[player.UserId] = nil
        PlayerStats[player.UserId] = { catchCount = 0, secretList = {}, joinTime = os.time(), name = player.Name, lastCatchTime = os.time(), afkNotified = false }
        PlayerNameToId[string.lower(player.Name)]        = player.UserId
        PlayerNameToId[string.lower(player.DisplayName)] = player.UserId
        BuildMentionCache(player.Name, player.DisplayName)
        task.spawn(function()
            task.wait(1)
            if not SCRIPT_ACTIVE then return end
            AvatarCache[player.UserId] = GetAvatarUrlById(player.UserId)
            SendWebhook(EMOJI_JOIN .. " Player Joined Server", "welcam", TierColors.Join, {
                { name = SEP .. " Username",     value = "**" .. player.Name .. "**",                     inline = true },
                { name = SEP .. " Total Player", value = "**" .. tostring(#Players:GetPlayers()) .. "**", inline = true },
            }, nil, AvatarCache[player.UserId], GetMention(player.Name), "join")
        end)
        WatchForFish(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if not SCRIPT_ACTIVE then return end
        local pName      = player.Name
        local pId        = player.UserId
        local avatarUrl  = AvatarCache[pId] or GetAvatarUrlById(pId)
        local totalNow   = #Players:GetPlayers() - 1
        local mentionStr = GetMention(pName)

        AvatarCache[pId]                    = nil
        PlayerStats[pId]                    = nil
        PlayerNameToId[string.lower(pName)] = nil
        for k, v in pairs(PlayerNameToId) do if v == pId then PlayerNameToId[k] = nil end end
        MentionCache[string.lower(pName)]   = nil

        SendWebhook(EMOJI_LEAVE .. " Player Left Server", "Salah satu pemain keluar server.", TierColors.Leave, {
            { name = SEP .. " Username",     value = "**" .. pName .. "**",              inline = true },
            { name = SEP .. " Total Player", value = "**" .. tostring(totalNow) .. "**", inline = true },
        }, nil, avatarUrl, mentionStr, "leave")

        LeaveTimers[pId] = true
        task.spawn(function()
            task.wait(600)
            if not SCRIPT_ACTIVE then return end
            if LeaveTimers[pId] then
                LeaveTimers[pId] = nil
                local notBackContent = BuildContent(mentionStr, "notback")
                PostWebhook(WEBHOOK_URL, {
                    username   = "M B G",
                    avatar_url = WEBHOOK_AVATAR,
                    content    = notBackContent,
                    embeds     = { BuildEmbed(EMOJI_NOTBACK .. " Player Tidak Kembali", "Pemain ini belum balik lagi ke server, semoga aman ya~", TierColors.NotBack, {
                        { name = SEP .. " Username", value = "**" .. pName .. "**",               inline = true },
                        { name = SEP .. " Info",     value = "Tidak kembali selama **10 menit**", inline = true },
                    }, avatarUrl, nil, "M B G Webhook") },
                })
            end
        end)
    end)
end

-- ============================================================
--  UI
-- ============================================================

local function CreateUI()
    local gui = Instance.new("ScreenGui")
    gui.Name         = "BloxGankUI"
    gui.ResetOnSpawn = false
    gui.Parent       = (gethui and gethui()) or CoreGui

    local savedConfig = LoadConfig()

    -- Webhook inputs + toggle ditaruh di ScrollingFrame + UIListLayout supaya otomatis
    -- nyusun elemen berurutan tanpa nabrak, dan bisa di-scroll kalau kepanjangan.
    -- Tombol aksi (CHECK PLAYER / START) tetap fixed di bawah, di luar scroll,
    -- biar selalu keliatan & gampang dijangkau.
    local FRAME_H = 430
    local frame = Instance.new("Frame")
    frame.Name             = "Main"
    frame.Size             = UDim2.new(0, 300, 0, FRAME_H)
    frame.AnchorPoint       = Vector2.new(0.5, 0.5)
    frame.Position          = UDim2.new(0.5, 0, 0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel  = 0
    frame.ClipsDescendants = true
    frame.Parent           = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(50, 50, 50); stroke.Thickness = 1; stroke.Parent = frame

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36); topBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    topBar.BorderSizePixel = 0; topBar.Parent = frame
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

    local topBarFix = Instance.new("Frame")
    topBarFix.Size = UDim2.new(1, 0, 0, 8); topBarFix.Position = UDim2.new(0, 0, 1, -8)
    topBarFix.BackgroundColor3 = Color3.fromRGB(30, 30, 30); topBarFix.BorderSizePixel = 0; topBarFix.Parent = topBar

    local title = Instance.new("TextLabel")
    title.Text = "🎣 Main Bareng Gengz Monitor"; title.Size = UDim2.new(1, -80, 1, 0); title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1; title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = topBar

    local function MakeWinBtn(text, xOffset, bgColor)
        local btn = Instance.new("TextButton")
        btn.Text = text; btn.Size = UDim2.new(0, 28, 0, 22); btn.Position = UDim2.new(1, xOffset, 0.5, -11)
        btn.BackgroundColor3 = bgColor; btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 12; btn.BorderSizePixel = 0; btn.Parent = topBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        return btn
    end

    local minBtn   = MakeWinBtn("—", -58, Color3.fromRGB(60, 60, 60))
    local closeBtn = MakeWinBtn("✕", -28, Color3.fromRGB(200, 50, 50))

    minBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
    end)

    -- ============================================================
    --  FLOATING LOGO INDICATOR
    -- ============================================================
    local floatLogo = Instance.new("ImageButton")
    floatLogo.Name             = "BloxGankFloatLogo"
    floatLogo.Size             = UDim2.new(0, 46, 0, 46)
    floatLogo.Position         = UDim2.new(0, 20, 0, 90)
    floatLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    floatLogo.Image            = BRAND_ICON
    floatLogo.ScaleType        = Enum.ScaleType.Crop
    floatLogo.BorderSizePixel  = 0
    floatLogo.ZIndex           = 5
    floatLogo.Parent           = gui
    Instance.new("UICorner", floatLogo).CornerRadius = UDim.new(1, 0)

    local floatStroke = Instance.new("UIStroke")
    floatStroke.Color     = Color3.fromRGB(50, 50, 50)
    floatStroke.Thickness = 2
    floatStroke.Parent    = floatLogo

    local floatStatusDot = Instance.new("Frame")
    floatStatusDot.Size             = UDim2.new(0, 14, 0, 14)
    floatStatusDot.Position         = UDim2.new(1, -14, 1, -14)
    floatStatusDot.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    floatStatusDot.BorderSizePixel  = 0
    floatStatusDot.ZIndex           = 6
    floatStatusDot.Parent           = floatLogo
    Instance.new("UICorner", floatStatusDot).CornerRadius = UDim.new(1, 0)

    local floatStatusDotStroke = Instance.new("UIStroke")
    floatStatusDotStroke.Color     = Color3.fromRGB(20, 20, 20)
    floatStatusDotStroke.Thickness = 2
    floatStatusDotStroke.Parent    = floatStatusDot

    local floatPulseTween = nil
    local function SetFloatStatus(active)
        floatStatusDot.BackgroundColor3 = active and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(255, 60, 60)
        floatStroke.Color               = active and Color3.fromRGB(0, 220, 100) or Color3.fromRGB(50, 50, 50)
        if floatPulseTween then floatPulseTween:Cancel(); floatPulseTween = nil end
        floatStroke.Transparency = 0
        if active then
            floatPulseTween = TweenService:Create(
                floatStroke,
                TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                { Transparency = 0.55, Thickness = 3 }
            )
            floatPulseTween:Play()
        else
            floatStroke.Thickness = 2
        end
    end
    SetFloatStatus(false)

    local floatDragging, floatDragStart, floatStartPos, floatMoved = false, nil, nil, false

    floatLogo.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging  = true
            floatMoved     = false
            floatDragStart = input.Position
            floatStartPos  = floatLogo.Position
        end
    end)

    floatLogo.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            floatDragging = false
            if not floatMoved then
                frame.Visible = not frame.Visible
            end
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if floatDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - floatDragStart
            if math.abs(delta.X) > 3 or math.abs(delta.Y) > 3 then floatMoved = true end
            floatLogo.Position = UDim2.new(
                floatStartPos.X.Scale, floatStartPos.X.Offset + delta.X,
                floatStartPos.Y.Scale, floatStartPos.Y.Offset + delta.Y
            )
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        if not SCRIPT_ACTIVE then
            SCRIPT_TERMINATED = true
            gui:Destroy()
            return
        end

        -- Matikan monitoring SEGERA. Semua webhook monitoring biasa
        -- langsung berhenti dan request lama yang masih ngantri dibatalkan.
        SCRIPT_ACTIVE = false
        MONITOR_SESSION = MONITOR_SESSION + 1

        -- Jadwalkan hard-stop dari SEKARANG, bukan setelah animasi GUI.
        -- Jadi batas matinya tetap maksimal 3 detik sejak tombol X ditekan.
        task.delay(3, function()
            SCRIPT_ACTIVE = false
            MONITOR_SESSION = MONITOR_SESSION + 1
            SCRIPT_TERMINATED = true
            if gui and gui.Parent then gui:Destroy() end
        end)

        -- Kirim SATU notif bahwa monitor benar-benar dimatikan.
        -- forceSend sengaja dipakai karena SCRIPT_ACTIVE sudah false.
        SendMonitorStoppedWebhook()

        SetFloatStatus(false)
        TweenService:Create(frame, TweenInfo.new(0.15), { Size = UDim2.new(0,300,0,0), BackgroundTransparency=1 }):Play()
        task.wait(0.2)
        if gui then gui:Destroy() end
    end)

    local function HoverTween(btn, hoverColor, baseColor)
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = hoverColor }):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), { BackgroundColor3 = baseColor  }):Play() end)
    end
    HoverTween(minBtn,   Color3.fromRGB(80,80,80),  Color3.fromRGB(60,60,60))
    HoverTween(closeBtn, Color3.fromRGB(230,70,70), Color3.fromRGB(200,50,50))

    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
        end
    end)

    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0,8,0,8); statusDot.Position = UDim2.new(0,16,0,46)
    statusDot.BackgroundColor3 = Color3.fromRGB(255,60,60); statusDot.BorderSizePixel = 0; statusDot.Parent = frame
    Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1,0)

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Text = "Tidak Aktif"; statusLabel.Size = UDim2.new(1,-40,0,20); statusLabel.Position = UDim2.new(0,30,0,38)
    statusLabel.BackgroundTransparency = 1; statusLabel.TextColor3 = Color3.fromRGB(180,180,180)
    statusLabel.Font = Enum.Font.Gotham; statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left; statusLabel.Parent = frame

    -- ============================================================
    --  SCROLLABLE CONTENT AREA (webhook inputs + toggle)
    -- ============================================================
    local BOTTOM_BLOCK_H = 74 -- tinggi area tombol aksi di bawah (fixed, di luar scroll)
    local SCROLL_Y        = 64

    local content = Instance.new("ScrollingFrame")
    content.Name                   = "Content"
    content.Position               = UDim2.new(0, 0, 0, SCROLL_Y)
    content.Size                   = UDim2.new(1, 0, 0, FRAME_H - SCROLL_Y - BOTTOM_BLOCK_H)
    content.BackgroundTransparency = 1
    content.BorderSizePixel        = 0
    content.ScrollBarThickness     = 3
    content.ScrollBarImageColor3   = Color3.fromRGB(80, 80, 80)
    content.CanvasSize             = UDim2.new(0, 0, 0, 0)
    content.Parent                 = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder     = Enum.SortOrder.LayoutOrder
    listLayout.Padding       = UDim.new(0, 4)
    listLayout.Parent        = content

    -- "AutomaticCanvasSize" gak semua executor/game client dukung, jadi canvas size
    -- dihitung MANUAL tiap kali AbsoluteContentSize berubah -- kompatibel di executor manapun.
    local function UpdateCanvasSize()
        content.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

    local listPad = Instance.new("UIPadding")
    listPad.PaddingLeft   = UDim.new(0, 12)
    listPad.PaddingRight  = UDim.new(0, 12)
    listPad.PaddingTop    = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 6)
    listPad.Parent        = content

    local function MakeLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Text = text; lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(130,130,130)
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = content
        return lbl
    end

    local function MakeInput(placeholder)
        local box = Instance.new("TextBox")
        box.PlaceholderText = placeholder; box.Size = UDim2.new(1, 0, 0, 28)
        box.BackgroundColor3 = Color3.fromRGB(35,35,35); box.TextColor3 = Color3.fromRGB(220,220,220)
        box.PlaceholderColor3 = Color3.fromRGB(100,100,100); box.Font = Enum.Font.Gotham; box.TextSize = 10
        box.ClearTextOnFocus = false; box.BorderSizePixel = 0; box.Text = ""
        box.TextXAlignment = Enum.TextXAlignment.Left; box.ClipsDescendants = true; box.Parent = content
        Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
        local pad = Instance.new("UIPadding", box); pad.PaddingLeft = UDim.new(0,8); pad.PaddingRight = UDim.new(0,8)
        return box
    end

    -- Toggle row: label kiri + switch kanan dalam satu baris ringkas.
    local function MakeToggleRow(labelText, defaultOn, onChange)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        row.Parent = content

        local lbl = Instance.new("TextLabel")
        lbl.Text = labelText; lbl.Size = UDim2.new(1, -44, 1, 0)
        lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(130,130,130)
        lbl.Font = Enum.Font.Gotham; lbl.TextSize = 10; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(0,36,0,18); bg.Position = UDim2.new(1,-36,0.5,-9)
        bg.BackgroundColor3 = Color3.fromRGB(60,60,60); bg.BorderSizePixel = 0; bg.Parent = row
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0,14,0,14); knob.Position = UDim2.new(0,2,0.5,-7)
        knob.BackgroundColor3 = Color3.fromRGB(200,200,200); knob.BorderSizePixel = 0; knob.Parent = bg
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local hitbox = Instance.new("TextButton")
        hitbox.Size = UDim2.new(0,36,0,18); hitbox.Position = UDim2.new(1,-36,0.5,-9)
        hitbox.BackgroundTransparency = 1; hitbox.Text = ""; hitbox.BorderSizePixel = 0; hitbox.Parent = row

        local state = false
        local function setState(enabled)
            state = enabled
            TweenService:Create(knob, TweenInfo.new(0.15), {
                Position         = enabled and UDim2.new(0,20,0.5,-7) or UDim2.new(0,2,0.5,-7),
                BackgroundColor3 = enabled and Color3.fromRGB(0,220,100) or Color3.fromRGB(200,200,200),
            }):Play()
            TweenService:Create(bg, TweenInfo.new(0.15), {
                BackgroundColor3 = enabled and Color3.fromRGB(0,100,50) or Color3.fromRGB(60,60,60),
            }):Play()
            lbl.TextColor3 = enabled and Color3.fromRGB(0,220,100) or Color3.fromRGB(130,130,130)
            if onChange then onChange(enabled) end
        end

        hitbox.MouseButton1Click:Connect(function() setState(not state) end)
        setState(defaultOn)

        return { setState = setState, getState = function() return state end, hitbox = hitbox }
    end

    MakeLabel("👋 Webhook Join / Leave")
    local inputJoin  = MakeInput("Paste webhook join/leave...")
    MakeLabel("🐋 Webhook Secret Fish")
    local inputFish  = MakeInput("Paste webhook secret fish...")
    MakeLabel("📊 Webhook Stats (fallback Check Player)")
    local inputStats = MakeInput("Paste webhook stats...")
    MakeLabel("🎯 Webhook Event Hunt (Role Nelayan)")
    local inputEvent = MakeInput("Kosong = pakai webhook join/leave...")
    MakeLabel("🧬 Webhook Mutasi List")
    local inputMutasi = MakeInput("Kosong = pakai webhook secret fish...")
    MakeLabel(EMOJI_CHECK .. " Webhook Check Player")
    local inputCheckplayer = MakeInput("Kosong = pakai webhook stats...")

    local saveEnabled = false
    local saveToggle = MakeToggleRow("💾 Simpan Config", false, function(enabled)
        saveEnabled = enabled
    end)

    -- Toggle ON/OFF khusus buat notifikasi Event Hunt (treasure/thunderzilla/crystal).
    -- Gak ngaruh ke fitur lain, bisa diubah kapan aja termasuk pas monitoring udah aktif.
    local eventToggle = MakeToggleRow("🔔 Notif Event Hunt", true, function(enabled)
        EVENT_NOTIF_ENABLED = enabled
    end)

    if savedConfig then
        if savedConfig.webhook_join        and savedConfig.webhook_join        ~= "" then inputJoin.Text        = savedConfig.webhook_join        end
        if savedConfig.webhook_fish        and savedConfig.webhook_fish        ~= "" then inputFish.Text        = savedConfig.webhook_fish        end
        if savedConfig.webhook_stats       and savedConfig.webhook_stats       ~= "" then inputStats.Text       = savedConfig.webhook_stats       end
        if savedConfig.webhook_event       and savedConfig.webhook_event       ~= "" then inputEvent.Text       = savedConfig.webhook_event       end
        if savedConfig.webhook_mutasi      and savedConfig.webhook_mutasi      ~= "" then inputMutasi.Text      = savedConfig.webhook_mutasi      end
        if savedConfig.webhook_checkplayer and savedConfig.webhook_checkplayer ~= "" then inputCheckplayer.Text = savedConfig.webhook_checkplayer end
        saveToggle.setState(true)
    end

    -- ============================================================
    --  TOMBOL AKSI (fixed di bawah, di luar scroll area)
    -- ============================================================
    local BTN_Y1 = FRAME_H - BOTTOM_BLOCK_H          -- CHECK PLAYER
    local BTN_Y3 = BTN_Y1 + 26 + 6                    -- START MONITORING

    local checkBtn = Instance.new("TextButton")
    checkBtn.Text = EMOJI_CHECK .. " CHECK PLAYER"; checkBtn.Size = UDim2.new(1,-24,0,26); checkBtn.Position = UDim2.new(0,12,0,BTN_Y1)
    checkBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); checkBtn.TextColor3 = Color3.fromRGB(220,220,220)
    checkBtn.Font = Enum.Font.GothamBold; checkBtn.TextSize = 11; checkBtn.BorderSizePixel = 0; checkBtn.Parent = frame
    Instance.new("UICorner", checkBtn).CornerRadius = UDim.new(0,6)
    HoverTween(checkBtn, Color3.fromRGB(65,65,65), Color3.fromRGB(45,45,45))

    checkBtn.MouseButton1Click:Connect(function()
        if not SCRIPT_ACTIVE then
            checkBtn.Text = "⚠️ Start monitoring dulu"
            task.wait(1.5)
            checkBtn.Text = EMOJI_CHECK .. " CHECK PLAYER"
            return
        end
        SendPlayerCheckWebhook()
        checkBtn.Text = "✅ Terkirim!"
        task.wait(1.2)
        checkBtn.Text = EMOJI_CHECK .. " CHECK PLAYER"
    end)

    local startBtn = Instance.new("TextButton")
    startBtn.Text = "START MONITORING"; startBtn.Size = UDim2.new(1,-24,0,34); startBtn.Position = UDim2.new(0,12,0,BTN_Y3)
    startBtn.BackgroundColor3 = Color3.fromRGB(0,180,100); startBtn.TextColor3 = Color3.fromRGB(255,255,255)
    startBtn.Font = Enum.Font.GothamBold; startBtn.TextSize = 12; startBtn.BorderSizePixel = 0; startBtn.Parent = frame
    startBtn.TextScaled  = true
    startBtn.TextWrapped = false
    local startBtnSizeConstraint = Instance.new("UITextSizeConstraint")
    startBtnSizeConstraint.MaxTextSize = 12
    startBtnSizeConstraint.Parent      = startBtn
    local startBtnPad = Instance.new("UIPadding", startBtn)
    startBtnPad.PaddingLeft  = UDim.new(0,6)
    startBtnPad.PaddingRight = UDim.new(0,6)
    Instance.new("UICorner", startBtn).CornerRadius = UDim.new(0,6)
    HoverTween(startBtn, Color3.fromRGB(0,210,120), Color3.fromRGB(0,180,100))

    startBtn.MouseButton1Click:Connect(function()
        if SCRIPT_ACTIVE then return end

        if not inputJoin.Text:find("discord.com/api/webhooks") then
            startBtn.Text = "❌ WEBHOOK JOIN INVALID!"; startBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
            task.wait(2); startBtn.Text = "START MONITORING"; startBtn.BackgroundColor3 = Color3.fromRGB(0,180,100)
            return
        end

        WEBHOOK_URL = inputJoin.Text
        if inputFish.Text:find("discord.com/api/webhooks")        then WEBHOOK_FISH        = inputFish.Text        end
        if inputStats.Text:find("discord.com/api/webhooks")       then WEBHOOK_STATS       = inputStats.Text       end
        if inputEvent.Text:find("discord.com/api/webhooks")       then WEBHOOK_EVENT       = inputEvent.Text       end
        if inputMutasi.Text:find("discord.com/api/webhooks")      then WEBHOOK_MUTASI      = inputMutasi.Text      end
        if inputCheckplayer.Text:find("discord.com/api/webhooks") then WEBHOOK_CHECKPLAYER = inputCheckplayer.Text end

        if saveEnabled then SaveConfig(WEBHOOK_URL, WEBHOOK_FISH, WEBHOOK_STATS, WEBHOOK_EVENT, WEBHOOK_MUTASI, WEBHOOK_CHECKPLAYER) end

        MONITOR_SESSION = MONITOR_SESSION + 1
        SCRIPT_ACTIVE = true
        statusDot.BackgroundColor3 = Color3.fromRGB(0,220,100)
        statusLabel.Text           = "Aktif — Monitoring..."
        statusLabel.TextColor3     = Color3.fromRGB(0,220,100)
        startBtn.Text              = "✅ MONITORING AKTIF"
        startBtn.BackgroundColor3  = Color3.fromRGB(30,30,30)

        SetFloatStatus(true)

        for _, box in ipairs({ inputJoin, inputFish, inputStats, inputEvent, inputMutasi, inputCheckplayer }) do
            box.TextEditable = false
        end
        saveToggle.hitbox.Active = false
        -- NOTE: eventToggle SENGAJA tetap aktif setelah monitoring jalan,
        -- biar notif Event Hunt bisa di-ON/OFF kapan aja tanpa stop monitoring.

        StartMonitoring()
    end)
end

-- ============================================================
--  INIT
-- ============================================================

local uiOk, uiErr = pcall(CreateUI)
if not uiOk then
    warn("[M B G] Gagal bikin UI: " .. tostring(uiErr))
end
