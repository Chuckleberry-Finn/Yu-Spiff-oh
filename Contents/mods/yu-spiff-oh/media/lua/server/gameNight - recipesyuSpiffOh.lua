require "recipecode"
require "gameNight - recipes"

function Recipe.GameNight.OpenBoosterYuSpiffOh(items, result, player)
    result:getModData()["gameNight_specialOnCardApplyBooster"] = true
end