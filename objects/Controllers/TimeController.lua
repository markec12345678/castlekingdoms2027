local TimeController = _G.class("TimeController")
local actionBar = require("states.ui.ActionBar")
local SID = require("objects.Controllers.LanguageController").lines
TimeController.static.TIME_MONTHS = {
    SID.months.jan,
    SID.months.feb,
    SID.months.mar,
    SID.months.apr,
    SID.months.may,
    SID.months.jun,
    SID.months.jul,
    SID.months.aug,
    SID.months.sep,
    SID.months.oct,
    SID.months.nov,
    SID.months.dec,
}
TimeController.static.TIME_INTERVAL = 30
function TimeController:initialize()
    self.timer = 0
    self.currentMonth = self.class.TIME_MONTHS[1]
    self.month = 1
    self.year = 1000
end

function TimeController:serialize()
    local data = {}

    data.timer = self.timer
    data.currentMonth = self.currentMonth
    data.month = self.month
    data.year = self.year

    return data
end

function TimeController:deserialize(data)
    for k, v in pairs(data) do
        self[k] = v
    end
end

function TimeController:setMonth(month)
    self.month = month
end

function TimeController:setCurrentMonth(month)
    self.currentMonth = self.class.TIME_MONTHS[month]
end

function TimeController:setCurrentYear(year)
    self.year = year
end

function TimeController:getCurrentMonth()
    return self.currentMonth
end

function TimeController:getCurrentYear()
    return self.year
end

function TimeController:setCurrentDate(month, year)
    self:setCurrentMonth(month)
    self:setCurrentYear(year)
    return self.year
end

function TimeController:update()
    self.timer = self.timer + _G.dt
    if self.timer >= self.class.TIME_INTERVAL then
        self:setMonth(self.month + 1)
        self:setCurrentMonth(self.month)
        if self.month == 13 then
            self:setCurrentMonth(1)
            self:setMonth(1)
            self:setCurrentYear(self.year + 1)
        end

        -- Dispatch in-game time changed event
        local Events = require "objects.Enums.Events"
        _G.bus.emit(Events.OnInGameTimeChanged, self.year, self.month)

        -- Reset timer
        self.timer = 0
    end
end

return TimeController:new()
