---@enum event
local EVENTS = {
    OnResourceStore = 1,
    OnResourceTake = 2,
    OnMarketBuy = 3,
    OnMarketSell = 4,
    OnGoldChanged = 5,
    OnTaxCollected = 6,
    OnPopulationChange = 7,
    OnWeaponStore = 8,
    OnWeaponTake = 9,
    OnFoodStore = 10,
    OnFoodTake = 11,
    OnBuildingPlaced = 12,
    OnBuildingDestroyed = 13,
    OnMissionCompleted = 14,
    OnTierUpgraded = 15,
    OnHouseUpgraded = 16,
    OnMaxPopChanged = 17,
    OnMarketResourceClicked = 18,
    OnInGameTimeChanged = 19
}

return EVENTS
