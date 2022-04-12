local item, super = Class(Item, "mane_ax")

function item:init()
    super:init(self)

    -- Display name
    self.name = "Mane Axe"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Item icon (for equipment)
    self.icon = "ui/menu/icon/axe"

    -- Battle description
    self.effect = ""
    -- Shop description
    self.shop = "Beginner\nax"
    -- Menu description
    self.description = "Beginner's ax forged from the\nmane of a dragon whelp."

    -- Shop buy price
    self.buy_price = 80
    -- Shop sell price (usually half of buy price)
    self.sell_price = 40

    -- Consumable target mode (party, enemy, noselect, or none/nil)
    self.target = nil
    -- Where this item can be used (world, battle, all, or none/nil)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        attack = 0,
    }
    -- Bonus name and icon (displayed in equip menu)
    self.bonus_name = nil
    self.bonus_icon = nil

    -- Equippable characters (default true for armors, false for weapons)
    self.can_equip = {
        susie = true,
    }

    -- Character reactions
    self.reactions = {
        susie = "I'm too GOOD for that.",
        ralsei = "Ummm... it's a bit big.",
        noelle = "It... smells nice...",
    }
end

return item