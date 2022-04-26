local CyberTrashCan, super = Class(Event)

function CyberTrashCan:init(x, y, properties)
    super:init(self, x, y)

    properties = properties or {}

    self:setOrigin(0.5, 1)
    self:setScale(2)

    self.sprite = Sprite("world/event/cyber_trash")
    self:addChild(self.sprite)

    self:setSize(self.sprite:getSize())
    self:setHitbox(5, 23, 22, 15)

    self.item = properties["item"]
    self.money = properties["money"]

    self.solid = true
end

function CyberTrashCan:onAdd(parent)
    super:onAdd(self, parent)

    if self:getFlag("opened") then
        self.sprite:setFrame(2)
    end
end

function CyberTrashCan:onInteract(player, dir)
    if self:getFlag("opened") then
        self.world:showText({
            "* (You dug through the trash...)",
            "* (And found trash!)",
        })
    else
        Assets.playSound("snd_impact")
        self.sprite:setFrame(2)
        self:setFlag("opened", true)

        local name, success, result_text
        if self.item then
            local item = self.item
            if type(self.item) == "string" then
                item = Registry.createItem(self.item)
            end
            success, result_text = Game.inventory:tryGiveItem(item)
            name = item:getName()
        elseif self.money then
            name = self.money.." Dark Dollars"
            success = true
            result_text = "* ([color:yellow]"..name.."[color:reset] was added to your [color:yellow]MONEY HOLE[color:reset].)"
            Game.money = Game.money + self.money
        end

        if name then
            if self.item then
                self.world:showText({
                    "* (You dug through the trash...)",
                    "* (And found a "..name.."!)",
                    result_text,
                }, function()
                    if not success then
                        self:setFlag("opened", false)
                    end
                end)
            else
                self.world:showText({
                    "* (You dug through the trash...)",
                    "* (And found $"..self.money.."!)",
                    result_text,
                })
            end
        else
            self.world:showText({
                "* (You dug through the trash...)",
                "* (And found trash!)",
            })
        end
    end
end

return CyberTrashCan