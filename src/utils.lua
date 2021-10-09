local utils = {}

function utils.copy(tbl, deep)
    local new_tbl = {}
    for k,v in pairs(tbl) do
        if type(v) == "table" and deep then
            new_tbl[k] = utils.copy(v, true)
        else
            new_tbl[k] = v
        end
    end
    return new_tbl
end

local function dumpKey(key)
    if type(key) == 'table' then
        return '('..tostring(key)..')'
    elseif type(key) == 'string' and not key:find("[^%a_%-]") then
        return key
    else
        return '['..utils.dump(key)..']'
    end
end

function utils.dump(o)
    if type(o) == 'table' then
        local s = '{'
        local cn = 1
        if #o ~= 0 then
            for _,v in ipairs(o) do
                if cn > 1 then s = s .. ', ' end
                s = s .. utils.dump(v)
                cn = cn + 1
            end
        else
            for k,v in pairs(o) do
                if cn > 1 then s = s .. ', ' end
                s = s .. dumpKey(k) .. ' = ' .. utils.dump(v)
                cn = cn + 1
            end
        end
        return s .. '}'
    elseif type(o) == 'string' then
        return '"' .. o .. '"'
    else
        return tostring(o)
    end
end

function utils.splitFast(str, sep)
    local t={} ; i=1
    for str in string.gmatch(str, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function utils.split(str, sep, remove_empty)
    local t = {}
    local i = 1
    local s = ""
    while i <= #str do
        if str:sub(i, i + (#sep - 1)) == sep then
            if not remove_empty or s ~= "" then
                table.insert(t, s)
            end
            s = ""
            i = i + (#sep - 1)
        else
            s = s .. str:sub(i, i)
        end
        i = i + 1
    end
    if not remove_empty or s ~= "" then
        table.insert(t, s)
    end
    return t
end

function utils.hook(target, func)
    return function(...)
        return func(target, ...)
    end
end

function utils.equal(a, b, deep)
    if type(a) ~= type(b) then
        return false
    elseif type(a) == "table" then
        for k,v in pairs(a) do
            if b[k] == nil then
                return false
            elseif deep and not utils.equal(v, b[k]) then
                return false
            elseif not deep and v ~= b[k] then
                return false
            end
        end
        for k,v in pairs(b) do
            if a[k] == nil then
                return false
            end
        end
    elseif a ~= b then
        return false
    end
    return true
end

function utils.getFilesRecursive(dir)
    local result = {}

    local paths = love.filesystem.getDirectoryItems(dir)
    for _,path in ipairs(paths) do
        local info = love.filesystem.getInfo(dir.."/"..path)
        if info then
            if info.type == "directory" then
                local inners = getFilesRecursive(dir.."/"..path)
                for _,inner in ipairs(inners) do
                    table.insert(result, path.."/"..inner)
                end
            else
                table.insert(result, path)
            end
        end
    end

    return result
end

function utils.getCombinedText(text)
    if type(text) == "table" then
        local s = ""
        for _,v in ipairs(text) do
            if type(v) == "string" then
                s = s .. v
            end
        end
        return s
    else
        return tostring(text)
    end
end


-- https://github.com/Wavalab/rgb-hsl-rgb
function utils.hslToRgb(h, s, l)
    if s == 0 then return l, l, l end
    local function to(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < .16667 then return p + (q - p) * 6 * t end
        if t < .5 then return q end
        if t < .66667 then return p + (q - p) * (.66667 - t) * 6 end
        return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return to(p, q, h + .33334), to(p, q, h), to(p, q, h - .33334)
end

function utils.rgbToHsl(r, g, b)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local b = max + min
    local h = b / 2
    if max == min then return 0, 0, h end
    local s, l = h, h
    local d = max - min
    s = l > .5 and d / (2 - b) or d / b
    if max == r then h = (g - b) / d + (g < b and 6 or 0)
    elseif max == g then h = (b - r) / d + 2
    elseif max == b then h = (r - g) / d + 4
    end
    return h * .16667, s, l
end

-- https://github.com/s-walrus/hex2color
function utils.hexToRgb(hex, value)
	return {tonumber(string.sub(hex, 2, 3), 16)/256, tonumber(string.sub(hex, 4, 5), 16)/256, tonumber(string.sub(hex, 6, 7), 16)/256, value or 1}
end

function utils:rgbToHex(rgb)
    return string.format("#%02X%02X%02X", rgb[1], rgb[2], rgb[3])
end

function utils.merge(tbl, other, deep)
    if #tbl > 0 and #other > 0 then
        for _,v in ipairs(other) do
            table.insert(tbl, v)
        end
    else
        for k,v in pairs(other) do
            if deep and type(tbl[k]) == "table" and type(v) == "table" then
                utils.merge(tbl[k], v, true)
            else
                tbl[k] = v
            end
        end
    end
    return tbl
end

function utils.removeFromTable(tbl, val)
    for i,v in ipairs(tbl) do
        if v == val then
            table.remove(tbl, i)
            return v
        end
    end
end


return utils