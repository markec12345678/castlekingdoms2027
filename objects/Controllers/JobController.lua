
local JobController = class('JobController')
			function JobController:initialize()
                self.list = {
                    ["Stonemason"] = {},
                    ["Woodcutter"] = {},
                    ["Miner"] = {},
                    ["Farmer"] = {},
                }
			end
			function JobController:add(job, workplace)
                self.list[job][#self.list[job]] = workplace
                --print(inspect(self.list["Stonemason"]),{depth = 1})
			end
            function JobController:find_job(worker,job)
                for _, workplace in pairs(self.list[job]) do
                    if workplace.free_spots > 0 then   
                        workplace:join(worker)
                        worker.state = "Go to workplace"
                    end
                end       
            end
return JobController