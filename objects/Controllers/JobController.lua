local Woodcutter = require("objects.Units.Woodcutter")
local Stonemason = require("objects.Units.Stonemason")
local OrchardFarmer = require("objects.Units.OrchardFarmer")
local WheatFarmer = require("objects.Units.WheatFarmer")
local Miner = require("objects.Units.Miner")
local Miller = require("objects.Units.Miller")
local Baker = require("objects.Units.Baker")

local JobController = _G.class('JobController')
function JobController:initialize()
    self.list = {
        ["Stonemason"] = {},
        ["Woodcutter"] = {},
        ["Miner"] = {},
        ["OrchardFarmer"] = {},
        ["WheatFarmer"] = {},
        ["Miller"] = {},
        ["Baker"] = {}
    }
    self.workers = 0
    self.requested_workers = 0
end
function JobController:add(job, workplace)
    table.insert(self.list[job], workplace)
end
function JobController:add_available_worker()
    self.workers = self.workers + 1
    self.requested_workers = self.requested_workers - 1
end
function JobController:make_worker()
    for job, workplaces in pairs(self.list) do
        for _, workplace in pairs(workplaces) do
            if workplace.free_spots > 0 then
                if self.workers == 0 then
                    if self.requested_workers == 0 then
                        local peasant = _G.campfire:get_free_peasant()
                        if peasant then
                            peasant:get_a_job()
                            self.requested_workers = self.requested_workers + 1
                        end
                    end
                    return
                end
                self.workers = self.workers - 1
                local worker
                if job == "Stonemason" then
                    worker = Stonemason:new(_G.spawn_point_x, _G.spawn_point_y, "Stonemason")
                elseif job == "Miner" then
                    worker = Miner:new(_G.spawn_point_x, _G.spawn_point_y, "Miner")
                elseif job == "OrchardFarmer" then
                    worker = OrchardFarmer:new(_G.spawn_point_x, _G.spawn_point_y, "OrchardFarmer")
                elseif job == "WheatFarmer" then
                    worker = WheatFarmer:new(_G.spawn_point_x, _G.spawn_point_y, "WheatFarmer")
                elseif job == "Woodcutter" then
                    worker = Woodcutter:new(_G.spawn_point_x, _G.spawn_point_y, "Woodcutter")
                elseif job == "Miller" then
                    worker = Miller:new(_G.spawn_point_x, _G.spawn_point_y, "Miller")
                elseif job == "Baker" then
                    worker = Baker:new(_G.spawn_point_x, _G.spawn_point_y, "Baker")
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
    self.list = {
        ["Stonemason"] = {},
        ["Woodcutter"] = {},
        ["Miner"] = {},
        ["OrchardFarmer"] = {},
        ["WheatFarmer"] = {},
        ["Miller"] = {},
        ["Baker"] = {}
    }
    local ls = {}
    for k, v in pairs(self.list) do
        ls[k] = {}
        for idx, sv in ipairs(v) do
            ls[k][idx] = _G.state:serializeObject(sv)
        end
    end
    data.rawlist = ls
    data.workers = self.workers
    data.requested_workers = self.requested_workers
    return data
end
function JobController:deserialize(data)
    self.workers = data.workers
    self.requested_workers = data.requested_workers
    for k, v in pairs(data.rawlist) do
        for idx, sv in ipairs(v) do
            self[k][idx] = _G.state:dereferenceObject(sv)
        end
    end
end
return JobController:new()
