-- Button code from https://github.com/aseprite/Aseprite-Script-Examples/blob/main/Custom%20Widgets.lua

local Buttons = { diagtile = false }

local mouse = { position = Point(0, 0), leftClick = false }
local focusedWidget = nil


Buttons.show = function(dialog)
    local customWidgets = {
        {
            bounds = Rectangle(2, 2, 23, 23),
            state = {
                normal = { part = "button_normal", color = "button_normal_text" },
                hot = { part = "button_hot", color = "button_hot_text" },
                selected = { part = "button_selected", color = "button_selected_text" },
                focused = { part = "button_focused", color = "button_normal_text" }
            },
            image = {
                bounds = Rectangle(0, 0, 12, 12),
            },
            onclick = function()
                Buttons.selected = -1
                dialog:modify{id = "diagtile", visible = false}
            end
        },
        {
            bounds = Rectangle(27, 2, 23, 23),
            state = {
                normal = { part = "button_normal", color = "button_normal_text" },
                hot = { part = "button_hot", color = "button_hot_text" },
                selected = { part = "button_selected", color = "button_selected_text" },
                focused = { part = "button_focused", color = "button_normal_text" }
            },
            image = {
                bounds = Rectangle(12, 0, 12, 12),
            },
            onclick = function() 
                Buttons.selected = 0
                dialog:modify{id = "diagtile", visible = false}
            end
        },
        {
            bounds = Rectangle(52, 2, 23, 23),
            state = {
                normal = { part = "button_normal", color = "button_normal_text" },
                hot = { part = "button_hot", color = "button_hot_text" },
                selected = { part = "button_selected", color = "button_selected_text" },
                focused = { part = "button_focused", color = "button_normal_text" }
            },
            image = {
                bounds = Rectangle(24, 0, 12, 12),
            },
            onclick = function()
                Buttons.selected = 1
                dialog:modify { id = "diagtile", visible = true }
            end
        },
        {
            bounds = Rectangle(77, 2, 23, 23),
            state = {
                normal = { part = "button_normal", color = "button_normal_text" },
                hot = { part = "button_hot", color = "button_hot_text" },
                selected = { part = "button_selected", color = "button_selected_text" },
                focused = { part = "button_focused", color = "button_normal_text" }
            },
            image = {
                bounds = Rectangle(0, 12, 12, 12),
            },
            onclick = function()
                Buttons.selected = 2 
                dialog:modify{id = "diagtile", visible = false}
            end
        },
        {
            bounds = Rectangle(102, 2, 23, 23),
            state = {
                normal = { part = "button_normal", color = "button_normal_text" },
                hot = { part = "button_hot", color = "button_hot_text" },
                selected = { part = "button_selected", color = "button_selected_text" },
                focused = { part = "button_focused", color = "button_normal_text" }
            },
            image = {
                bounds = Rectangle(12, 12, 12, 12),
            },
            onclick = function()
                Buttons.selected = 3
                dialog:modify{id = "diagtile", visible = false}
            end
        },
        {
            bounds = Rectangle(127, 2, 23, 23),
            state = {
                normal = { part = "button_normal", color = "button_normal_text" },
                hot = { part = "button_hot", color = "button_hot_text" },
                selected = { part = "button_selected", color = "button_selected_text" },
                focused = { part = "button_focused", color = "button_normal_text" }
            },
            image = {
                bounds = Rectangle(24, 12, 12, 12),
            },
            onclick = function()
                Buttons.selected = 4
                dialog:modify{id = "diagtile", visible = false}
            end
        }
    }
    dialog:canvas {
        id = "canvas",
        width = 150,
        height = 25,
        onpaint = function(ev)
            local ctx = ev.context

            -- Draw each custom widget
            for _, widget in ipairs(customWidgets) do
                local state = widget.state.normal

                if widget == focusedWidget then
                    state = widget.state.focused
                end

                local isMouseOver = widget.bounds:contains(mouse.position)

                if isMouseOver then
                    state = widget.state.hot or state

                    if mouse.leftClick then
                        state = widget.state.selected
                    end
                end

                ctx:drawThemeRect(state.part, widget.bounds)

                local center = Point(widget.bounds.x + widget.bounds.width / 2,
                    widget.bounds.y + widget.bounds.height / 2)

                if widget.icon then
                    -- Assuming default icon size of 16x16 pixels
                    local size = Rectangle(0, 0, 16, 16)

                    ctx:drawThemeImage(widget.icon, center.x - size.width / 2,
                        center.y - size.height / 2)
                elseif widget.text then
                    local size = ctx:measureText(widget.text)

                    ctx.color = app.theme.color[state.color]
                    ctx:fillText(widget.text, center.x - size.width / 2,
                        center.y - size.height / 2)
                elseif widget.image then
                    -- widget.image.bounds are the UV coordinates of the image, in pixels
                    local size = Rectangle(0, 0, widget.image.bounds.w,
                        widget.image.bounds.h)
                    ctx:drawImage(spritesheet,
                        widget.image.bounds.x, widget.image.bounds.y,
                        widget.image.bounds.width, widget.image.bounds.height,
                        center.x - size.width / 2, center.y - size.height / 2,
                        size.width, size.height
                    )
                end
            end
        end,
        onmousemove = function(ev)
            -- Update the mouse position
            mouse.position = Point(ev.x, ev.y)

            dialog:repaint()
        end,
        onmousedown = function(ev)
            -- Update information about left mouse button being pressed
            mouse.leftClick = ev.button == MouseButton.LEFT

            dialog:repaint()
        end,
        onmouseup = function(ev)
            -- When releasing left mouse button over a widget, call `onclick` method
            if mouse.leftClick then
                for _, widget in ipairs(customWidgets) do
                    local isMouseOver = widget.bounds:contains(mouse.position)

                    if isMouseOver then
                        widget.onclick()

                        -- Last clicked widget has focus on it
                        focusedWidget = widget
                    end
                end
            end

            -- Update information about left mouse button being released
            mouse.leftClick = false

            dialog:repaint()
        end
    }
end

return Buttons
