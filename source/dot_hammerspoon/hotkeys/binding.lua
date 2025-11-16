---@diagnostic disable: undefined-global

local modal = require("hotkeys.modal")
local tiling = require("services.window.tiling")
local window = require("services.window.grid")

---@type table|nil
local registry = hs.loadSpoon("HotkeyRegistry")
assert(registry, "Failed to load HotkeyRegistry Spoon")

registry:registerActions("modal", modal)
registry:registerActions("window", window)
registry:registerActions("tiling", tiling)
registry:setRegistryPath(hs.configdir .. "/hotkeys/registry.json")

local function bindFromRegistry()
    local function categorizeHotkeys(hotkeys)
        local globalBindings = {}
        local modalBindings = {}

        for _, hotkey in ipairs(hotkeys) do
            if not hotkey.action then
                goto continue
            end

            local action = registry:resolveAction(hotkey.action)
            if not action then
                print(string.format("Warning: Could not resolve action: %s", hotkey.action))
                goto continue
            end

            local binding = { hotkey.modifiers, hotkey.key, action }

            if hotkey.mode == "global" then
                table.insert(globalBindings, binding)
            else
                modalBindings[hotkey.mode] = modalBindings[hotkey.mode] or {}
                table.insert(modalBindings[hotkey.mode], binding)
            end

            ::continue::
        end

        return globalBindings, modalBindings
    end

    local function bindGlobalHotkeys(bindings)
        for _, binding in ipairs(bindings) do
            hs.hotkey.bind(binding[1], binding[2], binding[3])
        end
    end

    local function bindModalHotkeys(modalBindings)
        local function isRepeatableMode(modeName)
            return modeName == "move"
        end

        for modeName, bindings in pairs(modalBindings) do
            local mode = modal.modes[modeName]
            if not mode then
                hs.alert.show("Modal mode not found: " .. modeName)
                goto continue
            end

            for _, binding in ipairs(bindings) do
                if isRepeatableMode(modeName) then
                    mode:bind(binding[1], binding[2], binding[3], nil, binding[3])
                else
                    mode:bind(binding[1], binding[2], binding[3])
                end
            end

            ::continue::
        end
    end

    local hotkeys = registry:parseHotkeys(true)
    local globalBindings, modalBindings = categorizeHotkeys(hotkeys)

    bindGlobalHotkeys(globalBindings)
    bindModalHotkeys(modalBindings)
end

registry.onRegistryLoaded = function()
    print("Registry loaded, rebinding hotkeys...")
    bindFromRegistry()
end

registry:enableUrlHandler()
registry:loadRegistry()
registry:startWatching()
