local WeaponController = _G.class('WeaponController')
local WEAPON = require("objects.Enums.Weapon")

function WeaponController:initialize()
    self.list = {}
    self.weapons = {}

    for _, v in pairs(WEAPON) do
        self.weapons[v] = {}
    end

    self.nodeList = {}
end

function WeaponController:store(weapon) -- TODO add amount
    if _G.state.notFullArmoury[weapon] < 1 then
        for _, v in ipairs(self.list) do
            if v:store(weapon) then
                return true
            end
        end
    else
        self.weapons[weapon][#self.weapons[weapon]].id.parent:store(weapon)
        return true
    end
end

function WeaponController:take(weapon, amount)
    local takenWeapon = 0
    if not weapon then
        for _ = 1, (amount or 1) do
            for weaponType, weaponPile in pairs(self.weapons) do
                if takenWeapon == amount then
                    return
                end
                if next(weaponPile) ~= nil then
                    takenWeapon = takenWeapon + 1
                    weaponPile[#weaponPile].id.parent:take(weaponType, weaponPile[#weaponPile])
                end
            end
        end
    else
        for _ = 1, (amount or 1) do
            if next(self.weapons[weapon]) == nil then
                break
            else
                self.weapons[weapon][#self.weapons[weapon]].id.parent:take(weapon, self.weapons[weapon][#self.weapons[weapon]])
            end
        end
    end
end

function WeaponController:serialize()
    local data = {}
    data.nodeList = self.nodeList
    local weapon = {}
    for weapontype, weaponlist in pairs(self.weapons) do
        weapon[weapontype] = {}
        for i, weaponpile in ipairs(weaponlist) do
            weapon[weapontype][i] = {}
            for sk, sv in pairs(weaponpile) do
                if sk == "id" then
                    weapon[weapontype][i][sk] = _G.state:serializeObject(sv)
                else
                    weapon[weapontype][i][sk] = sv
                end
            end
        end
    end
    local armouryList = {}
    for _, v in ipairs(self.list) do
        armouryList[#armouryList + 1] = _G.state:serializeObject(v)
    end
    data.armouryList = armouryList
    data.rawWeapon = weapon
    return data
end

function WeaponController:deserialize(data)
    self.nodeList = data.nodeList
    for weapontype, weaponlist in pairs(data.rawWeapon) do
        self.weapons[weapontype] = {}
        for i, weaponpile in ipairs(weaponlist) do
            self.weapons[weapontype][i] = {}
            for sk, sv in pairs(weaponpile) do
                if sk == "id" then
                    self.weapons[weapontype][i][sk] = _G.state:dereferenceObject(sv)
                else
                    self.weapons[weapontype][i][sk] = sv
                end
            end
        end
    end
    for _, v in ipairs(data.armouryList) do
        self.list[#self.list + 1] = _G.state:dereferenceObject(v)
    end
end

return WeaponController:new()
