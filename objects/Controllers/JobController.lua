local Woodcutter = require("objects.Units.Woodcutter")
local Stonemason = require("objects.Units.Stonemason")
local Farmer = require("objects.Units.Farmer")
local Miner = require("objects.Units.Miner")

local JobController = class('JobController')
function JobController:initialize()
    self.list = {
        ["Stonemason"] = {},
        ["Woodcutter"] = {},
        ["Miner"] = {},
        ["Farmer"] = {}
    }
    self.workers = 0
    self.requested_workers = 0
end
function JobController:add(job, workplace)
    table.insert(self.list[job], workplace)
end
function JobController:find_job(worker, job)
    -- for _, workplace in pairs(self.list[job]) do
    --     if workplace.free_spots > 0 then   
    --         workplace:join(worker)
    --         worker.state = "Go to workplace"
    --         break
    --     end
    -- end       
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
                elseif job == "Farmer" then
                    worker = Farmer:new(_G.spawn_point_x, _G.spawn_point_y, "Farmer")
                end
                workplace:join(worker)
                worker.state = "Go to workplace"
                break
            end
        end
    end
end
return JobController:new()
