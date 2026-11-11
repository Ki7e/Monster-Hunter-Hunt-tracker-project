-- HuntSplit: temporary Wilds enemy-state diagnostic.
-- Place in reframework/autorun/ alongside huntsplit.lua.
-- This only observes calls; it does not modify game state or create splits.

local OUTPUT = "huntsplit_event_test.txt" -- REFramework writes under reframework/data/
local MAX_EVENTS = 200
local events = {
    "HuntSplit enemy-state hook test",
    "Fields: event number | state (numeric) | enemy pointer | quest elapsed ms (sampled next frame)",
    "A state value is NOT confirmed to mean death/capture until tested in game.",
}
local pending = {}
local count = 0
local dropped = 0
local status = "Initializing"

local function save_log()
    local ok, err = pcall(function()
        fs.write(OUTPUT, table.concat(events, "\n") .. "\n")
    end)
    if not ok then status = "Log write failed: " .. tostring(err) end
end

local function get_elapsed_ms()
    local manager = sdk.get_managed_singleton("app.MissionManager")
    if not manager then return nil end
    local director = manager:get_field("_QuestDirector")
    if not director then return nil end
    return director:call("get_QuestElapsedTimeMSec")
end

local type_def = sdk.find_type_definition("app.cQuestDirector")
local method = type_def and type_def:get_method("notifyEmStateChange")

if not method then
    status = "Hook method NOT found (check REFramework log)"
    events[#events + 1] = status
    save_log()
else
    status = "Hook installed; start a quest"
    events[#events + 1] = status
    save_log()

    sdk.hook(method,
        function(args)
            -- Instance method: args[3] = EM_STATE, args[4] = enemy browser pointer.
            -- No game method calls or file writes inside the hook.
            if count < MAX_EVENTS then
                local state = sdk.to_int64(args[3])
                pending[#pending + 1] = {
                    state = tostring(state),
                    enemy = tostring(args[4])
                }
                count = count + 1
            else
                dropped = dropped + 1
            end
            -- No return: original game function runs normally.
        end,
        function(retval)
            return retval
        end
    )
end

re.on_frame(function()
    if #pending == 0 then return end
    local ms = "unavailable"
    local ok, value = pcall(get_elapsed_ms)
    if ok and value ~= nil then ms = tostring(value) end
    for _, item in ipairs(pending) do
        events[#events + 1] = string.format(
            "%d | state=%s | enemy=%s | quest_ms=%s",
            #events - 4, item.state, item.enemy, ms
        )
    end
    pending = {}
    status = string.format("Hook active: %d event(s) recorded", count)
    save_log()
end)

re.on_draw_ui(function()
    if imgui.tree_node("HuntSplit: Enemy event test") then
        imgui.text(status)
        imgui.text("Event count: " .. tostring(count))
        imgui.text("Dropped after limit: " .. tostring(dropped))
        imgui.text("Log: reframework/data/" .. OUTPUT)
        imgui.tree_pop()
    end
end)
