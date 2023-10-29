local ui = require("Extended_UI")

local rage = ui.create("rage", 1)
rage:checkbox("check0", true)
rage:checkbox("check1", false)
rage:checkbox("check2")
rage:color_picker(rage.check0, "check1-color0", color_t(5, 5, 5, 255))
rage:color_picker(rage.check1, "check1-color1", color_t(25, 255, 25, 255))
rage:slider("slider0", -150, 150, 1, 0, "words")

local aa = ui.create("antiaim", 2)
aa:checkbox("check0")
aa:keybind(aa.check0, "check0-keybind")
aa:multi_selection("multi0", {"items0", "items1", "items2", "items3"}, 3)
aa:separator()
aa:selection("slect0", {"items0", "items1", "items2", "items3"}, 3)

local debug = ui.create("debug", 2)
debug:button("import", function() 
    print("import button pressed")
end)

debug:button("export", function() 
    print("export button pressed")
end)

debug:button("debug", function()
    --print(ui.antiaim.check0:get())
    --print(aa.check0:get())

    aa:depend({rage.check0, true})
end)

callbacks.add(e_callbacks.PAINT, function() end)