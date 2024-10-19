-- TODO: CHANGE FILENAME
--- CHANGE THIS FILE'S NAME WHERE IT SAYS `ADDON_NAME`

local applyItemDetails = require "gameNight - applyItemDetails"
local deckActionHandler = applyItemDetails.deckActionHandler
local gamePieceAndBoardHandler = applyItemDetails.gamePieceAndBoardHandler

local YuSpiffOh = {}

applyItemDetails.yuSpiffOh = {}

function applyItemDetails.yuSpiffOh.rollCard(rarity)

    local cards = YuSpiffOh.cardsByRarity[rarity]
    if not cards then return end

    local card = cards[ZombRand(#cards)+1]
    if not card then return end

    return card
end



function applyItemDetails.yuSpiffOh.weighedProbability(outcomesAndWeights)
    local totalWeight = 0
    for outcome, weight in pairs(outcomesAndWeights) do totalWeight = totalWeight + weight end
    local randomNumber = ZombRand(totalWeight)+1
    local cumulativeWeight = 0
    for outcome, weight in pairs(outcomesAndWeights) do
        cumulativeWeight = cumulativeWeight + weight
        if randomNumber <= cumulativeWeight then
            return outcome
        end
    end
end


function applyItemDetails.yuSpiffOh.spawnRandomCard(zombie)
    local common = 16
    local uncommon = 10
    local rare = zombie and 5 or 4
    local super_rare = zombie and 3 or 2
    local ultra_rare = zombie and 2 or 1

    local rarity = applyItemDetails.yuSpiffOh.weighedProbability({ common=common, uncommon=uncommon, rare=rare, super_rare=super_rare, ultra_rare=ultra_rare})
    local card = applyItemDetails.yuSpiffOh.rollCard(rarity)
    return card
end


function applyItemDetails.applyBoostersToYuSpiffOhCards(item, zombie)
    local cards = {}

    for i=0, 9 do
        local card = applyItemDetails.yuSpiffOh.spawnRandomCard(zombie)
        table.insert(cards, card)
    end

    item:getModData()["gameNight_cardDeck"] = cards
    item:getModData()["gameNight_cardFlipped"] = {}
    for i=1, #cards do item:getModData()["gameNight_cardFlipped"][i] = true end
end


function applyItemDetails.applyCardForYuSpiffOh(item)
    if not item:getModData()["gameNight_cardDeck"] then

        local itemCont = item:getContainer()
        local zombie = itemCont and (itemCont:getType() == "inventorymale" or itemCont:getType() == "inventoryfemale")

        local applyBoosters = item:getModData()["gameNight_specialOnCardApplyBooster"]
        if applyBoosters then
            applyItemDetails.applyBoostersToYuSpiffOhCards(item, zombie)
            item:getModData()["gameNight_specialOnCardApplyBooster"] = nil
            item:getModData()["gameNight_specialOnCardApplyDeck"] = nil
            gamePieceAndBoardHandler.refreshInventory(getPlayer())
            return
        end

        local applyDeck = item:getModData()["gameNight_specialOnCardApplyDeck"]
        if not applyDeck then
            if (ZombRand(10) < 1) or zombie then
                local card = applyItemDetails.yuSpiffOh.spawnRandomCard(true)
                item:getModData()["gameNight_cardDeck"] = { card }
                item:getModData()["gameNight_cardFlipped"] = { true }
                item:getModData()["gameNight_specialOnCardApplyDeck"] = nil
            else
                applyDeck = true
            end
        end

        if applyDeck then
            local deckID = YuSpiffOh.deckIDs[ZombRand(#YuSpiffOh.deckIDs)+1]
            local cards = YuSpiffOh.buildDeck(deckID)
            if cards then
                item:getModData()["gameNight_cardDeck"] = cards
                item:getModData()["gameNight_cardFlipped"] = {}
                for i=1, #cards do item:getModData()["gameNight_cardFlipped"][i] = true end
            end
            item:getModData()["gameNight_specialOnCardApplyDeck"] = nil
        end

        gamePieceAndBoardHandler.refreshInventory(getPlayer())
    end
end


function YuSpiffOh.buildDeck(deckID)
    local cards = {}
    local deckData = YuSpiffOh.Decks[deckID]
    if not deckData then return end

    for card,numberOf in pairs(deckData) do
        local cardID = card
        for n=1, numberOf do
            table.insert(cards, cardID)
        end
    end

    if #cards < 40 then
        for i=#cards, 39 do
            local card = applyItemDetails.yuSpiffOh.spawnRandomCard()
            table.insert(cards, card)
        end
    end

    return cards
end


YuSpiffOh.Decks = {

    ["Yugi's Grandpa Deck"] = {
        ["Exodia the Forbidden One"] = 1, ["Left Arm of the Forbidden One"] = 1, ["Right Arm of the Forbidden One"] = 1,
        ["Left Leg of the Forbidden One"] = 1, ["Right Leg of the Forbidden One"] = 1, ["Blue-Eyes White Dragon"] = 1,
        ["Summoned Skull"] = 1, ["Mystical Elf"] = 1, ["Celtic Guardian"] = 1, ["Giant Soldier of Stone"] = 1,
        ["Man-Eater Bug"] = 1, ["Sangan"] = 1, ["Kuriboh"] = 1, ["Dark Magician"] = 1, ["Pot of Greed"] = 1,
        ["Graceful Charity"] = 1, ["Monster Reborn"] = 1, ["Mystical Space Typhoon"] = 1,
        ["Swords of Revealing Light"] = 1, ["Mirror Force"] = 1, ["Call of the Haunted"] = 1, ["Polymerization"] = 1,
        ["Fissure"] = 1, ["Dark Hole"] = 1, ["Waboku"] = 1, ["Heavy Storm"] = 1, ["Trap Hole"] = 1, ["Magical Hats"] = 1,
        ["Reinforcements"] = 1,
    },

    ["Joey Wheeler Deck"] = {
        ["Red-Eyes Black Dragon"] = 2, ["Gearfried the Iron Knight"] = 2, ["Flame Swordsman"] = 1, ["Time Wizard"] = 1,
        ["Baby Dragon"] = 1, ["Alligator's Sword"] = 1, ["Panther Warrior"] = 1, ["Goblin Attack Force"] = 2,
        ["Jinzo"] = 1, ["Axe Raider"] = 1, ["Rocket Warrior"] = 1, ["Giant Trunade"] = 1, ["Flame Manipulator"] = 1,
        ["Mystical Space Typhoon"] = 1, ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Polymerization"] = 1,
        ["Premature Burial"] = 1, ["Reinforcement of the Army"] = 1, ["Monster Reborn"] = 1, ["Skull Dice"] = 1,
        ["Graceful Dice"] = 1, ["Sakuretsu Armor"] = 2, ["Trap Jammer"] = 1, ["Call of the Haunted"] = 1,
        ["Kunai with Chain"] = 1, ["Scapegoat"] = 1, ["Ring of Destruction"] = 1, ["Mirror Force"] = 1,
        ["Heavy Storm"] = 1, ["Masaki the Legendary Swordsman"] = 1,
    },

    ["Pegasus Deck"] = {
        ["Relinquished"] = 1, ["Toon World"] = 1, ["Blue-Eyes Toon Dragon"] = 1, ["Toon Summoned Skull"] = 1,
        ["Toon Gemini Elf"] = 2, ["Toon Mermaid"] = 1, ["Toon Goblin Attack Force"] = 1, ["Toon Masked Sorcerer"] = 1,
        ["Man-Eater Bug"] = 1, ["Jinzo"] = 1, ["Thousand-Eyes Restrict"] = 1, ["Thousand-Eyes Idol"] = 1,
        ["Sangan"] = 1, ["Mystical Space Typhoon"] = 1, ["Toon Table of Contents"] = 2, ["Pot of Greed"] = 1,
        ["Graceful Charity"] = 1, ["Polymerization"] = 1, ["Snatch Steal"] = 1, ["Monster Reborn"] = 1,
        ["Scapegoat"] = 1, ["Call of the Haunted"] = 1, ["Mirror Force"] = 1, ["Ring of Destruction"] = 1,
        ["Sakuretsu Armor"] = 2, ["Torrential Tribute"] = 1, ["Negate Attack"] = 1, ["Toon Defense"] = 1,
        ["Heavy Storm"] = 1,
    },

    ["Yugi Starter Deck"] = {
        ["Dark Magician"] = 1, ["Summoned Skull"] = 1, ["Celtic Guardian"] = 1, ["Feral Imp"] = 1,
        ["Giant Soldier of Stone"] = 1, ["Mystical Elf"] = 1, ["Beaver Warrior"] = 1, ["Man-Eater Bug"] = 1,
        ["Wall of Illusion"] = 1, ["Magician of Faith"] = 1, ["Sangan"] = 1, ["Trap Hole"] = 1, ["Fissure"] = 1,
        ["Change of Heart"] = 1, ["Monster Reborn"] = 1, ["Mystical Space Typhoon"] = 1, ["Book of Moon"] = 1,
        ["Graceful Charity"] = 1, ["Pot of Greed"] = 1, ["Mirror Force"] = 1, ["Call of the Haunted"] = 1,
        ["Swords of Revealing Light"] = 1, ["Soul Release"] = 1, ["Horn of the Unicorn"] = 1,
        ["Polymerization"] = 1, ["Dark Hole"] = 1, ["Waboku"] = 1, ["Reinforcements"] = 1, ["Magical Hats"] = 1,
    },

    ["Kaiba Starter Deck"] = {
        ["Blue-Eyes White Dragon"] = 2, ["Battle Ox"] = 1, ["Ryu-Kishin Powered"] = 1, ["Luster Dragon"] = 1,
        ["Lord of D"] = 1, ["Mystic Horseman"] = 1, ["Hyozanryu"] = 1, ["Judge Man"] = 1, ["Sakuretsu Armor"] = 1,
        ["La Jinn the Mystical Genie of the Lamp"] = 1, ["Giant Soldier of Stone"] = 1, ["Wall of Illusion"] = 1,
        ["Spear Dragon"] = 1, ["Kaiser Sea Horse"] = 1, ["Mystical Space Typhoon"] = 1, ["Polymerization"] = 1,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Monster Reborn"] = 1, ["Snatch Steal"] = 1,
        ["Ring of Destruction"] = 1, ["Call of the Haunted"] = 1, ["Trap Jammer"] = 1, ["Enemy Controller"] = 1,
        ["Premature Burial"] = 1, ["Fissure"] = 1, ["Trap Hole"] = 1, ["The Flute of Summoning Dragon"] = 1,
    },

    ["Goat Control"] = {
        ["Jinzo"] = 1, ["Airknight Parshath"] = 1, ["Tsukuyomi"] = 1,
        ["Black Luster Soldier - Envoy of the Beginning"] = 1, ["Sinister Serpent"] = 1, ["Sangan"] = 1,
        ["Magician of Faith"] = 2, ["Breaker the Magical Warrior"] = 1, ["Spirit Reaper"] = 1,
        ["Scapegoat"] = 2, ["Metamorphosis"] = 2, ["Snatch Steal"] = 1,
        ["Nobleman of Crossout"] = 2, ["Heavy Storm"] = 1, ["Mystical Space Typhoon"] = 1,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Delinquent Duo"] = 1,
        ["Premature Burial"] = 1, ["Book of Moon"] = 2,
        ["Call of the Haunted"] = 1, ["Mirror Force"] = 1, ["Torrential Tribute"] = 1,
        ["Sakuretsu Armor"] = 2, ["Ring of Destruction"] = 1,
    },

    ["Chaos Control"] = {
        ["Black Luster Soldier - Envoy of the Beginning"] = 1, ["Chaos Sorcerer"] = 2, ["Jinzo"] = 1,
        ["Airknight Parshath"] = 1, ["Tsukuyomi"] = 1, ["Sangan"] = 1, ["Breaker the Magical Warrior"] = 1,
        ["Spirit Reaper"] = 1, ["Sinister Serpent"] = 1,
        ["Scapegoat"] = 2, ["Metamorphosis"] = 2, ["Graceful Charity"] = 1,
        ["Pot of Greed"] = 1, ["Delinquent Duo"] = 1, ["Snatch Steal"] = 1,
        ["Heavy Storm"] = 1, ["Mystical Space Typhoon"] = 1, ["Nobleman of Crossout"] = 2,
        ["Premature Burial"] = 1, ["Book of Moon"] = 2,
        ["Call of the Haunted"] = 1, ["Mirror Force"] = 1, ["Torrential Tribute"] = 1,
        ["Ring of Destruction"] = 1,
    },

    ["Warrior Beatdown"] = {
        ["Exiled Force"] = 1, ["D D Warrior Lady"] = 2, ["Blade Knight"] = 2,
        ["Goblin Attack Force"] = 2, ["Breaker the Magical Warrior"] = 1,
        ["Jinzo"] = 1, ["Mystical Space Typhoon"] = 1, ["Reinforcement of the Army"] = 2,
        ["Heavy Storm"] = 1, ["Snatch Steal"] = 1, ["Nobleman of Crossout"] = 2,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["The Warrior Returning Alive"] = 1,
        ["Premature Burial"] = 1, ["Mirror Force"] = 1, ["Torrential Tribute"] = 1,
        ["Sakuretsu Armor"] = 2, ["Call of the Haunted"] = 1, ["Ring of Destruction"] = 1,
    },

    ["Burn Deck"] = {
        ["Des Koala"] = 2, ["Stealth Bird"] = 2, ["Lava Golem"] = 1,
        ["Spirit Reaper"] = 1, ["Sangan"] = 1, ["Magician of Faith"] = 2, ["D D Warrior Lady"] = 1,
        ["Wave-Motion Cannon"] = 3, ["Gravity Bind"] = 2, ["Level Limit - Area B"] = 2,
        ["Messenger of Peace"] = 2, ["Swords of Revealing Light"] = 1, ["Secret Barrel"] = 2,
        ["Ceasefire"] = 1, ["Magic Cylinder"] = 1, ["Ring of Destruction"] = 1,
        ["Torrential Tribute"] = 1, ["Ojama Trio"] = 1,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Mystical Space Typhoon"] = 1,
        ["Heavy Storm"] = 1, ["Snatch Steal"] = 1,
    },

    ["Machine Aggro"] = {
        ["Jinzo"] = 1, ["Reflect Bounder"] = 2, ["X-Head Cannon"] = 2,
        ["XYZ-Dragon Cannon"] = 1, ["Y-Dragon Head"] = 2, ["Z-Metal Tank"] = 2,
        ["Mystical Space Typhoon"] = 1, ["Limiter Removal"] = 1,
        ["Heavy Storm"] = 1, ["Pot of Greed"] = 1, ["Graceful Charity"] = 1,
        ["Snatch Steal"] = 1, ["Premature Burial"] = 1, ["Call of the Haunted"] = 1,
        ["Mirror Force"] = 1, ["Torrential Tribute"] = 1, ["Sakuretsu Armor"] = 2,
        ["Ring of Destruction"] = 1, ["Nobleman of Crossout"] = 2, ["Smashing Ground"] = 2,
    },

    ["Zombie Deck"] = {
        ["Pyramid Turtle"] = 3, ["Spirit Reaper"] = 2, ["Vampire Lord"] = 2,
        ["Ryu Kokki"] = 2, ["Book of Life"] = 3, ["Call of the Mummy"] = 2,
        ["Torrential Tribute"] = 1, ["Mirror Force"] = 1, ["Sakuretsu Armor"] = 2,
        ["Ring of Destruction"] = 1, ["Mystical Space Typhoon"] = 1, ["Heavy Storm"] = 1,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Snatch Steal"] = 1,
        ["Premature Burial"] = 1, ["Nobleman of Crossout"] = 2, ["Creature Swap"] = 2,
        ["Book of Moon"] = 1, ["Call of the Haunted"] = 1,
    },

    ["Control Warrior"] = {
        ["D D Assailant"] = 2, ["D D Warrior Lady"] = 1, ["Exiled Force"] = 1,
        ["Blade Knight"] = 2, ["Jinzo"] = 1, ["Breaker the Magical Warrior"] = 1,
        ["Spirit Reaper"] = 1, ["Mystical Space Typhoon"] = 1, ["Heavy Storm"] = 1,
        ["Reinforcement of the Army"] = 2, ["Nobleman of Crossout"] = 2,
        ["Snatch Steal"] = 1, ["Premature Burial"] = 1, ["Pot of Greed"] = 1,
        ["Graceful Charity"] = 1, ["The Warrior Returning Alive"] = 1, ["Swords of Revealing Light"] = 1,
        ["Sakuretsu Armor"] = 2, ["Mirror Force"] = 1, ["Torrential Tribute"] = 1,
        ["Ring of Destruction"] = 1, ["Call of the Haunted"] = 1, ["Smashing Ground"] = 1,
    },

    ["Monarch Control"] = {
        ["Mobius the Frost Monarch"] = 2, ["Zaborg the Thunder Monarch"] = 2, ["Spirit Reaper"] = 1,
        ["Breaker the Magical Warrior"] = 1, ["Magician of Faith"] = 2, ["D D Warrior Lady"] = 1, ["Sangan"] = 1,
        ["Mystical Space Typhoon"] = 1, ["Heavy Storm"] = 1, ["Snatch Steal"] = 1, ["Premature Burial"] = 1,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Nobleman of Crossout"] = 2, ["Soul Exchange"] = 2,
        ["Brain Control"] = 1, ["Mirror Force"] = 1, ["Torrential Tribute"] = 1, ["Sakuretsu Armor"] = 2,
        ["Call of the Haunted"] = 1, ["Ring of Destruction"] = 1,
    },

    ["Reasoning Gate OTK"] = {
        ["Jinzo"] = 1, ["Sacred Crane"] = 2, ["Airknight Parshath"] = 1,
        ["Dimension Fusion"] = 2, ["Chaos Sorcerer"] = 1, ["Black Luster Soldier - Envoy of the Beginning"] = 1,
        ["D D Warrior Lady"] = 1, ["Mystic Tomato"] = 2, ["Breaker the Magical Warrior"] = 1,
        ["Magician of Faith"] = 1, ["Sinister Serpent"] = 1, ["Reasoning"] = 3,
        ["Monster Gate"] = 2, ["Metamorphosis"] = 2, ["Scapegoat"] = 2,
        ["Nobleman of Crossout"] = 2, ["Pot of Greed"] = 1, ["Graceful Charity"] = 1,
        ["Premature Burial"] = 1, ["Snatch Steal"] = 1, ["Heavy Storm"] = 1,
        ["Mystical Space Typhoon"] = 1, ["Torrential Tribute"] = 1, ["Ring of Destruction"] = 1,
        ["Call of the Haunted"] = 1, ["Mirror Force"] = 1,
    },

    ["Anti-Meta Beatdown"] = {
        ["Banisher of the Light"] = 2, ["D D Warrior Lady"] = 2, ["Exiled Force"] = 1,
        ["Blade Knight"] = 2, ["Kycoo the Ghost Destroyer"] = 2, ["Breaker the Magical Warrior"] = 1,
        ["Jinzo"] = 1, ["Mystic Tomato"] = 2, ["Mystical Space Typhoon"] = 1,
        ["Heavy Storm"] = 1, ["Nobleman of Crossout"] = 2, ["Snatch Steal"] = 1,
        ["Premature Burial"] = 1, ["Pot of Greed"] = 1, ["Graceful Charity"] = 1,
        ["Smashing Ground"] = 2, ["Reinforcement of the Army"] = 2,
        ["Mirror Force"] = 1, ["Torrential Tribute"] = 1, ["Ring of Destruction"] = 1,
        ["Sakuretsu Armor"] = 2, ["Call of the Haunted"] = 1, ["Swords of Revealing Light"] = 1,
    },

    ["Warrior Toolbox"] = {
        ["Exiled Force"] = 1, ["D D Warrior Lady"] = 2, ["Blade Knight"] = 2,
        ["Mystic Swordsman LV2"] = 1, ["Don Zaloog"] = 2, ["Jinzo"] = 1, ["Breaker the Magical Warrior"] = 1,
        ["Spirit Reaper"] = 1, ["Mystic Tomato"] = 2, ["Reinforcement of the Army"] = 2,
        ["Mystical Space Typhoon"] = 1, ["Heavy Storm"] = 1, ["Nobleman of Crossout"] = 2,
        ["Snatch Steal"] = 1, ["Premature Burial"] = 1, ["Pot of Greed"] = 1,
        ["Graceful Charity"] = 1, ["The Warrior Returning Alive"] = 1,
        ["Swords of Revealing Light"] = 1, ["Sakuretsu Armor"] = 2, ["Mirror Force"] = 1,
        ["Torrential Tribute"] = 1, ["Ring of Destruction"] = 1, ["Call of the Haunted"] = 1,
        ["Smashing Ground"] = 1,
    },

    ["Spellcaster Control"] = {
        ["Magician of Faith"] = 2, ["Breaker the Magical Warrior"] = 1, ["Chaos Sorcerer"] = 2,
        ["Black Luster Soldier - Envoy of the Beginning"] = 1, ["Skilled Dark Magician"] = 2, ["Apprentice Magician"] = 2,
        ["Tsukuyomi"] = 1, ["Sangan"] = 1, ["Mystical Space Typhoon"] = 1, ["Heavy Storm"] = 1,
        ["Pot of Greed"] = 1, ["Graceful Charity"] = 1, ["Nobleman of Crossout"] = 2,
        ["Snatch Steal"] = 1, ["Premature Burial"] = 1, ["Book of Moon"] = 2,
        ["Swords of Revealing Light"] = 1, ["Call of the Haunted"] = 1, ["Mirror Force"] = 1,
        ["Torrential Tribute"] = 1, ["Ring of Destruction"] = 1, ["Sakuretsu Armor"] = 2, ["Smashing Ground"] = 1,
    },

    ["Chaos Warrior"] = {
        ["Black Luster Soldier - Envoy of the Beginning"] = 1, ["Chaos Sorcerer"] = 2, ["D D Warrior Lady"] = 1,
        ["Exiled Force"] = 1, ["Blade Knight"] = 2, ["Mystic Tomato"] = 2,
        ["Breaker the Magical Warrior"] = 1, ["Jinzo"] = 1, ["Tribe-Infecting Virus"] = 1, ["Magician of Faith"] = 2,
        ["Sangan"] = 1, ["Mystical Space Typhoon"] = 1, ["Heavy Storm"] = 1, ["Pot of Greed"] = 1,
        ["Graceful Charity"] = 1, ["Snatch Steal"] = 1, ["Premature Burial"] = 1, ["Nobleman of Crossout"] = 2,
        ["Reinforcement of the Army"] = 2, ["Sakuretsu Armor"] = 2, ["Torrential Tribute"] = 1, ["Mirror Force"] = 1,
        ["Ring of Destruction"] = 1, ["Call of the Haunted"] = 1, ["Smashing Ground"] = 1,
    },

    ["Stall Burn Lock"] = {
        ["Lava Golem"] = 1, ["Spirit Reaper"] = 2, ["Stealth Bird"] = 2,
        ["Des Koala"] = 2, ["Sangan"] = 1, ["Magician of Faith"] = 2, ["Ojama Trio"] = 2,
        ["Wave-Motion Cannon"] = 3, ["Messenger of Peace"] = 2, ["Level Limit - Area B"] = 2, ["Gravity Bind"] = 2,
        ["Swords of Revealing Light"] = 1, ["Ceasefire"] = 1, ["Magic Cylinder"] = 1, ["Secret Barrel"] = 2,
        ["Torrential Tribute"] = 1, ["Ring of Destruction"] = 1, ["Nightmare Wheel"] = 2,
        ["Heavy Storm"] = 1, ["Mystical Space Typhoon"] = 1, ["Pot of Greed"] = 1, ["Graceful Charity"] = 1,
        ["Snatch Steal"] = 1,
    }
}


YuSpiffOh.cardsByRarity = {}

YuSpiffOh.cardsByRarity.common = {
    "3-Hump Lacooda","4-Starred Ladybug of Doom","7","7 Colored Fish","7 Completed","8-Claws Scorpion",
    "A Cat of Ill Omen","A Deal with Dark Ruler","A Feint Plan","A Hero Emerges","A Legendary Ocean",
    "A Man with Wdjat","A Wingbeat of Giant Dragon","Abare Ushioni","Absolute End","Absorbing Kid from the Sky",
    "Abyssal Designator","Acrobat Monkey","Agido","Aitsu","Alpha The Magnet Warrior","Altar for Tribute",
    "Amazoness Archer","Amazoness Blowpiper","Amazoness Fighter","Amazoness Paladin","Amazoness Spellcaster",
    "Amphibious Bugroth MK-3","An Owl of Luck","Ancient Brain","Ancient Elf","Ancient Gear Soldier",
    "Ancient Lizard Warrior","Ancient One of the Deep Forest","Ancient Telescope","Ansatsu","Anti-Aircraft Flower",
    "Anti-Spell","Aqua Spirit","Arcane Archer of the Forest","Archfiend Marmot of Nefariousness","Archfiend Soldier",
    "Archfiend's Oath","Archfiend's Roar","Armaill","Armed Dragon LV3","Armed Samurai - Ben Kei","Armor Break",
    "Armored Glass","Armored Lizard","Armored Starfish","Armored Zombie","Arsenal Robber","Arsenal Summoner",
    "Astral Barrier","Aswan Apparition","Atomic Firefly","Attack and Receive","Aussa the Earth Charmer",
    "Autonomous Action Unit","Baby Dragon","Backfire","Bad Reaction to Simochi","Bait Doll",
    "Ballista of Rampart Smashing","Balloon Lizard","Banner of Courage","Bark of Dark Ruler",
    "Baron of the Fiend Sword","Basic Insect","Battery Charger","Batteryman AA","Battle Footballer",
    "Battle Ox","Battle Steer","Battle-Scarred","Bean Soldier","Beaver Warrior","Begone, Knave!",
    "Beta The Magnet Warrior","Bickuribox","Big Bang Shot","Big Eye","Big Koala","Big Wave Small Wave",
    "Bio-Mage","Birdface","Bite Shoes","Black Dragon's Chick","Black Luster Ritual","Blackland Fire Dragon",
    "Blade Rabbit","Blade Knight","Blast Juggler","Blasting the Ruins","Blazing Inpachi","Blessings of the Nile","Blind Destruction",
    "Blindly Loyal Goblin","Block Attack","Blue-Winged Crown","Boar Soldier","Bokoichi the Freightening Car",
    "Bombardment Beetle","Boneheimer","Book of Secret Arts","Book of Taiyou","Bottom Dweller",
    "Bottomless Shifting Sand","Bowganian","Bubble Crash","Bubonic Vermin","Burglar","Burning Algae",
    "Burning Beast","Burning Land","Burst Breath","Buster Rancher","Call of the Haunted","Call of the Mummy",
    "Cannonball Spear Shellfish","Card Shuffle","Castle of Dark Illusions","Castle Walls","Catnipped Kitty",
    "Cave Dragon","Cemetary Bomb","Ceremonial Bell","Cestus of Dagla","Chain Energy","Chaos End","Chaos Greed",
    "Chaos Necromancer","Charm of Shabti","Checkmate","Chopman the Desperate Outlaw","Chorus of Sanctuary",
    "Chosen One","Chu-Ske the Mouse Fighter","Claw Reacher","Clown Zombie","Coach Goblin","Cobra Jar",
    "Cobraman Sakuzy","Cockroach Knight","Cocoon of Evolution","Cold Wave","Collected Power","Commencement Dance",
    "Contract with Exodia","Contract with the Dark Master","Convulsion of Nature","Corroding Shark","Crab Turtle",
    "Crass Clown","Crawling Dragon","Crawling Dragon #2","Creeping Doom Manta","Crimson Ninja","Crimson Sentry",
    "Cure Mermaid","Curse of Aging","Curse of the Masked Beast","Cursed Seal of the Forbidden Spell","Cyber Falcon",
    "Cyber Raider","Cyber Saurus","Cyber Soldier of Darkworld","Cyclon Laser","D Human","D Tribe","D D Dynamite",
    "D D Trainer","Dancing Elf","Dancing Fairy","Dark Assailant","Dark Bat","Dark Blade","Dark Cat with White Tail",
    "Dark Coffin","Dark Dust Spirit","Dark Factory of Mass Production","Dark Gray","Dark Magic Attack",
    "Dark Magician Knight","Dark Mimic LV1","Dark Room of Nightmare","Dark Scorpion - Chick the Yellow",
    "Dark Scorpion - Cliff the Trap Remover","Dark Scorpion - Gorg the Strong","Dark Scorpion - Meanae the Thorn",
    "Dark Scorpion Burglars","Dark Titan of Terror","Dark Witch","Dark Zebra","Darkfire Soldier #1",
    "Darkfire Soldier #2","Darkworld Thorns","De-Spell","Deal of Phantom","Decayed Commander","Deepsea Shark",
    "Deepsea Warrior","Delta Attacker","Demotion","Des Dendle","Des Kangaroo","Des Lacooda","Des Wombat",
    "Desert Sunlight","Desertapir","Despair from the Dark","Desrook Archfiend","Destroyer Golem","Dharma Cannon",
    "Dian Keto the Cure Master","Dice Jar","Dice Re-Roll","Different Dimension Capsule","Dimension Distortion",
    "Dimension Jar","Disappear","Disarmament","Disc Fighter","Disk Magician","Dissolverock","Disturbance Strategy",
    "Divine Dragon Ragnarok","DNA Surgery","DNA Transplant","Dokuroyaiba","Doma The Angel of Silence","Don Turtle",
    "Dora of Fate","Doriado's Blessing","Double Attack","Double Coston","Double Snare","Dragged Down into the Grave",
    "Dragon Manipulator","Dragon Piper","Dragon Treasure","Dragon Zombie","Dragon's Gunfire","Dragon's Rage",
    "Dragonic Attack","Draining Shield","Dream Clown","Dreamsprite","Drill Bug","Driving Snow","Drooling Lizard",
    "Dummy Golem","Dust Barrier","Dust Tornado","Eagle Eye","Earthbound Spirit","Earthquake","Earthshaker",
    "Eatgaboon","Ekibyo Drakmord","Electric Lizard","Electric Snake","Electro-Whip","Element Doom","Element Dragon",
    "Element Magician","Element Saurus","Element Soldier","Element Valkyrie","Elemental Burst",
    "Elemental HERO Clayman","Elephant Statue of Blessing","Elephant Statue of Disaster",
    "Emblem of Dragon Destroyer","Emergency Provisions","Emissary of the Oasis","Empress Judge",
    "Empress Mantis","Enchanted Javelin","Enchanting Mermaid","Energy Drain","Enraged Muka Muka",
    "Eria the Water Charmer","Eternal Rest","Exhausting Spell","Exiled Force","Fairy Box","Fairy Guardian",
    "Fairy of the Spring","Fairy's Hand Mirror","Faith Bird","Familiar Knight","Fengsheng Mirror","Fenrir",
    "Feral Imp","Fiend Comedian","Fiend Reflection #2","Fiend Scorpion","Fiend's Hand Mirror","Final Attack Orders",
    "Final Countdown","Final Destiny","Final Ritual of the Ancients","Fire Kraken","Fire Sorcerer","Firebird",
    "Firegrass","Fireyarou","Flame Cerebrus","Flame Champion","Flame Dancer","Flame Manipulator","Flame Ruler",
    "Flash Assailant","Flying Fish","Flying Kamakiri #2","Flying Penguin","Forest","Formation Union","Fox Fire",
    "Freezing Beast","Frenzied Panda","Frontier Wiseman","Frontline Base","Frozen Soul","Fruits of Kozaky's Studies",
    "Fuh-Rin-Ka-Zan","Fulfillment of the Contract","Fushi No Tori","Fusion Weapon","Gagagigo","Gaia Power",
    "Gale Lizard","Gamble","Gamma the Magnet Warrior","Garoozis","Garuda the Wind Spirit","Gather Your Mind",
    "Gazelle the King of Mythical Beasts","Germ Infection","Giant Axe Mummy","Giant Flea","Giant Orc",
    "Giant Soldier of Stone","Giant Turtle Who Feeds on Flames","Gift of the Martyr","Giga Gagagigo",
    "Giga-Tech Wolf","Gigantes","Gigobyte","Giltia the D Knight","Girochin Kuwagata","Goblin Calligrapher",
    "Goblin Fan","Goblin King","Goblin of Greed","Goblin Thief","Gogiga Gagagigo","Good Goblin Housekeeping",
    "Gora Turtle of Illusion","Gorgon's Eye","Graceful Dice","Gradius","Gradius' Option","Granadora",
    "Grand Tiki Elder","Grave Lure","Grave Protector","Gravekeeper's Cannonholder","Gravekeeper's Curse",
    "Gravekeeper's Servant","Gravekeeper's Vassal","Graverobber's Retribution","Gravity Axe - Grarl","Gray Wing",
    "Great Angus","Great Long Nose","Great White","Green Phantom King","Griggle","Ground Attacker Bugroth",
    "Ground Collapse","Gryphon's Feather Duster","Guardian Elma","Guardian Kay'est","Guardian of the Labyrinth",
    "Guardian of the Throne Room","Guardian Statue","Gust","Gyaku-Gire Panda","Hade-Hane","Hamburger Recipe",
    "Hane-Hane","Hard Armor","Harpie Girl","Harpie Lady","Harpie Lady 2","Harpie Lady 3","Headless Knight",
    "Heart of Clear Water","Heart of the Underdog","Heavy Mech Support Platform","Helping Robo for Combat",
    "Hercules Beetle","Hibikime","Hidden Spellbook","Hieroglyph Lithograph","High Tide Gyojin",
    "Hiita the Fire Charmer","Hinotama","Hinotama Soul","Hitotsu-Me Giant","Homunculus the Alchemic Being",
    "Horn of Light","Horus' Servant","House of Adhesive Tape","Howling Insect","Huge Revolution",
    "Human-Wave Tactics","Humanoid Slime","Humanoid Worm Drake","Hungry Burger","Hunter Spider","Hyena","Hyosube",
    "Hyper Hammerhead","Hysteric Fairy","Illusionist Faceless Mage","Impenetrable Formation","Inaba White Rabbit",
    "Incandescent Ordeal","Inferno","Inferno Tempest","Infinite Dismissal","Inpachi","Insect Barrier",
    "Insect Imitation","Insect Knight","Insect Soldiers of the Sky","Inspection","Invasion of Flames","Invigoration",
    "Iron Blacksmith Kotetsu","Island Turtle","Jade Insect Whistle","Jam Defender","Jar Robber","Jellyfish",
    "Jigen Bakudan","Jinzo #7","Jirai Gumo","Judgment of the Desert","Just Desserts","KA-2 Des Scissors",
    "Kagemusha of the Blue Flame","Kaiser Colosseum","Kaminari Attack","Kaminote Blow","Kangaroo Champ","Kelbek",
    "Keldo","Killer Needle","King Fog","King of Yamimakai","Kiryu","Kiseitai","Kishido Spirit","Knight's Title",
    "Koitsu","Kojikocy","Kotodama","Koumori Dragon","Kozaky","Kryuel","Kumootoko","Kurama","Kuwagata α",
    "Labyrinth of Nightmare","Labyrinth Tank","Labyrinth Wall","Lady Assailant of Flames","Lady Ninja Yae",
    "Lady of Faith","Lady Panther","Larvae Moth","Larvas","Laser Cannon Armor","Last Will","Launcher Spider",
    "Lava Battleguard","Legendary Sword","Leogun","Lesser Dragon","Level Conversion Lab","Level Up!",
    "Life Absorbing Machine","Light of Intervention","Light of Judgment","Lighten the Load","Lightning Blade",
    "Lightning Conger","Lightning Vortex","Liquid Beast","Little-Winguard","Lizard Soldier","Lone Wolf",
    "Lord of the Lamp","Lord Poison","Luminous Spark","Luster Dragon","M-Warrior #1","M-Warrior #2",
    "Machine Conversion Factory","Magical Ghost","Magical Labyrinth","Magical Marionette","Magical Merchant",
    "Magical Plant Mandragola","Maharaghi","Maiden of the Aqua","Maiden of the Moonlight","Maji-Gire Panda",
    "Major Riot","Maju Garzett","Malevolent Nuzzler","Malice Dispersion","Mammoth Graveyard","Man Eater",
    "Man-Eating Treasure Chest","Man-Thro' Tro'","Maryokutai","Masaki the Legendary Swordsman","Mask of Weakness",
    "Masked Dragon","Mass Driver","Master & Expert","Master Kyonshee","Mecha-Dog Marron","Mechanical Snail",
    "Meda Bat","Medusa Worm","Mega Thunderball","Melchid the Four-Face Beast","Metal Armored Bug","Metal Detector",
    "Metal Fish","Metalsilver Armor","Metalzoa","Meteorain","Micro Ray","Mighty Guard","Minar","Mind Haxorz",
    "Mind Wipe","Mine Golem","Minefield Eruption","Minor Goblin Official","Miracle Dig","Miracle Restoring",
    "Mirage Dragon","Misairuzame","Mispolymerization","Moai Interceptor Cannons","Mokey Mokey","Mokey Mokey King",
    "Mokey Mokey Smackdown","Molten Behemoth","Molten Destruction","Molten Zombie","Monk Fighter","Monster Egg",
    "Morale Boost","Morinphen","Mountain","Mr Volcano","Mucus Yolk","Multiplication of Ants","Mushroom Man #2",
    "Musician King","Mustering of the Dark Scorpions","My Body as a Shield","Mysterious Guard","Mysterious Puppeteer",
    "Mystic Clown","Mystic Horseman","Mystic Lamp","Mystic Plasma Zone","Mystic Probe","Mystical Elf","Mystical Moon",
    "Mystical Sheep #2","Mystik Wok","Narrow Pass","Needle Ceiling","Needle Wall","Nekogal #1","Nemuriko",
    "Neo Aqua Madoor","Neo Bug","Neo the Magic Swordsman","Nightmare Horse","Nightmare Penguin","Nin-Ken Dog",
    "Ninjitsu Art of Decoy","Niwatori","Nobleman-Eater Bug","Non Aggression Area","Non-Spellcasting Area",
    "Nubian Guard","Numinous Healer","Nutrient Z","Octoberser","Ocubeam","Offerings to the Doomed",
    "Ogre of the Black Shadow","Ojama Black","Ojama Delta Hurricane!!","Ojama Green","Ojama Trio","Ojama Yellow",
    "Old Vindictive Magician","Ominous Fortunetelling","One-Eyed Shield Dragon","Oni Tank T-34","Ookazi",
    "Oppressed People","Opti-Camouflage Armor","Ordeal of a Traveler","Order to Smash","Oscillo Hero","Otohime",
    "Outstanding Dog Marron","Overdrive","Pale Beast","Pandemonium","Pandemonium Watchbear","Paralyzing Potion",
    "Patrician of Darkness","Peacock","Penguin Knight","People Running About","Performance of Sword",
    "Peten the Dark Clown","Petit Angel","Petit Dragon","Petit Moth","Pharaoh's Servant","Pharaonic Protector",
    "Physical Double","Pikeru's Second Sight","Pinch Hopper","Pineapple Blast","Piranha Army",
    "Pitch-Black Power Stone","Pitch-Black Warwolf","Pitch-Dark Dragon","Pixie Knight","Poison Fangs",
    "Poison Mummy","Poison of the Old Man","Pole Position","Possessed Dark Soul","Power of Kaishin",
    "Precious Cards from Beyond","Prevent Rat","Prickle Fairy","Primal Seed","Protector of the Throne",
    "Psychic Kappa","Pumpking the King of Ghosts","Punished Eagle","Pyramid Energy","Pyramid of Light",
    "Pyro Clock of Destiny","Queen Bird","Queen of Autumn Leaves","Rabid Horseman","Raging Flame Sprite",
    "Raigeki Break","Rain of Mercy","Raise Body Heat","Rare Metal Dragon","Raregold Armor","Ray & Temperature",
    "Ray of Hope","Really Eternal Rest","Recycle","Red Archery Girl","Red Medicine","Regenerating Mummy",
    "Reinforcements","Release Restraint","Remove Brainwashing","Remove Trap","Respect Play","Reversal Quiz",
    "Reverse Trap","Ring of Magnetism","Rising Air Current","Rite of Spirit","Roaring Ocean Snake","Robolady",
    "Robotic Knight","Roboyarou","Roc from the Valley of Haze","Rock Bombardment","Rock Ogre Grotto #1",
    "Rocket Jumper","Rod of Silence - Kay'est","Rod of the Mind's Eye","Rogue Doll","Root Water","Roulette Barrel",
    "Royal Keeper","Rush Recklessly","Ryu Kokki","Ryu-Kishin Clown","Ryu-Kishin Powered","Ryu-Ran","Sacred Crane",
    "Saggi the Dark Clown","Sakuretsu Armor","Salamandra","Sand Gambler","Sand Stone","Sasuke Samurai #2",
    "Science Soldier","Scroll of Bewitchment","Sea Serpent Warrior of Darkness","Sebek's Blessing","Second Goblin",
    "Secret Barrel","Secret Pass to the Treasures","Self-Destruct Button","Senri Eye","Serpentine Princess",
    "Servant of Catabolism","Shadow of Eyes","Shadowknight Archfiend","Shapesnatch","Shifting Shadows",
    "Shinato's Ark","Shining Abyss","Shining Friendship","Shooting Star Bow - Ceal","Silpheed","Silver Fang",
    "Skilled White Magician","Skull Dice","Skull Dog Marron","Skull Knight","Skull Knight #2","Skull Lair",
    "Skull Mariner","Skull Red Bird","Skull-Mark Ladybug","Sky Dragon","Sky Scout","Sleeping Lion","Slime Toad",
    "Slot Machine","Smashing Ground","Snake Fang","Sogen","Solar Flare Dragon","Solar Ray","Solemn Wishes",
    "Solomon's Lawbook","Sonic Bird","Sonic Duck","Sonic Jammer","Sorcerer of the Doomed","Soul Demolition",
    "Soul of Purity and Light","Soul Release","Soul Reversal","Soul Tiger","Soul-Absorbing Bone Tower","Souleater",
    "Souls of the Forgotten","Space Mambo","Sparks","Spatial Collapse","Spear Cretin","Spell Purification",
    "Spell Reproduction","Spellbook Organization","Spherous Lady","Spike Seadra","Spikebot","Spirit Caller",
    "Spirit Elimination","Spirit of Flames","Spirit of the Books","Spirit of the Pot of Greed","Spirit Ryu",
    "Spirit's Invitation","Spiritual Energy Settle Machine","Spring of Rebirth","St Joan","Stamping Destruction",
    "Staunch Defender","Stealth Bird","Steel Ogre Grotto #1","Steel Scorpion","Stim-Pack","Stone Ogre Grotto",
    "Stuffed Animal","Stumbling","Succubus Knight","Summoner of Illusions","Super Robolady","Super Roboyarou",
    "Supply","Swamp Battleguard","Swarm of Locusts","Swarm of Scarabs","Sword Hunter","Sword of Dark Destruction",
    "Sword of Deep-Seated","Sword of the Soul-Eater","Swordsman of Landstar","Swordstalker","Tactical Espionage Expert",
    "Tailor of the Fickle","Tainted Wisdom","Takuhee","Taunt","Terra the Terrible","Terrorking Salmon","The 13th Grave",
    "The All-Seeing White Tiger","The Big March of Animals","The Bistro Butcher","The Cheerful Coffin",
    "The Creator Incarnate","The Dark - Hex-Sealed Fusion","The Dark Door","The Dragon Dwelling in the Cave",
    "The Earl of Demise","The Earth - Hex-Sealed Fusion","The Emperor's Holiday","The Eye of Truth",
    "The Forgiving Maiden","The Furious Sea King","The Graveyard in the Fourth Dimension",
    "The Gross Ghost of Fled Dreams","The Hunter with 7 Weapons","The Illusory Gentleman",
    "The Immortal of Thunder","The Inexperienced Spy","The Judgement Hand","The Kick Man",
    "The Law of the Normal","The Light - Hex-Sealed Fusion","The Little Swordsman of Aile",
    "The Portrait's Secret","The Puppet Magic of Dark Ruler","The Regulation of Tribe","The Reliable Guardian",
    "The Rock Spirit","The Second Sarcophagus","The Secret of the Bandit","The Spell Absorbing Life",
    "The Statue of Easter Island","The Stern Mystic","The Thing in the Crater","The Third Sarcophagus",
    "The Trojan Horse","The Unfriendly Amazon","The Unhappy Girl","The Unhappy Maiden","The Warrior Returning Alive",
    "The Wicked Worm Beast","Thousand Knives","Thousand Needles","Thousand-Eyes Idol","Threatening Roar",
    "Three-Headed Geedo","Throwstone Unit","Thunder Crash","Thunder of Ruler","Time Seal","Timeater","Timidity",
    "Token Thanksgiving","Toll","Tongyo","Toon Alligator","Toon Defense","Tornado Wall","Torpedo Fish",
    "Tower of Babel","Trap Hole","Trap Master","Tremendous Fire","Trent","Trial of Nightmare","Tribute Doll",
    "Tripwire Beast","Troop Dragon","Turtle Bird","Turtle Oath","Turtle Tiger","Turu-Purun","Tutan Mask",
    "Twin Long Rods #2","Twin Swords of Flashing Light - Tryce","Twin-Headed Behemoth","Twin-Headed Fire Dragon",
    "Twin-Headed Wolf","Two Thousand Needles","Two-Headed King Rex","Two-Man Cell Battle","Two-Mouth Darkruler",
    "Tyhone","Tyhone #2","Type Zero Magic Crusher","Ultimate Baseball Kid","Ultimate Obedient Fiend","Umi",
    "Umiiruka","Union Rider","United Resistance","Unknown Warrior of Fiend","Unshaven Angler","Uraby","Ushi Oni",
    "Vampire Lady","Vengeful Bog Spirit","Vilepawn Archfiend","Violet Crystal","Waboku","Wall of Revealing Light",
    "Wall Shadow","Warrior Dai Grepher","Warrior of Zera","Wasteland","Watapon","Water Magician","Water Omotics",
    "Wattkid","Weapon Change","Weather Report","Whiptail Crow","Whirlwind Prodigy","White Dragon Ritual",
    "White Magician Pikeru","White Ninja","Winged Dragon, Guardian of the Fortress #1",
    "Winged Dragon, Guardian of the Fortress #2","Winged Minion","Winged Sage Falcos","Wingweaver",
    "Witch Doctor of Chaos","Witty Phantom","Wodan the Resident of the Forest","Wolf Axwielder","Woodborg Inpachi",
    "Woodland Sprite","World Suppression","Worm Drake","Wow Warrior","Wynn the Wind Charmer","Xing Zhen Hu",
    "Yado Karu","Yami","Yellow Luster Shield","Zero Gravity","Zoa","Zolga","Zombie Tiger","Zombyra the Dark",
}

YuSpiffOh.cardsByRarity.uncommon = {
    "A Feather of the Phoenix","Abyss Soldier","Acid Rain","Adhesion Trap Hole","After the Struggle",
    "Airknight Parshath","Alligator's Sword", "Amazoness Archers","Amazoness Chain Master","Amazoness Swords Woman","Amazoness Tiger",
    "Amphibian Beast","Amplifier","Ancient Gear Beast","Ancient Gear Golem","Ante","Apprentice Magician","Aqua Chorus",
    "Aqua Madoor","Armed Dragon LV5","Armed Dragon LV7","Armed Ninja","Armor Exe","Array of Revealing Light",
    "Arsenal Bug","Asura Priest","Avatar of The Pot","Axe of Despair","Axe Raider","Back to Square One",
    "Backup Soldier","Banisher of the Light","Barrel Behind the Door","Bazoo the Soul-Eater","Beast of Talwar",
    "Beast Soul Swap","Beastking of the Swamps","Beckoning Light","Berserk Gorilla","Big Shield Gardna",
    "Black Illusion Ritual","Black Luster Soldier","Black Pendant","Black Tyranno","Bladefly","Blast Magician",
    "Blast with Chain","Blowback Dragon","Book of Life","Book of Moon","Bottomless Trap Hole","Brain Control",
    "Breaker the Magical Warrior","Burst Stream of Destruction","Buster Blader","Byser Shock","Cannon Soldier",
    "Card Destruction","Card of Safe Return","Card of Sanctity","Cat's Ear Tribe","Ceasefire","Celtic Guardian",
    "Centrifugal Field","Chain Destruction","Change of Heart","Chaos Sorcerer","Chaosrider Gustaph",
    "Charcoal Inpachi","Chiron the Mage","Cipher Soldier","Coffin Seller","Combination Attack",
    "Compulsory Evacuation Device","Continuous Destruction Punch","Contract with the Abyss","Covering Fire",
    "Creature Swap","Curse of Anubis","Curse of Darkness","Curse of Dragon","Curse of Royal","Cyber Harpie Lady",
    "D D Borderline","D D Crazy Beast","D D Scout Plane","D D Survivor","D D Warrior Lady","Dark Core",
    "Dark Designator","Dark Driceratops","Dark Elf","Dark Energy","Dark Hole","Dark Jeroid","Dark King of the Abyss",
    "Dark Magician Girl","Dark Master - Zorc","Dark Mimic LV3","Dark Paladin","Dark Scorpion Combination",
    "Dark Snake Syndrome","Dark Spirit of the Silent","Dark-Piercing Light","Darkbishop Archfiend","Darkfire Dragon",
    "De-Fusion","Deck Devastation Virus","Dekoichi the Battlechanted Locomotive","Des Feral Imp","Des Koala",
    "Destiny Board","Destruction Punch","Destruction Ring","Different Dimension Gate","Diffusion Wave-Motion",
    "Dimensionhole","Divine Wrath","Dokurorider","Double Spell","Dragon Capture Jar","Dragon Seeker",
    "Dramatic Rescue","Drillago","Drop Off","Earth Chant","Elegant Egotist","Elemental HERO Avian",
    "Elemental HERO Burstinatrix","Elemental HERO Sparkman","Embodiment of Apophis","Emissary of the Afterlife",
    "Enchanting Fitting Room","Enemy Controller","Enraged Battle Ox","Fairy Meteor Crush","Fairy's Gift",
    "Fake Trap","Falling Down","Fatal Abacus","Fear from the Dark","Fiber Jar","Final Flame","Fissure",
    "Flame Swordsman","Flying Kamakiri #1","Forced Requisition","Freed the Matchless General","Fuhma Shuriken",
    "Fusilier Dragon, the Dual-Mode Beast","Fusion Gate","Fusion Sage","Fusion Sword Murasame Blade","Fusionist",
    "Gadget Soldier","Gaia The Fierce Knight","Gatling Dragon","Gear Golem the Moving Fortress",
    "Gearfried the Iron Knight","Gearfried the Swordmaster","Gemini Elf","Getsu Fuhma","Giant Germ","Giant Rat",
    "Giant Trunade","Gift of The Mystical Elf","Gilasaurus","Goblin Attack Force","Goblin's Secret Remedy",
    "Goddess of Whim","Goddess with the Third Eye","Golem Sentry","Gora Turtle","Granmarg the Rock Monarch",
    "Gravekeeper's Assailant","Gravekeeper's Chief","Gravekeeper's Guard","Gravekeeper's Spear Soldier",
    "Gravekeeper's Spy","Gravekeeper's Watcher","Gravity Bind","Great Maju Garzett","Great Moth","Great Phantom Thief",
    "Greenkappa","Gren Maju Da Eiza","Gryphon Wing","Guardian Baou","Guardian Sphinx","Guardian Tryce",
    "Gyakutenno Megami","Hammer Shot","Hand of Nephthys","Harpie Lady 1","Harpie Lady Sisters",
    "Harpies' Hunting Ground","Hayabusa Knight","Heavy Slump","Heavy Storm","Helpoemer","Hero Signal",
    "Hiro's Shadow Scout","Horn of the Unicorn","Horus the Black Flame Dragon LV4",
    "Horus the Black Flame Dragon LV6","Hyozanryu","Infernal Flame Emperor","Infernalqueen Archfiend",
    "Inferno Fire Blast","Infinite Cards","Insect Princess","Interdimensional Matter Transporter",
    "Invader of Darkness","Invitation to a Dark Sleep","Jam Breeding Machine","Jar of Greed",
    "Jowgen the Spiritualist","Jowls of Dark Demise","Judge Man","Judgment of Anubis","Kabazauls","Kaibaman",
    "Kaiser Glider","Kaiser Sea Horse","Karate Man","Karbonala Warrior","King of the Skull Servants",
    "King of the Swamp","King Tiger Wanghu","Kunai with Chain","Kuriboh","Kycoo the Ghost Destroyer",
    "La Jinn the Mystical Genie of the Lamp","Last Turn","Legendary Jujitsu Master","Lekunga","Lesser Fiend",
    "Level Limit - Area B","Lightforce Sword","Limiter Removal","Little Chimera","Lord of D","Lost Guardian",
    "Luster Dragon #2","Machine Duplication","Machine King","Mad Dog of Darkness","Mad Sword Beast","Mage Power",
    "Magic Cylinder","Magic Drain","Magic Jammer","Magic Reflector","Magical Hats","Magical Scientist",
    "Magical Thorn","Magician of Faith","Magician's Circle","Maha Vailo","Makyura the Destructor",
    "Malice Doll of Demise","Man-Eater Bug","Manga Ryu-Ran","Manju of the Ten Thousand Hands","Marauding Captain",
    "Mask of Brutality","Mask of Darkness","Mask of Restrict","Mask of the Accursed","Masked Sorcerer",
    "Mataza the Zapper","Mechanicalchaser","Mefist the Infernal General","Mega Ton Magical Cannon","Megasonic Eye",
    "Mermaid Knight","Metallizing Parasite - Lunatite","Metalmorph","Metamorphosis","Meteor of Destruction",
    "Michizure","Millennium Shield","Milus Radiant","Mind Crush","Mirror Force","Mirror Wall",
    "Mobius the Frost Monarch","Moisture Creature","Monster Gate","Monster Reborn","Monster Recovery",
    "Monster Reincarnation","Morphing Jar #2","Mother Grizzly","Mudora","Muka Muka","Mystic Swordsman LV2",
    "Mystic Tomato","Mystical Sheep #1","Mystical Shine Ball","Mystical Space Typhoon","Necklace of Command",
    "Necrovalley","Needle Worm","Neko Mane King","Newdoria","Night Assailant","Nightmare Wheel","Nimble Momonga",
    "Ninja Grandmaster Sasuke","Ninjitsu Art of Transformation","Nobleman of Crossout","Nobleman of Extermination",
    "Nuvia the Wicked","Opticlops","Order to Charge","Paladin of White Dragon","Panther Warrior","Parasite Paracide","Parrot Dragon",
    "Penguin Soldier","Pharaoh's Treasure","Polymerization","Pot of Greed","Premature Burial","Princess of Tsurugi",
    "Protector of the Sanctuary","Pyramid Turtle","Rare Metalmorph","Re-Fusion","Ready for Intercepting",
    "Reaper of the Cards","Reasoning","Reckless Greed","Red-Eyes Black Metal Dragon","Red-Eyes Darkness Dragon",
    "Reflect Bounder","Reinforcement of the Army","Reload","Return from the Different Dimension",
    "Return of the Doomed","Revival Jam","Revival of Dokurorider","Riryoku Field","Ritual Weapon",
    "Rivalry of Warlords","Robbin' Goblin","Rocket Warrior","Rope of Life","Royal Command","Royal Magical Library",
    "Royal Oppression","Royal Tribute","Rude Kaiser","Ryu Senshi","Ryu-Kishin","Sage's Stone","Salvage",
    "Sangan","Sanwitch","Sasuke Samurai","Scapegoat","Sealmaster Meisei","Second Coin Toss","Seiyaryu",
    "Senju of the Thousand Hands","Seven Tools of the Bandit","Shadow Ghoul","Shadow Spell","Shadow Tamer",
    "Share the Pain","Shield & Sword","Shift","Shining Angel","Silent Magician LV4","Silent Magician LV8",
    "Silent Swordsman LV3","Silent Swordsman LV5","Silent Swordsman LV7","Sinister Serpent","Skilled Dark Magician",
    "Skull Invitation","Skull Servant","Slate Warrior","Smoke Grenade of the Thief","Snatch Steal",
    "Sorcerer of Dark Magic","Soul Absorption","Soul Exchange","Soul of the Pure","Soul Resurrection",
    "Spear Dragon","Spell Economics","Spell Shield Type-8","Spellbinding Circle","Spiral Spear Strike",
    "Spirit Barrier","Spirit Message A","Spirit Message I","Spirit Message L","Spirit Message N",
    "Spirit of the Breeze","Spirit of the Harp","Star Boy","Statue of the Wicked","Steel Ogre Grotto #2",
    "Stone Statue of the Aztecs","Stop Defense","Stray Lambs","Summoned Skull","Super Rejuvenation",
    "Sword of Dragon's Soul","Swords of Concealing Light","Swords of Revealing Light","Talisman of Spell Sealing",
    "Talisman of Trap Sealing","Terraforming","The A Forces","The Agent of Creation - Venus",
    "The Agent of Force - Mars","The Agent of Wisdom - Mercury","The Dragon's Bead","The Fiend Megacyber",
    "The Flute of Summoning Dragon","The Legendary Fisherman","The Sanctuary in the Sky","The Shallow Grave",
    "Theban Nightmare","Thestalos the Firestorm Monarch","Thousand Dragon","Thousand Energy",
    "Three-Legged Zombies","Thunder Dragon","Thunder Nyan Nyan","Tiger Axe","Time Wizard","Token Feastevil",
    "Toon Cannon Soldier","Toon Gemini Elf","Toon Goblin Attack Force","Toon Masked Sorcerer","Toon Mermaid",
    "Toon Summoned Skull","Toon Table of Contents","Toon World","Tornado Bird","Torrential Tribute",
    "Trap Dustshoot","Trap Jammer","Trap of Board Eraser","Triangle Ecstasy Spark","Triangle Power",
    "Tribe-Infecting Virus","Tribute to the Doomed","Twin-Headed Thunder Dragon","Two-Pronged Attack",
    "Tyrant Dragon","UFO Turtle","Ultimate Offering","Ultra Evolution Pill","United We Stand","Upstart Goblin",
    "Vampire Baby","Vampire Genesis","Vampire Lord","Vampiric Orchis","Versago the Destroyer","Wall of Illusion",
    "Wandering Mummy","Wave-Motion Cannon","White Magical Hat","Wicked-Breaking Flamberge - Baou","Widespread Ruin",
    "Wild Nature's Release","Windstorm of Etaqua","Witch of the Black Forest","Witch's Apprentice","X-Head Cannon",
    "XY-Dragon Cannon","XZ-Tank Cannon","Y-Dragon Head","Yamadron","Yaranzo","Yomi Ship","Z-Metal Tank",
    "Zaborg the Thunder Monarch",
}

YuSpiffOh.cardsByRarity.rare = {
    "Acid Trap Hole","Ameba","Anti-Spell Fragrance","Appropriate","Assault on GHQ","B E S Big Core","Barrel Dragon",
    "Beautiful Headhuntress","Behemoth the King of All Animals","Berserk Dragon",
    "Black Luster Soldier - Envoy of the Beginning","Black Skull Dragon","Blast Held by a Tribute","Blue Medicine",
    "Blue-Eyes Shining Dragon","Blue-Eyes Toon Dragon","Blue-Eyes White Dragon","Burning Spear",
    "Butterfly Dagger - Elma","Catapult Turtle","Chain Disappearance","Chaos Command Magician",
    "Charubin the Fire Knight","Confiscation","Cosmo Queen","Cost Down","Criosphinx","Cyber Jar",
    "D D Assailant","Dark Balter the Terrible","Dark Flare Knight","Dark Magician","Dark Magician of Chaos",
    "Dark Necrofear","Dark Ruler Ha Des","Dark Sage","Darklord Marie","Dedication through Light and Darkness",
    "Des Counterblow","Des Volstgalph","Dimension Fusion","Don Zaloog","Dragoness the Wicked Knight",
    "Ectoplasmer","Elemental HERO Thunder Giant","Elf's Light","Exchange","Exile of the Wicked","Exodia Necross",
    "Fairy King Truesdale","Fiend Skull Dragon","Fire Princess","Flame Ghost","Flint","Flower Wolf",
    "Gaia Soul the Combustible Collective","Gaia the Dragon Champion","Gate Guardian","Ghost Knight of Jackal",
    "Gravedigger Ghoul","Graverobber","Guardian Angel Joan","Guardian Ceal","Guardian Grarl","Gust Fan",
    "Hallowed Life Barrier","Harpie's Pet Dragon","Hieracosphinx","Horus the Black Flame Dragon LV8","Hoshiningen",
    "Imperial Order","Injection Fairy Lily","Invader of the Throne","Jinzo","Kazejin","Lava Golem",
    "Left Arm of the Forbidden One","Left Leg of the Forbidden One","Legendary Flame Lord",
    "Levia-Dragon - Daedalus","Luminous Soldier","Manticore of Darkness","Mask of Dispel","Master of Oz",
    "Megamorph","Megarock Dragon","Messenger of Peace","Metal Dragon","Mind Control","Mirage Knight",
    "Mirage of Nightmare","Morphing Jar","Mystic Swordsman LV4","Mystic Swordsman LV6","Needle Burrower",
    "Novox's Prayer","Ojama King","Painful Choice","Penalty Game!","Phoenix Wing Wind Blast",
    "Pikeru's Circle of Enchantment","Prohibition","Raimei","Reaper on the Nightmare","Red-Eyes Black Dragon",
    "Relinquished","Rescue Cat","Restructer Revolution","Right Arm of the Forbidden One",
    "Right Leg of the Forbidden One","Ring of Destruction","Royal Decree","Sacred Phoenix of Nephthys",
    "Sanga of the Thunder","Serpent Night Dragon","Shadowslayer","Skill Drain","Skull Archfiend of Lightning",
    "Skull Guardian","Solemn Judgment","Sonic Maid","Special Hurricane","Spell Absorption","Spell Canceller",
    "Spirit of the Pharaoh","Spirit Reaper","Spiritualism","Steel Shell","Strike Ninja","Suijin","Susa Soldier",
    "Terrorking Archfiend","The Agent of Judgment - Saturn","The Creator","The First Sarcophagus",
    "The Masked Beast","Thousand-Eyes Restrict","Tragedy","Tsukuyomi","Valkyrion the Magna Warrior",
    "Warrior of Tradition","White Hole","Winged Kuriboh","XYZ-Dragon Cannon","Yata-Garasu","YZ-Tank Dragon",
}

YuSpiffOh.cardsByRarity.super_rare = {
    "A-Team: Trap Disposal Unit","Big Burn","Big-Tusked Mammoth","Brain Jacker","Call of the Grave","Chain Burst",
    "Cross Counter","Cyber-Stein","D D Designator","Dark Blade the Dragon Knight","Dark Mirror Force",
    "Different Dimension Dragon","Elemental HERO Flame Wingman","Elemental Mistress Doriado","Emes the Infinity",
    "Enervating Mist","Exodia the Forbidden One","Forced Ceasefire","Freed the Brave Wanderer","Garnecia Elefantis",
    "Giant Red Seasnake","Graceful Charity","Grave Ohja","Great Dezard","Harpie's Feather Duster","Inferno Hammer",
    "Kozaky's Self-Destruct Button","Kwagar Hercules","Legacy Hunter","Legendary Black Belt","Mid Shield Gardna",
    "Mikazukinoyaiba","Millennium Scorpion","Mind on Air","Mystical Knight of Jackal","Nitro Unit",
    "Ocean Dragon Lord - Neo-Daedalus","Orca Mega-Fortress of Darkness","Patrol Robo","Question",
    "Rafflesia Seduction","Raigeki","Royal Surrender","Sasuke Samurai #4","Serial Spell","Spell Vanishing",
    "Spell-Stopping Statute","Takriminos","Teva","The Forceful Sentry","Twinheaded Beast","Ultimate Insect LV1",
    "Ultimate Insect LV3","Ultimate Insect LV5","Yamata Dragon",
}

YuSpiffOh.cardsByRarity.ultra_rare = {
    "Andro Sphinx","Anti Raigeki","Archlord Zerato","Chaos Emperor Dragon - Envoy of the End","Delinquent Duo",
    "Fushioh Richie","Greed","Hino-Kagu-Tsuchi","Horn of Heaven","King Dragun","Master Monk","Mazera DeVille",
    "Muko","Penumbral Soldier Lady","Perfect Machine King","Reshef the Dark Being","Shinato, King of a Higher Plane",
    "Sphinx Teleia","The End of Anubis","The Last Warrior from Another Planet","Theinen the Great Sphinx",
    "Tri-Horned Dragon","Ultimate Insect LV7",
}

YuSpiffOh.deckIDs = {}
for deckID,cards in pairs(YuSpiffOh.Decks) do
    table.insert(YuSpiffOh.deckIDs, deckID)
end

YuSpiffOh.cards = {}
for _,cards in pairs(YuSpiffOh.cardsByRarity) do
    for _,card in pairs(cards) do
        table.insert(YuSpiffOh.cards, card)
    end
end
deckActionHandler.addDeck("yuSpiffOhCards", YuSpiffOh.cards)

gamePieceAndBoardHandler.registerSpecial("Base.yuSpiffOhCards", {
    actions = { examine=true}, examineScale = 1, applyCards = "applyCardForYuSpiffOh", textureSize = {100,140}
})