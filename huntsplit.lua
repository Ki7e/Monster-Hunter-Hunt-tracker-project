
-- HuntSplit v0.2
-- Monster Hunter Wilds quest timer experiment

local function format_time(milliseconds)
    local total_seconds = math.floor(milliseconds / 1000)
    local minutes = math.floor(total_seconds / 60)
    local seconds = total_seconds % 60
    local centiseconds = math.floor(
        (milliseconds % 1000) / 10
    )

    return string.format(
        "%02d:%02d.%02d",
        minutes,
        seconds,
        centiseconds
    )
end

local function read_quest_time()
    local manager =
        sdk.get_managed_singleton("app.MissionManager")

    if not manager then
        return nil, "MissionManager unavailable"
    end

    local director = manager:get_field("_QuestDirector")

    if not director then
        return nil, "QuestDirector unavailable"
    end

    local milliseconds =
        director:call("get_QuestElapsedTimeMSec")

    return milliseconds, nil
end

re.on_draw_ui(function()
    imgui.text("HuntSplit v0.2")
    imgui.separator()

    local success, milliseconds, err =
        pcall(read_quest_time)

    if not success then
        imgui.text("Read error: " .. tostring(milliseconds))
        return
    end

    if milliseconds == nil then
        imgui.text(err or "Timer unavailable")
        return
    end

    imgui.text("Quest time: " .. format_time(milliseconds))
    imgui.text("Raw milliseconds: " .. tostring(milliseconds))
end)

log.info("[HuntSplit] Quest timer experiment loaded")
