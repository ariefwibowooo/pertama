-- ============================================================
--  BLOX Gank Server Monitor  |  Discord: @bloxgank
-- ============================================================

local HttpService       = game:GetService("HttpService")
local Players           = game:GetService("Players")
local TextChatService    = game:GetService("TextChatService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local CoreGui            = game:GetService("CoreGui")
local TweenService       = game:GetService("TweenService")
local Workspace          = game:GetService("Workspace")

local WEBHOOK_URL         = ""
local WEBHOOK_FISH        = ""
local WEBHOOK_EVENT       = ""
local WEBHOOK_MUTASI      = ""
local WEBHOOK_CHECKPLAYER = ""
local WEBHOOK_BALANCER    = "" -- webhook khusus Elemental Balancer Tracking
local WEBHOOK_GALATAMA    = "" -- webhook khusus leaderboard Galatama. Kosong = fallback ke WEBHOOK_FISH lalu WEBHOOK_URL.
local WEBHOOK_AVATAR      = ""
local PROXY               = "https://square-haze-a007.remediashop.workers.dev"
local SCRIPT_ACTIVE       = false
local EVENT_NOTIF_ENABLED = true -- toggle ON/OFF notifikasi Event Hunt

local EVENT_COOLDOWN_SECONDS = 120
local ROLE_NELAYAN_ID        = "1547792158994464809"

local BRAND_NAME        = "BLOX GANK"
local BRAND_ICON        = "https://raw.githubusercontent.com/revkatomy-max/asset-id/main/blox%20logo.png"
local BRAND_FOOTER_TEXT = "BLOX GANK • Server Monitor"

local TierColors = {
    Secret    = 16754127,
    Forgotten = 16777215,
    Ruby      = 16753920,
    Legendary = 3407871,
    Mutasi    = 14149373,
    Join      = 10940871,
    Leave     = 16729344,
    NotBack   = 16711680,
    AFK       = 16119078,
    Mitos     = 16711680,
}

local EMOJI_NOTIF     = "<a:alert:1549710084244766830>"
local EMOJI_SEPARATOR = "<a:panah:1549711353390956564>"
local EMOJI_STARTER   = "<a:monitor:1549713022199668767>"
local EMOJI_FORGOTTEN = "<a:forgoten:1550326770064957531>"
local EMOJI_MUTASI    = "<a:mut:1549980637396475914>"
local EMOJI_RUBY       = "<a:ruby:1517740619794092153>"
local EMOJI_LEGENDARY  = "<a:apiijo:1517778951223902239>"
local EMOJI_TREASURE   = "<a:harta:1549712320916226218>"
local EMOJI_MEGALODON  = "<a:megablink:1517740677814030437>"
local EMOJI_THUNDER    = "<a:thunder:1517730620250390589>"
local EMOJI_THUNDER_TITLE = "⚡" -- Unicode plain, dipakai khusus di title/author embed
                                  -- (custom emoji animated <a:...> nggak dirender Discord
                                  -- di title/author name, cuma jalan di description/field)
local EMOJI_CRYSTAL    = "<a:crystal:1549712227735703552>"
local EMOJI_EVENTTAG   = "<:BloxylogoBOT:1550011261176258570>"
local EMOJI_JOIN       = "<a:masuk:1549980666144227408>"
local EMOJI_LEAVE      = "<a:pergi:1549980694204252271>"
local EMOJI_NOTBACK    = "<a:turu:1549988686874026094>"
local EMOJI_CHECK      = "<a:cari:1550011157006254110>"
local EMOJI_LOCATION   = "<a:lokasi:1550327235708452884>"
local EMOJI_AFK        = "<a:turu:1549988686874026094>"
local EMOJI_BLIZZARD   = "<a:beku:1549980720418525296>"
local EMOJI_STORM      = "<a:badai:1549980746473537658>"
local EMOJI_VOLCANIC   = "<a:gunung:1549980777650065538>"
local EMOJI_SILENTREACH = "🌊"
local SEP = EMOJI_SEPARATOR

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
    "Colossal Shipwreck Crab", "Astrelle", "Moonwake Ray", "Astralune", "Starglass Guardian", "Pelagon", "Crimson Dreadtusk", "Riftborn Arowana",
    "Pyrocoil", "Stormshell Brute", "Wintertusk Mammofin", "Elemental Hydra", "Overlord Hydra", "Tribunal Withering core", "Ashen Kingfish", "Everbloom", "Mr Money Bags", "Velobyte", "Cenobyte.EXE", "Shellshock X",
}

local ForgottenList = {
    "Sea Eater", "Thunderzilla", "Iridesca", "Frostbite Leviathan", "Fluorivane",
    "Cerulean Dragon", "Crystalline Behemoth", "Trench Warden", "Ragnarex", "Astralune", "Crimson Dreadtusk", "Elemental Hydra", "Overlord Hydra", "Everbloom","Cenobyte.EXE",
}

local MutasiList = {
    "Noob", "Fairy Dust", "Holographic", "Gemstone", "Fire", "Color Burn",
    "BloodMoon", "Binary", "Lightning", "Disco", "Festive", "Radioactive", "Moon Fragment", "Abyssal", "Cosmic", "Equinox", "Glitch",
    "Elemental", "Solar", "1x1x1", "Artic frost", "8-Bit",
}

-- whitelist nama spesies yang ke-false-positive kedetect sebagai mutasi (dibuang dulu sebelum scan mutasi)
local MutasiFalsePositiveSpecies = {
    "abyssal maw angler",
}

local LegendaryCrystalList = {
    "Blue Sea Dragon", "Star Snail", "Cute Dumbo", "Blossom Jelly", "Bioluminescent Octopus",
}

-- ============================================================
--  MYTHIC TIER (embed merah polos)
-- ============================================================
local MythicFishList = {
    "Shiny Hammerhead Shark",
}

-- ============================================================
--  GALATAMA EVENT — POINT BASED
-- ============================================================

-- Ikan tier SECRET yang kena hitungan poin Galatama.
local GalatamaFishPoints = {
    ["Velobyte"]       = 5000,
    ["Shellshock X"]   = 3000,
    ["Cenobyte.EXE"]   = 30000,
}

-- Bonus mutasi buat ikan tier SECRET: FLAT, semua jenis mutasi dapet poin yang sama,
-- KECUALI Big & Shiny (dua itu bukan mutasi beneran, cuma qualifier ukuran/visual).
local GALATAMA_SECRET_MUTASI_BONUS = 1000

-- Ikan tier MYTHIC khusus Galatama (terpisah dari MythicFishList di atas, yang itu
-- cuma buat embed merah polos "Shiny Hammerhead Shark") + poin base-nya.
local GalatamaMythicList = {
    "Toytech angler", "F-15H", "Mediclaw", "Circuit Shark", "Whaleware", "AX-0TL",
}

local GalatamaMythicFishPoints = {
    ["Toytech angler"]    = 100,
    ["F-15H"]             = 100,
    ["Mediclaw"]          = 100,
    ["Circuit Shark"]     = 100,
    ["Whaleware"]         = 100,
    ["AX-0TL"]            = 100,
}

-- Bonus mutasi buat ikan tier MYTHIC Galatama: FLAT juga, kecuali Big & Shiny.
local GALATAMA_MYTHIC_MUTASI_BONUS = 50

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
    ["Runic Enchant Stone"]       = "1 in 700k",
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
    ["Two-headed shark"]          = "1 in 3M",
    ["Ragnarex"]                  = "1 in 35M",
    ["Colossal Shipwreck Crab"]   = "1 in 5M",
    ["Astrelle"]                  = "1 in 6M",
    ["Moonwake Ray"] = "1 in 5M",
    ["Astralune"] = "1 in 20M",
    ["Starglass Guardian"] = "1 in 3M",
    ["Pelagon"] = "1 in 4.5M",
    ["Riftborn Arowana"] = "1 in 4.5M",
    ["Pyrocoil"] = "1 in 4M",
    ["Stormshell Brute"] = "1 in 4M",
    ["Wintertusk Mammofin"] = "1 in 4M",
    ["Crimson Dreadtusk"] ="1 in 20M",
    ["Elemental Hydra"] = "1 in 40M",
    ["Overlord Hydra"] = "1 in 45M",
    ["Ashen Kingfish"] = "1 in 3.5M",
    ["Everbloom"] = "1 in 20M",
    ["Mr Money Bags"] = "1 in 4M",
    ["Tribunal Withering Core"] = "1 in 5M",
    ["Velobyte"] = "1 in 5M",
    ["Shellshock X"] = "1 in 3M",
    ["Cenobyte.EXE"] = "1 in 30M",

}

