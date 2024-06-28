local Unit = require("objects.Units.Unit")
local Object = require("objects.Object")
local anim = require("libraries.anim8")

local ANIM_WALKING_EAST = "walking_east"
local ANIM_WALKING_NORTH = "walking_north"
local ANIM_WALKING_NORTHEAST = "walking_northeast"
local ANIM_WALKING_NORTHWEST = "walking_northwest"
local ANIM_WALKING_SOUTH = "walking_south"
local ANIM_WALKING_SOUTHEAST = "walking_southeast"
local ANIM_WALKING_SOUTHWEST = "walking_southwest"
local ANIM_WALKING_WEST = "walking_west"
-- EAT
local ANIM_EATING_EAST = "eating_east"
local ANIM_EATING_NORTH = "eating_north"
local ANIM_EATING_NORTHEAST = "eating_northeast"
local ANIM_EATING_NORTHWEST = "eating_northwest"
local ANIM_EATING_SOUTH = "eating_south"
local ANIM_EATING_SOUTHEAST = "eating_southeast"
local ANIM_EATING_SOUTHWEST = "eating_southwest"
local ANIM_EATING_WEST = "eating_west"
-- sit
local ANIM_SITTING_EAST = "sitting_east"
local ANIM_SITTING_NORTH = "sitting_north"
local ANIM_SITTING_NORTHEAST = "sitting_northeast"
local ANIM_SITTING_NORTHWEST = "sitting_northwest"
local ANIM_SITTING_SOUTH = "sitting_south"
local ANIM_SITTING_SOUTHEAST = "sitting_southeast"
local ANIM_SITTING_SOUTHWEST = "sitting_southwest"
local ANIM_SITTING_WEST = "sitting_west"
-- sit
local ANIM_STANDING_UP_EAST = "standing_up_east"
local ANIM_STANDING_UP_NORTH = "standing_up_north"
local ANIM_STANDING_UP_NORTHEAST = "standing_up_northeast"
local ANIM_STANDING_UP_NORTHWEST = "standing_up_northwest"
local ANIM_STANDING_UP_SOUTH = "standing_up_south"
local ANIM_STANDING_UP_SOUTHEAST = "standing_up_southeast"
local ANIM_STANDING_UP_SOUTHWEST = "standing_up_southwest"
local ANIM_STANDING_UP_WEST = "standing_up_west"
-- run
local ANIM_RUNNING_EAST = "sit_east"
local ANIM_RUNNING_NORTH = "sit_north"
local ANIM_RUNNING_NORTHEAST = "sit_northeast"
local ANIM_RUNNING_NORTHWEST = "sit_northwest"
local ANIM_RUNNING_SOUTH = "sit_south"
local ANIM_RUNNING_SOUTHEAST = "sit_southeast"
local ANIM_RUNNING_SOUTHWEST = "sit_southwest"
local ANIM_RUNNING_WEST = "sit_west"
-- die from arrow
local ANIM_DIE_ARROW = "die_arrow"

local DEER_ADULT = "adult"
local DEER_MEDIUM = "medium"
local DEER_BABY = "baby"

local reverseBothAndConcanate = function(array1, array2)
    local reverse1 = _G.reverse(array1)
    local reverse2 = _G.reverse(array2)
    return _G.addOther(reverse1, reverse2)
end

