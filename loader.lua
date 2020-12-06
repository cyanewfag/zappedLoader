local scrSize = engine.screen_size();
local keyTable = { {0xBF, "/"}, {0x20, " "}, {0x30, "0"}, {0x31, "1"}, {0x32, "2"}, {0x33, "3"}, {0x34, "4"}, {0x35, "5"}, {0x36, "6"}, {0x37, "7"}, {0x38, "8"}, {0x39, "9"}, {0x41, "A"}, {0x42, "B"}, {0x43, "C"}, {0x44, "D"}, {0x45, "E"}, {0x46, "F"}, {0x47, "G"}, {0x48, "H"}, {0x49, "I"}, {0x4A, "J"}, {0x4B, "K"}, {0x4C, "L"}, {0x4D, "M"}, {0x4E, "N"}, {0x4F, "O"}, {0x50, "P"}, {0x51, "Q"}, {0x52, "R"}, {0x53, "S"}, {0x54, "T"}, {0x55, "U"}, {0x56, "V"}, {0x57, "W"}, {0x58, "X"}, {0x59, "Y"}, {0x5A, "Z"} };
local mouseVars = { false, 0, 0, false, 0, 0, "", false, 0, 0 };
local forms = {{"Login Form", 300, 250, (scrSize.x / 2) - 150, (scrSize.y / 2) - 200, {}}};
local colors = {color.new(38, 38, 38), color.new(48, 48, 48), color.new(189, 137, 255), color.new(58, 58, 58), color.new(68, 68, 68)};
local fonts = { renderer.create_font("Arial", 12, true) };
local defaults = { color.new(255, 255, 255), renderer.create_font("Arial", 12, true) }
local selectedIndex = 0;
local selectedForm = "";

-- Misc Functions
function round(x, n) -- Credits toma91
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end

function safeLog(str, r, g, b, a)
    if (str ~= nil) then
        str = tostring(str)
        if (str ~= "") then
            if (r ~= nil and g ~= nil and b ~= nil and a ~= nil) then
                local color = color.new(r, g, b, a);
                if (color ~= nil) then
                    utils.log(str, color);
                end
            else
                utils.event_log(str, true);
            end
        end
    end
end

function tableContains(table, value)
    for i = 1, #table do
        if (table[i][1] == value) then
            return true;
        end
    end

    return false;
end

function findTableIndex(table, value)
    for i = 1, #table do
        if (table[i][1] == value) then
            return i;
        end
    end

    return 0;
end

-- Custom Drawing Functions
function drawText(x, y, text, font, color, style)
    if (x ~= nil and y ~= nil and text ~= nil) then
        text = tostring(text);
        if (color == nil) then color = defaults[1]; end
        if (font == nil) then font = defaults[2]; end

        if (style ~= "c" and style ~= "r" and style ~= "cr") then
            renderer.text(x, y, text, color, font);
        else
            local textSize = renderer.get_text_size(text, font);

            if (style == "c") then
                renderer.text(x - (textSize.x / 2), y - (textSize.y / 2), text, color, font);
            elseif (style == "r") then
                renderer.text(x - textSize.x, y, text, color, font);
            else
                renderer.text(x - textSize.x, y - (textSize.y / 2), text, color, font);
            end
        end
    end
end

