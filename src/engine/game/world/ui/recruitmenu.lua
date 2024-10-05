---@class RecruitMenu : Object
---@overload fun(...) : RecruitMenu
local RecruitMenu, super = Class(Object)

function RecruitMenu:init()
    super.init(self, 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    self:setParallax(0, 0)

    self.draw_children_below = 0

    self.font = Assets.getFont("main")
    self.description_font = Assets.getFont("plain")

    self.heart = Sprite("player/heart", 58, 114)
    self.heart:setOrigin(0.5, 0.5)
    self.heart:setColor(Game:getSoulColor())
    self.heart.layer = 100
    self:addChild(self.heart)
    
    self.arrow_left = Assets.getTexture("ui/flat_arrow_left")
    self.arrow_right = Assets.getTexture("ui/flat_arrow_right")
    
    self.recruits = Game:getRecruits(true)
    
    self.state = "SELECT"
    
    self.selected = 1
    self.selected_page = 1
    self.old_selection = self.selected
    
    self.recruit_box = Sprite("ui/menu/recruit/gradient_bright", 370, 75)
    Game.stage:addChild(self.recruit_box)
    
    self:setRecruitInBox(self.selected)
end

function RecruitMenu:setRecruitInBox(selected)
    if self.recruit_sprite then
        self.recruit_sprite:remove()
    end
    local recruit = self.recruits[selected]
    self.recruit_box:setSprite("ui/menu/recruit/gradient_" .. recruit:getBoxGradientType())
    self.recruit_box:setColor(recruit:getBoxGradientColor())
    self.recruit_sprite = Sprite(recruit:getBoxSprite()[1], self.recruit_box.width / 2 + recruit:getBoxSprite()[2], self.recruit_box.height / 2 + recruit:getBoxSprite()[3])
    self.recruit_sprite:setScale(2)
    self.recruit_sprite:setOrigin(0.5, 0.5)
    self.recruit_sprite:play(recruit:getBoxSprite()[4])
    self.recruit_box:addChild(self.recruit_sprite)
end

function RecruitMenu:getMaxPages()
    return math.ceil(#self.recruits / 9)
end

function RecruitMenu:getFirstSelectedInPage()
    return 1 + (self.selected_page - 1) * 9
end

function RecruitMenu:getLastSelectedInPage()
    return math.min(#self.recruits, 9 * self.selected_page)
end

function RecruitMenu:update()
    self.old_selection = self.selected
    if Input.pressed("left", true) and self.state == "INFO" then
        self.selected = self.selected - 1
        if self.selected < 1 then
            self.selected = #self.recruits
        end
    end
    if Input.pressed("right", true) and self.state == "INFO" then
        self.selected = self.selected + 1
        if self.selected > #self.recruits then
            self.selected = 1
        end
    end
    
    if Input.pressed("up", true) and self.state == "SELECT" then
        self.selected = self.selected - 1
        if self.selected < self:getFirstSelectedInPage() then
            self.selected = self:getLastSelectedInPage()
        end
    end
    if Input.pressed("down", true) and self.state == "SELECT" then
        self.selected = self.selected + 1
        if self.selected > self:getLastSelectedInPage() then
            self.selected = self:getFirstSelectedInPage()
        end
    end
    
    if self:getMaxPages() > 1 then
        if Input.pressed("left", true) and self.state == "SELECT" then
            self.selected_page = self.selected_page - 1
            self.selected = self.selected - 9
            if self.selected_page < 1 then
                self.selected_page = self:getMaxPages()
                self.selected = self.selected + self:getMaxPages() * 9
            end
            if self.selected > self:getLastSelectedInPage() then
                self.selected = self:getLastSelectedInPage()
            end
        end
        if Input.pressed("right", true) and self.state == "SELECT" then
            self.selected_page = self.selected_page + 1
            self.selected = self.selected + 9
            if self.selected_page > self:getMaxPages() then
                self.selected_page = 1
                self.selected = self.selected - self:getMaxPages() * 9
            end
            if self.selected > self:getLastSelectedInPage() then
                self.selected = self:getLastSelectedInPage()
            end
        end
    end
    
    if self.old_selection ~= self.selected then
        self:setRecruitInBox(self.selected)
    end
    
    if Input.pressed("confirm", false) then
        if self.state == "SELECT" then
            self.state = "INFO"
            self.recruit_box:setPosition(80, 70)
        end
    end
    if Input.pressed("cancel", false) then
        if self.state == "SELECT" then
            self.recruit_box:remove()
            self:remove()
            Game.world:closeMenu()
        else
            self.state = "SELECT"
            self.selected_page = math.ceil(self.selected / 9)
            self.recruit_box:setPosition(370, 75)
        end
    end
    
    -- Update the heart target position
    if self.state == "SELECT" then
        self.heart_target_x = 58
        self.heart_target_y = 114 + (self.selected - (self.selected_page - 1) * 9 - 1) * 35
    else
        self.heart_target_x = 58
        self.heart_target_y = 416
    end
    
    -- Move the heart closer to the target
    if (math.abs((self.heart_target_x - self.heart.x)) <= 2) then
        self.heart.x = self.heart_target_x
    end
    if (math.abs((self.heart_target_y - self.heart.y)) <= 2) then
        self.heart.y = self.heart_target_y
    end
    self.heart.x = self.heart.x + ((self.heart_target_x - self.heart.x) / 2) * DTMULT
    self.heart.y = self.heart.y + ((self.heart_target_y - self.heart.y) / 2) * DTMULT
end

function RecruitMenu:draw()
    love.graphics.setFont(self.font)
    
    if self.state == "SELECT" then
        love.graphics.setLineWidth(4)
        Draw.setColor(PALETTE["world_border"])
        love.graphics.rectangle("line", 32, 12, 587, 427)
        Draw.setColor(PALETTE["world_fill"])
        love.graphics.rectangle("fill", 34, 14, 583, 423)
    
        Draw.setColor(COLORS["white"])
        Draw.print("Recruits", 80, 30)
        Draw.setColor({0,1,0})
        Draw.print("PROGRESS", 270, 30, {scale_x = 0.5, scale_y = 1})
        
        local offset = 0
        for i,recruit in pairs(self.recruits) do
            if i <= self:getLastSelectedInPage() and i >= self:getFirstSelectedInPage() then
                Draw.setColor(COLORS["white"])
                if i == self.selected then
                    Draw.printAlign(recruit:getName(), 473, 240, "center")
                    Draw.print("CHAPTER " .. recruit:getChapter(), 368, 280)
                    Draw.printAlign("LV " .. recruit:getLevel(), 576, 280, "right")
                    if Input.usingGamepad() then
                        Draw.print("More Info", 414, 320)
                        Draw.draw(Input.getTexture("confirm"), 380, 323, 0, 2, 2)
                        Draw.print("Quit", 414, 352)
                        Draw.draw(Input.getTexture("cancel"), 380, 353, 0, 2, 2)
                    else
                        Draw.print(Input.getText("confirm") .. ": More Info", 380, 320)
                        Draw.print(Input.getText("cancel") .. ": Quit", 380, 352)
                    end
                    Draw.setColor(COLORS["yellow"])
                end
                local name = recruit:getName()
                Draw.print(name, 80, 100 + offset, {scale_x = math.min(1, 12 / #name), scale_y = 1})
                if Game:hasRecruit(recruit.id) then
                    Draw.setColor({0,1,0})
                    Draw.print("Recruited!", 275, 100 + offset, {scale_x = 0.5, scale_y = 1})
                else
                    Draw.setColor(PALETTE["world_light_gray"])
                    local recruit_progress = recruit:getRecruited() .. " / " .. recruit:getRecruitAmount()
                    Draw.print(recruit_progress, 280, 100 + offset, {scale_x = math.min(1, 5 / #recruit_progress), scale_y = 1})
                end
                offset = offset + 35
            end
        end
        
        if self:getMaxPages() > 1 then
            Draw.setColor(1, 1, 1, 1)
            local offset = Utils.round(math.sin(Kristal.getTime() * 5)) * 2
            Draw.draw(self.arrow_left, 22 - offset, 213, 0, 2, 2)
            Draw.draw(self.arrow_right, 612 + offset, 213, 0, 2, 2)
        end
    elseif self.state == "INFO" then
        love.graphics.setLineWidth(4)
        Draw.setColor(PALETTE["world_border"])
        love.graphics.rectangle("line", 32, 12, 577, 437)
        Draw.setColor(PALETTE["world_fill"])
        love.graphics.rectangle("fill", 34, 14, 573, 433)

        Draw.setColor(COLORS["white"])
        for i,recruit in pairs(self.recruits) do
            Draw.printAlign(self.selected .. "/" .. #self.recruits, 590, 30, "right", 0, 0.5, 1)
            if i == self.selected then
                Draw.print("CHAPTER " .. recruit:getChapter(), 300, 30, {scale_x = 0.5, scale_y = 1})
                Draw.print(recruit:getName(), 300, 70)
                love.graphics.setFont(self.description_font)
                Draw.printAlign(Game:hasRecruit(recruit.id) and recruit:getDescription() or "Not yet fully recruited", 301, 120, {["align"] = "left", ["line_offset"] = 4})
                love.graphics.setFont(self.font)

                Draw.print("LIKE", 80, 240)
                local like = recruit:getLike()
                Draw.print(Game:hasRecruit(recruit.id) and like or "?", 180, 240, {scale_x = math.min(1, 21 / #like), scale_y = 1})

                Draw.print("DISLIKE", 80, 280, {scale_x = 0.81, scale_y = 1})
                local dislike = recruit:getDislike()
                Draw.print(Game:hasRecruit(recruit.id) and dislike or "?", 180, 280, {scale_x = math.min(1, 21 / #dislike), scale_y = 1})

                Draw.print("?????", 80, 320, {scale_x = 1.15, scale_y = 1})
                Draw.print("?????????", 180, 320)
                Draw.print("?????", 80, 360, {scale_x = 1.15, scale_y = 1})
                Draw.print("?????????", 180, 360)
                if Input.usingGamepad() then
                    Draw.print("Press         to Return", 80, 400)
                    Draw.draw(Input.getTexture("cancel"), 165, 402, 0, 2, 2)
                else
                    Draw.print("Press " .. Input.getText("cancel") .. " to Return", 80, 400)
                end
                Draw.print("LEVEL", 525, 240, {scale_x = 0.5, scale_y = 1})
                Draw.printAlign(recruit:getLevel(), 590, 240, "right", 0, 0.5, 1)
                Draw.print("ATTACK", 518, 280, {scale_x = 0.5, scale_y = 1})
                Draw.printAlign(recruit:getAttack(), 590, 280, "right", 0, 0.5, 1)
                Draw.print("DEFENSE", 511, 320, {scale_x = 0.5, scale_y = 1})
                Draw.printAlign(recruit:getDefense(), 590, 320, "right", 0, 0.5, 1)
                Draw.printAlign("ELEMENT " .. recruit:getElement(), 590, 360, "right", 0, 0.5, 1)
            end

            Draw.setColor(1, 1, 1, 1)
            local offset = Utils.round(math.sin(Kristal.getTime() * 5)) * 2
            Draw.draw(self.arrow_left, 22 - offset, 218, 0, 2, 2)
            Draw.draw(self.arrow_right, 602 + offset, 218, 0, 2, 2)
        end
    else
        error("Unknown Recruit Menu State.")
    end

    love.graphics.setLineWidth(1)
    Draw.setColor(PALETTE["world_border"])
    love.graphics.rectangle("line", self.recruit_box.x, self.recruit_box.y, self.recruit_box.width + 1, self.recruit_box.height + 1)

    super.draw(self)
end

return RecruitMenu