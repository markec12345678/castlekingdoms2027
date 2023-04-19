local console = require("libraries.console")

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
        ["HopsFarmer"] = {},
        ["DairyFarmer"] = {},
        ["Miller"] = {},
        ["Baker"] = {},
        ["Fletcher"] = {},
        ["Poleturner"] = {},
        ["Armourer"] = {},
        ["Blacksmith"] = {},
        ["Brewer"] = {},
        ["OxHandler"] = {}
    }
    self.unlimitedWorkers = false
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

function JobController:toggleUnlimitedWorkers()
    self.unlimitedWorkers = not self.unlimitedWorkers
    if self.unlimitedWorkers then
        print("No longer waiting for peasants to fill worker pool.")
    else
        print("Peasants now work almost normally. Bugs are to be expected.")
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
                if not self.unlimitedWorkers then
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
                end
                self.workers = self.workers - 1
                local workerClass = _G.getClassByName(job)
                local worker = workerClass:new(_G.spawnPointX, _G.spawnPointY, job)

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

local instance = JobController:new()
console.addCommand("unlimitedWorkers", function() instance:toggleUnlimitedWorkers() end, "Directly spawn workers without waiting for peasants.")
return instance
