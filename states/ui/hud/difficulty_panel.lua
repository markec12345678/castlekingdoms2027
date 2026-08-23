-- states/ui/hud/difficulty_panel.lua
-- Castle Kingdoms 2027 v3.12.133 - Difficulty Settings Panel
--
-- Modern UI panel for selecting game difficulty:
--   * 5 difficulty cards: Peaceful, Easy, Normal, Hard, Brutal
--   * Each card shows: icon, label (SL+EN), description, key modifiers
--   * Current difficulty highlighted with golden border
--   * Confirm button to apply
--   * Mid-game change shows warning toast
--
-- Toggle with Ctrl+Shift+F (F for "Force" / difficulty).

local PanelAnim = require("states.ui.hud.PanelAnimations")
local Difficulty = require("objects.Gameplay.DifficultySettings")
local UISound = require("objects.Audio.UISoundHelper")

local DifficultyPanel = {}

local visible = false
local selectedDifficulty = nil  -- preview selection (before apply)
local cardPositions = {}  -- populated during draw for click detection

local animState = PanelAnim.createState({
    duration = 0.22,
    slideDir = "down",
    slideDist = 24,
    easing = "easeOut",
})

function DifficultyPanel.toggle()
    if not visible then
        visible = true
        PanelAnim.open(animState)
        UISound.playPanelOpen()
        -- Initialize selected to current
        selectedDifficulty = Difficulty.getCurrent()
    else
        PanelAnim.close(animState)
        UISound.playPanelClose()
    end
end

function DifficultyPanel.setVisible(state)
    if state and not visible then
        visible = true
        PanelAnim.open(animState)
        selectedDifficulty = Difficulty.getCurrent()
    elseif not state and visible then
        PanelAnim.close(animState)
    end
end

function DifficultyPanel.isVisible()
    return visible or PanelAnim.isAnimating(animState)
end

function DifficultyPanel.update(dt)
    if not visible and not PanelAnim.isAnimating(animState) then return end
    PanelAnim.update(animState, dt)
    if animState.phase == "closed" then
        visible = false
    end
end

