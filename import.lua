

local buttons = require("buttons")

local baba_png_pattern = "^(.*[^a-zA-Z0-9_])(([a-zA-Z0-9_]+)_(%d+)_(%d+)%.png)$"

function importtile()
    local dialog = Dialog("Import Baba Tile")
    local filepath
    local usetemplate = true
    dialog:file{
        id = "file",
        title = "Select a tile to import",
        open = true,
        filetypes = {"png"},
        hexpand = true,
        onchange = function ()
            filepath = dialog.data["file"]
            local dir_path, filename, obj_name, dir, frame_num = string.match(filepath, baba_png_pattern)
            dialog:modify{id = "open", enabled = 
                filepath ~= nil and
                dir_path ~= nil and
                filename ~= nil and
                obj_name ~= nil and
                dir ~= nil and
                frame_num ~= nil
            }
        end
    }
    dialog:check{
        id = "usetemplate",
        text = "Use Template",
        selected = usetemplate,
        onclick = function()
            usetemplate = usetemplate
            dialog:modify{id = "file", enabled = usetemplate}
        end
    }
    buttons.show(dialog)
    dialog:check{
        id = "diagtile",
        text = "Diagonal Tiling",
        selected = buttons.diagtile,
        onclick = function()
            buttons.diagtile = not buttons.diagtile
        end,
        visible = false
    }
    dialog:separator()
    local progresslabel = dialog:label{
        id = "progresslabel",
        text = "Loading files...",
        visible = false
    }
    local progress = dialog:slider{
        id = "progress",
        value = 0,
        min = 0,
        max = 1,
        visible = false
    }
    dialog:button{
        id = "open",
        text = "Open",
        entry = true,
        onclick = function()
            if usetemplate then
                Sprite{fromFile = plugin.path .. app.fs.pathSeparator .. tostring(buttons.selected) .. ".aseprite"}
            else
                if filepath == nil then return end
                local dir_path, filename, obj_name, dir, frame_num = string.match(filepath, baba_png_pattern)
                local baseimage = Image{ fromFile=filepath }
                local tilewidth, tileheight, width, height
                width, height = baseimage.width,baseimage.height
                local tilestoload = {}
                if buttons.selected == -1 then
                    tilestoload = {0}
                    tilewidth, tileheight = 1, 1
                elseif buttons.selected == 0 then
                    tilestoload = {0, 8, 16, 24}
                    tilewidth, tileheight = 4, 1
                elseif buttons.selected == 1 then
                    if buttons.diagtile then
                        tilestoload = {
                            0,  1,  5,  4, 23, 36, 27, 19, 25, 40, 43, -1,
                            8,  9, 13, 12, 35, 44, 45, 28, 34, 42, 26, 39, 
                        10, 11, 15, 14, 18, 41, 33, 22, 38, 46, 31, 30, 
                            2,  3,  7,  6, 29, 17, 21, 37, 16, 24, 20, 32,
                        }
                        tilewidth, tileheight = 12, 4
                    else
                        tilestoload = {
                            0,  1,  5,  4,
                            8,  9, 13, 12,
                        10, 11, 15, 14,
                            2,  3,  7,  6,
                        }
                        tilewidth, tileheight = 4, 4
                    end
                elseif buttons.selected == 2 then
                    tilestoload = {
                        31,  0,  1,  2,  3,
                        7,  8,  9, 10, 11,
                        15, 16, 17, 18, 19,
                        23, 24, 25, 26, 27  
                    }
                    tilewidth, tileheight = 5, 4
                elseif buttons.selected == 3 then
                    tilestoload = {
                        0,  1,  2,  3,
                        8,  9, 10, 11,
                    16, 17, 18, 19,
                    24, 25, 26, 27  
                }
                tilewidth, tileheight = 4, 4
                elseif buttons.selected == 4 then
                    tilestoload = {0, 1, 2, 3}
                    tilewidth, tileheight = 4, 1
                else
                    error("Invalid tile, this should never happen")
                end
                -- Show loading bar
                dialog:modify{
                    id = "progress",
                    visible = true,
                    value = 0,
                    max = #tilestoload * 3
                }
                dialog:modify{
                    id = "progresslabel",
                    visible = true
                }
                local tileimages = {{}, {}, {}}
                for i, tile in ipairs(tilestoload) do
                    if tile < 0 then
                        table.insert(tileimages, nil)
                    else
                        for frame = 1, 3 do
                            local x, y = (i - 1) % tilewidth, (i - 1) // tilewidth
                            local tileimage = Image{ fromFile = dir_path .. obj_name .. "_" .. tile .. "_" .. frame .. ".png"}
                            table.insert(tileimages[frame], {
                                image = tileimage,
                                x = x * width,
                                y = y * height
                            })
                            dialog:modify{id = "progress", value = i * 3 + frame - 1}
                        end
                    end
                end
                dialog:close()
                local newsprite = Sprite(tilewidth * width, tileheight * height)
                app.transaction(function ()
                    newsprite.data = tostring(buttons.selected)
                    newsprite:newEmptyFrame()
                    newsprite:newEmptyFrame()
                    for frame = 1, 3 do
                        newsprite.frames[frame].duration = 0.2
                        local image = Image(tilewidth * width, tileheight * height)
                        for i, tile in ipairs(tileimages[frame]) do
                            image:drawImage(tile.image, Point(tile.x, tile.y))
                            dialog:modify{id = "progress", value = frame * #tilestoload + i}
                            if frame == 1 then
                                local s = newsprite:newSlice(Rectangle(tile.x, tile.y, width, height))
                                s.name = tostring(tilestoload[i])
                            end
                        end
                        newsprite:newCel(newsprite.layers[1], frame, image, Point(0, 0))
                    end
                    newsprite.gridBounds = Rectangle(0, 0, width, height)
                    app.command.ShowGrid()
                end)
            end
        end,
        hexpand = false,
        enabled = false
    }
    dialog:button{
        id = "cancel",
        text = "Cancel",
        onclick = function()
            dialog:close()
        end,
        hexpand = false
    }
    dialog:show{wait = false}
end

return importtile