local NP = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/"

local FishImageURL = {
    ["Frostborn Shark"]          = NP .. "bg_frostborn.png",
    ["Crystal Goliath"]          = NP .. "bg_crystalgoliath.png",
    ["Crystalline Behemoth"]     = NP .. "bg_crystalline.png",
    ["Elemental Tempestray"]     = NP .. "bg_elementaltempest.png",
    ["Dark Megalodon"]           = NP .. "bg_darkmega.png",
    ["Withering Core"]           = NP .. "bg_witheringcore.png",
    ["Flame Tyrant"]             = NP .. "bg_flametyrant.png",
    ["Scorching Veinmaw"]        = NP .. "bg_scorchingvein.png",
    ["Cerulean Dragon"]          = NP .. "bg_ceruleandragon.png",
    ["King Crab"]                = NP .. "bg_kingcrab.png",
    ["Queen Crab"]               = NP .. "bg_queencrab.png",
    ["Panther Eel"]              = NP .. "bg_panthereel.png",
    ["Cryoshade Glider"]         = NP .. "bg_cryoshade.png",
    ["Giant Squid"]              = NP .. "bg_giantsquid.png",
    ["Depthseeker Ray"]          = NP .. "bg_depthseeker.png",
    ["Robot Kraken"]             = NP .. "bg_robotkraken.png",
    ["Ghost Shark"]              = NP .. "bg_ghostshark.png",
    ["Skeleton Narwhal"]         = NP .. "bg_skeletonnarwhal.png",
    ["Blob Shark"]               = NP .. "bg_blobshark.png",
    ["Worm Fish"]                = NP .. "bg_wormfish.png",
    ["Cosmic Mutant Shark"]      = NP .. "bg_cosmicmutant.png",
    ["Megalodon"]                = NP .. "bg_megalodon.png",
    ["Bloodmoon Whale"]          = NP .. "bg_bloodmoonwhale.png",
    ["Frostmoon Whale"]          = NP .. "bg_frostmoonwhale.png",
    ["Thunderzilla"]             = NP .. "bg_thunderzilla.png",
    ["Thin Armor Shark"]         = NP .. "bg_thinarmor.png",
    ["Scare"]                    = NP .. "bg_scare.png",
    ["Lochness Monster"]         = NP .. "bg_lochness.png",
    ["Ancient Magma Whale"]      = NP .. "bg_ancientmagma.png",
    ["Crystal Crab"]             = NP .. "bg_crystalcrab.png",
    ["Orca"]                     = NP .. "bg_orca.png",
    ["Eerie Shark"]              = NP .. "bg_eerieshark.png",
    ["Monster Shark"]            = NP .. "bg_monstershark.png",
    ["Eggy Enchant Stone"]       = NP .. "bg_eggy.png",
    ["Strawberry Orca"]          = NP .. "bg_strawberryorca.png",
    ["Iridesca"]                 = NP .. "bg_iridesca.png",
    ["Frogalloon"]               = NP .. "bg_frogalloon.png",
    ["Blocky Lochness Monster"]  = NP .. "bg_blockyloch.png",
    ["Aurelion"]                 = NP .. "bg_aurelion.png",
    ["Frostbite Leviathan"]      = NP .. "bg_frostbite.png",
    ["Runic Enchant Stone"]      = NP .. "bg_runicstone.png",
    ["Bonemaw Tyrant"]           = NP .. "bg_bonemaw.png",
    ["Mutant Runic Koi"]         = NP .. "bg_mutantkoi.png",
    ["Deepsea Monster Axolotl"]  = NP .. "bg_deepseaaxolotl.png",
    ["Fluorivane"]               = NP .. "bg_fluorivane.png",
    ["Sea Eater"]                = NP .. "bg_seaeater.png",
    ["Pirate Megalodon"]         = NP .. "bg_piratemega.png",
    ["Elpirate Gran Maja"]       = NP .. "bg_elpirate.png",
    ["Cursed Kraken"]            = NP .. "bg_cursedkraken.png",
    ["Mosasaur Shark"]           = NP .. "bg_mosasaur.png",
    ["King Jelly"]               = NP .. "bg_kingjelly.png",
    ["Gladiator Shark"]          = NP .. "bg_gladiator.png",
    ["Ancient Lochness Monster"] = NP .. "bg_ancientloch.png",
    ["Elshark Gran Maja"]        = NP .. "bg_elshark.png",
    ["Viridis Lurker"]           = NP .. "bg_viridis.png",
    ["Bone Whale"]               = NP .. "bg_bonewhale.png",
    ["Ancient Whale"]            = NP .. "bg_ancientwhale.png",
    ["Great Whale"]              = NP .. "bg_greatwhale.png",
    ["Coral Whale"]              = NP .. "bg_coralwhale.png",
    ["Love Nessie"]              = NP .. "bg_lovenessie.png",
    ["Broken Heart Nessie"]      = NP .. "bg_brokenheartnessie.png",
    ["Leviathan"]                = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/semangat%20kt%20w%20teh.png",
    ["Rainbow Comet Shark"]      = "https://raw.githubusercontent.com/revkatomy-max/asset-id/main/Rainbow%20Comet%20Shark.png",
    ["Ruby Gemstone"]            = "https://raw.githubusercontent.com/revkatomy-max/pisit-image/main/1.png",
    ["Glacial Serpent"]          = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_glacial.png",
    ["Machodon"]                 = "https://raw.githubusercontent.com/revkatomy-max/pisit-image/main/42.png",
    ["Crystal"]                  = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_crystal.png",
    ["treasure hunt"]            = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_treasure.png",
    ["Caustic Maw"]              = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_causticmaw.png",
    ["Aurora"]                   = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_aurora.png",
    ["Coral Reaper"]             = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_coralreaper.png",
    ["Trench Warden"]            = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_trenchwarden.png",
    ["Ketupat Whale"]            = "https://raw.githubusercontent.com/revkatomy-max/asset-id/main/Ketupat%20Whale.png",
    ["Caeruleum Razerback"]      = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_caeruleum.png",
    ["Two-headed shark"]         = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_twoheaded.png",
    ["Ragnarex"]                 = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_ragnarex.png",
    ["Colossal Shipwreck Crab"]  = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_colshipcrab.png",
    ["Astrelle"]                 = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_astrelle.png",
["Astralune"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_astralune.png",
["Moonwake Ray"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_moonwake.png",
["Pelagon"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_pelagon.png",
["Starglass Guardian"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_starglass.png",
["Riftborn Arowana"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_riftborn.png",
["Pyrocoil"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_pyrocoil.png",
["Stormshell Brute"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_stormshell.png",
["Wintertusk Mammofin"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_wintertusk.png",
["Crimson Dreadtusk"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_crimsondread.png",
["Elemental Hydra"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_overlordhydra.png",
["Tribunal Withering core"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_tribunal.png",
["Ashen Kingfish"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_ashenkingfish.webp",
["Everbloom"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_everbloom.webp",
["Mr Money Bags"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_mrmoneybags.webp",
["Overlord Hydra"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_elementalhydra.png",
["Velobyte"]       = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_velobyte.png",
["Cenobyte.EXE"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_cenobyte.png",
["Shellshock X"] = "https://raw.githubusercontent.com/revkatomy-max/new-pisit-image/main/bg_shellshockx.png",
    
}

local FishImageURLLower = {}
for k, v in pairs(FishImageURL) do
    FishImageURLLower[string.lower(k)] = v
end

local function GetFishImageURL(baseName)
    if not baseName then return nil end
    return FishImageURL[baseName] or FishImageURLLower[string.lower(baseName)]
end

-- ============================================================
--  EVENT HUNT DATABASE (aktif: Treasure Hunt, Thunderzilla, Crystal, Blizzard, Storm, Volcanic)
-- ============================================================

local EventHuntData = {
    {
        textTriggers = { "treasure hunt" },
        title        = EMOJI_TREASURE .. " Treasure Hunt Dimulai!",
        description  = "katakan Peta 🗺️",
        color        = 16766720,
        emoji        = "💰",
        thumbUrl     = FishImageURL["treasure hunt"],
    },
    {
        textTriggers = { "thunderzilla hunt", "thunderzilla" },
        title        = EMOJI_THUNDER_TITLE .. " Thunderzilla Hunt Dimulai!",
        description  = "zilla oi " .. EMOJI_THUNDER,
        color        = 16776960,
        emoji        = "⚡",
        thumbUrl     = FishImageURL["Thunderzilla"],
    },
    {
        textTriggers = { "crystals have spawned", "crystals have", "crystal" },
        title        = EMOJI_CRYSTAL .. " Crystal Event Dimulai!",
        description  = "Crystal muncul gas nambang " .. EMOJI_CRYSTAL,
        color        = 1146986,
        emoji        = "💎",
        thumbUrl     = FishImageURL["Crystal"],
    },
    {
        textTriggers = { "a blizzard has started", "blizzard has started", "blizzard" },
        title        = EMOJI_BLIZZARD .. " Blizzard Dimulai!",
        description  = "Cuaca beku, siap-siap gas " .. EMOJI_BLIZZARD,
        color        = 10730212,
        emoji        = "❄️",
        thumbUrl     = FishImageURL["Wintertusk Mammofin"],
    },
    {
        textTriggers = { "storm elemental event event has started", "storm elemental event has started", "a massive storm is occurring!", "a massive storm is occurring" },
        title        = EMOJI_STORM .. " Storm Dimulai!",
        description  = "Badai mulai, hati-hati mancing " .. EMOJI_STORM,
        color        = 6579300,
        emoji        = "🌪️",
        thumbUrl     = FishImageURL["Stormshell Brute"],
    },
    {
        textTriggers = { "volcano elemental event has started", "volcano elemental event", "a volcano has erupted", "volcanic" },
        title        = EMOJI_VOLCANIC .. " Volcanic Dimulai!",
        description  = "Gunung berapi aktif, gas sikat " .. EMOJI_VOLCANIC,
        color        = 14898213,
        emoji        = "🌋",
        thumbUrl     = FishImageURL["Pyrocoil"],
    },
    {
        textTriggers = { "kraken defeat event has started", "kraken defeat event", "kraken defeat" },
        title        = "🦑 Kraken Defeat Event Dimulai!",
        description  = "Boost luck aktif + mutasi **8-Bit** bisa muncul! Gas sikat sekarang 🦑",
        color        = 3066993,
        emoji        = "🦑",
        thumbUrl     = BRAND_ICON,
    },
}

local EventCooldown = {}

-- ============================================================
--  STATE / CACHE
-- ============================================================

local FishImageCache  = {}
local AvatarCache     = {}
local LeaveTimers     = {}
local PlayerStats     = {}
local GalatamaStats   = {} -- [userId] = { name = ..., totalPoints = 0, catches = { [fishBaseName] = { count, totalPoints } } }
local PlayerNameToId  = {}
local SpawnPointCache = {}

-- ============================================================
--  AFK / IDLE DETECTION
-- ============================================================

local AFK_THRESHOLD_SECONDS  = 3600
local AFK_CHECK_INTERVAL     = 60

-- ============================================================
--  SAVE CONFIG
-- ============================================================

local CONFIG_FILE = "bloxgank_config.json"

local function SaveConfig(joinUrl, fishUrl, eventUrl, mutasiUrl, checkplayerUrl, balancerUrl, galatamaUrl)
    if not writefile then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode({
            webhook_join        = joinUrl        or "",
            webhook_fish        = fishUrl        or "",
            webhook_event       = eventUrl       or "",
            webhook_mutasi      = mutasiUrl      or "",
            webhook_checkplayer = checkplayerUrl or "",
            webhook_balancer    = balancerUrl    or "",
            webhook_galatama    = galatamaUrl    or "",
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

-- Format angka poin Galatama dengan pemisah ribuan, contoh: 20000 -> "20,000 pts"
local function FormatPoints(n)
    n = math.floor(n or 0)
    local sign = ""
    if n < 0 then sign = "-"; n = -n end
    local s = tostring(n)
    local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return sign .. formatted .. " pts"
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
--  FISH DETECTION
-- ============================================================

local function FindSecretFish(fishName)
    local lower = string.lower(fishName)
    for _, baseName in ipairs(SecretFishList) do
        if lower == string.lower(baseName) then return baseName, nil end
    end
    local bestBase, bestLen, bestMutasi = nil, 0, nil
    for _, baseName in ipairs(SecretFishList) do
        local baseLower = string.lower(baseName)
        local s = string.find(lower, baseLower, 1, true)
        if s then
            local afterPos = s + #baseName
            local suffix   = string.match(fishName:sub(afterPos), "^%s*(.-)%s*$") or ""
            local validMatch = true
            if suffix ~= "" then
                local suffixLower = string.lower(suffix)
                local isMutasi = false
                for _, mutasiName in ipairs(MutasiList) do
                    if string.lower(mutasiName) == suffixLower then
                        isMutasi = true
                        break
                    end
                end
                if not isMutasi then
                    validMatch = false
                end
            end
            if validMatch and #baseName > bestLen then
                local mutasi = nil
                if s > 1 then
                    mutasi = fishName:sub(1, s - 1):match("^%s*(.-)%s*$")
                    if mutasi == "" then mutasi = nil end
                end
                bestLen    = #baseName
                bestBase   = baseName
                bestMutasi = mutasi
            end
        end
    end
    return bestBase, bestMutasi
end

local function FindMutasi(fishName)
    local lower = string.lower(fishName)

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

local function FindMythicFish(fishName)
    local lower = string.lower(fishName)
    for _, baseName in ipairs(MythicFishList) do
        if string.find(lower, string.lower(baseName), 1, true) then
            return baseName
        end
    end
    return nil
end

-- Deteksi ikan tier MYTHIC khusus Galatama (Pailatee / SPFin Shark), sama persis
-- logic-nya kayak FindSecretFish tapi buat GalatamaMythicList, plus deteksi mutasi-nya.
local function FindGalatamaMythicFish(fishName)
    local lower = string.lower(fishName)
    for _, baseName in ipairs(GalatamaMythicList) do
        if lower == string.lower(baseName) then return baseName, nil end
    end
    local bestBase, bestLen, bestMutasi = nil, 0, nil
    for _, baseName in ipairs(GalatamaMythicList) do
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

-- Cari bonus mutasi FLAT (dipakai buat Secret & Mythic Galatama, tinggal beda angka
-- flatAmount-nya). Mutasi dicek per-kata: kalau ADA minimal 1 kata yang bukan
-- "big"/"shiny", berarti ada mutasi beneran -> dapet flatAmount. Kalau mutasi kosong,
-- atau isinya cuma "Big"/"Shiny" doang (tanpa mutasi beneran), bonusnya 0.
local function GetFlatMutasiBonus(mutasi, flatAmount)
    if not mutasi or mutasi == "" then return 0, nil end
    local hasQualifying = false
    local labelWords = {}
    for word in mutasi:gmatch("%S+") do
        local wl = word:lower()
        if wl ~= "big" and wl ~= "shiny" then
            hasQualifying = true
            table.insert(labelWords, word)
        end
    end
    if not hasQualifying then return 0, nil end
    return flatAmount, table.concat(labelWords, " ")
end

local function FindGalatamaFish(baseName)
    if not baseName then return nil end
    local lower = baseName:lower()
    for name, _ in pairs(GalatamaFishPoints) do
        if lower == name:lower() then return name end
    end
    return nil
end

-- Resolve key GalatamaStats buat player ini. Kalau uid ADA dan sebelumnya sempat ada catch
-- yang kesimpen pakai fallback key nama (waktu uid-nya belum kedeteksi), stat lama itu
-- otomatis di-MERGE ke entry uid, terus fallback key-nya dibuang -- jadi nggak kepecah
-- jadi 2 baris beda di leaderboard begitu player-nya udah ke-index normal.
local function ResolveGalatamaKey(uid, playerName)
    local nameKey = "name:" .. string.lower(playerName)
    if not uid then
        return nameKey
    end
    local nameEntry = GalatamaStats[nameKey]
    if nameEntry then
        if not GalatamaStats[uid] then
            GalatamaStats[uid] = { name = playerName, totalPoints = 0, catches = {} }
        end
        GalatamaStats[uid].totalPoints = GalatamaStats[uid].totalPoints + (nameEntry.totalPoints or 0)
        for fishName, catchData in pairs(nameEntry.catches or {}) do
            if not GalatamaStats[uid].catches[fishName] then
                GalatamaStats[uid].catches[fishName] = { count = 0, totalPoints = 0 }
            end
            GalatamaStats[uid].catches[fishName].count       = GalatamaStats[uid].catches[fishName].count + (catchData.count or 0)
            GalatamaStats[uid].catches[fishName].totalPoints = GalatamaStats[uid].catches[fishName].totalPoints + (catchData.totalPoints or 0)
        end
        GalatamaStats[nameKey] = nil
    end
    return uid
end

-- Terapkan scoring poin Galatama (dipakai bareng buat tier SECRET & MYTHIC, tinggal beda
-- basePoints/flatBonusAmount) dan nambahin field "⚖️ Galatama" ke embed fields.
local function ApplyGalatamaScoring(fields, uid, playerName, galBase, basePoints, mutasi, flatBonusAmount)
    local galKey = ResolveGalatamaKey(uid, playerName)
    if not GalatamaStats[galKey] then
        GalatamaStats[galKey] = { name = playerName, totalPoints = 0, catches = {} }
    end
    local mutasiBonus, bonusLabel = GetFlatMutasiBonus(mutasi, flatBonusAmount)
    local totalAdded = basePoints + mutasiBonus

    GalatamaStats[galKey].totalPoints = GalatamaStats[galKey].totalPoints + totalAdded
    if not GalatamaStats[galKey].catches[galBase] then
        GalatamaStats[galKey].catches[galBase] = { count = 0, totalPoints = 0 }
    end
    GalatamaStats[galKey].catches[galBase].count       = GalatamaStats[galKey].catches[galBase].count + 1
    GalatamaStats[galKey].catches[galBase].totalPoints = GalatamaStats[galKey].catches[galBase].totalPoints + totalAdded

    local totalNow = GalatamaStats[galKey].totalPoints

    local galDesc
    if mutasiBonus > 0 then
        galDesc = "**+" .. FormatPoints(totalAdded) .. "**"
            .. " (" .. FormatPoints(basePoints) .. " base + " .. FormatPoints(mutasiBonus) .. " bonus mutasi 🌀 *" .. (bonusLabel or mutasi) .. "*)"
            .. "\ntotal: **" .. FormatPoints(totalNow) .. "**"
    else
        galDesc = "**+" .. FormatPoints(totalAdded) .. "**"
        if mutasi then galDesc = galDesc .. " *(mutasi " .. mutasi .. " — no bonus)*" end
        galDesc = galDesc .. "\ntotal: **" .. FormatPoints(totalNow) .. "**"
    end

    table.insert(fields, { name = "⚖️ Galatama", value = galDesc, inline = false })
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
-- ============================================================

local function FindValueByName(container, names)
    if not container then return nil end
    for _, n in ipairs(names) do
        local child = container:FindFirstChild(n)
        if child then return child end
    end
    return nil
end

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

local function FindPlayerValueInWorkspace(player, names)
    if not player then return nil end

    local playerFolder = Workspace:FindFirstChild(player.Name)
    if playerFolder then
        local direct = FindValueByName(playerFolder, names)
        if direct then return direct end
        local nested = FindValueRecursive(playerFolder, names)
        if nested then return nested end
    end

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
--  NEAREST SPAWN LOCATION (fallback lokasi player, dihitung dari jarak ke SpawnLocation)
-- ============================================================

local SPAWN_FOLDER_NAME  = "!!! SPAWN LOCATIONS"
local SPAWN_MAX_DISTANCE = 400

local function CacheSpawnLocations()
    SpawnPointCache = {}
    local folder = Workspace:FindFirstChild(SPAWN_FOLDER_NAME)
    if not folder then
        warn("[BLOX Gank DEBUG] Folder '" .. SPAWN_FOLDER_NAME .. "' tidak ditemukan di Workspace!")
        return
    end

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("spawn", 1, true) then
            local lowerName = obj.Name:lower()
            local areaName

            if lowerName == "spawnlocation" or lowerName == "spawn" then
                areaName = obj.Parent and obj.Parent.Name or nil
            else
                areaName = obj.Name:gsub("%s*[Ss]pawn[Ll]ocation%s*$", "")
            end

            areaName = areaName and Trim(areaName) or nil
            if areaName and areaName ~= "" then
                table.insert(SpawnPointCache, { name = areaName, position = obj.Position })
            end
        end
    end

    print("[BLOX Gank DEBUG] CacheSpawnLocations: ketemu " .. #SpawnPointCache .. " spawn point.")
end

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
    return nil
end

-- Ambil Caught & Map dari leaderstats; fallback: descendant player -> workspace -> attribute -> nearest spawn
local function GetPlayerStatsAndLocation(player)
    local caught, location = "N/A", "N/A"
    if not player then return caught, location end
    local ls = player:FindFirstChild("leaderstats")

    local caughtStat = FindValueByName(ls, { "caught", "Caught" })
    if caughtStat then caught = FormatNumber(caughtStat.Value) end

    local locStat = FindValueByName(ls, { "Map", "map", "Location", "Zone" })
        or FindValueRecursive(player, { "Map", "map", "Location", "Zone" })
        or FindPlayerValueInWorkspace(player, { "Map", "map", "Location", "Zone" })
    if locStat then
        location = tostring(locStat.Value)
    else
        local attrLoc = player:GetAttribute("Map") or player:GetAttribute("map")
            or player:GetAttribute("Location") or player:GetAttribute("Zone")
        if attrLoc ~= nil then
            location = tostring(attrLoc)
        else
            local nearest = GetNearestSpawnArea(player)
            if nearest then location = nearest .. " (est.)" end
        end
    end

    return caught, location
end

-- Scanner heuristik: Server Luck & timer sisa cuma ada di teks GUI, bukan value/stat
local function ScanServerLuckInfo()
    local luckValue, luckEnds = nil, nil
    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return luckValue, luckEnds end

    for _, v in ipairs(pg:GetDescendants()) do
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            local t = v.Text or ""
            if t ~= "" then
                if not luckValue then
                    local m = t:match("[Ll]uck.-x%s*(%d+)") or t:match("x%s*(%d+).-[Ll]uck")
                    if m then luckValue = m end
                end
                if not luckEnds then
                    local h, m2, s = t:match("(%d+)h%s*(%d+)m%s*(%d+)s")
                    if h then luckEnds = h .. "h " .. m2 .. "m " .. s .. "s" end
                end
            end
        end
        if luckValue and luckEnds then break end
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
            "• **%s** -  Caught: %s - %s %s",
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

local function BuildEmbed(title, description, color, fields, imageUrl, thumbUrl, footerTag, author)
    local embed = {
        title       = title,
        description = description,
        color       = color,
        fields      = fields,
        footer      = { text = (footerTag or BRAND_FOOTER_TEXT) .. " " .. os.date("%d/%m/%Y %H:%M:%S") },
        timestamp   = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }
    if imageUrl then embed.image     = { url = imageUrl } end
    if thumbUrl then embed.thumbnail = { url = thumbUrl } end
    -- author == false artinya sengaja gak mau nampilin author sama sekali (beda dari nil = default brand)
    if author == nil then
        embed.author = BrandAuthor()
    elseif author ~= false then
        embed.author = author
    end
    return embed
end

local function PostWebhook(url, body)
    local requestFunc = GetRequestFunc()
    if not requestFunc then
        warn("[BLOX Gank DEBUG] PostWebhook gagal: gak ketemu request function.")
        return
    end
    if url == "" then
        warn("[BLOX Gank DEBUG] PostWebhook gagal: url webhook kosong.")
        return
    end
    task.spawn(function()
        local ok, err = pcall(function()
            local res = requestFunc({
                Url     = url,
                Method  = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body    = HttpService:JSONEncode(body),
            })
            local status = res and (res.StatusCode or res.status_code)
            if status and (status < 200 or status >= 300) then
                warn("[BLOX Gank DEBUG] Webhook response bukan 2xx! Status: " .. tostring(status))
            end
        end)
        if not ok then
            warn("[BLOX Gank DEBUG] PostWebhook ERROR: " .. tostring(err))
        end
    end)
end

local function BuildContent(captionType)
    if captionType == "forgotten" then return "forgotten kak"
    elseif captionType == "secret" then return "Secret atau core it"
    elseif captionType == "leave"   then return "ke disconect ya?"
    elseif captionType == "join"    then return "yeay kembali"
    elseif captionType == "notback" then return "lah kok ngilang"
    elseif captionType == "mutasi"  then return "cek mutasinya"
    elseif captionType == "afk"     then return "mancing gak si"
    end
    return nil
end

local function SendWebhook(title, description, color, fields, imageUrl, thumbUrl, captionType)
    local f = {}
    for _, v in ipairs(fields) do table.insert(f, v) end
    PostWebhook(WEBHOOK_URL, {
        username   = "BLOX Gank",
        avatar_url = WEBHOOK_AVATAR,
        content    = BuildContent(captionType),
        embeds     = { BuildEmbed(title, description, color, f, imageUrl, thumbUrl) },
    })
end

local function SendFishWebhook(title, description, color, fields, imageUrl, thumbUrl, captionType)
    local url = (WEBHOOK_FISH ~= "") and WEBHOOK_FISH or WEBHOOK_URL
    if url == "" then return end
    local f = {}
    for _, v in ipairs(fields) do table.insert(f, v) end
    PostWebhook(url, {
        content = BuildContent(captionType),
        embeds  = { BuildEmbed(title, description, color, f, imageUrl, thumbUrl) },
    })
end

local function SendMutasiWebhook(title, description, color, fields, imageUrl, thumbUrl, captionType)
    local url = (WEBHOOK_MUTASI ~= "") and WEBHOOK_MUTASI
        or ((WEBHOOK_FISH ~= "") and WEBHOOK_FISH or WEBHOOK_URL)
    if url == "" then return end
    local f = {}
    for _, v in ipairs(fields) do table.insert(f, v) end
    PostWebhook(url, {
        username   = "BLOX Gank Mutasi",
        avatar_url = WEBHOOK_AVATAR,
        content    = BuildContent(captionType),
        embeds     = { BuildEmbed(title, description, color, f, imageUrl, thumbUrl, "BLOX Gank Mutasi List") },
    })
end

local function SendPlayerCheckWebhook()
    local url = (WEBHOOK_CHECKPLAYER ~= "") and WEBHOOK_CHECKPLAYER or WEBHOOK_URL

    if url == "" then
        warn("[BLOX Gank DEBUG] SendPlayerCheckWebhook batal: gak ada webhook valid.")
        return
    end

    local description = BuildPlayerCheckDescription()
    PostWebhook(url, {
        username   = "BLOX Gank",
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { BuildEmbed(
            EMOJI_CHECK .. " Check Player On Server " .. Players.LocalPlayer.Name,
            description,
            TierColors.Join,
            {},
            nil, nil,
            "BLOX Gank Check Player"
        )},
    })
end

-- ============================================================
--  GALATAMA LEADERBOARD
-- ============================================================

local function SendGalatamaLeaderboard()
    local leaderData = {}
    for _, gs in pairs(GalatamaStats) do
        if (gs.totalPoints or 0) > 0 then
            local catchLines = {}
            for fishName, catchData in pairs(gs.catches) do
                local count = catchData.count or 0
                local p     = catchData.totalPoints or 0
                table.insert(catchLines, fishName .. " x" .. count .. " (" .. FormatPoints(p) .. ")")
            end
            table.insert(leaderData, {
                name        = gs.name,
                totalPoints = gs.totalPoints,
                catchStr    = #catchLines > 0 and table.concat(catchLines, "\n") or "-",
            })
        end
    end
    if #leaderData == 0 then return end
    table.sort(leaderData, function(a, b) return a.totalPoints > b.totalPoints end)

    local medals = { "🥇", "🥈", "🥉" }
    local fields = {}
    for i, entry in ipairs(leaderData) do
        if i > 10 then break end
        local medal = medals[i] or ("#" .. i)
        table.insert(fields, {
            name   = medal .. " " .. entry.name .. " — ⚖️ " .. FormatPoints(entry.totalPoints),
            value  = entry.catchStr,
            inline = false,
        })
    end

    local url = (WEBHOOK_GALATAMA ~= "") and WEBHOOK_GALATAMA
        or ((WEBHOOK_FISH ~= "") and WEBHOOK_FISH or WEBHOOK_URL)
    if url == "" then return end

    PostWebhook(url, {
        username   = "BLOX Gank Galatama",
        avatar_url = WEBHOOK_AVATAR,
        embeds     = { BuildEmbed(
            "🏆 LEADERBOARD GALATAMA",
            "```\n[SECRET] Dark Megalodon (10,000) | Coral Reaper (6,000) | Elemental Tempestray (1,000)\nBonus Mutasi Secret: semua mutasi +1,000 (kecuali Big & Shiny)\n\n[MYTHIC] Pailatee (60) | SPFin Shark (60)\nBonus Mutasi Mythic: semua mutasi +100 (kecuali Big & Shiny)\n```",
            16766720, fields, nil, nil, "BLOX Gank Galatama"
        )},
    })
end

-- ============================================================
--  EVENT WEBHOOK SENDER
-- ============================================================

local function SendEventWebhook(eventData, rawText)
    local url = (WEBHOOK_EVENT ~= "") and WEBHOOK_EVENT or WEBHOOK_URL
    if url == "" then return end
    PostWebhook(url, {
        username   = "BLOX Gank Event",
        avatar_url = WEBHOOK_AVATAR,
        content    = "<@&" .. ROLE_NELAYAN_ID .. ">",
        embeds     = { BuildEmbed(
            eventData.title,
            eventData.description,
            eventData.color,
            {
                { name = SEP .. " Host Server",  value = "**" .. Players.LocalPlayer.Name .. "**",              inline = true },
                { name = SEP .. " Total Player", value = "**" .. tostring(#Players:GetPlayers()) .. "** orang", inline = true },
                { name = SEP .. " Waktu Mulai",  value = os.date("%H:%M:%S"),                                   inline = true },
            },
            nil,
            eventData.thumbUrl,
            "BLOX Gank Event Monitor",
            { name = EMOJI_EVENTTAG .. " Event Hunt Alert", icon_url = WEBHOOK_AVATAR ~= "" and WEBHOOK_AVATAR or nil }
        )},
    })
end

-- ============================================================
--  AFK / IDLE WEBHOOK SENDER
-- ============================================================

local function SendAfkWebhook(pName, avatarUrl)
    SendWebhook(EMOJI_AFK .. " Player Idle Terdeteksi", "Pemain ini kayaknya lagi gak mancing (gak ada catch sama sekali).", TierColors.AFK, {
        { name = SEP .. " Username", value = "**" .. pName .. "**",                          inline = true },
        { name = SEP .. " Info",     value = "Tidak ada catch selama **60 menit**",           inline = true },
    }, nil, avatarUrl, "afk")
end

-- ============================================================
--  EVENT DETECTION (edge-trigger per label: notif cuma kirim sekali pas OFF -> ON)
-- ============================================================

local _hookedLabels = {}
local LabelEventState = {}

local function ProcessEventText(text, label)
    if not SCRIPT_ACTIVE then return end
    if not EVENT_NOTIF_ENABLED then return end
    if not text or text == "" then return end
    local lower = text:lower()

    local isRelevant = lower:find("hunt") or lower:find("crystal") or lower:find("blizzard") or lower:find("storm") or lower:find("volcanic") or lower:find("volcano") or lower:find("kraken")

    local state = LabelEventState[label]
    if not state then
        state = {}
        LabelEventState[label] = state
    end

    for _, evData in ipairs(EventHuntData) do
        local matched = false
        if isRelevant then
            for _, trigger in ipairs(evData.textTriggers) do
                if lower:find(trigger, 1, true) then matched = true; break end
            end
        end

        local wasMatched = state[evData.title] or false
        state[evData.title] = matched

        if matched and not wasMatched then
            local now = os.time()
            if (now - (EventCooldown[evData.title] or 0)) >= EVENT_COOLDOWN_SECONDS then
                EventCooldown[evData.title] = now
                SendEventWebhook(evData, text)
            end
        end
    end
end

local function HookLabel(label)
    if _hookedLabels[label] then return end
    _hookedLabels[label] = true
    ProcessEventText(label.Text, label)
    label:GetPropertyChangedSignal("Text"):Connect(function()
        ProcessEventText(label.Text, label)
    end)
    label.AncestryChanged:Connect(function(_, parent)
        if not parent then LabelEventState[label] = nil end
    end)
end

local function StartEventMonitor()
    task.spawn(function()
        local pg = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
        if not pg then return end
        for _, v in ipairs(pg:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") then HookLabel(v) end
        end
        pg.DescendantAdded:Connect(function(v)
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                task.wait(0)
                HookLabel(v)
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

local function GetAvatarUrlById(userId)
    if not userId then return nil end
    return PROXY .. "/avatar/" .. tostring(userId) .. "?t=" .. tostring(os.time())
end

-- ============================================================
--  ELEMENTAL BALANCER MONITOR
--  Angka count dibaca dari attribute "Players" di folder PressurePlates.
--  Nama pemain per elemen di-scan pakai polling GetPartsInPart (bukan Touched
--  -- lebih reliable, gak tergantung event fisika/CanCollide/timing).
-- ============================================================

local _lastBalanceState  = nil
local _lastBalanceCooldown = 0
local BALANCE_CHECK_INTERVAL = 10

local ElementPlayers = { Fire = {}, Frozen = {}, Storm = {} }

local function GetCountersFolder()
    return Workspace:FindFirstChild("Islands")
        and Workspace.Islands:FindFirstChild("Throne Room")
        and Workspace.Islands["Throne Room"]:FindFirstChild("ThroneRoomFishing")
        and Workspace.Islands["Throne Room"].ThroneRoomFishing:FindFirstChild("Counters")
end

-- Scan siapa aja yang lagi ada di plate tiap elemen, pakai bounding box tiap PressurePlate
-- (diperbesar sedikit) -- lebih toleran daripada overlap persis ke mesh Cube/Cell yang kecil,
-- biar pemain yang berdiri agak di pinggir plate tetap kedetect.
local function RefreshElementPlayers()
    local counters = GetCountersFolder()
    if not counters then return end

    local overlapParams = OverlapParams.new()
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude
    overlapParams.FilterDescendantsInstances = {}

    for _, elem in ipairs({"Fire", "Frozen", "Storm"}) do
        local names = {}
        local folder = counters:FindFirstChild(elem)
        local plates = folder and folder:FindFirstChild("PressurePlates")
        if plates then
            for _, plateModel in ipairs(plates:GetChildren()) do
                local ok, cframe, size = pcall(function()
                    return plateModel:GetBoundingBox()
                end)
                if ok and cframe then
                    local paddedSize = size + Vector3.new(6, 10, 6)
                    local ok2, hits = pcall(function()
                        return Workspace:GetPartBoundsInBox(cframe, paddedSize, overlapParams)
                    end)
                    if ok2 and hits then
                        for _, hitPart in ipairs(hits) do
                            local char = hitPart.Parent
                            local player = char and Players:GetPlayerFromCharacter(char)
                            if player then names[player.UserId] = player.Name end
                        end
                    end
                end
            end
        end
        ElementPlayers[elem] = names
    end
end

local function GetElementPlayerNames(elem)
    local names = {}
    for _, name in pairs(ElementPlayers[elem]) do
        table.insert(names, name)
    end
    return #names > 0 and table.concat(names, ", ") or "—"
end

local function GetElementCounts()
    local ok, result = pcall(function()
        local counters = GetCountersFolder()
        if not counters then return nil end

        local counts = {}
        for _, elem in ipairs({"Fire", "Frozen", "Storm"}) do
            local folder = counters:FindFirstChild(elem)
            local plates = folder and folder:FindFirstChild("PressurePlates")
            counts[elem] = (plates and plates:GetAttribute("Players")) or 0
        end
        return counts
    end)
    if not ok then
        warn("[BLOX Gank DEBUG] GetElementCounts pcall ERROR: " .. tostring(result))
        return nil
    end
    return result
end

local function StartElementalBalancerMonitor()
    task.spawn(function()
        while SCRIPT_ACTIVE do
            task.wait(BALANCE_CHECK_INTERVAL)
            if not SCRIPT_ACTIVE then break end

            local counts = GetElementCounts()
            if counts then
                local fire   = counts["Fire"]   or 0
                local frozen = counts["Frozen"] or 0
                local storm  = counts["Storm"]  or 0
                local total  = fire + frozen + storm

                if total > 0 then
                    RefreshElementPlayers()

                    local isBalanced = (fire == frozen) and (frozen == storm) and (fire > 0)
                    local stateNow   = isBalanced and "balanced" or "unbalanced"
                    local formation  = fire .. "-" .. frozen .. "-" .. storm

                    if stateNow ~= _lastBalanceState then
                        local now = os.time()
                        if (now - _lastBalanceCooldown) >= EVENT_COOLDOWN_SECONDS then
                            _lastBalanceCooldown = now
                            _lastBalanceState    = stateNow

                            local url = (WEBHOOK_BALANCER ~= "") and WEBHOOK_BALANCER
                                or ((WEBHOOK_EVENT ~= "") and WEBHOOK_EVENT or WEBHOOK_URL)
                            if url ~= "" then
                                local title, color
                                if isBalanced then
                                    title = EMOJI_THUNDER_TITLE .. " Elemental Balancer — BALANCE!"
                                    color = 10181046
                                else
                                    title = EMOJI_THUNDER_TITLE .. " Elemental Balancer — TIDAK SEIMBANG"
                                    color = 8421504
                                end

                                PostWebhook(url, {
                                    username   = "BLOX Gank Event",
                                    avatar_url = WEBHOOK_AVATAR,
                                    content    = "<@&" .. ROLE_NELAYAN_ID .. ">",
                                    embeds     = { BuildEmbed(
                                        title, "", color,
                                        {
                                            { name = SEP .. " Fire",    value = "**" .. fire   .. "** player (" .. GetElementPlayerNames("Fire")   .. ")", inline = true },
                                            { name = SEP .. " Frozen",  value = "**" .. frozen .. "** player (" .. GetElementPlayerNames("Frozen") .. ")", inline = true },
                                            { name = SEP .. " Storm",   value = "**" .. storm  .. "** player (" .. GetElementPlayerNames("Storm")  .. ")", inline = true },
                                            { name = SEP .. " Host",    value = "**" .. Players.LocalPlayer.Name .. "**", inline = true },
                                            { name = SEP .. " Formasi", value = "**" .. formation .. "**",     inline = true },
                                        },
                                        nil, FishImageURL["Overlord Hydra"],
                                        "BLOX Gank Elemental Balancer",
                                        false
                                    )},
                                })
                            end
                        end
                    end
                end
            end
        end
    end)
end

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

                    SendAfkWebhook(pName, avatarUrl)
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
        }, nil, imageUrl, "secret")
        return
    end

    local mythicBase = FindMythicFish(data.fish)
    if mythicBase then
        local imageUrl = GetFishImageURL(mythicBase) or (FishImageCache[mythicBase] and (PROXY .. "/asset/" .. FishImageCache[mythicBase]))
        SendFishWebhook(EMOJI_NOTIF .. " Mythic Fish Detected!", "", TierColors.Mitos, {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Ikan",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
        }, nil, imageUrl, "secret")
        return
    end

    local rubyBase = FindRuby(data.fish)
    if rubyBase then
        local imageUrl = GetFishImageURL(rubyBase) or (FishImageCache[rubyBase] and (PROXY .. "/asset/" .. FishImageCache[rubyBase]))
        SendFishWebhook(EMOJI_RUBY .. " Ruby Gemstone!", "", TierColors.Ruby, {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Item",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
        }, nil, imageUrl, "secret")
        return
    end

    local galMythicBase, galMythicMutasi = FindGalatamaMythicFish(data.fish)
    if galMythicBase then
        local imageUrl = GetFishImageURL(galMythicBase) or (FishImageCache[galMythicBase] and (PROXY .. "/asset/" .. FishImageCache[galMythicBase]))
        local galMythicMutasiField = galMythicMutasi and (EMOJI_MUTASI .. " *" .. galMythicMutasi .. "*") or "—"
        local fields = {
            { name = SEP .. " Pemain", value = "**" .. data.player .. "**", inline = true },
            { name = SEP .. " Ikan",   value = "**" .. data.fish .. "**",   inline = true },
            { name = SEP .. " Berat",  value = "**" .. data.weight .. "**", inline = true },
            { name = SEP .. " Mutasi", value = galMythicMutasiField,        inline = true },
        }
        ApplyGalatamaScoring(fields, uid, data.player, galMythicBase, GalatamaMythicFishPoints[galMythicBase], galMythicMutasi, GALATAMA_MYTHIC_MUTASI_BONUS)
        SendFishWebhook("🔱 Mythic Tier Detected!", "", TierColors.Mitos, fields, nil, imageUrl, "secret")
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

        -- Galatama point scoring (tier Secret) -- bonus mutasi FLAT 1000 (kecuali Big/Shiny)
        local galBase = FindGalatamaFish(baseName)
        if galBase then
            ApplyGalatamaScoring(fields, uid, data.player, galBase, GalatamaFishPoints[galBase], mutasi, GALATAMA_SECRET_MUTASI_BONUS)
        end
        if isForgotten then
            SendFishWebhook(EMOJI_FORGOTTEN .. " Forgotten Tier Detected!", "", TierColors.Forgotten, fields, nil, imageUrl, "forgotten")
        else
            SendFishWebhook(EMOJI_NOTIF .. " Secret Fish Detected!", "", TierColors.Secret, fields, nil, imageUrl, "secret")
        end
        return
    end

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
        nil, avatarUrl, "mutasi"
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
    if TextChatService then
        TextChatService.MessageReceived:Connect(function(msg)
            local text = msg.Text or ""
            if msg.TextSource == nil then CheckAndSend(text) end

            local lowerText = Trim(string.lower(text))
            if lowerText == "!checkplayer" then
                SendPlayerCheckWebhook()
            elseif lowerText == "!galatamalb" then
                SendGalatamaLeaderboard()
            end
        end)
    end
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local onMessage = chatEvents:FindFirstChild("OnMessageDoneFiltering")
        if onMessage then
            onMessage.OnClientEvent:Connect(function(d)
                if not (d and d.Message) then return end
                local lowerMsg = string.lower(d.Message)
                if string.find(lowerMsg, "%[server%]") or string.find(lowerMsg, "obtained") then
                    CheckAndSend(d.Message)
                end
                local trimmedMsg = Trim(lowerMsg)
                if trimmedMsg == "!checkplayer" then
                    SendPlayerCheckWebhook()
                elseif trimmedMsg == "!galatamalb" then
                    SendGalatamaLeaderboard()
                end
            end)
        end
    end
end

-- ============================================================
--  START MONITORING
-- ============================================================

local function StartMonitoring()
    CacheSpawnLocations()

    local allPlayers = Players:GetPlayers()
    local names      = {}
    for _, p in ipairs(allPlayers) do table.insert(names, p.Name) end

    SendWebhook(EMOJI_STARTER .. " Monitor Started", "Server monitor sudah aktif", TierColors.Join, {
        { name = SEP .. " Host",          value = "**" .. Players.LocalPlayer.Name .. "**",     inline = true  },
        { name = SEP .. " Total Player",  value = "**" .. tostring(#allPlayers) .. "** orang",   inline = true  },
        { name = SEP .. " Daftar Player", value = "```\n" .. table.concat(names, ", ") .. "```", inline = false },
    })

    HookChat()
    StartEventMonitor()
    StartElementalBalancerMonitor()
    StartAfkMonitor()

    for _, p in ipairs(allPlayers) do
        WatchForFish(p)
        AvatarCache[p.UserId]                       = GetAvatarUrlById(p.UserId)
        PlayerStats[p.UserId]                       = { catchCount = 0, secretList = {}, joinTime = os.time(), name = p.Name, lastCatchTime = os.time(), afkNotified = false }
        PlayerNameToId[string.lower(p.Name)]        = p.UserId
        PlayerNameToId[string.lower(p.DisplayName)] = p.UserId
        ResolveGalatamaKey(p.UserId, p.Name) -- gabungin stray stat Galatama (fallback key nama) kalau ada
    end

    Players.PlayerAdded:Connect(function(player)
        if not SCRIPT_ACTIVE then return end
        LeaveTimers[player.UserId] = nil
        PlayerStats[player.UserId] = { catchCount = 0, secretList = {}, joinTime = os.time(), name = player.Name, lastCatchTime = os.time(), afkNotified = false }
        PlayerNameToId[string.lower(player.Name)]        = player.UserId
        PlayerNameToId[string.lower(player.DisplayName)] = player.UserId
        ResolveGalatamaKey(player.UserId, player.Name) -- gabungin stray stat Galatama (fallback key nama) kalau ada
        task.spawn(function()
            task.wait(1)
            AvatarCache[player.UserId] = GetAvatarUrlById(player.UserId)
            SendWebhook(EMOJI_JOIN .. " Player Joined Server", "welcam", TierColors.Join, {
                { name = SEP .. " Username",     value = "**" .. player.Name .. "**",                     inline = true },
                { name = SEP .. " Total Player", value = "**" .. tostring(#Players:GetPlayers()) .. "**", inline = true },
            }, nil, AvatarCache[player.UserId], "join")
        end)
        WatchForFish(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        if not SCRIPT_ACTIVE then return end
        local pName      = player.Name
        local pId        = player.UserId
        local avatarUrl  = AvatarCache[pId] or GetAvatarUrlById(pId)
        local totalNow   = #Players:GetPlayers() - 1

        AvatarCache[pId]                    = nil
        PlayerStats[pId]                    = nil
        PlayerNameToId[string.lower(pName)] = nil
        for k, v in pairs(PlayerNameToId) do if v == pId then PlayerNameToId[k] = nil end end

        SendWebhook(EMOJI_LEAVE .. " Player Left Server", "Salah satu pemain keluar server.", TierColors.Leave, {
            { name = SEP .. " Username",     value = "**" .. pName .. "**",              inline = true },
            { name = SEP .. " Total Player", value = "**" .. tostring(totalNow) .. "**", inline = true },
        }, nil, avatarUrl, "leave")

        LeaveTimers[pId] = true
        task.spawn(function()
            task.wait(600)
            if LeaveTimers[pId] then
                LeaveTimers[pId] = nil
                local notBackContent = BuildContent("notback")
                PostWebhook(WEBHOOK_URL, {
                    username   = "BLOX Gank",
                    avatar_url = WEBHOOK_AVATAR,
                    content    = notBackContent,
                    embeds     = { BuildEmbed(EMOJI_NOTBACK .. " Player Tidak Kembali", "Pemain ini belum balik lagi ke server, semoga aman ya~", TierColors.NotBack, {
                        { name = SEP .. " Username", value = "**" .. pName .. "**",               inline = true },
                        { name = SEP .. " Info",     value = "Tidak kembali selama **10 menit**", inline = true },
                    }, avatarUrl, nil, "BLOX Gank Webhook") },
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
    title.Text = "🎣 BLOX Gank Monitor"; title.Size = UDim2.new(1, -80, 1, 0); title.Position = UDim2.new(0, 10, 0, 0)
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
        TweenService:Create(frame, TweenInfo.new(0.15), { Size = UDim2.new(0,300,0,0), BackgroundTransparency=1 }):Play()
        task.wait(0.2); gui:Destroy()
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

    local BOTTOM_BLOCK_H = 108
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
    MakeLabel("🎯 Webhook Event Hunt (Role Nelayan)")
    local inputEvent = MakeInput("Kosong = pakai webhook join/leave...")
    MakeLabel("🧬 Webhook Mutasi List")
    local inputMutasi = MakeInput("Kosong = pakai webhook secret fish...")
    MakeLabel(EMOJI_CHECK .. " Webhook Check Player")
    local inputCheckplayer = MakeInput("Kosong = pakai webhook join/leave...")
    MakeLabel(EMOJI_THUNDER_TITLE .. " Webhook Elemental Balancer")
    local inputBalancer = MakeInput("Kosong = pakai webhook event hunt...")
    MakeLabel("⚖️ Webhook Galatama")
    local inputGalatama = MakeInput("Kosong = pakai webhook secret fish...")

    local saveEnabled = false
    local saveToggle = MakeToggleRow("💾 Simpan Config", false, function(enabled)
        saveEnabled = enabled
    end)

    local eventToggle = MakeToggleRow("🔔 Notif Event Hunt", true, function(enabled)
        EVENT_NOTIF_ENABLED = enabled
    end)

    if savedConfig then
        if savedConfig.webhook_join        and savedConfig.webhook_join        ~= "" then inputJoin.Text        = savedConfig.webhook_join        end
        if savedConfig.webhook_fish        and savedConfig.webhook_fish        ~= "" then inputFish.Text        = savedConfig.webhook_fish        end
        if savedConfig.webhook_event       and savedConfig.webhook_event       ~= "" then inputEvent.Text       = savedConfig.webhook_event       end
        if savedConfig.webhook_mutasi      and savedConfig.webhook_mutasi      ~= "" then inputMutasi.Text      = savedConfig.webhook_mutasi      end
        if savedConfig.webhook_checkplayer and savedConfig.webhook_checkplayer ~= "" then inputCheckplayer.Text = savedConfig.webhook_checkplayer end
        if savedConfig.webhook_balancer    and savedConfig.webhook_balancer    ~= "" then inputBalancer.Text    = savedConfig.webhook_balancer    end
        if savedConfig.webhook_galatama    and savedConfig.webhook_galatama    ~= "" then inputGalatama.Text    = savedConfig.webhook_galatama    end
        saveToggle.setState(true)
    end

    local BTN_Y1 = FRAME_H - BOTTOM_BLOCK_H          -- CHECK PLAYER
    local BTN_Y2 = BTN_Y1 + 26 + 6                    -- GALATAMA LB
    local BTN_Y3 = BTN_Y2 + 26 + 6                    -- START MONITORING

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

    local galatamaBtn = Instance.new("TextButton")
    galatamaBtn.Text = "⚖️ GALATAMA LB"; galatamaBtn.Size = UDim2.new(1,-24,0,26); galatamaBtn.Position = UDim2.new(0,12,0,BTN_Y2)
    galatamaBtn.BackgroundColor3 = Color3.fromRGB(45,45,45); galatamaBtn.TextColor3 = Color3.fromRGB(220,220,220)
    galatamaBtn.Font = Enum.Font.GothamBold; galatamaBtn.TextSize = 11; galatamaBtn.BorderSizePixel = 0; galatamaBtn.Parent = frame
    Instance.new("UICorner", galatamaBtn).CornerRadius = UDim.new(0,6)
    HoverTween(galatamaBtn, Color3.fromRGB(65,65,65), Color3.fromRGB(45,45,45))

    galatamaBtn.MouseButton1Click:Connect(function()
        if not SCRIPT_ACTIVE then
            galatamaBtn.Text = "⚠️ Start monitoring dulu"
            task.wait(1.5)
            galatamaBtn.Text = "⚖️ GALATAMA LB"
            return
        end
        SendGalatamaLeaderboard()
        galatamaBtn.Text = "✅ Terkirim!"
        task.wait(1.2)
        galatamaBtn.Text = "⚖️ GALATAMA LB"
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
        if inputEvent.Text:find("discord.com/api/webhooks")       then WEBHOOK_EVENT       = inputEvent.Text       end
        if inputMutasi.Text:find("discord.com/api/webhooks")      then WEBHOOK_MUTASI      = inputMutasi.Text      end
        if inputCheckplayer.Text:find("discord.com/api/webhooks") then WEBHOOK_CHECKPLAYER = inputCheckplayer.Text end
        if inputBalancer.Text:find("discord.com/api/webhooks")    then WEBHOOK_BALANCER    = inputBalancer.Text    end
        if inputGalatama.Text:find("discord.com/api/webhooks")    then WEBHOOK_GALATAMA    = inputGalatama.Text    end

        if saveEnabled then SaveConfig(WEBHOOK_URL, WEBHOOK_FISH, WEBHOOK_EVENT, WEBHOOK_MUTASI, WEBHOOK_CHECKPLAYER, WEBHOOK_BALANCER, WEBHOOK_GALATAMA) end

        SCRIPT_ACTIVE = true
        statusDot.BackgroundColor3 = Color3.fromRGB(0,220,100)
        statusLabel.Text           = "Aktif — Monitoring..."
        statusLabel.TextColor3     = Color3.fromRGB(0,220,100)
        startBtn.Text              = "✅ MONITORING AKTIF"
        startBtn.BackgroundColor3  = Color3.fromRGB(30,30,30)

        SetFloatStatus(true)

        for _, box in ipairs({ inputJoin, inputFish, inputEvent, inputMutasi, inputCheckplayer, inputBalancer, inputGalatama }) do
            box.TextEditable = false
        end
        saveToggle.hitbox.Active = false

        StartMonitoring()
    end)
end

-- ============================================================
--  INIT
-- ============================================================

local uiOk, uiErr = pcall(CreateUI)
if not uiOk then
    warn("[BLOX Gank] Gagal bikin UI: " .. tostring(uiErr))
end