function DifficultyPanel.draw()
    if not visible and not PanelAnim.isAnimating(animState) then return end

    local alpha = PanelAnim.getProgress(animState)
    local offsetX, offsetY = PanelAnim.getOffset(animState)

    local screenW, screenH = love.graphics.getDimensions()
    local panelW = math.min(960, screenW - 60)
    local panelH = math.min(640, screenH - 60)
    local panelX = (screenW - panelW) / 2
    local panelY = (screenH - panelH) / 2

    local font = love.graphics.getFont()
    local titleFont = love.graphics.newFont(16)
    local smallFont = love.graphics.newFont(11)

    -- Dim background
    love.graphics.setColor(0, 0, 0, 0.65 * alpha)
    love.graphics.rectangle("fill", 0, 0, screenW, screenH)

    love.graphics.push("all")
    love.graphics.translate(offsetX, offsetY)

    -- Panel background
    love.graphics.setColor(0.08, 0.07, 0.1, 0.98 * alpha)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setColor(0.6, 0.7, 0.85, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8, 8, 8)
    love.graphics.setLineWidth(1)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0.85, 0.75, 0.5, alpha)
    love.graphics.print("⚔ TEŽAVNOST — Castle Kingdoms 2027", panelX + 16, panelY + 12)

    -- Hint line
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.55, 0.6, 0.65, alpha)
    love.graphics.print("Ctrl+Shift+F: zapri  |  Klik na kartico za izbiro  |  ENTER: potrdi  |  ESC: prekliči",
        panelX + 16, panelY + 36)

    -- Current difficulty display
    local currentDiff = Difficulty.getCurrentInfo()
    love.graphics.setFont(font)
    love.graphics.setColor(currentDiff.color[1], currentDiff.color[2], currentDiff.color[3], alpha)
    love.graphics.print("Trenutna: " .. currentDiff.icon .. " " .. currentDiff.label .. " (" .. currentDiff.labelEn .. ")",
        panelX + 16, panelY + 56)

    -- 5 difficulty cards (horizontal row)
    local cardW = 170
    local cardH = 380
    local cardGap = 12
    local totalCardsW = 5 * cardW + 4 * cardGap
    local cardsStartX = panelX + (panelW - totalCardsW) / 2
    local cardsY = panelY + 90

    cardPositions = {}

    local allDiffs = Difficulty.getAll()
    for i, diff in ipairs(allDiffs) do
        local cx = cardsStartX + (i - 1) * (cardW + cardGap)
        local cy = cardsY
        local isSelected = selectedDifficulty == diff.key
        local isCurrent = diff.isCurrent

        -- Card background
        if isSelected then
            love.graphics.setColor(diff.color[1] * 0.3, diff.color[2] * 0.3, diff.color[3] * 0.3, alpha * 0.95)
        else
            love.graphics.setColor(0.12, 0.13, 0.16, alpha * 0.8)
        end
        love.graphics.rectangle("fill", cx, cy, cardW, cardH, 6, 6, 6, 6)

        -- Card border
        if isSelected then
            love.graphics.setColor(diff.color[1], diff.color[2], diff.color[3], alpha)
            love.graphics.setLineWidth(3)
        elseif isCurrent then
            love.graphics.setColor(0.95, 0.85, 0.3, alpha)
            love.graphics.setLineWidth(2)
        else
            love.graphics.setColor(0.4, 0.45, 0.55, alpha * 0.7)
            love.graphics.setLineWidth(1)
        end
        love.graphics.rectangle("line", cx, cy, cardW, cardH, 6, 6, 6, 6)
        love.graphics.setLineWidth(1)

        -- Top color bar
        love.graphics.setColor(diff.color[1], diff.color[2], diff.color[3], alpha)
        love.graphics.rectangle("fill", cx, cy, cardW, 6, 6, 6, 0, 0)

        -- Icon (large)
        love.graphics.setFont(titleFont)
        love.graphics.setColor(diff.color[1], diff.color[2], diff.color[3], alpha)
        love.graphics.print(diff.icon, cx + 12, cy + 18)

        -- Label SL
        love.graphics.setColor(0.95, 0.92, 0.85, alpha)
        love.graphics.print(diff.label, cx + 50, cy + 20)

        -- Label EN
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 0.65, 0.7, alpha)
        love.graphics.print(diff.labelEn, cx + 50, cy + 40)

        -- "Trenutna" badge
        if isCurrent then
            love.graphics.setFont(smallFont)
            love.graphics.setColor(0.95, 0.85, 0.3, alpha)
            love.graphics.print("★ TRENUTNA", cx + 12, cy + 60)
        end

        -- "Izbrana" badge
        if isSelected and not isCurrent then
            love.graphics.setFont(smallFont)
            love.graphics.setColor(diff.color[1], diff.color[2], diff.color[3], alpha)
            love.graphics.print("› IZBRANA", cx + 12, cy + 60)
        end

        -- Description (SL)
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.85, 0.88, 0.92, alpha)
        -- Wrap description
        local descY = cy + 84
        local words = {}
        for w in diff.description:gmatch("%S+") do words[#words + 1] = w end
        local line = ""
        local maxW = cardW - 24
        for _, w in ipairs(words) do
            local test = line == "" and w or (line .. " " .. w)
            if smallFont:getWidth(test) > maxW then
                if line ~= "" then
                    love.graphics.print(line, cx + 12, descY)
                    descY = descY + 14
                end
                line = w
            else
                line = test
            end
        end
        if line ~= "" then
            love.graphics.print(line, cx + 12, descY)
        end

        -- Modifiers list
        local modY = cy + 160
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.7, 0.75, 0.8, alpha)
        love.graphics.print("MODIFIKATORJI:", cx + 12, modY)
        modY = modY + 16

        local modifiers = {
            { key = "playerGoldMultiplier", label = "Zlato", suffix = "x" },
            { key = "playerProductionMultiplier", label = "Proizvodnja", suffix = "x" },
            { key = "playerBuildCostMultiplier", label = "Stroški gradnje", suffix = "x" },
            { key = "playerDamageMultiplier", label = "Poškodba (igralec)", suffix = "x" },
            { key = "playerHealthMultiplier", label = "Zdravje (igralec)", suffix = "x" },
            { key = "enemyDamageMultiplier", label = "Poškodba (AI)", suffix = "x" },
            { key = "enemyHealthMultiplier", label = "Zdravje (AI)", suffix = "x" },
            { key = "enemyAggressionMultiplier", label = "AI agresivnost", suffix = "x" },
            { key = "resourceDepletionMultiplier", label = "Poraba virov", suffix = "x" },
        }
        for _, m in ipairs(modifiers) do
            local val = diff.modifiers[m.key] or 1.0
            -- Color: green for player bonuses, red for penalties
            local valColor
            if m.key:find("^player") then
                if val > 1.0 then valColor = {0.3, 0.85, 0.4, alpha}
                elseif val < 1.0 then valColor = {0.85, 0.4, 0.3, alpha}
                else valColor = {0.7, 0.7, 0.7, alpha} end
            elseif m.key:find("^enemy") then
                if val > 1.0 then valColor = {0.85, 0.4, 0.3, alpha}
                elseif val < 1.0 then valColor = {0.3, 0.85, 0.4, alpha}
                else valColor = {0.7, 0.7, 0.7, alpha} end
            else
                if val > 1.0 then valColor = {0.85, 0.6, 0.3, alpha}
                elseif val < 1.0 then valColor = {0.3, 0.7, 0.85, alpha}
                else valColor = {0.7, 0.7, 0.7, alpha} end
            end
            love.graphics.setColor(0.65, 0.7, 0.75, alpha)
            love.graphics.print(m.label, cx + 12, modY)
            love.graphics.setColor(valColor[1], valColor[2], valColor[3], valColor[4])
            love.graphics.print(string.format("%.2f%s", val, m.suffix), cx + cardW - 50, modY)
            modY = modY + 14
        end

        -- Record card position for click handling
        cardPositions[#cardPositions + 1] = {
            key = diff.key,
            x = cx, y = cy, w = cardW, h = cardH,
        }
    end

    -- Apply button (only if selection differs from current)
    if selectedDifficulty and selectedDifficulty ~= Difficulty.getCurrent() then
        local btnW = 200
        local btnH = 36
        local btnX = panelX + (panelW - btnW) / 2
        local btnY = panelY + panelH - 56
        love.graphics.setColor(0.2, 0.5, 0.3, alpha)
        love.graphics.rectangle("fill", btnX, btnY, btnW, btnH, 4, 4, 4, 4)
        love.graphics.setColor(0.4, 0.9, 0.5, alpha)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", btnX, btnY, btnW, btnH, 4, 4, 4, 4)
        love.graphics.setLineWidth(1)
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print("✓ POTRDI (ENTER)", btnX + 36, btnY + 10)
    end

    -- Footer hint
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.5, 0.55, 0.6, alpha)
    love.graphics.print("5 težavnosti · Persistenca v difficulty_setting.txt · Sprememba sredi igre je možna",
        panelX + 16, panelY + panelH - 22)

    love.graphics.setFont(font)
    love.graphics.pop()
    love.graphics.setColor(1, 1, 1, 1)
