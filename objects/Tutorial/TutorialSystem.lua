-- objects/Tutorial/TutorialSystem.lua
-- Castle Kingdoms 2027 - Tutorial System
-- Interactive guided tutorial for new players (10 steps in Slovenian)

local Tutorial = {}

local initialized = false
local isActive = false
local currentStep = 0
local stepCompleted = false
local waitTimer = 0
local hasBeenShown = false

local STEPS = {
    {
        id = "welcome",
        title = "Dobrodošli v Castle Kingdoms 2027!",
        text = "Ta vadba vam bo pokazala osnove igre. Pritisnite PRESLEDEK za nadaljevanje.",
        waitForAction = false,
    },
    {
        id = "place_keep",
        title = "Postavite svoj grad",
        text = "Kliknite na gumb za grad v spodnji vrstici, nato kliknite na teren za postavitev.",
        waitForAction = "build_keep",
    },
    {
        id = "build_stockpile",
        title = "Zgradite skladišče",
        text = "Kliknite na kladivo za odprtje menija zgradb, nato izberite skladišče.",
        waitForAction = "build_stockpile",
    },
    {
        id = "build_woodcutter",
        title = "Zgradite drvarjevo kočo",
        text = "V meniju zgradb izberite drvarjevo kočo za pridobivanje lesa.",
        waitForAction = "build_woodcutter",
    },
    {
        id = "build_granary",
        title = "Zgradite kaščo",
        text = "Kliknite na jabolko za gradnjo kašče, kjer bo shranjena hrana.",
        waitForAction = "build_granary",
    },
    {
        id = "build_farm",
        title = "Zgradite kmetijo",
        text = "V meniju kmetij izberite pšenično kmetijo za pridelavo hrane.",
        waitForAction = "build_wheat_farm",
    },
    {
        id = "check_resources",
        title = "Preverite svoje surovine",
        text = "Poglejte zgornjo vrstico — vidite lahko količino zlata, lesa, kamna in hrane.",
        waitForAction = false,
    },
    {
        id = "build_barracks",
        title = "Zgradite barake",
        text = "Kliknite na grad, nato izberite barake za usposabljanje vojakov.",
        waitForAction = "build_barracks",
    },
    {
        id = "train_archer",
        title = "Usposobite lokostrelca",
        text = "Kliknite na barake, nato izberite lokostrelca za usposabljanje.",
        waitForAction = "train_archer",
    },
    {
        id = "complete",
        title = "Čestitke!",
        text = "Naučili ste se osnov Castle Kingdoms 2027. Zdaj lahko gradite svoje kraljestvo in se borite proti sovražnikom. Srečno!",
        waitForAction = false,
    },
}

Tutorial.STEPS = STEPS

function Tutorial.init()
    if initialized then return end
    initialized = true

    local file = love.filesystem.newFile("tutorial_completed.flag")
    if file:open("r") then
        hasBeenShown = true
        file:close()
    end

    -- Castle Kingdoms 2027 v2.4.0: Subscribe to GameEventBus for auto-completing steps
    local GameEventBus = _G.GameEventBus
    if GameEventBus then
        pcall(function()
            GameEventBus.on(GameEventBus.EVENTS.BUILDING_BUILT, function(data)
                if data and data.buildingType then
                    local btype = string.lower(data.buildingType)
                    if btype:match("keep") then Tutorial.completeStep("build_keep")
                    elseif btype:match("stockpile") then Tutorial.completeStep("build_stockpile")
                    elseif btype:match("woodcutter") then Tutorial.completeStep("build_woodcutter")
                    elseif btype:match("granary") then Tutorial.completeStep("build_granary")
                    elseif btype:match("wheat") or btype:match("farm") then Tutorial.completeStep("build_wheat_farm")
                    elseif btype:match("barracks") then Tutorial.completeStep("build_barracks")
                    end
                end
            end)
        end)
        print("[TutorialSystem] Subscribed to GameEventBus BUILDING_BUILT events")
    end

    print("[TutorialSystem] Initialized")
end

function Tutorial.start()
    if not initialized then Tutorial.init() end
    isActive = true
    currentStep = 0
    Tutorial.nextStep()
    print("[TutorialSystem] Started")
end

function Tutorial.stop()
    isActive = false
    currentStep = 0
    print("[TutorialSystem] Stopped")
end

function Tutorial.skip()
    Tutorial.stop()
    local file = love.filesystem.newFile("tutorial_completed.flag")
    if file:open("w") then
        file:write("completed")
        file:close()
    end
    hasBeenShown = true
    print("[TutorialSystem] Skipped and marked as completed")
end

function Tutorial.nextStep()
    currentStep = currentStep + 1

    if currentStep > #STEPS then
        Tutorial.stop()
        local file = love.filesystem.newFile("tutorial_completed.flag")
        if file:open("w") then
            file:write("completed")
            file:close()
        end
        hasBeenShown = true
        if _G.ModernUI then
            _G.ModernUI.notifySuccess("Vadba končana!")
        end
        return
    end

    local step = STEPS[currentStep]
    stepCompleted = false
    waitTimer = 0

    if _G.ModernUI then
        _G.ModernUI.notifyInfo(step.title)
    end

    print(string.format("[TutorialSystem] Step %d/%d: %s", currentStep, #STEPS, step.id))
end

function Tutorial.completeStep(actionType)
    if not isActive then return end
    local step = STEPS[currentStep]
    if not step then return end
    if step.waitForAction == actionType then
        stepCompleted = true
        Tutorial.nextStep()
    end
end

function Tutorial.update(dt)
    if not isActive then return end
    local step = STEPS[currentStep]
    if not step then return end
    if not step.waitForAction and not stepCompleted then
        waitTimer = waitTimer + dt
    end
end

function Tutorial.draw()
    if not isActive then return end

    local step = STEPS[currentStep]
    if not step then return end

    local w, h = love.graphics.getDimensions()
    local boxW = 600
    local boxH = 120
    local boxX = (w - boxW) / 2
    local boxY = h - 150 - boxH - 20

    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)

    love.graphics.setColor(0.8, 0.7, 0.3, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxW, boxH)

    love.graphics.setColor(1, 0.9, 0.5, 1)
    love.graphics.print(step.title, boxX + 20, boxY + 15)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(step.text, boxX + 20, boxY + 45, boxW - 40)

    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.print(string.format("Korak %d/%d", currentStep, #STEPS), boxX + boxW - 100, boxY + 10)

    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    if not step.waitForAction then
        love.graphics.print("Pritisnite PRESLEDEK za nadaljevanje", boxX + 20, boxY + boxH - 25)
    else
        love.graphics.print("Čakam na dejanje...", boxX + 20, boxY + boxH - 25)
    end
    love.graphics.print("ESC za preskok", boxX + boxW - 120, boxY + boxH - 25)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

function Tutorial.keypressed(key)
    if not isActive then return false end
    if key == "escape" then
        Tutorial.skip()
        return true
    elseif key == "space" then
        local step = STEPS[currentStep]
        if step and not step.waitForAction then
            Tutorial.nextStep()
            return true
        end
    end
    return false
end

function Tutorial.isActive()
    return isActive
end

function Tutorial.hasBeenShown()
    return hasBeenShown
end

function Tutorial.getCurrentStep()
    return STEPS[currentStep]
end

function Tutorial.getCurrentStepNumber()
    return currentStep
end

function Tutorial.getTotalSteps()
    return #STEPS
end

function Tutorial.reset()
    hasBeenShown = false
    love.filesystem.remove("tutorial_completed.flag")
    print("[TutorialSystem] Reset")
end

return Tutorial