function drawRoundedRect(x, y, w, h, r, color)
    if (x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        if (color == nil) then color = defaults[1]; end
        if (color == nil) then r = 0; end

        renderer.filled_circle(x + r, y + r, r, color);
        renderer.filled_circle(x + r, y + h - r, r, color);
        renderer.filled_circle(x + w - r, y + r, r, color);
        renderer.filled_circle(x + w - r, y + h - r, r, color);
        renderer.filled_rect(x + r, y, w - (r * 2), h, color)
        renderer.filled_rect(x, y + r, w, h - (r * 2), color)
    end
end

function drawRectShadow(x, y, w, h, rectColor, r)
    if (x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        local curAlpha = rectColor.a;

        if (curAlpha >= r) then
            local alphaStep = round(curAlpha / r, 0);

            for i = 1, r do
                renderer.rect(x - i, y - i, w + (i * 2), h + (i * 2), rectColor);
                local red, g, b, a = rectColor.r, rectColor.g, rectColor.b, round(rectColor.a - alphaStep, 0);

                if (i ~= r - 1) then
                    rectColor = color.new(red, g, b, a);
                else
                    rectColor = color.new(red, g, b, a);
                end
            end
        end
    end
end

-- Handlers
function mouseHandler()
    if (game.focused) then
        local mousePos = keys.get_mouse()
        mouseVars[2], mouseVars[3] = mousePos.x, mousePos.y;

        if (keys.key_down(0x01)) then
            if (keys.key_pressed(0x01)) then
                mouseVars[8], mouseVars[9], mouseVars[10] = true, mouseVars[2], mouseVars[3];
                selectedIndex = 0;
            else
                mouseVars[8], mouseVars[9], mouseVars[10] = false, 0, 0;
            end

            if (not mouseVars[1]) then
                mouseVars[1] = true;

                for i = 1, #forms do
                    if (mouseVars[2] >= forms[i][4] and mouseVars[2] <= forms[i][4] + forms[i][2] and mouseVars[3] >= forms[i][5] and mouseVars[3] <= forms[i][5] + forms[i][3]) then
                        mouseVars[4], mouseVars[5], mouseVars[6], mouseVars[7] = true, forms[i][4] - mouseVars[2], forms[i][5] - mouseVars[3], forms[i][1];
                    end
                end
            end

            if (mouseVars[4]) then
                for i = 1, #forms do
                    if (forms[i][1] == mouseVars[7]) then
                        forms[i][4], forms[i][5] = mouseVars[2] + mouseVars[5], mouseVars[3] + mouseVars[6];
                    end
                end
            end
        else
            mouseVars[1], mouseVars[4], mouseVars[8] = false, false, false;
        end
    end
end

function loginHandler()

end

function textHandler()
    if (selectedIndex ~= 0 and selectedForm ~= "") then
        local text = "";
        local formsIndex;
        local index;

        for i = 1, #forms do
            if (forms[i][1] == selectedForm) then
                formsIndex = i;
                index = selectedIndex;
            end
        end

        for i = 1, #keyTable do
            if (keys.key_pressed(keyTable[i][1])) then
                if (not keys.key_down(0x10)) then
                    text = text .. string.lower(keyTable[i][2]);
                else
                    text = text .. keyTable[i][2];
                end
            end
        end

        forms[formsIndex][6][index][2] = forms[formsIndex][6][index][2] .. text;

        if (keys.key_pressed(0x08)) then
            if (#forms[formsIndex][6][index][2] ~= 0) then
                forms[formsIndex][6][index][2] = forms[formsIndex][6][index][2]:sub(1, #forms[formsIndex][6][index][2] - 1)
            end
        end
    end
end

function drawHandler(name, on)
    for i = 1, #forms do
        if (forms[i][1] == name) then
            if (on) then
                renderer.set_clip(forms[i][4], forms[i][5], forms[i][3], forms[i][2])
            else
                renderer.remove_clip();
            end
        end
    end
end

-- Controls
function drawForm(name)
    for i = 1, #forms do
        if (forms[i][1] == name) then
            renderer.filled_rect(forms[i][4], forms[i][5], forms[i][2], forms[i][3], colors[1]);
            renderer.filled_rect(forms[i][4], forms[i][5], forms[i][2], 32, colors[2]);
            renderer.gradient_rect(forms[i][4], forms[i][5] + 22, forms[i][2], 12, true, colors[2], colors[1]);
            renderer.rect(forms[i][4], forms[i][5], forms[i][2], forms[i][3], colors[2]);
            renderer.filled_rect(forms[i][4], forms[i][5], forms[i][2], 2, colors[3]);
            drawText(forms[i][4] + (forms[i][2] / 2), forms[i][5] + 14, name, nil, nil, "c")
        end
    end
end

function addTextbox(parentName, varname, x, y, w, h, centered)
    if (varname ~= nil and x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        local index;
        local formsIndex;
        if (parentName ~= nil) then
            for i = 1, #forms do
                if (forms[i][1] == parentName) then
                    if (varname ~= nil) then
                        if (not tableContains(forms[i][6], varname)) then
                            table.insert(forms[i][6], {varname, ""})
                        end
                    end

                    index = findTableIndex(forms[i][6], varname);
                    formsIndex = i;

                    x, y = x + forms[i][4], y + forms[i][5];
                end

                if (centered) then
                    x = (forms[i][4] + (forms[i][2] / 2)) - (w / 2)
                end
            end
        end

        renderer.set_clip(x, y, h + 1, w + 1);
        if (mouseVars[2] >= x and mouseVars[2] <= x + w and mouseVars[3] >= y and mouseVars[3] <= y + h) then
            if (selectedIndex ~= index) then
                renderer.filled_rect(x, y, w, h, colors[2]);
                renderer.rect(x, y, w, h, colors[4]);
            end

            if (keys.key_pressed(0x01)) then
                selectedForm = parentName;
                selectedIndex = index;
            end
        end

        if (selectedIndex == index) then
            renderer.filled_rect(x, y, w, h, colors[2]);
            renderer.rect(x, y, w, h, colors[4]);
        else
            renderer.filled_rect(x, y, w, h, colors[1]);
            renderer.rect(x, y, w, h, colors[2]);
        end

        drawText(x + (w / 2), y + (h / 2), forms[formsIndex][6][index][2], nil, nil, "c")
        renderer.remove_clip();
    end
end

function addButton(parentName, text, x, y, w, h, centered, func, varname)
    if (func ~= nil and x ~= nil and y ~= nil and w ~= nil and h ~= nil) then
        if (text == nil) then text = ""; end text = tostring(text);
        if (parentName ~= nil) then
            for i = 1, #forms do
                if (forms[i][1] == parentName) then
                    if (varname ~= nil) then
                        if (not tableContains(forms[i][6], varname)) then
                            table.insert(forms[i][6], {varname})
                        end
                    end

                    x, y = x + forms[i][4], y + forms[i][5];
                end

                if (centered) then
                    x = (forms[i][4] + (forms[i][2] / 2)) - (w / 2)
                end
            end
        end

        if (mouseVars[2] >= x and mouseVars[2] <= x + w and mouseVars[3] >= y and mouseVars[3] <= y + h) then
            if (keys.key_down(0x01)) then
                renderer.filled_rect(x, y, w, h, colors[4]);
                renderer.rect(x, y, w, h, colors[5]);
            else
                renderer.filled_rect(x, y, w, h, colors[2]);
                renderer.rect(x, y, w, h, colors[4]);
            end

            if (keys.key_pressed(0x01)) then
                selectedIndex = 0;
                -- run function
            end
        else
            renderer.filled_rect(x, y, w, h, colors[1]);
            renderer.rect(x, y, w, h, colors[2]);
        end

        drawText(x + (w / 2), y + (h / 2), text, nil, nil, "c")
    end
end

-- Callbacks
function on_render()
    -- Handlers
    mouseHandler();
    textHandler();

    -- Login Form
    drawHandler("Login Form", true);
    drawForm("Login Form");
    drawHandler("Login Form", false);
    addTextbox("Login Form", "var_login_username", 35, 75, 125, 35, true)
    addTextbox("Login Form", "var_login_password", 35, 120, 125, 35, true)
    addButton("Login Form", "Login", 35, 165, 125, 35, true, loginHandler)
end
