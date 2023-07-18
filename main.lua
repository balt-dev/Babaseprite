spritesheet = nil
palette = nil

local import = require("import")

function init(plugin)    
    plugin:newCommand{
        id = "ImportTile",
        title = "Import Baba Tile",
        group = "file_import_1",
        onclick = import
    }

    -- Load assets
    spritesheet = Image{fromFile = plugin.path .. app.fs.pathSeparator .. "assets.png"}
end