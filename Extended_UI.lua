local json = require("primordial/JSON Library.97")
local ui = { }

--[===[
-- =======================================================================
--      Data
-- =======================================================================
--]===]

ui.__type = {
    group = -1,
    button = 0,
    keybind = 1,
    text_input = 2,
    text = 3,
    separator = 4,
    list = 5,
    checkbox = 6,
    color_picker = 7,
    multi_selection = 8,
    selection = 9,
    slider = 10
}

ui.__metasave = true

--[===[
-- =======================================================================
--      UI handling
-- =======================================================================
--]===]

ui.__data = { }
ui.create = function(_group, _column)
    local data = {
        group = _group,
        column = _column,
        id = ui.__type.group
    }

    menu.set_group_column(_group, _column)

    ui.__index = ui
    return setmetatable(data, ui)
end

function ui:create_element(_id, _name, _options)
    local ref = nil

    if _id == ui.__type.button then
        ref = menu.add_button(
            self.group, 
            _name, 
            _options.fn
        )
    elseif _id == ui.__type.checkbox then
        ref = menu.add_checkbox(
            self.group, 
            _name, 
            _options.default_value
        )
    elseif _id == ui.__type.color_picker then
        ref = _options.parent.ref:add_color_picker(
            _name, 
            _options.default_value, 
            _options.alpha
        )
    elseif _id == ui.__type.keybind then
        ref = _options.parent.ref:add_keybind(
            _name, 
            _options.default_value
        )
    elseif _id == ui.__type.list then
        ref = menu.add_list(
            self.group, 
            _name, 
            _options.items, 
            _options.visible_count
        )
    elseif _id == ui.__type.multi_selection then
        ref = menu.add_multi_selection(
            self.group, 
            _name, 
            _options.items, 
            _options.visible_count
        )
    elseif _id == ui.__type.selection then
        ref = menu.add_selection(
            self.group, 
            _name, 
            _options.items, 
            _options.visible_count
        )
    elseif _id == ui.__type.slider then
        ref = menu.add_slider(
            self.group, 
            _name, 
            _options.min, 
            _options.max, 
            _options.step, 
            _options.precision,
            _options.suffix
        )
    elseif _id == ui.__type.text_input then
        ref = menu.add_text_input(
            self.group, 
            _name
        )
    elseif _id == ui.__type.text then
        ref = menu.add_text(
            self.group, 
            _name
        )
    elseif _id == ui.__type.separator then
        ref = menu.add_separator(
            self.group
        )
    end

    local data = {
        name = _name,
        id = _id,
        ref = ref,
        group = self.group,

        get = function(self, _item)
            if self.id == ui.__type.multi_selection then
                return self.ref:get(_item)
            else
                return self.ref:get() 
            end
        end
    }

    -- [[ Config data ]] --
    if not ui.__data[self.group] then ui.__data[self.group] = { } end
    ui.__data[self.group][_name] = data

    -- [[ Meta data ]] --
    if ui.__metasave then
        if not ui[self.group] then ui[self.group] = { } end
        ui[self.group][_name] = data
        self[_name] = data
    end

    --return data 
    return setmetatable(data, ui)
end

--[===[
-- =======================================================================
--      Wrappers
-- =======================================================================
--]===]

function ui:button(_name, _fn)
    -- To avoid crashing
    _fn = _fn or function() end

    return self:create_element(ui.__type.button, _name, {
        fn = _fn
    })
end

function ui:checkbox(_name, _default_value)
    return self:create_element(ui.__type.checkbox, _name, {
        default_value = _default_value
    })
end

function ui:color_picker(_parent, _name, _default_value, _alpha) 
    return self:create_element(ui.__type.color_picker, _name, {
        parent = _parent,
        default_value = _default_value,
        alpha = _alpha
    })
end

function ui:keybind(_parent, _name, _default_value)
    return self:create_element(ui.__type.keybind, _name, {
        parent = _parent,
        default_value = _default_value
    })
end

function ui:list(_name, _items, _visible_count)
    return self:create_element(ui.__type.list, _name, {
        items = _items,
        visible_count = _visible_count
    })
end

function ui:multi_selection(_name, _items, _visible_count)
    return self:create_element(ui.__type.multi_selection, _name, {
        items = _items, 
        visible_count = _visible_count
    })
end

function ui:selection(_name, _items, _visible_count)
    return self:create_element(ui.__type.selection, _name, {
        items = _items,
        visible_count = _visible_count
    })
end

function ui:slider(_name, _min, _max, _step, _precision, _suffix)
    return self:create_element(ui.__type.slider, _name, {
        min = _min,
        max = _max,
        step = _step,
        precision = _precision,
        suffix = _suffix
    })
end

function ui:text_input(_name) return self:create_element(ui.__type.text_input, _name) end
function ui:text(_name, _options) return self:create_element(ui.__type.text, _name, _options) end
function ui:separator() return self:create_element(ui.__type.separator, "separator") end

--[===[
-- =======================================================================
--      Config system
-- =======================================================================
--]===]

ui.export = function()
    local d = { }

    for i, v in pairs(ui.__data) do   
        d[i] = { }

        for i0, v0 in pairs(v) do
            if v0.id < ui.__type.checkbox then goto skip end

            if v0.id == ui.__type.multi_selection then       
                local s = { }
                for i1, v1 in pairs(v0.ref:get_items()) do
                    table.insert(s, {v1, v0.ref:get(v1)})
                end
    
                table.insert(d[i], {v0.name, s})
            elseif v0.id == ui.__type.color_picker then                         
                local clr = v0.ref:get()
                table.insert(d[i], {v0.name, clr.r, clr.g, clr.b, clr.a})
            else                               
                table.insert(d[i], {v0.name, v0.ref:get()})
            end

            ::skip::
        end
    end 

    return json.encode(d)
end

ui.import = function(data)
    local db = json.parse(data)

    for i, v in pairs(db) do
        for i0, v0 in pairs(v) do
            if ui.__data[i] == nil or ui.__data[i][v0[1]] == nil then goto skip end                          

            if ui.__data[i][v0[1]].id == ui.__type.multi_selection then  
                for i1, v1 in pairs(v0[2]) do
                    ui.__data[i][v0[1]].ref:set(v1[1], v1[2])
                end
            elseif ui.__data[i][v0[1]].id == ui.__type.color_picker then              
                ui.__data[i][v0[1]].ref:set(color_t(v0[2], v0[3], v0[4], v0[5]))
            else                                                                
                ui.__data[i][v0[1]].ref:set(v0[2])        
            end

            ::skip::
        end 
    end
end

--[===[
-- =======================================================================
--      Utilities
-- =======================================================================
--]===]

function ui:depend(...)
    local args = {...} 
    local result = nil

    for i, v in pairs(args) do
        local con = nil

        if type(v[1]) == 'boolean' then con = v[1] else con = v[1].ref:get() == v[2] end

        if result then
            result = (result and con)
        else 
            result = con
        end
    end

    if self.id == -1 then
        menu.set_group_visibility(self.group, result) 
    else 
        self.ref:set_visible(result)
    end
end

return ui
