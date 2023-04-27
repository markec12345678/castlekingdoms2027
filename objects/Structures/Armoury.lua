local tileQuads = require("objects.object_quads")
local Structure = require("objects.Structure")
local Object = require("objects.Object")

local tiles, quadArray = _G.indexBuildingQuads("armory (1)")
local tilesExt, quadArrayExt = _G.indexBuildingQuads("armory (2)")

local WEAPON = require("objects.Enums.Weapon")
local quadMap = {}
for _, v in pairs(WEAPON) do
    quadMap[v] = {}
end

local armouryFx = {
    ["weapons"] = {_G.fx["stckweap2"],},
}

for i = 1, 16 do
    quadMap[WEAPON.bow][#quadMap[WEAPON.bow] + 1] = tileQuads["bow_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.crossbow][#quadMap[WEAPON.crossbow] + 1] = tileQuads["crossbow_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.spear][#quadMap[WEAPON.spear] + 1] = tileQuads["spear_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.pike][#quadMap[WEAPON.pike] + 1] = tileQuads["pike_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.mace][#quadMap[WEAPON.mace] + 1] = tileQuads["mace_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.sword][#quadMap[WEAPON.sword] + 1] = tileQuads["sword_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.leatherArmor][#quadMap[WEAPON.leatherArmor] + 1] = tileQuads["leather_goods (" .. tostring(i) .. ")"]
    quadMap[WEAPON.shield][#quadMap[WEAPON.shield] + 1] = tileQuads["shield_goods (" .. tostring(i) .. ")"]
end

local goodsOffsetY = {
    [WEAPON.bow] = -58 - 11,
    [WEAPON.crossbow] = -54 - 11,
    [WEAPON.spear] = -83,
    [WEAPON.pike] = -79 - 11,
    [WEAPON.mace] = -67 - 11,
    [WEAPON.sword] = -66 - 11,
    [WEAPON.leatherArmor] = -52 - 11,
    [WEAPON.shield] = -48 - 11,
}

local maxQuantity = {
    [WEAPON.bow] = 16,
    [WEAPON.crossbow] = 16,
    [WEAPON.spear] = 16,
    [WEAPON.pike] = 16,
    [WEAPON.mace] = 16,
    [WEAPON.sword] = 16,
    [WEAPON.leatherArmor] = 16,
    [WEAPON.shield] = 16,
}


local ArmouryAlias = _G.class("ArmouryAlias", Structure)
function ArmouryAlias:initialize(tile, gx, gy, parent, offsetY, offsetX, serializeParent)
    local mytype = "Static structure"
    self.parent = parent
    Structure.initialize(self, gx, gy, mytype)
    self.serializeParent = not (serializeParent)
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.tile = tile
    self.baseOffsetY = offsetY or 0
    self.additionalOffsetY = 0
    self.offsetX = offsetX or 0
    self.offsetY = self.additionalOffsetY - self.baseOffsetY
    self:render()
end

function ArmouryAlias:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.serializeParent then
        data.parent = _G.state:serializeObject(self.parent)
    end
    data.serializeParent = self.serializeParent
    data.tileKey = self.tileKey
    data.baseOffsetY = self.baseOffsetY
    data.additionalOffsetY = self.additionalOffsetY
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function ArmouryAlias.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    if data.tileKey then
        obj.tile = quadArray[data.tileKey]
        obj.tileKey = data.tileKey
        obj:render()
    end
    if obj.serializeParent then
        obj.parent = _G.state:dereferenceObject(data.parent)
    end
    return obj
end

local Armoury = _G.class("Armoury", Structure)

Armoury.static.WIDTH = 4
Armoury.static.LENGTH = 4
Armoury.static.HEIGHT = 18
Armoury.static.ALIAS_NAME = "ArmouryAlias"
Armoury.static.DESTRUCTIBLE = true

function Armoury:initialize(gx, gy)
    Structure.initialize(self, gx, gy, "Armoury")
    _G.state.map:setWalkable(self.gx, self.gy, 1)
    self.health = 200
    self.tile = quadArray[tiles + 1]
    self.offsetX = 0
    self.offsetY = -45 * 2 + 6
    for tile = 1, tiles do
        local hsl = ArmouryAlias:new(quadArray[tile], self.gx, self.gy + (tiles - tile + 1), self,
            -self.offsetY + 8 * (tiles - tile + 1))
        hsl.tileKey = tile
    end
    for tile = 1, tiles do
        local hsl = ArmouryAlias:new(quadArray[tiles + 1 + tile], self.gx + tile, self.gy, self, -self.offsetY + 8 * tile
            , 16)
        hsl.tileKey = tiles + 1 + tile
    end


    self.weaponpile = {}
    for i = 1, 4 do
        self.weaponpile[i] = {
            id = nil,
            empty = true,
            type = nil,
            quantity = 0,
            index = i
        }
    end

    self.weaponpile[1].id = ArmouryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 1, self, 0, -8 - 6, true)
    self.weaponpile[2].id = ArmouryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 1, self, 3, -8 - 6 - 3, true)
    self.weaponpile[3].id = ArmouryAlias:new(tileQuads["empty"], self.gx + 1, self.gy + 3, self, 0, -8 - 6, true)
    self.weaponpile[4].id = ArmouryAlias:new(tileQuads["empty"], self.gx + 3, self.gy + 3, self, 3, -8 - 6 - 3, true)

    table.insert(_G.weaponpile.nodeList, {
        gx = self.gx + 4,
        gy = self.gy + 4
    })
    table.insert(_G.weaponpile.nodeList, {
        gx = self.gx - 1,
        gy = self.gy + 4
    })
    table.insert(_G.weaponpile.nodeList, {
        gx = self.gx + 4,
        gy = self.gy - 1
    })
    table.insert(_G.weaponpile.nodeList, {
        gx = self.gx - 1,
        gy = self.gy - 1
    })

    _G.weaponpile.list[(#_G.weaponpile.list or 0) + 1] = self

    local tileQuads = require("objects.object_quads")
    for xx = 0, Armoury.static.WIDTH - 1 do
        for yy = 0, Armoury.static.LENGTH - 1 do
            if not _G.objectFromSubclassAtGlobal(self.gx + xx, self.gy + yy, Structure) then
                ArmouryAlias:new(tileQuads["empty"], self.gx + xx, self.gy + yy, self, 0, 0)
            end
        end
    end

    self:applyBuildingHeightMap()
end

function Armoury:destroy()
    _G.arrayRemove(_G.weaponpile.nodeList, function(t, i, j)
        local pile = _G.weaponpile.nodeList[i]
        local keepElement = not (pile.gx == self.gx + 4 and pile.gy == self.gy + 4)
            and not (pile.gx == self.gx - 1 and pile.gy == self.gy + 4)
            and not (pile.gx == self.gx + 4 and pile.gy == self.gy - 1)
            and not (pile.gx == self.gx - 1 and pile.gy == self.gy - 1)
        return keepElement
    end)
    _G.arrayRemove(_G.weaponpile.list, function(t, i, j)
        local armoury = _G.weaponpile.list[i]
        return armoury ~= self
    end)
    for i = 1, 4 do
        local pile = self.weaponpile[i]
        if pile.type then
            _G.state.weapons[pile.type] = _G.state.weapons[pile.type] - pile.quantity
            if pile.quantity < maxQuantity[pile.type] then
                _G.state.notFullArmoury[pile.type] = _G.state.notFullArmoury[pile.type] - 1
            end
            if pile.quantity > 0 then
                table.remove(_G.weaponpile.weapons[pile.type], pile.key)
            end
        end
    end
    if _G.BuildingManager:count(self.class) == 1 then
        _G.state.firstArmoury = true
    end
    Structure.destroy(self)
end

function Armoury:onClick()
    local ActionBar = require("states.ui.ActionBar")
    ActionBar:switchMode("armoury")
end

function Armoury:store(weapon)
    for index = 1, #self.weaponpile do
        if self.weaponpile[index].type == weapon and self.weaponpile[index].quantity < maxQuantity[weapon] then
            self.weaponpile[index].quantity = self.weaponpile[index].quantity + 1
            _G.state.weapons[weapon] = _G.state.weapons[weapon] + 1
            self:updateWeaponPile(index)
            _G.playSfx(self, armouryFx["weapons"])
            return true
        end
    end
    local found = false
    for index = 1, #self.weaponpile do
        if self.weaponpile[index].empty then
            self.weaponpile[index].empty = false
            self.weaponpile[index].type = weapon
            self.weaponpile[index].quantity = 1
            _G.state.notFullArmoury[self.weaponpile[index].type] = _G.state.notFullArmoury[self.weaponpile[index].type] +
                1
            _G.state.weapons[weapon] = _G.state.weapons[weapon] + 1
            self.weaponpile[index].key = #_G.weaponpile.weapons[weapon] + 1
            _G.weaponpile.weapons[weapon][self.weaponpile[index].key] = self.weaponpile[index]
            self:updateWeaponPile(index)
            found = true
            _G.playSfx(self, armouryFx["weapons"])
            break
        end
    end
    if not found then
        return false
    else
        return true
    end
end

function Armoury:take(weapon, from)
    if from.type == weapon and from.quantity > 0 then
        if from.quantity == maxQuantity[weapon] then
            _G.state.notFullArmoury[weapon] = _G.state.notFullArmoury[weapon] + 1
        end
        from.quantity = from.quantity - 1
        _G.state.weapons[weapon] = _G.state.weapons[weapon] - 1
        self:updateWeaponPile(from)
        return true
    end
    for index = 1, 9 do
        if self.weaponpile[index].type == weapon and self.weaponpile[index].quantity > 0 then
            self.weaponpile[index].quantity = self.weaponpile[index].quantity - 1
            _G.state.weapons[weapon] = _G.state.weapons[weapon] - 1
            self:updateWeaponPile(index)
            return true
        end
    end
    return false
end

function Armoury:hideWeaponPiles()
    for _, pile in ipairs(self.weaponpile) do
        pile.id.tile = tileQuads["empty"]
        pile.id:render()
    end
end

function Armoury:showWeaponPiles()
    for idx, pile in ipairs(self.weaponpile) do
        if pile.quantity > 0 then
            self:updateWeaponPile(idx, true)
        end
    end
end

function Armoury:updateWeaponPile(index, induced)
    local pile
    if type(index) ~= "number" then
        pile = index
    else
        pile = self.weaponpile[index]
    end
    if pile.quantity == 0 then
        table.remove(_G.weaponpile.weapons[pile.type], pile.key)
        _G.state.notFullArmoury[pile.type] = _G.state.notFullArmoury[pile.type] - 1
        pile.quantity = -1
        pile.type = nil
        pile.empty = true
        pile.id.tile = tileQuads["empty"]
        pile.id:render()
        return
    end
    pile.id.tile = quadMap[pile.type][pile.quantity]
    pile.id.additionalOffsetY = goodsOffsetY[pile.type]
    pile.id.offsetY = pile.id.additionalOffsetY - pile.id.baseOffsetY
    pile.id:render()
    if pile.quantity == maxQuantity[pile.type] then
        _G.state.notFullArmoury[pile.type] = _G.state.notFullArmoury[pile.type] - 1
    end
    if not induced then
        self:enterHover(true)
    end
end

function Armoury:load(data)
    Object.deserialize(self, data)
    Structure.load(self, data)
    self.tile = quadArray[tiles + 1]
    self:applyBuildingHeightMap()
end

function Armoury:serialize()
    local data = {}
    local structData = Structure.serialize(self)
    for k, v in pairs(structData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    data.stPileRaw = {}
    for _, v in ipairs(self.weaponpile) do
        data.stPileRaw[#data.stPileRaw + 1] = {}
        for sk, sv in pairs(v) do
            if sk ~= "id" then
                data.stPileRaw[#data.stPileRaw][sk] = sv
            else
                data.stPileRaw[#data.stPileRaw][sk] = _G.state:serializeObject(sv)
            end
        end
    end
    data.health = self.health
    data.offsetX = self.offsetX
    data.offsetY = self.offsetY
    return data
end

function Armoury.static:deserialize(data)
    local obj = self:allocate()
    Object.deserialize(obj, data)
    Structure.load(obj, data)
    obj.weaponpile = {}
    for idx, v in ipairs(data.stPileRaw) do
        obj.weaponpile[idx] = {}
        for sk, sv in pairs(v) do
            if sk == "id" then
                obj.weaponpile[idx][sk] = _G.state:dereferenceObject(sv)
                obj.weaponpile[idx][sk].parent = obj
            else
                obj.weaponpile[idx][sk] = sv
            end
        end
    end
    for idx, pile in ipairs(obj.weaponpile) do
        if pile.quantity > 0 then
            obj:updateWeaponPile(idx)
        end
    end
    obj.tile = quadArray[tiles + 1]
    Structure.render(obj)
    return obj
end

function Armoury:enterHover(induced)
    local armories = _G.BuildingManager:getPlayerBuildings(Armoury)
    for _, v in pairs(armories) do
        if not induced then
            v.hover = true
        end
        for tile = 1, tiles do
            local alias = _G.objectFromClassAtGlobal(v.gx, v.gy + (tiles - tile + 1), ArmouryAlias)
            if not alias then return end
            alias.tile = quadArray[tile]
            alias.tileKey = tile
            alias:render()
        end

        for tile = 1, tiles do
            local alias = _G.objectFromClassAtGlobal(v.gx + tile, v.gy, ArmouryAlias)
            if not alias then return end
            alias.tile = quadArray[tiles + 1 + tile]
            alias.tileKey = tiles + 1 + tile
            alias:render()
        end
        v.tile = quadArray[tiles + 1]
        v:render()
        v:showWeaponPiles()
    end
end

function Armoury:exitHover(induced)
    local armories = _G.BuildingManager:getPlayerBuildings(Armoury)
    for _, v in pairs(armories) do
        if induced then
            if v.hover then return end
        end
        v.hover = false
        for tile = 1, tilesExt do
            local alias = _G.objectFromClassAtGlobal(v.gx, v.gy + (tilesExt - tile + 1), ArmouryAlias)
            if alias then
                alias.tile = quadArrayExt[tile]
                alias.tileKey = tile
                alias:render()
            end
        end

        for tile = 1, tilesExt do
            local alias = _G.objectFromClassAtGlobal(v.gx + tile, v.gy, ArmouryAlias)
            if alias then
                alias.tile = quadArrayExt[tilesExt + 1 + tile]
                alias.tileKey = tilesExt + 1 + tile
                alias:render()
            end
        end
        v.tile = quadArrayExt[tilesExt + 1]
        v:render()
        v:hideWeaponPiles()
    end
end

return Armoury