local an = {
    [DEER_ADULT] = {
        [ANIM_WALKING_EAST] = _G.indexQuads("body_deer_walk_e", 16),
        [ANIM_WALKING_NORTH] = _G.indexQuads("body_deer_walk_n", 16),
        [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_deer_walk_ne", 16),
        [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_deer_walk_nw", 16),
        [ANIM_WALKING_SOUTH] = _G.indexQuads("body_deer_walk_s", 16),
        [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_deer_walk_se", 16),
        [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_deer_walk_sw", 16),
        [ANIM_WALKING_WEST] = _G.indexQuads("body_deer_walk_w", 16),
        --128
        --EAT
        [ANIM_EATING_EAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_e", 8, nil, true))),
        [ANIM_EATING_NORTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_n", 8, nil, true))),
        [ANIM_EATING_NORTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_ne", 8, nil, true))),
        [ANIM_EATING_NORTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_nw", 8, nil, true))),
        [ANIM_EATING_SOUTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_s", 8, nil, true))),
        [ANIM_EATING_SOUTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_se", 8, nil, true))),
        [ANIM_EATING_SOUTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_sw", 8, nil, true))),
        [ANIM_EATING_WEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_eat_w", 8, nil, true))),
        --64
        --SIT
        [ANIM_SITTING_EAST] = _G.indexQuads("body_deer_sit_e", 16),
        [ANIM_SITTING_NORTH] = _G.indexQuads("body_deer_sit_n", 16),
        [ANIM_SITTING_NORTHEAST] = _G.indexQuads("body_deer_sit_ne", 16),
        [ANIM_SITTING_NORTHWEST] = _G.indexQuads("body_deer_sit_nw", 16),
        [ANIM_SITTING_SOUTH] = _G.indexQuads("body_deer_sit_s", 16),
        [ANIM_SITTING_SOUTHEAST] = _G.indexQuads("body_deer_sit_se", 16),
        [ANIM_SITTING_SOUTHWEST] = _G.indexQuads("body_deer_sit_sw", 16),
        [ANIM_SITTING_WEST] = _G.indexQuads("body_deer_sit_w", 16),
        -- standing up
        [ANIM_STANDING_UP_EAST] = _G.reverse(_G.indexQuads("body_deer_sit_e", 16)),
        [ANIM_STANDING_UP_NORTH] = _G.reverse(_G.indexQuads("body_deer_sit_n", 16)),
        [ANIM_STANDING_UP_NORTHEAST] = _G.reverse(_G.indexQuads("body_deer_sit_ne", 16)),
        [ANIM_STANDING_UP_NORTHWEST] = _G.reverse(_G.indexQuads("body_deer_sit_nw", 16)),
        [ANIM_STANDING_UP_SOUTH] = _G.reverse(_G.indexQuads("body_deer_sit_s", 16)),
        [ANIM_STANDING_UP_SOUTHEAST] = _G.reverse(_G.indexQuads("body_deer_sit_se", 16)),
        [ANIM_STANDING_UP_SOUTHWEST] = _G.reverse(_G.indexQuads("body_deer_sit_sw", 16)),
        [ANIM_STANDING_UP_WEST] = _G.reverse(_G.indexQuads("body_deer_sit_w", 16)),
        --128
        --RUNNING
        [ANIM_RUNNING_EAST] = _G.indexQuads("body_deer_run_e", 16),
        [ANIM_RUNNING_NORTH] = _G.indexQuads("body_deer_run_n", 16),
        [ANIM_RUNNING_NORTHEAST] = _G.indexQuads("body_deer_run_ne", 16),
        [ANIM_RUNNING_NORTHWEST] = _G.indexQuads("body_deer_run_nw", 16),
        [ANIM_RUNNING_SOUTH] = _G.indexQuads("body_deer_run_s", 16),
        [ANIM_RUNNING_SOUTHEAST] = _G.indexQuads("body_deer_run_se", 16),
        [ANIM_RUNNING_SOUTHWEST] = _G.indexQuads("body_deer_run_sw", 16),
        [ANIM_RUNNING_WEST] = _G.indexQuads("body_deer_run_w", 16),
        --DIE
        [ANIM_DIE_ARROW] = _G.indexQuads("body_deer_die_arrow", 24),
    },
    [DEER_MEDIUM] = {
        [ANIM_WALKING_EAST] = _G.indexQuads("body_deer_medium_walk_e", 16),
        [ANIM_WALKING_NORTH] = _G.indexQuads("body_deer_medium_walk_n", 16),
        [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_deer_medium_walk_ne", 16),
        [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_deer_medium_walk_nw", 16),
        [ANIM_WALKING_SOUTH] = _G.indexQuads("body_deer_medium_walk_s", 16),
        [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_deer_medium_walk_se", 16),
        [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_deer_medium_walk_sw", 16),
        [ANIM_WALKING_WEST] = _G.indexQuads("body_deer_medium_walk_w", 16),
        --128
        --EAT
        [ANIM_EATING_EAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_e", 8, nil, true))),
        [ANIM_EATING_NORTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_n", 8, nil, true))),
        [ANIM_EATING_NORTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_ne", 8, nil, true))),
        [ANIM_EATING_NORTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_nw", 8, nil, true))),
        [ANIM_EATING_SOUTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_s", 8, nil, true))),
        [ANIM_EATING_SOUTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_se", 8, nil, true))),
        [ANIM_EATING_SOUTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_sw", 8, nil, true))),
        [ANIM_EATING_WEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_medium_eat_w", 8, nil, true))),
        --64
        [ANIM_SITTING_EAST] = _G.addOther(_G.indexQuads("body_deer_medium_sit_e", 8), _G.indexQuads("body_deer_medium_sit_part2_e", 8)),
        [ANIM_SITTING_NORTH] = _G.addOther(_G.indexQuads("body_deer_medium_sit_n", 8), _G.indexQuads("body_deer_medium_sit_part2_n", 8)),
        [ANIM_SITTING_NORTHEAST] = _G.addOther(_G.indexQuads("body_deer_medium_sit_ne", 8), _G.indexQuads("body_deer_medium_sit_part2_ne", 8)),
        [ANIM_SITTING_NORTHWEST] = _G.addOther(_G.indexQuads("body_deer_medium_sit_nw", 8), _G.indexQuads("body_deer_medium_sit_part2_nw", 8)),
        [ANIM_SITTING_SOUTH] = _G.addOther(_G.indexQuads("body_deer_medium_sit_s", 8), _G.indexQuads("body_deer_medium_sit_part2_s", 8)),
        [ANIM_SITTING_SOUTHEAST] = _G.addOther(_G.indexQuads("body_deer_medium_sit_se", 8), _G.indexQuads("body_deer_medium_sit_part2_se", 8)),
        [ANIM_SITTING_SOUTHWEST] = _G.addOther(_G.indexQuads("body_deer_medium_sit_sw", 8), _G.indexQuads("body_deer_medium_sit_part2_sw", 8)),
        [ANIM_SITTING_WEST] = _G.addOther(_G.indexQuads("body_deer_medium_sit_w", 8), _G.indexQuads("body_deer_medium_sit_part2_w", 8)),
        --
        [ANIM_STANDING_UP_EAST] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_e", 8), _G.indexQuads("body_deer_medium_sit_e", 8)),
        [ANIM_STANDING_UP_NORTH] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_n", 8), _G.indexQuads("body_deer_medium_sit_n", 8)),
        [ANIM_STANDING_UP_NORTHEAST] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_ne", 8), _G.indexQuads("body_deer_medium_sit_ne", 8)),
        [ANIM_STANDING_UP_NORTHWEST] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_nw", 8), _G.indexQuads("body_deer_medium_sit_nw", 8)),
        [ANIM_STANDING_UP_SOUTH] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_s", 8), _G.indexQuads("body_deer_medium_sit_s", 8)),
        [ANIM_STANDING_UP_SOUTHEAST] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_se", 8), _G.indexQuads("body_deer_medium_sit_se", 8)),
        [ANIM_STANDING_UP_SOUTHWEST] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_sw", 8), _G.indexQuads("body_deer_medium_sit_sw", 8)),
        [ANIM_STANDING_UP_WEST] = reverseBothAndConcanate(_G.indexQuads("body_deer_medium_sit_part2_w", 8), _G.indexQuads("body_deer_medium_sit_w", 8)),
        --128
        --RUNNING
        [ANIM_RUNNING_EAST] = _G.indexQuads("body_deer_medium_run_e", 16),
        [ANIM_RUNNING_NORTH] = _G.indexQuads("body_deer_medium_run_n", 16),
        [ANIM_RUNNING_NORTHEAST] = _G.indexQuads("body_deer_medium_run_ne", 16),
        [ANIM_RUNNING_NORTHWEST] = _G.indexQuads("body_deer_medium_run_nw", 16),
        [ANIM_RUNNING_SOUTH] = _G.indexQuads("body_deer_medium_run_s", 16),
        [ANIM_RUNNING_SOUTHEAST] = _G.indexQuads("body_deer_medium_run_se", 16),
        [ANIM_RUNNING_SOUTHWEST] = _G.indexQuads("body_deer_medium_run_sw", 16),
        [ANIM_RUNNING_WEST] = _G.indexQuads("body_deer_medium_run_w", 16),
        --DIE
        [ANIM_DIE_ARROW] = _G.indexQuads("body_deer_medium_die_arrow", 24),
    },
    [DEER_BABY] = {
        [ANIM_WALKING_EAST] = _G.indexQuads("body_deer_baby_walk_e", 16),
        [ANIM_WALKING_NORTH] = _G.indexQuads("body_deer_baby_walk_n", 16),
        [ANIM_WALKING_NORTHEAST] = _G.indexQuads("body_deer_baby_walk_ne", 16),
        [ANIM_WALKING_NORTHWEST] = _G.indexQuads("body_deer_baby_walk_nw", 16),
        [ANIM_WALKING_SOUTH] = _G.indexQuads("body_deer_baby_walk_s", 16),
        [ANIM_WALKING_SOUTHEAST] = _G.indexQuads("body_deer_baby_walk_se", 16),
        [ANIM_WALKING_SOUTHWEST] = _G.indexQuads("body_deer_baby_walk_sw", 16),
        [ANIM_WALKING_WEST] = _G.indexQuads("body_deer_baby_walk_w", 16),
        --128
        --EAT
        [ANIM_EATING_EAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_e", 8, nil, true))),
        [ANIM_EATING_NORTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_n", 8, nil, true))),
        [ANIM_EATING_NORTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_ne", 8, nil, true))),
        [ANIM_EATING_NORTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_nw", 8, nil, true))),
        [ANIM_EATING_SOUTH] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_s", 8, nil, true))),
        [ANIM_EATING_SOUTHEAST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_se", 8, nil, true))),
        [ANIM_EATING_SOUTHWEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_sw", 8, nil, true))),
        [ANIM_EATING_WEST] = _G.addReverse(_G.addReverse(_G.indexQuads("body_deer_baby_eat_w", 8, nil, true))),
        --64
        [ANIM_SITTING_EAST] = _G.indexQuads("body_deer_baby_sit_e", 16),
        [ANIM_SITTING_NORTH] = _G.indexQuads("body_deer_baby_sit_n", 16),
        [ANIM_SITTING_NORTHEAST] = _G.indexQuads("body_deer_baby_sit_ne", 16),
        [ANIM_SITTING_NORTHWEST] = _G.indexQuads("body_deer_baby_sit_nw", 16),
        [ANIM_SITTING_SOUTH] = _G.indexQuads("body_deer_baby_sit_s", 16),
        [ANIM_SITTING_SOUTHEAST] = _G.indexQuads("body_deer_baby_sit_se", 16),
        [ANIM_SITTING_SOUTHWEST] = _G.indexQuads("body_deer_baby_sit_sw", 16),
        [ANIM_SITTING_WEST] = _G.indexQuads("body_deer_baby_sit_w", 16),
        --
        [ANIM_STANDING_UP_EAST] = _G.reverse(_G.indexQuads("body_deer_baby_sit_e", 16)),
        [ANIM_STANDING_UP_NORTH] = _G.reverse(_G.indexQuads("body_deer_baby_sit_n", 16)),
        [ANIM_STANDING_UP_NORTHEAST] = _G.reverse(_G.indexQuads("body_deer_baby_sit_ne", 16)),
        [ANIM_STANDING_UP_NORTHWEST] = _G.reverse(_G.indexQuads("body_deer_baby_sit_nw", 16)),
        [ANIM_STANDING_UP_SOUTH] = _G.reverse(_G.indexQuads("body_deer_baby_sit_s", 16)),
        [ANIM_STANDING_UP_SOUTHEAST] = _G.reverse(_G.indexQuads("body_deer_baby_sit_se", 16)),
        [ANIM_STANDING_UP_SOUTHWEST] = _G.reverse(_G.indexQuads("body_deer_baby_sit_sw", 16)),
        [ANIM_STANDING_UP_WEST] = _G.reverse(_G.indexQuads("body_deer_baby_sit_w", 16)),
        --128
        --RUNNING
        [ANIM_RUNNING_EAST] = _G.indexQuads("body_deer_baby_walk_e", 16),
        [ANIM_RUNNING_NORTH] = _G.indexQuads("body_deer_baby_walk_n", 16),
        [ANIM_RUNNING_NORTHEAST] = _G.indexQuads("body_deer_baby_walk_ne", 16),
        [ANIM_RUNNING_NORTHWEST] = _G.indexQuads("body_deer_baby_walk_nw", 16),
        [ANIM_RUNNING_SOUTH] = _G.indexQuads("body_deer_baby_walk_s", 16),
        [ANIM_RUNNING_SOUTHEAST] = _G.indexQuads("body_deer_baby_walk_se", 16),
        [ANIM_RUNNING_SOUTHWEST] = _G.indexQuads("body_deer_baby_walk_sw", 16),
        [ANIM_RUNNING_WEST] = _G.indexQuads("body_deer_baby_walk_w", 16),
        --DIE
        [ANIM_DIE_ARROW] = _G.indexQuads("body_deer_baby_die_arrow", 24),
    }
}

local DEFAULT_ANIMATION_FRAMETIME = 0.05

local deerFx = {
    ["got_shot"] = { _G.fx["arrowbasic_01"], _G.fx["arrowbasic_02"] },
    ["fall"] = { _G.fx["deerfall_1"] }
}

local Deer = _G.class('Deer', Unit)

function Deer:initialize(gx, gy, herdIndex, age, type)
    Unit.initialize(self, gx, gy, type)
    self.state = "Idle"
    self.waitTimer = 0
    self.offsetY = -10
    self.offsetX = -5
    self.count = 1
    self.sitDownTimer = 0
    self.age = age or DEER_ADULT
    self.herdIndex = herdIndex
    self.previousHerdLocation = {["gx"] = nil, ["gy"] = nil}
    self.migrating = false
    self.marked = false
    self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_WEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_SITTING_WEST)
    self.sittingDirection = nil
    local speedmultiplier = nil
    if self.age == DEER_ADULT then
        speedmultiplier = 1
    elseif self.age == DEER_MEDIUM then
        speedmultiplier = 0.8
    else --BABY
        speedmultiplier = 0.6
    end
    self.straightWalkSpeed = math.floor(self.straightWalkSpeed * speedmultiplier)
    self.diagonalWalkSpeed = math.floor(self.diagonalWalkSpeed * speedmultiplier)
    _G.HerdController.deerHerds:registerDeer(self)
end

function Deer:startStandingUp()
    local facingDir = self.sittingDirection
    local callback = function()
        self:standUpCallback()
    end
    if facingDir == "west" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_WEST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_WEST)
    elseif facingDir == "southwest" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_SOUTHWEST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_SOUTHWEST)
    elseif facingDir == "northwest" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_NORTHWEST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_NORTHWEST)
    elseif facingDir == "north" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_NORTH], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_NORTH)
    elseif facingDir == "south" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_SOUTH], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_SOUTH)
    elseif facingDir == "east" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_EAST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_EAST)
    elseif facingDir == "southeast" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_SOUTHEAST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_SOUTHEAST)
    elseif facingDir == "northeast" then
        self.animation = anim.newAnimation(an[self.age][ANIM_STANDING_UP_NORTHEAST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_STANDING_UP_NORTHEAST)
    end
end

function Deer:standUpCallback()
    self.state = "Idle"
    self.marked = false
    self.animation:pauseAtEnd()
end

function Deer:startSittingDown()
    self.state = "Sitting"
    self.sittingDirection = self.moveDir or "west"
    local facingDir = self.sittingDirection
    local callback = function()
        self:sitDownCallback()
    end
    if facingDir == "west" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_WEST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_WEST)
    elseif facingDir == "southwest" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_SOUTHWEST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_SOUTHWEST)
    elseif facingDir == "northwest" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_NORTHWEST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_NORTHWEST)
    elseif facingDir == "north" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_NORTH], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_NORTH)
    elseif facingDir == "south" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_SOUTH], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_SOUTH)
    elseif facingDir == "east" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_EAST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_EAST)
    elseif facingDir == "southeast" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_SOUTHEAST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_SOUTHEAST)
    elseif facingDir == "northeast" then
        self.animation = anim.newAnimation(an[self.age][ANIM_SITTING_NORTHEAST], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_SITTING_NORTHEAST)
    end
end

function Deer:sitDownCallback()
    self.sitDownTimer = math.random(5, 10)
    self.animation:pauseAtEnd()
end

local eatingDurations = {["1-5"] = 0.09, ["6-7"] = 0.12, ["8-9"] = 0.3, ["10-14"] = 0.09, ["15-17"] = 0.7, ["18-23"] = 0.09, ["24-25"] = 0.25, ["26-30"] = 0.09, ["31-32"] = 0.7, ["33-51"] = 0.09,
    ["52-53"] = 0.7}
function Deer:startEating()
    self.state = "Eating"
    local facingDir = self.moveDir
    local callback = function()
        self:eatingCallback()
    end
    if facingDir == "west" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_WEST], eatingDurations, callback, ANIM_EATING_WEST)
    elseif facingDir == "southwest" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_SOUTHWEST], eatingDurations, callback, ANIM_EATING_SOUTHWEST)
    elseif facingDir == "northwest" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_NORTHWEST], eatingDurations, callback, ANIM_EATING_NORTHWEST)
    elseif facingDir == "north" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_NORTH], eatingDurations, callback, ANIM_EATING_NORTH)
    elseif facingDir == "south" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_SOUTH], eatingDurations, callback, ANIM_EATING_SOUTH)
    elseif facingDir == "east" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_EAST], eatingDurations, callback, ANIM_EATING_EAST)
    elseif facingDir == "southeast" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_SOUTHEAST], eatingDurations, callback, ANIM_EATING_SOUTHEAST)
    elseif facingDir == "northeast" then
        self.animation = anim.newAnimation(an[self.age][ANIM_EATING_NORTHEAST], eatingDurations, callback, ANIM_EATING_NORTHEAST)
    end
