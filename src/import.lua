local buttons = require("buttons")
local createtiles = require("template")

function importtile()
    local dialog = Dialog("Import Baba Tile")
    local filepath
    local usetemplate = false
    dialog:file {
        id = "file",
        title = "Select a tile to import",
        open = true,
        label = "    File",
        filetypes = { "png" },
        hexpand = true,
        entry = true,
        onchange = function()
            filepath = dialog.data["file"]
            local dir_path, filename, obj_name, dir, frame_num = string.match(filepath, baba_png_pattern)
            dialog:modify { id = "open", enabled =
                filepath ~= nil and
                dir_path ~= nil and
                filename ~= nil and
                obj_name ~= nil and
                dir ~= nil and
                frame_num ~= nil
            }
        end
    }
    dialog:check {
        id = "usetemplate",
        text = "Use Template",
        selected = usetemplate,
        onclick = function()
            usetemplate = not usetemplate
            dialog:modify { id = "file", visible = not usetemplate }
            dialog:modify { id = "open", enabled = usetemplate}
            dialog:modify { id = "width", visible = usetemplate}
            dialog:modify { id = "height", visible = usetemplate}
        end
    }
    buttons.show(dialog)
    dialog:check {
        id = "diagtile",
        text = "Diagonal Tiling",
        selected = buttons.diagtile,
        onclick = function()
            buttons.diagtile = not buttons.diagtile
        end,
        visible = false
    }
    dialog:number {
        id = "width",
        label = "Width",
        decimals = 0,
        visible = false,
        value = 24
    }
    dialog:number{
        id = "height",
        label = "Height",
        decimals = 0,
        visible = false,
        value = 24
    }
    dialog:separator()
    dialog:label {
        id = "progresslabel",
        text = "Loading files...",
        visible = false
    }
    dialog:slider {
        id = "progress",
        value = 0,
        min = 0,
        max = 1,
        visible = false
    }
    dialog:button {
        id = "open",
        text = "Open",
        entry = true,
        onclick = function()
            if filepath == nil and not usetemplate then return end
            local tilewidth, tileheight, width, height, dir_path, obj_name, baseimage
            if usetemplate then
                width, height = dialog.data["width"], dialog.data["height"]
            else 
                dir_path, _, obj_name, _, _ = string.match(filepath, baba_png_pattern)
                baseimage = Image { fromFile = filepath }
                width, height = baseimage.width, baseimage.height
            end
            local tilestoload = {}
            if buttons.selected == -1 then
                tilestoload = { 0 }
                tilewidth, tileheight = 1, 1
            elseif buttons.selected == 0 then
                tilestoload = { 0, 8, 16, 24 }
                tilewidth, tileheight = 4, 1
            elseif buttons.selected == 1 then
                if buttons.diagtile then
                    tilestoload = {
                        0, 1, 5, 4, 23, 36, 27, 19, 25, 40, 43, -1,
                        8, 9, 13, 12, 35, 44, 45, 28, 34, 42, 26, 39,
                        10, 11, 15, 14, 18, 41, 33, 22, 38, 46, 31, 30,
                        2, 3, 7, 6, 29, 17, 21, 37, 16, 24, 20, 32,
                    }
                    tilewidth, tileheight = 12, 4
                else
                    tilestoload = {
                        0, 1, 5, 4,
                        8, 9, 13, 12,
                        10, 11, 15, 14,
                        2, 3, 7, 6,
                    }
                    tilewidth, tileheight = 4, 4
                end
            elseif buttons.selected == 2 then
                tilestoload = {
                    31, 0, 1, 2, 3,
                    7, 8, 9, 10, 11,
                    15, 16, 17, 18, 19,
                    23, 24, 25, 26, 27
                }
                tilewidth, tileheight = 5, 4
            elseif buttons.selected == 3 then
                tilestoload = {
                    0, 1, 2, 3,
                    8, 9, 10, 11,
                    16, 17, 18, 19,
                    24, 25, 26, 27
                }
                tilewidth, tileheight = 4, 4
            elseif buttons.selected == 4 then
                tilestoload = { 0, 1, 2, 3 }
                tilewidth, tileheight = 4, 1
            else return end -- The user didn't pick a tile kind yet
            -- Show loading bar
            dialog:modify {
                id = "progress",
                visible = true,
                value = 0,
                max = #tilestoload * 3
            }
            dialog:modify {
                id = "progresslabel",
                visible = true
            }
            local tileimages = { {}, {}, {} }
            local fallbacks = { -- This is an unorganized mess
                [31] = 14, [32] = 15, [33] = 15, [34] = 9, [35] = 11, [36] = 13, [37] = 15, [38] = 11, [39] = 15, [40] = 15, [41] = 15, [42] = 13, [43] = 15, [44] = 15, [45] = 15, [46] = 15, [16] = 3, [17] = 7, [18] = 11, [19] = 15, [20] = 6, [21] = 7, [22] = 14, [23] = 15, [24] = 7, [25] = 15, [26] = 12, [27] = 13, [28] = 14, [29] = 15, [30] = 15
            }
            for i, tile in ipairs(tilestoload) do
                for frame = 1, 3 do
                    local failed = false
                    local path
                    if not usetemplate then
                        path = dir_path .. obj_name .. "_" .. tile .. "_" .. frame .. ".png"
                        if not app.fs.isFile(path) then
                            -- print(tostring(tile) .. " not found, trying fallback " .. tostring(fallbacks[tile]) .. "...")
                            if fallbacks[tile] then
                                path = dir_path .. obj_name .. "_" .. fallbacks[tile] .. "_" .. frame .. ".png"
                                tile = fallbacks[tile]
                            end
                            if not app.fs.isFile(path) then
                                table.insert(tileimages[frame], nil)
                                failed = true
                            end
                        end
                    end
                    if not failed then
                        local x, y = (i - 1) % tilewidth, (i - 1) // tilewidth
                        local tileimage
                        if usetemplate then
                            tileimage = createtile(width, height, tile, buttons.selected)
                        else 
                            tileimage = Image { fromFile = path }
                        end
                        if tileimage.colorMode ~= ColorMode.RGB then
                            local sprite = Sprite{ fromFile = path , oneFrame = true}
                            tileimage = Image(sprite.width, sprite.height, ColorMode.RGB)
                            tileimage:drawSprite(sprite)
                            sprite:close()
                        end
                        table.insert(tileimages[frame], {
                            image = tileimage,
                            x = x * width,
                            y = y * height
                        })
                    else io.write ("Failed to load " .. obj_name .. "_" .. tostring(tile) .. "_" .. tostring(frame) .. "\n") end
                    dialog:modify { id = "progress", value = i * 3 + frame - 1 }
                end
            end
            dialog:close()
            local newsprite = Sprite(tilewidth * width, tileheight * height)
            --app.transaction(function()
                newsprite.data = tostring(buttons.selected)
                newsprite:newEmptyFrame()
                newsprite:newEmptyFrame()
                for frame = 1, 3 do
                    newsprite.frames[frame].duration = 0.2
                    local image = Image(tilewidth * width, tileheight * height)
                    for i, tile in ipairs(tileimages[frame]) do
                        image:drawImage(tile.image, Point(tile.x, tile.y))
                        dialog:modify { id = "progress", value = frame * #tilestoload + i }
                        if frame == 1 then
                            local s = newsprite:newSlice(Rectangle(tile.x, tile.y, width, height))
                            s.name = tostring(tilestoload[i])
                        end
                    end
                    newsprite:newCel(newsprite.layers[1], frame, image, Point(0, 0))
                end
                newsprite.gridBounds = Rectangle(0, 0, width, height)
                app.command.ShowGrid()
                app.command.LoadPalette{ filename=app.fs.joinPath(path, "baba.gpl") }
            --end)
        end,
        hexpand = false,
        enabled = false
    }
    dialog:button {
        id = "cancel",
        text = "Cancel",
        onclick = function()
            dialog:close()
        end,
        hexpand = false
    }
    dialog:show { wait = false }
end

return importtile
