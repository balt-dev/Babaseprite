local function open_dir(dir)
    -- Really hacky way of opening the file explorer that is OS independent
    -- Modified from https://github.com/PlasmaFlare/baba-aseprite-export/blob/master/baba_sprite_export.lua
    local out_files = app.fs.listFiles(dir)
    if #out_files > 0 then
        local sample_file = nil
        for _, f in ipairs(out_files) do
            if app.fs.fileExtension(f) == "png" then
                sample_file = f
                break
            end
        end

        if sample_file then
            local curr_sprite = app.activeSprite
            
            -- There's a possibility that opening the sample file will cause the "Open a sequence of files" dialog to appear.
            -- Disable it only for opening the sample file
            local old_sequence_pref = app.preferences.open_file.open_sequence
            app.preferences.open_file.open_sequence = 2 -- Set it to no

            app.open(app.fs.joinPath(dir, sample_file)) -- Open a sample png that was exported. Aseprite will then focus on this png.
            app.command.OpenInFolder() -- Opens the folder containing the sample png, effectively opening the folder with the exported sprites
            app.command.CloseFile() -- Close the sample png
            app.activeSprite = curr_sprite -- Focus back on the original aseprite file

            app.preferences.open_file.open_sequence = old_sequence_pref -- Restore the original setting
        end
    end
end


function exporttile()
    local dialog = Dialog("Export Baba Tile")
    local filepath = app.fs.filePath(app.sprite.filename)
    local tilename = app.fs.fileTitle(app.sprite.filename)
    dialog:file {
        id = "file",
        label = "Path + Name",
        entry = true,
        save = true,
        filename = filepath,
        title = "Select a directory to export to",
        filetypes = { "" },
        onchange = function()
            filepath = app.fs.filePath(dialog.data["file"])
            tilename = app.fs.fileTitle(dialog.data["file"])
            dialog:modify { id = "save", enabled = filepath ~= nil }
        end
    }
    dialog:separator()
    dialog:label {
        id = "progresslabel",
        text = "Exporting...",
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
        id = "explorer",
        text = "Open Folder",
        visible = false,
        onclick = function()
            open_dir(filepath)
        end
    }
    dialog:button {
        id = "save",
        text = "Export",
        onclick = function()
            dialog:modify {
                id = "progress",
                visible = true,
                value = 0,
                max = #app.sprite.frames * #app.sprite.slices
            }
            dialog:modify {
                id = "progresslabel",
                visible = true
            }
            local temp_sprite = Sprite(app.sprite)
            temp_sprite:flatten()
            app.transaction(function ()
                for frame = 1, 3 do
                    local frame_sprite = Sprite(temp_sprite)
                    local offset = 0
                    for delframe = 1, 3 do
                        if frame ~= delframe then
                            frame_sprite:deleteFrame(delframe + offset)
                            offset = offset - 1
                        end
                    end
                    for i, slice in ipairs(temp_sprite.slices) do
                        local slice_sprite = Sprite(frame_sprite)
                        slice_sprite:crop(slice.bounds)

                        local slice_name = slice.name
                        slice_sprite:saveAs(
                            app.fs.joinPath(filepath, tilename .. "_" .. slice_name .. "_" .. frame .. ".png")
                        )
                        slice_sprite:close()
                        dialog:modify {
                            id = "progress",
                            value = (frame - 1) * #app.sprite.slices + i,
                        }
                    end
                    frame_sprite:close()
                end
            end)
            temp_sprite:close()
            dialog.bounds = Rectangle(
                dialog.bounds.x,
                dialog.bounds.y,
                math.max(dialog.bounds.width, 500),
                dialog.bounds.height
            )
            dialog:modify {
                id = "progresslabel",
                text = "Exported to " .. filepath,
                visible = true
            }
            dialog:modify {
                id = "explorer",
                visible = true
            }
            dialog:modify {
                id = "progress",
                visible = false
            }
            dialog:modify {
                id = "save",
                visible = false
            }
            dialog:modify {
                id = "cancel",
                text = "Close"
            }
        end
    }
    dialog:button {
        id = "cancel",
        text = "Cancel",
        onclick = function()
            dialog:close()
        end
    }
    dialog.bounds = Rectangle(
        dialog.bounds.x,
        dialog.bounds.y,
        math.max(dialog.bounds.width, 300),
        dialog.bounds.height
    )
    dialog:show{wait = false}
end

return exporttile