end

function DifficultyPanel.keypressed(key, scancode, isrepeat)
    if not visible and not PanelAnim.isAnimating(animState) then return false end

    if key == "escape" then
        DifficultyPanel.toggle()
        return true
    end
    if key == "return" then
        -- Apply selected difficulty
        if selectedDifficulty and selectedDifficulty ~= Difficulty.getCurrent() then
            Difficulty.set(selectedDifficulty)
            UISound.playSuccess()
            DifficultyPanel.toggle()
        end
        return true
    end
    -- Number keys 1-5 to select
    if key >= "1" and key <= "5" then
        local idx = tonumber(key)
        local all = Difficulty.getAll()
        if all[idx] then
            if selectedDifficulty ~= all[idx].key then
                selectedDifficulty = all[idx].key
                UISound.playClick()
            end
            return true
        end
    end
    -- Arrow keys to navigate
    if key == "left" then
        local all = Difficulty.getAll()
        for i, d in ipairs(all) do
            if d.key == selectedDifficulty and i > 1 then
                selectedDifficulty = all[i - 1].key
                UISound.playClick()
                return true
            end
        end
        return true
    end
    if key == "right" then
        local all = Difficulty.getAll()
        for i, d in ipairs(all) do
            if d.key == selectedDifficulty and i < #all then
                selectedDifficulty = all[i + 1].key
                UISound.playClick()
                return true
            end
        end
        return true
    end
    return false
end

function DifficultyPanel.mousepressed(x, y, button)
    if not visible and not PanelAnim.isAnimating(animState) then return false end
    if button ~= 1 then return false end

    local screenW = love.graphics.getWidth()
    local panelW = math.min(960, screenW - 60)
    local panelX = (screenW - panelW) / 2
    local screenH = love.graphics.getHeight()
    local panelH = math.min(640, screenH - 60)
    local panelY = (screenH - panelH) / 2

    -- Click on a card
    for _, pos in ipairs(cardPositions) do
        if x >= pos.x and x <= pos.x + pos.w and y >= pos.y and y <= pos.y + pos.h then
            if selectedDifficulty ~= pos.key then
                selectedDifficulty = pos.key
                UISound.playClick()
            end
            return true
        end
    end

    -- Apply button click
    if selectedDifficulty and selectedDifficulty ~= Difficulty.getCurrent() then
        local btnW = 200
        local btnH = 36
        local btnX = panelX + (panelW - btnW) / 2
        local btnY = panelY + panelH - 56
        if x >= btnX and x <= btnX + btnW and y >= btnY and y <= btnY + btnH then
            Difficulty.set(selectedDifficulty)
            UISound.playSuccess()
            DifficultyPanel.toggle()
            return true
        end
    end

    -- Click outside panel closes
    if x < panelX or x > panelX + panelW or y < panelY or y > panelY + panelH then
        DifficultyPanel.toggle()
        return true
    end
    return false
end

function DifficultyPanel.mousemoved(x, y, dx, dy)
    return false
end

function DifficultyPanel.wheelmoved(x, y)
    return false
end

function DifficultyPanel.textinput(text)
    return false
end

function DifficultyPanel.mousereleased(x, y, button)
    return false
end

return DifficultyPanel
