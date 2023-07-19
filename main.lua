spritesheet = nil
path = nil
baba_png_pattern = "^(.*[^a-zA-Z0-9_])(([a-zA-Z0-9_]+)_(%d+)_(%d+)%.png)$"

local import = require("import")
local export = require("export")

function init(plugin)    
    plugin:newCommand{
        id = "ImportTile",
        title = "Import Baba Tile",
        group = "file_import_1",
        onclick = import
    }

    plugin:newCommand{
        id = "ExportTile",
        title = "Export Baba Tile",
        group = "file_export_1",
        onclick = export,
        onenabled = function ()
            return app.sprite ~= nil
        end
    }

    path = plugin.path .. app.fs.pathSeparator
    -- Load assets
    spritesheet = Image{fromFile = plugin.path .. app.fs.pathSeparator .. "assets.png"}
end