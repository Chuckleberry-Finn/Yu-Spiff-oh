require "recipecode"
require "gameNight - recipes"

function Recipe.GameNight.OpenSealedYuSpiffOhCards(craftRecipeData, character)
    --local item = craftRecipeData:getAllConsumedItems():get(0)
    local result = craftRecipeData:getAllCreatedItems():get(0)
    result:getModData()["gameNight_specialOnCardApplyBooster"] = true
end