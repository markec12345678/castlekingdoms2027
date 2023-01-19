local Woodcutter = require("objects.Units.Woodcutter")
local Stonemason = require("objects.Units.Stonemason")
local OrchardFarmer = require("objects.Units.OrchardFarmer")
local WheatFarmer = require("objects.Units.WheatFarmer")
local Miner = require("objects.Units.Miner")
local Miller = require("objects.Units.Miller")
local Baker = require("objects.Units.Baker")
local Fletcher = require("objects.Units.Fletcher")
local Armourer = require("objects.Units.Armourer")
local Blacksmith = require("objects.Units.Blacksmith")
local Brewer = require("objects.Units.Brewer")
local OxHandler = require("objects.Units.OxHandler")

local JobController = _G.class("JobController")
function JobController:initialize()
    self:initializeWorkplaces()
    self.workers = 0
    self.requestedWorkers = 0
end
function JobController:initializeWorkplaces()
    self.list = {
        ["Stonemason"] = {},
        ["Woodcutter"] = {},
        ["Miner"] = {},
        ["OrchardFarmer"] = {},
        ["WheatFarmer"] = {},
        ["Miller"] = {},
        ["Baker"] = {},
        ["Fletcher"] = {},
        ["Armourer"] = {},
        ["Blacksmith"] = {},
        ["Brewer"] = {},
        ["OxHandler"] = {}
    }
end
function JobController:add(job, workplace)
    table.insert(self.list[job], workplace)
end
function JobController:remove(job, workplace)
    for i = 1, #self.list[job] do
        if self.list[job][i] == workplace then
            table.remove(self.list[job], i)
        end
    end
end
function JobController:addAvailableWorker()
    self.workers = self.workers + 1
    self.requestedWorkers = self.requestedWorkers - 1
end
function JobController:makeWorker()
    for job, workplaces in pairs(self.list) do
        for _, workplace in pairs(workplaces) do
            if workplace.freeSpots > 0 then
                if self.workers == 0 then
                    if self.requestedWorkers == 0 then
                        local peasant = _G.campfire:getFreePeasant()
                        if peasant then
                            peasant:getAJob()
                            self.requestedWorkers = self.requestedWorkers + 1
                        end
                    end
                    return
                end
                self.workers = self.workers - 1
                local worker
                if job == "Stonemason" then
                    worker = Stonemason:new(_G.spawnPointX, _G.spawnPointY, "Stonemason")
                elseif job == "Miner" then
                    worker = Miner:new(_G.spawnPointX, _G.spawnPointY, "Miner")
                elseif job == "OrchardFarmer" then
                    worker = OrchardFarmer:new(_G.spawnPointX, _G.spawnPointY, "OrchardFarmer")
                elseif job == "WheatFarmer" then
                    worker = WheatFarmer:new(_G.spawnPointX, _G.spawnPointY, "WheatFarmer")
                elseif job == "Woodcutter" then
                    worker = Woodcutter:new(_G.spawnPointX, _G.spawnPointY, "Woodcutter")
                elseif job == "Miller" then
                    worker = Miller:new(_G.spawnPointX, _G.spawnPointY, "Miller")
                elseif job == "Baker" then
                    worker = Baker:new(_G.spawnPointX, _G.spawnPointY, "Baker")
                elseif job == "Fletcher" then
                    worker = Fletcher:new(_G.spawnPointX, _G.spawnPointY, "Fletcher")
                elseif job == "Armourer" then
                    worker = Armourer:new(_G.spawnPointX, _G.spawnPointY, "Armourer")
                elseif job == "Blacksmith" then
                    worker = Blacksmith:new(_G.spawnPointX, _G.spawnPointY, "Blacksmith")
                elseif job == "Brewer" then
                    worker = Brewer:new(_G.spawnPointX, _G.spawnPointY, "Brewer")
                elseif job == "OxHandler" then
                    worker = OxHandler:new(_G.spawnPointX, _G.spawnPointY, "OxHandler")
                end
                workplace:join(worker)
                worker.state = "Go to workplace"
                break
            end
        end
    end
end
function JobController:serialize()
    local data = {}
    local ls = {}
    for k, v in pairs(self.list) do
        ls[k] = {}
        for idx, sv in ipairs(v) do
            ls[k][idx] = _G.state:serializeObject(sv)
        end
    end
    data.rawlist = ls
    data.workers = self.workers
    data.requestedWorkers = self.requestedWorkers
    return data
end
function JobController:deserialize(data)
    self:initializeWorkplaces()
    self.workers = data.workers
    self.requestedWorkers = data.requestedWorkers
    for k, v in pairs(data.rawlist) do
        for idx, sv in ipairs(v) do
            self.list[k][idx] = _G.state:dereferenceObject(sv)
        end
    end
end
return JobController:new()