end

function Deer:eatingCallback()
    self.state = "Idle"
end

function Deer:dirSubUpdate()
    if self.moveDir == "west" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_WEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_WEST)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_WEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_WEST)
        end
    elseif self.moveDir == "southwest" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_SOUTHWEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_SOUTHWEST)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_SOUTHWEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_SOUTHWEST)
        end
    elseif self.moveDir == "northwest" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_NORTHWEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_NORTHWEST)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_NORTHWEST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_NORTHWEST)
        end
    elseif self.moveDir == "north" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_NORTH], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_NORTH)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_NORTH], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_NORTH)
        end
    elseif self.moveDir == "south" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_SOUTH], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_SOUTH)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_SOUTH], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_SOUTH)
        end
    elseif self.moveDir == "east" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_EAST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_EAST)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_EAST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_EAST)
        end
    elseif self.moveDir == "southeast" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_SOUTHEAST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_SOUTHEAST)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_SOUTHEAST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_SOUTHEAST)
        end
    elseif self.moveDir == "northeast" then
        if self.state == "run" then
            self.animation = anim.newAnimation(an[self.age][ANIM_RUNNING_NORTHEAST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_RUNNING_NORTHEAST)
        else
            self.animation = anim.newAnimation(an[self.age][ANIM_WALKING_NORTHEAST], DEFAULT_ANIMATION_FRAMETIME, nil, ANIM_WALKING_NORTHEAST)
        end
    end
end

function Deer:followTheHerd()
    local gx, gy = _G.HerdController.deerHerds:getHerdPosition(self.herdIndex)
    if self.previousHerdLocation.gx ~= gx or self.previousHerdLocation.gy ~= gy then
        self.migrating = true
        self.previousHerdLocation.gx = gx 
        self.previousHerdLocation.gy = gy
        local targetX, targetY
        repeat
            targetX = gx + math.random(-5, 5)
            targetY = gy + math.random(-5, 5)
        until _G.state.map:getWalkable(targetX, targetY) == 0
        return targetX, targetY
    else
        return self.gx, self.gy
    end
end

function Deer:die()
    _G.HerdController.deerHerds:removeDeer(self)
    self.toBeDeleted = true
    _G.freeVertexFromTile(self.cx, self.cy, self.previousVertId)
    self.animation = nil
    _G.freeVertexFromTile(self.cx, self.cy, self.vertId)
    _G.removeObjectAt(self.cx, self.cy, self.i, self.o, self)
end

function Deer:update()
    if self.pathState == "Waiting for path" then
        self:pathfind()
    elseif self.pathState == "No path" then
        local targetX, targetY = self:followTheHerd()
            self:requestPath(targetX, targetY)
    elseif self.state == "Sitting" then
        if self.sitDownTimer > 0 then
            self.sitDownTimer = self.sitDownTimer - _G.dt
        elseif self.animation.status == "paused" then
            self:startStandingUp()
            self.sitDownTimer = 0
            self.state = "Standing up"
        end
    elseif self.state == "Idle" then
        local targetX, targetY = self:followTheHerd()
            self:clearPath()
            self:requestPath(targetX, targetY)
            self.state = "Following the herd"
    elseif self.state == "Following the herd" then
        if self.moveDir == "none" then
            self:updateDirection()
        end
        self:move()
    end
    if self:reachedWaypoint() then
        if self.state == "Following the herd" then
            if self:reachedPathEnd() then
                if self.migrating then
                    _G.HerdController.deerHerds:herdReachedLocation(self.herdIndex)
                    self.migrating = false
                end
                -- Randomly decide whether to eat or sit
                if math.random(1, 2) == 1 then
                    -- decided to sit
                    self:startSittingDown()
                    self:clearPath()
                else
                    -- decided to eat
                    self:startEating()
                    self:clearPath()
                end
                return
            else
                self:setNextWaypoint()
            end
            self.count = self.count + 1
        end
    end
end

function Deer:animate()
    self:update()
    Unit.animate(self)
end

function Deer:waitForHunter()
    if self.state ~= "Sitting" then
        self:startSittingDown()
    end

    self.marked = true
    self.sitDownTimer = 5
end

function Deer:kill()
    if self.state ~= "Dead" then
        local callback = function()
            self:dieCallback()
        end
        self.state = "Dead"

        _G.playSfx(self, deerFx["got_shot"])
        self.animation = anim.newAnimation(an[self.age][ANIM_DIE_ARROW], DEFAULT_ANIMATION_FRAMETIME, callback, ANIM_DIE_ARROW)
        self:clearPath()
    end
end

function Deer:dieCallback()
    self.animation:pauseAtEnd()
    _G.playSfx(self, deerFx["fall"])
end

function Deer:load(data)
    Object.deserialize(self, data)
    Unit.load(self, data)
    local anData = data.animation
    if anData then
        local anCallback = nil
        local frameTime = DEFAULT_ANIMATION_FRAMETIME
        if string.find(anData.animationIdentifier, "standing") then
            anCallback = function() self:standUpCallback() end
        elseif string.find(anData.animationIdentifier, "sitting") then
            anCallback = function() self:sitDownCallback() end
        elseif string.find(anData.animationIdentifier, "eating") then
            anCallback = function() self:eatingCallback() end
            frameTime = eatingDurations
        elseif string.find(anData.animationIdentifier, "die") then
            anCallback = function() self:dieCallback() end
        end
        self.animation = anim.newAnimation(an[self.age][anData.animationIdentifier], frameTime, anCallback, anData.animationIdentifier)
        self.animation:deserialize(anData)
    end
    if not self.toBeDeleted then
        _G.HerdController.deerHerds:registerDeer(self)
    end
end

function Deer:serialize()
    local data = {}
    local unitData = Unit.serialize(self)
    for k, v in pairs(unitData) do
        if type(v) ~= "function" and type(v) ~= "userdata" then
            data[k] = v
        end
    end
    if self.animation then
        data.animation = self.animation:serialize()
    end
    data.state = self.state
    data.waitTimer = self.waitTimer
    data.offsetY = self.offsetY
    data.offsetX = self.offsetX
    data.count = self.count
    data.age = self.age
    data.herdIndex = self.herdIndex
    data.previousHerdLocation = self.previousHerdLocation
    data.migrating = self.migrating
    data.sitDownTimer = self.sitDownTimer
    data.sittingDirection = self.sittingDirection
    data.marked = self.marked
    return data
end

return Deer
