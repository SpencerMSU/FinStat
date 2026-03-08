
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local az = require 'lib.arizona-events'
local mimgui = require 'mimgui'
local sampev = require 'samp.events'
local hasJson, json = pcall(require, 'dkjson')

local LOG_TAB_ID = 0
local STATS_TAB_ID = 15
local LOG_DIALOG_ID = 26230
local STATS_DIALOG_ID = 0
local BANK_DIALOG_ID = 159
local WINDOW_WIDTH = 1030
local WINDOW_HEIGHT = 550
local dayMap = {
    [u8:decode("Понедельник")] = 1,
    [u8:decode("Вторник")] = 2,
    [u8:decode("Среда")] = 3,
    [u8:decode("Четверг")] = 4,
    [u8:decode("Пятница")] = 5,
    [u8:decode("Суббота")] = 6,
    [u8:decode("Воскресенье")] = 7
}
local displayDays = {
    [1] = "Понедельник", [2] = "Вторник", [3] = "Среда",
    [4] = "Четверг", [5] = "Пятница", [6] = "Суббота", [7] = "Воскресенье"
}
local bizTypesTranslation = {
    ["fuel-station"] = "АЗС/Магазин механики",
    ["tuning shop"] = "Предприятие (Тюнинг)",
    ["clothes shop"] = "Магазин одежды",
    ["ammo"] = "Магазин оружия",
    ["24/7"] = "24/7",
    ["food-stall"] = "Закусочная",
    ["video cards"] = "Магазин видеокарт",
    ["bar"] = "Бар",
    ["strip-club"] = "Отель",
    ["accessories-store"] = "Магазин аксессуаров",
    ["bookmaker's office"] = "Букмекерская компания",
    ["water rental"] = "Аренда водного транспорта",
    ["rental of transport"] = "Аренда транспорта",
    ["concert hall"] = "Концертный зал",
    ["cinema"] = "Кинотеатр",
    ["repair shop"] = "Мастерская одежды",
    ["pharmacy"] = "Аптека",
    ["pet shop"] = "Зоомагазин",
    ["farm shop"] = "Фермерский магазин",
    ["auto service"] = "Автосервис",
    ["auto bazaar"] = "Автобазар",
    ["plane-bike-rent"] = "Парковочное место"
}

local themes = {
    Dark = {
        WindowBg = mimgui.ImVec4(0.10, 0.10, 0.10, 1.00),
        ChildBg = mimgui.ImVec4(0.14, 0.14, 0.14, 1.00),
        PopupBg = mimgui.ImVec4(0.12, 0.12, 0.12, 1.00),
        Border = mimgui.ImVec4(0.43, 0.43, 0.50, 0.50),
        BorderShadow = mimgui.ImVec4(0.00, 0.00, 0.00, 0.00),
        FrameBg = mimgui.ImVec4(0.20, 0.20, 0.20, 1.00),
        FrameBgHovered = mimgui.ImVec4(0.30, 0.30, 0.30, 1.00),
        FrameBgActive = mimgui.ImVec4(0.25, 0.25, 0.25, 1.00),
        TitleBg = mimgui.ImVec4(0.10, 0.10, 0.10, 1.00),
        TitleBgActive = mimgui.ImVec4(0.10, 0.10, 0.10, 1.00),
        TitleBgCollapsed = mimgui.ImVec4(0.00, 0.00, 0.00, 0.51),
        MenuBarBg = mimgui.ImVec4(0.14, 0.14, 0.14, 1.00),
        ScrollbarBg = mimgui.ImVec4(0.02, 0.02, 0.02, 0.53),
        ScrollbarGrab = mimgui.ImVec4(0.31, 0.31, 0.31, 1.00),
        ScrollbarGrabHovered = mimgui.ImVec4(0.41, 0.41, 0.41, 1.00),
        ScrollbarGrabActive = mimgui.ImVec4(0.51, 0.51, 0.51, 1.00),
        CheckMark = mimgui.ImVec4(0.26, 0.59, 0.98, 1.00),
        SliderGrab = mimgui.ImVec4(0.24, 0.52, 0.88, 1.00),
        SliderGrabActive = mimgui.ImVec4(0.26, 0.59, 0.98, 1.00),
        Button = mimgui.ImVec4(0.20, 0.20, 0.20, 1.00),
        ButtonHovered = mimgui.ImVec4(0.28, 0.28, 0.28, 1.00),
        ButtonActive = mimgui.ImVec4(0.18, 0.18, 0.18, 1.00),
        Header = mimgui.ImVec4(0.26, 0.59, 0.98, 0.31),
        HeaderHovered = mimgui.ImVec4(0.26, 0.59, 0.98, 0.80),
        HeaderActive = mimgui.ImVec4(0.26, 0.59, 0.98, 1.00),
        Separator = mimgui.ImVec4(0.43, 0.43, 0.50, 0.50),
        SeparatorHovered = mimgui.ImVec4(0.10, 0.40, 0.75, 0.78),
        SeparatorActive = mimgui.ImVec4(0.10, 0.40, 0.75, 1.00),
        ResizeGrip = mimgui.ImVec4(0.26, 0.59, 0.98, 0.25),
        ResizeGripHovered = mimgui.ImVec4(0.26, 0.59, 0.98, 0.67),
        ResizeGripActive = mimgui.ImVec4(0.26, 0.59, 0.98, 0.95),
        Tab = mimgui.ImVec4(0.18, 0.35, 0.58, 0.86),
        TabHovered = mimgui.ImVec4(0.26, 0.59, 0.98, 0.80),
        TabActive = mimgui.ImVec4(0.20, 0.41, 0.68, 1.00),
        TabUnfocused = mimgui.ImVec4(0.07, 0.10, 0.15, 0.97),
        TabUnfocusedActive = mimgui.ImVec4(0.14, 0.26, 0.42, 1.00),
        Text = mimgui.ImVec4(1.00, 1.00, 1.00, 1.00),
        TextDisabled = mimgui.ImVec4(0.50, 0.50, 0.50, 1.00),
    },
    Light = {
        WindowBg = mimgui.ImVec4(0.95, 0.95, 0.95, 1.00),
        ChildBg = mimgui.ImVec4(1.00, 1.00, 1.00, 1.00),
        PopupBg = mimgui.ImVec4(1.00, 1.00, 1.00, 0.98),
        Border = mimgui.ImVec4(0.60, 0.60, 0.60, 1.00),
        BorderShadow = mimgui.ImVec4(0.00, 0.00, 0.00, 0.00),
        FrameBg = mimgui.ImVec4(0.90, 0.90, 0.90, 1.00),
        FrameBgHovered = mimgui.ImVec4(0.85, 0.85, 0.85, 1.00),
        FrameBgActive = mimgui.ImVec4(0.80, 0.80, 0.80, 1.00),
        TitleBg = mimgui.ImVec4(0.95, 0.95, 0.95, 1.00),
        TitleBgActive = mimgui.ImVec4(0.90, 0.90, 0.90, 1.00),
        TitleBgCollapsed = mimgui.ImVec4(1.00, 1.00, 1.00, 0.51),
        MenuBarBg = mimgui.ImVec4(0.86, 0.86, 0.86, 1.00),
        ScrollbarBg = mimgui.ImVec4(0.90, 0.90, 0.90, 0.53),
        ScrollbarGrab = mimgui.ImVec4(0.60, 0.60, 0.60, 0.80),
        ScrollbarGrabHovered = mimgui.ImVec4(0.40, 0.40, 0.40, 0.80),
        ScrollbarGrabActive = mimgui.ImVec4(0.40, 0.40, 0.40, 1.00),
        CheckMark = mimgui.ImVec4(0.26, 0.59, 0.98, 1.00),
        SliderGrab = mimgui.ImVec4(0.26, 0.59, 0.98, 0.78),
        SliderGrabActive = mimgui.ImVec4(0.46, 0.54, 0.80, 0.60),
        Button = mimgui.ImVec4(0.80, 0.80, 0.80, 1.00),
        ButtonHovered = mimgui.ImVec4(0.70, 0.70, 0.70, 1.00),
        ButtonActive = mimgui.ImVec4(0.60, 0.60, 0.60, 1.00),
        Header = mimgui.ImVec4(0.26, 0.59, 0.98, 0.31),
        HeaderHovered = mimgui.ImVec4(0.26, 0.59, 0.98, 0.80),
        HeaderActive = mimgui.ImVec4(0.26, 0.59, 0.98, 1.00),
        Separator = mimgui.ImVec4(0.39, 0.39, 0.39, 0.62),
        SeparatorHovered = mimgui.ImVec4(0.14, 0.44, 0.80, 0.78),
        SeparatorActive = mimgui.ImVec4(0.14, 0.44, 0.80, 1.00),
        ResizeGrip = mimgui.ImVec4(0.80, 0.80, 0.80, 0.56),
        ResizeGripHovered = mimgui.ImVec4(0.26, 0.59, 0.98, 0.67),
        ResizeGripActive = mimgui.ImVec4(0.26, 0.59, 0.98, 0.95),
        Tab = mimgui.ImVec4(0.85, 0.85, 0.85, 1.00),
        TabHovered = mimgui.ImVec4(0.26, 0.59, 0.98, 0.80),
        TabActive = mimgui.ImVec4(0.60, 0.73, 0.88, 1.00),
        TabUnfocused = mimgui.ImVec4(0.92, 0.93, 0.94, 0.99),
        TabUnfocusedActive = mimgui.ImVec4(0.74, 0.82, 0.91, 1.00),
        Text = mimgui.ImVec4(0.10, 0.10, 0.10, 1.00),
        TextDisabled = mimgui.ImVec4(0.40, 0.40, 0.40, 1.00),
    },
    Cheese = {
        WindowBg = mimgui.ImVec4(0.18, 0.12, 0.03, 1.00),
        ChildBg = mimgui.ImVec4(0.22, 0.15, 0.04, 1.00),
        PopupBg = mimgui.ImVec4(0.20, 0.14, 0.03, 0.98),
        Border = mimgui.ImVec4(0.40, 0.25, 0.05, 1.00),
        BorderShadow = mimgui.ImVec4(0.00, 0.00, 0.00, 0.00),
        FrameBg = mimgui.ImVec4(0.30, 0.20, 0.05, 1.00),
        FrameBgHovered = mimgui.ImVec4(0.35, 0.25, 0.08, 1.00),
        FrameBgActive = mimgui.ImVec4(0.40, 0.30, 0.10, 1.00),
        TitleBg = mimgui.ImVec4(0.18, 0.12, 0.03, 1.00),
        TitleBgActive = mimgui.ImVec4(0.22, 0.15, 0.04, 1.00),
        TitleBgCollapsed = mimgui.ImVec4(0.18, 0.12, 0.03, 0.51),
        MenuBarBg = mimgui.ImVec4(0.22, 0.15, 0.04, 1.00),
        ScrollbarBg = mimgui.ImVec4(0.10, 0.08, 0.02, 0.53),
        ScrollbarGrab = mimgui.ImVec4(0.40, 0.25, 0.05, 0.80),
        ScrollbarGrabHovered = mimgui.ImVec4(0.50, 0.35, 0.08, 0.80),
        ScrollbarGrabActive = mimgui.ImVec4(0.60, 0.45, 0.10, 1.00),
        CheckMark = mimgui.ImVec4(1.00, 0.80, 0.00, 1.00),
        SliderGrab = mimgui.ImVec4(0.40, 0.25, 0.05, 0.78),
        SliderGrabActive = mimgui.ImVec4(0.60, 0.45, 0.10, 0.60),
        Button = mimgui.ImVec4(0.40, 0.25, 0.05, 1.00),
        ButtonHovered = mimgui.ImVec4(0.50, 0.35, 0.08, 1.00),
        ButtonActive = mimgui.ImVec4(0.60, 0.45, 0.10, 1.00),
        Header = mimgui.ImVec4(0.40, 0.25, 0.05, 0.31),
        HeaderHovered = mimgui.ImVec4(0.40, 0.25, 0.05, 0.80),
        HeaderActive = mimgui.ImVec4(0.40, 0.25, 0.05, 1.00),
        Separator = mimgui.ImVec4(0.40, 0.25, 0.05, 0.62),
        SeparatorHovered = mimgui.ImVec4(0.50, 0.35, 0.08, 0.78),
        SeparatorActive = mimgui.ImVec4(0.50, 0.35, 0.08, 1.00),
        ResizeGrip = mimgui.ImVec4(0.40, 0.25, 0.05, 0.56),
        ResizeGripHovered = mimgui.ImVec4(0.50, 0.35, 0.08, 0.67),
        ResizeGripActive = mimgui.ImVec4(0.50, 0.35, 0.08, 0.95),
        Tab = mimgui.ImVec4(0.30, 0.20, 0.05, 1.00),
        TabHovered = mimgui.ImVec4(0.40, 0.25, 0.05, 0.80),
        TabActive = mimgui.ImVec4(0.50, 0.35, 0.08, 1.00),
        TabUnfocused = mimgui.ImVec4(0.25, 0.18, 0.04, 0.97),
        TabUnfocusedActive = mimgui.ImVec4(0.30, 0.20, 0.05, 1.00),
        Text = mimgui.ImVec4(1.00, 1.00, 0.90, 1.00),
        TextDisabled = mimgui.ImVec4(0.60, 0.60, 0.50, 1.00),
    }
}
local customColors = {
    Dark = {
        Green = mimgui.ImVec4(0.4, 1.0, 0.4, 1.0),
        Red = mimgui.ImVec4(1.0, 0.4, 0.4, 1.0),
        Orange = mimgui.ImVec4(1.0, 0.8, 0.2, 1.0),
        Gray = mimgui.ImVec4(0.5, 0.5, 0.5, 1.0),
        LightGray = mimgui.ImVec4(0.7, 0.7, 0.7, 1.0)
    },
    Light = {
        Green = mimgui.ImVec4(0.0, 0.6, 0.0, 1.0),
        Red = mimgui.ImVec4(0.8, 0.1, 0.1, 1.0),
        Orange = mimgui.ImVec4(0.8, 0.5, 0.0, 1.0),
        Gray = mimgui.ImVec4(0.4, 0.4, 0.4, 1.0),
        LightGray = mimgui.ImVec4(0.5, 0.5, 0.5, 1.0)
    },
    Cheese = {
        Green = mimgui.ImVec4(0.0, 0.6, 0.0, 1.0),
        Red = mimgui.ImVec4(0.8, 0.1, 0.1, 1.0),
        Orange = mimgui.ImVec4(0.9, 0.5, 0.0, 1.0),
        Gray = mimgui.ImVec4(0.4, 0.3, 0.2, 1.0),
        LightGray = mimgui.ImVec4(0.6, 0.5, 0.4, 1.0)
    }
}

local showFinStat = mimgui.new.bool(false)
local activeTab = 1
local bizList = {}
local currentBiz = nil
local cefCaptureActive = false
local cefCaptureDeadline = 0
local cefLastText = ''
local cefLastJson = nil
local cefBusinessesViewSeen = false
local autoCloseCef = false
local lastCefPacketTime = 0
local debugCef = mimgui.new.bool(false)
local operationsLog = {}
local bizDataCache = {}
local bizBalances = {}
local uiBankAmount = mimgui.new.int(0)
local logButtonId = LOG_TAB_ID
local selectedBizIndex = mimgui.new.int(0)
local tableWidthsInitialized = {}
local activeDialogContext = nil
local lastScanResults = {}
local cachedNick = nil
local lastNickCheck = 0
local mainWinPos = mimgui.ImVec2(0, 0)
local mainWinSize = mimgui.ImVec2(WINDOW_WIDTH, WINDOW_HEIGHT)

local processOverlay = {
    active = false, total = 0, current = 0, text = "", cancelFunc = nil
}


local autoState = {
    mode = 'idle',     
    bizId = nil,
    awaiting = nil,
    eventReceived = false,
    cancelRequested = false,
    bankMode = nil,
    bankAmount = 0,
    bankTargetBizId = nil,
}


local masterFile = getWorkingDirectory() .. '\\config\\FinancialStatistics.json'
local settings = { theme = 'Dark', preservation = 'Adaptive', widths = {} }


local function trim(text)
    if not text then return "" end
    return text:match("^%s*(.-)%s*$")
end
local function parseNumber(str)
    if not str then return nil end
    local clean = str:gsub("[%s,]", "")
    return tonumber(clean)
end
local function formatNumber(n)
    if not n then return "0" end
    n = tonumber(n)
    if not n then return "0" end
    local s = tostring(n)
    local k
    while true do
        s, k = string.gsub(s, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return s
end
local function getMyNick()
    if os.clock() - lastNickCheck > 2.0 then
        if isSampAvailable() then
            local res, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            if res then cachedNick = sampGetPlayerNickname(id) end
        end
        lastNickCheck = os.clock()
    end
    return cachedNick
end
local function getColor(name)
    local t = settings.theme or 'Dark'
    if not customColors[t] then t = 'Dark' end
    return customColors[t][name] or customColors.Dark[name]
end
local function applyTheme()
    local style = mimgui.GetStyle()
    local theme = themes[settings.theme] or themes.Dark
    style.WindowRounding = 10.0
    style.ChildRounding = 8.0
    style.FrameRounding = 6.0
    style.PopupRounding = 8.0
    style.ScrollbarRounding = 6.0
    style.GrabRounding = 6.0
    style.TabRounding = 6.0
    style.FrameBorderSize = 1.0
    if theme then
        for k, v in pairs(theme) do
            if mimgui.Col[k] then style.Colors[mimgui.Col[k]] = v end
        end
    end
end
local function compactForUi(text, limit)
    limit = limit or 700
    if not text then return '' end
    text = text:gsub("\r", ""):gsub("\n", " ")
    if #text > limit then return text:sub(1, limit) .. '...' end
    return text
end
local function tableCount(t)
    local c = 0
    for _ in pairs(t) do c = c + 1 end
    return c
end


local function saveMasterData()
    if not hasJson then return end
    local file = io.open(masterFile, 'w')
    if file then
        local data = { settings = settings, businesses = bizList, operations = operationsLog }
        file:write(json.encode(data, { indent = true }))
        file:close()
    end
end
local function loadMasterData()
    if not hasJson then return end
    local file = io.open(masterFile, 'r')
    if file then
        local content = file:read('*a')
        file:close()
        local data = json.decode(content)
        if type(data) == 'table' then
            if data.settings and type(data.settings) == 'table' then
                if data.settings.theme then settings.theme = data.settings.theme end
                if data.settings.preservation then settings.preservation = data.settings.preservation end
                if data.settings.widths and type(data.settings.widths) == 'table' then settings.widths = data.settings.widths end
            end
            if data.businesses and type(data.businesses) == 'table' then bizList = data.businesses else bizList = {} end
            if data.operations and type(data.operations) == 'table' then operationsLog = data.operations else operationsLog = {} end
        end
    end
end


local function sendCefEvent(str, serverId)
    serverId = serverId or 0
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #str)
    for i = 1, #str do
        raknetBitStreamWriteInt8(bs, string.byte(str, i))
    end
    raknetBitStreamWriteInt32(bs, serverId)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
    if debugCef[0] then
        print(string.format("[FinStat] Auto-click sent: %s (ID: %d)", str, serverId))
    end
end


local function signalEvent(name)
    if autoState.awaiting == name then
        autoState.eventReceived = true
    end
end

local function waitForEvent(name, timeoutSec)
    autoState.awaiting = name
    autoState.eventReceived = false
    local deadline = os.clock() + (timeoutSec or 10)
    while not autoState.eventReceived and os.clock() < deadline do
        if autoState.cancelRequested then return false end
        wait(15)
    end
    local ok = autoState.eventReceived
    autoState.awaiting = nil
    autoState.eventReceived = false
    return ok
end
local function isAutomationBusy()
    return autoState.mode ~= 'idle'
end
local function resetAutoState()
    autoState.mode = 'idle'
    autoState.bizId = nil
    autoState.awaiting = nil
    autoState.eventReceived = false
    autoState.cancelRequested = false
    autoState.bankMode = nil
    autoState.bankAmount = 0
    autoState.bankTargetBizId = nil
end

local function normalizeBizItem(item)
    if type(item) ~= 'table' then return nil end
    local out = {}
    out.id = tonumber(item.id or item.bizId or item.number or item.biz_id)
    out.rating = tonumber(item.rank or item.rating or item.stars or item.level)
    local rawType = item.type or item.name or item.title
    if rawType and bizTypesTranslation[rawType:lower()] then
        out.type = bizTypesTranslation[rawType:lower()]
    else
        out.type = rawType
    end
    if type(item.stats) == 'table' then
        local iter = ipairs
        if #item.stats == 0 then iter = pairs end
        for _, stat in iter(item.stats) do
            local val = tostring(stat.value or "")
            local labelRaw = tostring(stat.label or "")
            local labelLower = labelRaw:lower()
            local cleanVal = val:gsub("[%s,%%$]", "")
            local function isLabel(patterns)
                for _, pat in ipairs(patterns) do
                    if labelRaw:find(pat) or labelLower:find(pat) then return true end
                end
                return false
            end
            if isLabel({"налог", "tax", "\xCD\xE0\xEB\xEE\xE3"}) then
                local t, tm = cleanVal:match("^(%d+)/(%d+)$")
                if t and tm then out.tax = t; out.taxMax = tm end
            elseif isLabel({"банк", "bank", "баланс", "balance", "\xC1\xE0\xED\xEA", "\xD0\x91\xD0\xB0\xD0\xBD\xD0\xBA"}) then
                local b = cleanVal:match("^(-?%d+)$")
                if b then out.bank = b end
            elseif isLabel({"прибыль", "profit", "\xCF\xF0\xE8\xE1\xFB\xEB\xFC", "\xD0\x9F\xD1\x80\xD0\xB8\xD0\xB1"}) then
                local p = cleanVal:match("^(-?%d+)$")
                if p then out.profitToday = p end
            elseif isLabel({"занятость", "occupancy", "\xC7\xE0\xED\xFF\xF2\xEE\xF1\xF2\xFC"}) then
                local oc, om = cleanVal:match("^(%d+)/(%d+)$")
                if oc and om then out.occCur = tonumber(oc); out.occMax = tonumber(om) end
            else
                local v1, v2 = cleanVal:match("^(%d+)/(%d+)$")
                if v1 and v2 then
                    if val:find("%$") then
                        if not out.tax then out.tax = v1; out.taxMax = v2 end
                    else
                        if not out.occCur then out.occCur = tonumber(v1); out.occMax = tonumber(v2) end
                    end
                elseif cleanVal:match("^(-?%d+)$") then
                    local money = cleanVal:match("^(-?%d+)$")
                    if not out.bank then out.bank = money
                    elseif not out.profitToday then out.profitToday = money end
                end
            end
        end
    end
    if not out.occCur then
        local src = item
        if type(item.stats) == 'table' and item.stats.occCur then src = item.stats end
        local occCur = src.occCur or src.occupancyCur or src.occupancy
        if occCur then out.occCur = parseNumber(tostring(occCur)) end
        local occMax = src.occMax or src.occupancyMax or src.maxOccupancy
        if occMax then out.occMax = parseNumber(tostring(occMax)) end
    end
    return out
end

local function tryFillBizListFromJson(decoded, append)
    local list = nil
    if type(decoded) == 'table' then
        if #decoded == 1 and type(decoded[1]) == 'table' then list = decoded[1]
        elseif #decoded > 0 then list = decoded
        elseif type(decoded.businesses) == 'table' then list = decoded.businesses
        elseif type(decoded.items) == 'table' then list = decoded.items
        elseif type(decoded.data) == 'table' and type(decoded.data.businesses) == 'table' then list = decoded.data.businesses end
    end
    if type(list) ~= 'table' or #list == 0 then return false end
    local out = {}
    for _, it in ipairs(list) do
        local b = normalizeBizItem(it)
        if b then out[#out + 1] = b end
    end
    if #out == 0 then return false end
    if append then
        for _, v in ipairs(out) do
            if bizDataCache[v.id] then
                if not v.weekStats then v.weekStats = bizDataCache[v.id].weekStats end
                if not v.profitToday or v.profitToday == "0" or v.profitToday == 0 then v.profitToday = bizDataCache[v.id].profitToday end
                if not v.bank or v.bank == "0" or v.bank == 0 then v.bank = bizDataCache[v.id].bank end
            end
            local foundIdx = nil
            for i, existing in ipairs(bizList) do
                if existing.id == v.id then foundIdx = i; break end
            end
            if foundIdx then
                if bizList[foundIdx].weekStats and not v.weekStats then v.weekStats = bizList[foundIdx].weekStats end
                bizList[foundIdx] = v
            else
                table.insert(bizList, v)
            end
        end
    else
        for _, v in ipairs(out) do
            if bizDataCache[v.id] then
                if not v.weekStats then v.weekStats = bizDataCache[v.id].weekStats end
                if not v.profitToday or v.profitToday == "0" or v.profitToday == 0 then v.profitToday = bizDataCache[v.id].profitToday end
                if not v.bank or v.bank == "0" or v.bank == 0 then v.bank = bizDataCache[v.id].bank end
            end
        end
        bizList = out
    end
    tableWidthsInitialized = {}
    return true
end

local function triggerBizRefresh()
    currentBiz = nil
    cefLastText = ''
    cefLastJson = nil
    cefBusinessesViewSeen = false
    cefCaptureActive = true
    cefCaptureDeadline = os.clock() + 8.0
    autoCloseCef = true
    lastCefPacketTime = 0
    sampSendChat("/bizinfo")
end

local function startProfitScan()
    if isAutomationBusy() then return end
    lua_thread.create(function()
        autoState.mode = 'scan_profit'
        lastScanResults = {}
        processOverlay.active = true
        processOverlay.text = "Обновление списка..."
        processOverlay.total = 0
        processOverlay.current = 0
        processOverlay.cancelFunc = function() autoState.cancelRequested = true end

        cefBusinessesViewSeen = false
        cefCaptureActive = true
        cefCaptureDeadline = os.clock() + 15.0
        sampSendChat("/bizinfo")
        waitForEvent('pushItems', 10)
        wait(200)

        if autoState.cancelRequested then
            processOverlay.active = false
            resetAutoState()
            return
        end

        local targets = {}
        for _, b in ipairs(bizList) do
            local bType = b.type or ""
            local isParking = (bType == "Парковочное место") or (bType:lower():find("plane%-bike%-rent"))
            if not isParking then table.insert(targets, b) end
        end
        processOverlay.total = #targets
        processOverlay.text = "Сбор доп. прибыли..."

        for i, b in ipairs(targets) do
            if autoState.cancelRequested then break end
            processOverlay.current = i
            currentBiz = b
            lastScanResults[b.id] = {id = b.id, bank = b.bank, profitToday = b.profitToday}
            if debugCef[0] then sampAddChatMessage(string.format("[FinStat] Scan %d/%d: biz %d", i, #targets, b.id), 0xAAAAFF) end
            sendCefEvent("business.list.select|" .. b.id)
            local ok1 = waitForEvent('initBizInfo', 3)
            if ok1 then
                waitForEvent('detailsLoaded', 0.5)
            end
            sendCefEvent("business.info.exitlist")
            wait(150)
        end

        setVirtualKeyDown(27, true) wait(50) setVirtualKeyDown(27, false)
        cefCaptureActive = false
        processOverlay.active = false
        saveMasterData()
        resetAutoState()
    end)
end

local function startStatsScanSingle(bizId)
    if isAutomationBusy() then return end
    lua_thread.create(function()
        autoState.mode = 'scan_stats_single'
        autoState.bizId = bizId

        cefCaptureActive = true
        cefCaptureDeadline = os.clock() + 15.0
        cefBusinessesViewSeen = false
        sampSendChat("/bizinfo")
        waitForEvent('pushItems', 10)
        wait(50)

        sendCefEvent("business.list.select|" .. bizId)
        waitForEvent('initBizInfo', 10)
        wait(30)

        sendCefEvent("business.info.selectTab|" .. STATS_TAB_ID)
        waitForEvent('statsDialogParsed', 15)

        sendCefEvent("business.info.exitlist")
        wait(150)
        setVirtualKeyDown(27, true) wait(50) setVirtualKeyDown(27, false)
        

        cefCaptureActive = false
        resetAutoState()
    end)
end

local function startStatsScanAll()
    if isAutomationBusy() then return end
    lua_thread.create(function()
        autoState.mode = 'scan_stats_all'
        processOverlay.active = true
        processOverlay.text = "Сбор статистики..."
        processOverlay.total = #bizList
        processOverlay.current = 0
        processOverlay.cancelFunc = function() autoState.cancelRequested = true end

        cefCaptureActive = true
        cefCaptureDeadline = os.clock() + 60.0
        sampSendChat("/bizinfo")
        waitForEvent('pushItems', 10)
        wait(200)

        for idx, b in ipairs(bizList) do
            if autoState.cancelRequested or not processOverlay.active then break end
            processOverlay.current = idx
            autoState.bizId = b.id
            currentBiz = b
            lastScanResults[b.id] = {id = b.id, bank = b.bank, profitToday = b.profitToday}
            b.weekStats = nil

            cefCaptureActive = true
            cefCaptureDeadline = os.clock() + 20.0

            sendCefEvent("business.list.select|" .. b.id)
            local ok1 = waitForEvent('initBizInfo', 3)
            if ok1 then
                sendCefEvent("business.info.selectTab|" .. STATS_TAB_ID)
                local ok = waitForEvent('statsDialogParsed', 3)
                if not ok and processOverlay.active then
                    sampSendDialogResponse(0, 0, 0, "")
                    wait(50)
                end
            end

            sendCefEvent("business.info.exitlist")
            wait(150)
        end

        setVirtualKeyDown(27, true) wait(50) setVirtualKeyDown(27, false)
        cefCaptureActive = false
        processOverlay.active = false
        resetAutoState()
    end)
end

local function startLogScan(targets)
    if isAutomationBusy() then return end
    lua_thread.create(function()
        autoState.mode = 'scan_log'
        processOverlay.active = true
        processOverlay.text = "Скачивание журнала..."
        processOverlay.total = #targets
        processOverlay.current = 0
        processOverlay.cancelFunc = function() autoState.cancelRequested = true end

        cefCaptureActive = true
        cefCaptureDeadline = os.clock() + 60.0
        sampSendChat("/bizinfo")
        waitForEvent('pushItems', 10)
        wait(200)

        local originalBiz = currentBiz
        for i, biz in ipairs(targets) do
            if autoState.cancelRequested or not processOverlay.active then break end
            processOverlay.current = i
            autoState.bizId = biz.id
            currentBiz = biz

            sendCefEvent("business.list.select|" .. biz.id)
            local ok1 = waitForEvent('initBizInfo', 3)
            if ok1 then
                sendCefEvent("business.info.selectTab|" .. logButtonId)
                local ok = waitForEvent('logDialogParsed', 5)
                if not ok and processOverlay.active then
                    sampSendDialogResponse(LOG_DIALOG_ID, 0, -1, "")
                end
            end

            sendCefEvent("business.info.exitlist")
            wait(150)
        end
        setVirtualKeyDown(27, true) wait(50) setVirtualKeyDown(27, false)
        currentBiz = originalBiz
        cefCaptureActive = false
        processOverlay.active = false
        resetAutoState()
    end)
end

local function startBankOperation(mode, bizId, amount)
    if isAutomationBusy() then return end

    local queue = {}
    if bizId == 0 then
        for _, b in ipairs(bizList) do table.insert(queue, b.id) end
    else
        table.insert(queue, bizId)
    end
    if #queue == 0 then return end

    lua_thread.create(function()
        autoState.mode = 'bank'
        autoState.bankMode = mode
        autoState.bankAmount = amount
        processOverlay.active = true
        processOverlay.text = (mode == 'withdraw' and "Снятие средств..." or "Пополнение...")
        processOverlay.total = #queue
        processOverlay.current = 0
        processOverlay.cancelFunc = function() autoState.cancelRequested = true end

        cefCaptureActive = true
        cefCaptureDeadline = os.clock() + 30.0
        cefBusinessesViewSeen = false

        sampSendChat("/bizinfo")
        waitForEvent('pushItems', 10)
        wait(200)

        for i, bid in ipairs(queue) do
            if autoState.cancelRequested then break end
            processOverlay.current = i
            autoState.bankTargetBizId = bid

            sendCefEvent("business.list.select|" .. bid)
            local ok1 = waitForEvent('initBizInfo', 3)
            if ok1 then
                if mode == 'withdraw' then
                    sendCefEvent("business.info.widthdraw")
                else
                    sendCefEvent("business.info.deposit")
                end
                waitForEvent('bankDialogDone', 5)
            end

            sendCefEvent("business.info.exitlist")
            wait(150)
        end

        setVirtualKeyDown(27, true) wait(50) setVirtualKeyDown(27, false)
        cefCaptureActive = false
        processOverlay.active = false
        resetAutoState()

    end)
end
local function LoadingSpinner(radius, thickness, color)
    local window = mimgui.GetWindowDrawList()
    local p = mimgui.GetCursorScreenPos()
    local x, y = p.x + radius, p.y + radius
    local time = os.clock() * 10
    for i = 0, 30 do
        local alpha = i / 30
        local ang_start = time + (i * 0.15)
        local ang_end = time + ((i + 1) * 0.15)
        local colVec = mimgui.ColorConvertU32ToFloat4(color)
        local col = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(colVec.x, colVec.y, colVec.z, alpha))
        window:PathClear()
        window:PathArcTo(mimgui.ImVec2(x, y), radius, ang_start, ang_end, 10)
        window:PathStroke(col, 0, thickness)
    end
    mimgui.Dummy(mimgui.ImVec2(radius * 2, radius * 2))
end

local function buildBizComboItems(allLabel)
    local items = {}
    table.insert(items, allLabel or "Все бизнесы")
    for v in ipairs(bizList) do
        table.insert(items, string.format("%s [ID:%d]", bizList[v].type, bizList[v].id))
    end
    if selectedBizIndex[0] >= #items then selectedBizIndex[0] = 0 end
    return items
end

local function tryRestoreColumnWidths(tableName, colCount)
    if tableWidthsInitialized[tableName] then return true end
    if settings.preservation == 'Permanent' and settings.widths[tableName] and #settings.widths[tableName] == colCount then
        for i = 1, colCount do mimgui.SetColumnWidth(i - 1, settings.widths[tableName][i]) end
        tableWidthsInitialized[tableName] = true
        return true
    end
    return false
end

local function persistColumnWidths(tableName, colCount)
    if settings.preservation ~= 'Permanent' then return end
    if not settings.widths[tableName] then settings.widths[tableName] = {} end
    for i = 1, colCount do settings.widths[tableName][i] = mimgui.GetColumnWidth(i - 1) end
end

local function HelpMarker(id, title, desc)
    mimgui.SameLine()
    mimgui.PushStyleColor(mimgui.Col.Button, mimgui.ImVec4(0.5, 0.5, 0.5, 0.5))
    mimgui.PushStyleVarFloat(mimgui.StyleVar.FrameRounding, 10.0)
    if mimgui.Button("?##" .. id, mimgui.ImVec2(20, 20)) then
        mimgui.OpenPopup("HelpPopup_" .. id)
    end
    mimgui.PopStyleVar()
    mimgui.PopStyleColor()
    if mimgui.BeginPopup("HelpPopup_" .. id) then
        mimgui.TextColored(getColor('Green'), title)
        mimgui.Separator()
        mimgui.Text(desc)
        mimgui.EndPopup()
    end
end


local function drawBizTable(list, tableName, showOccupancy, showProfit)
    if #list == 0 then return end
    local colCount = 4 + (showOccupancy and 1 or 0) + (showProfit and 1 or 0)
    if not mimgui.Columns then return end
    mimgui.Columns(colCount, tableName, true)
    if not tryRestoreColumnWidths(tableName, colCount) then
        local widths = {}
        for i = 1, colCount do widths[i] = 20.0 end
        local headers = {"Крутость", "Бизнес"}
        if showOccupancy then table.insert(headers, "Занятость") end
        table.insert(headers, "Налог"); table.insert(headers, "Банк")
        if showProfit then table.insert(headers, "Прибыль сегодня") end
        for i, h in ipairs(headers) do
            local w = mimgui.CalcTextSize(h).x + 15.0
            if w > widths[i] then widths[i] = w end
        end
        local seenCalc = {}
        for _, biz in ipairs(list) do
            if not seenCalc[biz.id] then
                seenCalc[biz.id] = true
                local colIdx = 1
                local w = mimgui.CalcTextSize(tostring(biz.rating or "-")).x + 15.0
                if w > widths[colIdx] then widths[colIdx] = w end; colIdx = colIdx + 1
                w = mimgui.CalcTextSize(string.format("%s №%s", biz.type or "?", biz.id or "?")).x + 30.0
                if w > widths[colIdx] then widths[colIdx] = w end; colIdx = colIdx + 1
                if showOccupancy then
                    local txt = biz.occCur and biz.occMax and string.format("%d / (%d)", biz.occCur, biz.occMax) or "-"
                    w = mimgui.CalcTextSize(txt).x + 15.0
                    if w > widths[colIdx] then widths[colIdx] = w end; colIdx = colIdx + 1
                end
                local txt = string.format("$ %s / $ %s", formatNumber(biz.tax), formatNumber(biz.taxMax))
                w = mimgui.CalcTextSize(txt).x + 15.0
                if w > widths[colIdx] then widths[colIdx] = w end; colIdx = colIdx + 1
                txt = string.format("$ %s", formatNumber(biz.bank))
                w = mimgui.CalcTextSize(txt).x + 15.0
                if w > widths[colIdx] then widths[colIdx] = w end; colIdx = colIdx + 1
                if showProfit then
                    local todayProfit = 0
                    if biz.profitToday then todayProfit = parseNumber(biz.profitToday) or 0
                    elseif biz.weekStats and #biz.weekStats > 0 then todayProfit = parseNumber(biz.weekStats[#biz.weekStats].money) or 0 end
                    if todayProfit > 0 then txt = "+$ " .. formatNumber(todayProfit)
                    elseif todayProfit < 0 then txt = "-$ " .. formatNumber(math.abs(todayProfit))
                    else txt = "$ 0" end
                    w = mimgui.CalcTextSize(txt).x + 15.0
                    if w > widths[colIdx] then widths[colIdx] = w end
                end
            end
        end
        for i = 1, colCount do mimgui.SetColumnWidth(i - 1, widths[i]) end
        tableWidthsInitialized[tableName] = true
    end
    persistColumnWidths(tableName, colCount)
    mimgui.Text("Крутость"); mimgui.NextColumn()
    mimgui.Text("Бизнес"); mimgui.NextColumn()
    if showOccupancy then mimgui.Text("Занятость"); mimgui.NextColumn() end
    mimgui.Text("Налог"); mimgui.NextColumn()
    mimgui.Text("Банк"); mimgui.NextColumn()
    if showProfit then mimgui.Text("Прибыль сегодня"); mimgui.NextColumn() end
    mimgui.Separator()
    local seen = {}
    for _, biz in ipairs(list) do
        if not seen[biz.id] then
            seen[biz.id] = true
            mimgui.Text(tostring(biz.rating or "-")); mimgui.NextColumn()
            mimgui.Text(string.format("%s №%s", biz.type or "?", biz.id or "?")); mimgui.NextColumn()
            if showOccupancy then
                if biz.occCur and biz.occMax then mimgui.Text(string.format("%d / (%d)", biz.occCur, biz.occMax))
                else mimgui.Text("-") end
                mimgui.NextColumn()
            end
            local tVal = parseNumber(biz.tax) or 0
            local taxStr = string.format("$ %s / $ %s", formatNumber(biz.tax), formatNumber(biz.taxMax))
            if tVal > 50000 then mimgui.TextColored(getColor('Red'), taxStr) else mimgui.Text(taxStr) end
            mimgui.NextColumn()
            mimgui.Text(string.format("$ %s", formatNumber(biz.bank))); mimgui.NextColumn()
            if showProfit then
                local todayProfit = 0
                if biz.profitToday then todayProfit = parseNumber(biz.profitToday) or 0
                elseif biz.weekStats and #biz.weekStats > 0 then todayProfit = parseNumber(biz.weekStats[#biz.weekStats].money) or 0 end
                if todayProfit > 0 then mimgui.TextColored(getColor('Green'), "+$ " .. formatNumber(todayProfit))
                elseif todayProfit < 0 then mimgui.TextColored(getColor('Red'), "-$ " .. formatNumber(math.abs(todayProfit)))
                else mimgui.TextDisabled("$ 0") end
                mimgui.NextColumn()
            end
        end
    end
    mimgui.Columns(1)
end

local function DrawCheeseBg()
    if settings.theme ~= 'Cheese' then return end
    local drawList = mimgui.GetWindowDrawList()
    local winPos = mimgui.GetWindowPos()
    local winSize = mimgui.GetWindowSize()
    local col = mimgui.ColorConvertFloat4ToU32(mimgui.ImVec4(0.12, 0.08, 0.02, 0.6))
    local cellSize = 80
    local cols = math.ceil(winSize.x / cellSize) + 1
    local rows = math.ceil(winSize.y / cellSize) + 1
    for i = 0, cols do
        for j = 0, rows do
            local seed = i * 12.9898 + j * 78.233
            local val1 = math.sin(seed) * 43758.5453; val1 = val1 - math.floor(val1)
            local val2 = math.sin(seed + 1.0) * 43758.5453; val2 = val2 - math.floor(val2)
            local val3 = math.sin(seed + 2.0) * 43758.5453; val3 = val3 - math.floor(val3)
            local r = 5 + (val1 * 30)
            local cx = winPos.x + (i * cellSize) - (cellSize / 2) + (val2 * cellSize)
            local cy = winPos.y + (j * cellSize) - (cellSize / 2) + (val3 * cellSize)
            drawList:AddCircleFilled(mimgui.ImVec2(cx, cy), r, col)
        end
    end
end

local function DrawSidebar()
    mimgui.BeginChild("SideBar", mimgui.ImVec2(180, 0), true)
    local tabs = {
        {id = 1, label = "Статистика"}, {id = 2, label = "Бизнесы"},
        {id = 3, label = "Финансы"},     {id = 4, label = "Журнал"},
        {id = 5, label = "Патчноуты"},   {id = 6, label = "Настройки"},
        {id = 7, label = "Обновить данные"}
    }
    for _, tab in ipairs(tabs) do
        local isSelected = (activeTab == tab.id)
        if isSelected then mimgui.PushStyleColor(mimgui.Col.Button, mimgui.GetStyle().Colors[mimgui.Col.ButtonActive]) end
        if mimgui.Button(tab.label, mimgui.ImVec2(165, 40)) then
            if tab.id == 7 then triggerBizRefresh()
            else activeTab = tab.id; saveMasterData() end
        end
        if isSelected then mimgui.PopStyleColor() end
        mimgui.Dummy(mimgui.ImVec2(0, 5))
    end
    mimgui.SetCursorPosY(mimgui.GetWindowHeight() - 30)
    mimgui.Text("by @SpencerMSU")
    mimgui.EndChild()
end

local function DrawStatsTab()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    if #bizList == 0 then
        mimgui.TextColored(getColor('Gray'), "Нет данных. Нажмите 'Обновить данные'.")
        if cefCaptureActive then mimgui.TextColored(getColor('Orange'), "Ожидание данных от сервера...") end
        return
    end
    local regularBiz, parkingBiz = {}, {}
    for _, b in ipairs(bizList) do
        local t = b.type or ""
        if t == "Парковочное место" or t:lower() == "plane-bike-rent" then table.insert(parkingBiz, b)
        else table.insert(regularBiz, b) end
    end
    if #regularBiz > 0 then
        mimgui.Text("Мои бизнесы:")
        mimgui.SameLine()
        local avail = mimgui.GetContentRegionAvail().x
        local btnText = "Получить прибыль"
        local btnW = mimgui.CalcTextSize(btnText).x + 20
        mimgui.SetCursorPosX(mimgui.GetCursorPosX() + avail - btnW - 5)
        if mimgui.Button(btnText, mimgui.ImVec2(btnW, 25)) then startProfitScan() end
        drawBizTable(regularBiz, "MainBizTable", true, true)
    end
    if #parkingBiz > 0 then
        mimgui.Dummy(mimgui.ImVec2(0, 15)); mimgui.Separator(); mimgui.Dummy(mimgui.ImVec2(0, 5))
        mimgui.Text("Парковочные места:")
        drawBizTable(parkingBiz, "ParkingTable", false, true)
    end
    mimgui.Dummy(mimgui.ImVec2(0, 20)); mimgui.Separator(); mimgui.Dummy(mimgui.ImVec2(0, 10))
    local totalBank = 0
    for _, b in ipairs(bizList) do if b.bank then totalBank = totalBank + (parseNumber(b.bank) or 0) end end
    mimgui.PushStyleColor(mimgui.Col.ChildBg, mimgui.ImVec4(0.2, 0.35, 0.2, 0.6))
    mimgui.BeginChild("TotalBankBox", mimgui.ImVec2(0, 50), true)
    mimgui.SetCursorPosY(15)
    mimgui.Text("Общий баланс всех бизнесов: "); mimgui.SameLine()
    mimgui.SetWindowFontScale(1.2)
    mimgui.TextColored(getColor('Green'), "$ " .. formatNumber(totalBank))
    mimgui.SetWindowFontScale(1.0)
    mimgui.EndChild()
    mimgui.PopStyleColor()
end

local function DrawBizTab()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.Text("Выбор бизнеса для просмотра финансов:")
    if #bizList == 0 then
        mimgui.TextColored(getColor('Red'), "Сначала нажмите 'Обновить данные' слева!"); return
    end
    local items = buildBizComboItems("Все бизнесы (Суммарно)")
    mimgui.PushItemWidth(300)
    if mimgui.BeginCombo("##bizSelector", items[selectedBizIndex[0] + 1] or "Выберите бизнес") then
        for i, item in ipairs(items) do
            local isSel = (selectedBizIndex[0] == i - 1)
            if mimgui.Selectable(item, isSel) then selectedBizIndex[0] = i - 1 end
            if isSel then mimgui.SetItemDefaultFocus() end
        end
        mimgui.EndCombo()
    end
    mimgui.PopItemWidth()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    if mimgui.Button("Получить статистику", mimgui.ImVec2(300, 40)) then
        if selectedBizIndex[0] ~= 0 then
            local b = bizList[selectedBizIndex[0]]
            if b then b.weekStats = nil; saveMasterData(); startStatsScanSingle(b.id) end
        else
            if #bizList > 0 then startStatsScanAll() end
        end
    end
    local currentBizStats = nil
    if selectedBizIndex[0] == 0 then
        local aggMap, aggOrder, hasData = {}, {}, false
        for _, b in ipairs(bizList) do
            if b.weekStats then
                for _, row in ipairs(b.weekStats) do
                    if not aggMap[row.day] then aggMap[row.day] = 0; table.insert(aggOrder, row.day) end
                    aggMap[row.day] = aggMap[row.day] + (parseNumber(row.money) or 0); hasData = true
                end
            end
        end
        if hasData then
            currentBizStats = {}
            for _, day in ipairs(aggOrder) do table.insert(currentBizStats, {day = day, money = tostring(aggMap[day])}) end
        end
    else
        if bizList[selectedBizIndex[0]] then currentBizStats = bizList[selectedBizIndex[0]].weekStats end
    end
    if currentBizStats then
        local totalWeekly = 0
        for _, row in ipairs(currentBizStats) do totalWeekly = totalWeekly + (parseNumber(row.money) or 0) end
        mimgui.Text("Статистика за 7 дней (сохранено):")
        mimgui.PushStyleColor(mimgui.Col.ChildBg, mimgui.ImVec4(0.15, 0.3, 0.15, 0.5))
        mimgui.BeginChild("TotalBox", mimgui.ImVec2(0, 35), true)
        mimgui.SetCursorPosY(7); mimgui.Text("Общая прибыль за неделю: "); mimgui.SameLine()
        mimgui.TextColored(getColor('Green'), "$ " .. formatNumber(totalWeekly))
        mimgui.EndChild(); mimgui.PopStyleColor()
        if mimgui.Columns then
            local tName = "WeekTable"
            mimgui.Columns(2, tName, true)
            if not tryRestoreColumnWidths(tName, 2) then tableWidthsInitialized[tName] = true end
            persistColumnWidths(tName, 2)
            mimgui.Text("День недели"); mimgui.NextColumn()
            mimgui.Text("Прибыль"); mimgui.NextColumn(); mimgui.Separator()
            for _, row in ipairs(currentBizStats) do
                mimgui.Text(row.day); mimgui.NextColumn()
                mimgui.TextColored(getColor('Green'), "$ " .. formatNumber(parseNumber(row.money))); mimgui.NextColumn()
            end
            mimgui.Columns(1)
        end
    else
        mimgui.Dummy(mimgui.ImVec2(0, 20))
        mimgui.TextColored(getColor('LightGray'), "Данные не загружены. Нажмите кнопку выше.")
    end
end

local function DrawFinanceTab()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.Text("Управление финансами (Банк):")
    if #bizList == 0 then
        mimgui.TextColored(getColor('Red'), "Сначала нажмите 'Обновить данные' слева!"); return
    end
    local items = buildBizComboItems("Все бизнесы")
    mimgui.PushItemWidth(300)
    if mimgui.BeginCombo("##bizSelectorBank", items[selectedBizIndex[0] + 1] or "Выберите бизнес") then
        for i, item in ipairs(items) do
            local isSel = (selectedBizIndex[0] == i - 1)
            if mimgui.Selectable(item, isSel) then selectedBizIndex[0] = i - 1 end
            if isSel then mimgui.SetItemDefaultFocus() end
        end
        mimgui.EndCombo()
    end
    mimgui.PopItemWidth(); mimgui.Dummy(mimgui.ImVec2(0, 10))
    local bankBizId, bankBalance = nil, 0
    local isAll = (selectedBizIndex[0] == 0)
    if isAll then
        for _, bal in pairs(bizBalances) do bankBalance = bankBalance + bal end
        if bankBalance == 0 then
            for _, b in ipairs(bizList) do if b.bank then bankBalance = bankBalance + (parseNumber(b.bank) or 0) end end
        end
    else
        if bizList[selectedBizIndex[0]] then
            local b = bizList[selectedBizIndex[0]]
            bankBizId = b.id; bankBalance = bizBalances[b.id] or (parseNumber(b.bank or "0"))
        end
    end
    mimgui.Text("Текущий баланс: "); mimgui.SameLine()
    mimgui.TextColored(getColor('Green'), "$ " .. formatNumber(bankBalance))
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.PushStyleColor(mimgui.Col.Button, mimgui.ImVec4(0.8, 0.3, 0.3, 1))
    mimgui.PushStyleColor(mimgui.Col.ButtonHovered, mimgui.ImVec4(0.9, 0.4, 0.4, 1))
    if mimgui.Button("Пополнить##bank", mimgui.ImVec2(145, 30)) then end
    mimgui.PopStyleColor(2); mimgui.SameLine()
    mimgui.PushStyleColor(mimgui.Col.Button, mimgui.ImVec4(0.3, 0.8, 0.3, 1))
    mimgui.PushStyleColor(mimgui.Col.ButtonHovered, mimgui.ImVec4(0.4, 0.9, 0.4, 1))
    if mimgui.Button("Снять##bank", mimgui.ImVec2(145, 30)) then
        local amt = uiBankAmount[0]
        if amt > 0 then
            if isAll then startBankOperation('withdraw', 0, amt)
            elseif bankBizId then startBankOperation('withdraw', bankBizId, amt) end
        end
    end
    mimgui.PopStyleColor(2)
    mimgui.PushItemWidth(300)
    if mimgui.InputInt("##bankAmount", uiBankAmount, 0, 0) then
        if uiBankAmount[0] < 0 then uiBankAmount[0] = 0 end
    end
    mimgui.PopItemWidth()
    mimgui.TextDisabled("Если сумма > баланса, будет снят максимум.")
    mimgui.Dummy(mimgui.ImVec2(0, 5))
    mimgui.PushStyleColor(mimgui.Col.Button, mimgui.ImVec4(0.4, 0.4, 0.8, 1))
    mimgui.PushStyleColor(mimgui.Col.ButtonHovered, mimgui.ImVec4(0.5, 0.5, 0.9, 1))
    if isAll then
        if mimgui.Button("Снять ВСЕ средства со всех бизнесов", mimgui.ImVec2(300, 30)) then
            startBankOperation('withdraw', 0, -1)
        end
    elseif bankBizId then
        if mimgui.Button("Снять ВСЕ средства с этого бизнеса", mimgui.ImVec2(300, 30)) then
            startBankOperation('withdraw', bankBizId, -1)
        end
    end
    mimgui.PopStyleColor(2)
end 

local function DrawLogTab()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.Text("Журнал банковских операций:")
    if #bizList == 0 then
        mimgui.TextColored(getColor('Red'), "Сначала нажмите 'Обновить данные' слева!"); return
    end
    local items = buildBizComboItems("Все бизнесы")
    mimgui.PushItemWidth(300)
    if mimgui.BeginCombo("##bizSelectorOps", items[selectedBizIndex[0] + 1] or "Выбор...") then
        for i, item in ipairs(items) do
            local isSel = (selectedBizIndex[0] == i - 1)
            if mimgui.Selectable(item, isSel) then selectedBizIndex[0] = i - 1 end
            if isSel then mimgui.SetItemDefaultFocus() end
        end
        mimgui.EndCombo()
    end
    mimgui.PopItemWidth(); mimgui.SameLine()
    if mimgui.Button("Обновить журнал", mimgui.ImVec2(150, 25)) then
        if #bizList > 0 then
            local targets = {}
            if selectedBizIndex[0] == 0 then targets = bizList
            else
                local idx = selectedBizIndex[0]
                if bizList[idx] then table.insert(targets, bizList[idx]) end
            end
            startLogScan(targets)
        end
    end
    mimgui.BeginChild("OpsScroll", mimgui.ImVec2(0, 0), true)
    mimgui.Separator()
    local opsToShow = {}
    local isAll = (selectedBizIndex[0] == 0)
    if isAll then
        for bid, ops in pairs(operationsLog) do
            for _, op in ipairs(ops) do
                table.insert(opsToShow, {bizLabel = tostring(bid), date = op.date, user = op.user, action = op.action, isWithdraw = op.isWithdraw})
            end
        end
        table.sort(opsToShow, function(a, b) return (a.date or "") > (b.date or "") end)
    else
        local idx = selectedBizIndex[0]
        if bizList[idx] then
            local bid = tostring(bizList[idx].id)
            if operationsLog[bid] then
                for _, op in ipairs(operationsLog[bid]) do
                    table.insert(opsToShow, {date = op.date, user = op.user, action = op.action, isWithdraw = op.isWithdraw})
                end
            end
        end
    end
    if #opsToShow == 0 then
        mimgui.TextDisabled("Нет записей операций.")
    elseif mimgui.Columns then
        local cols = isAll and 4 or 3
        local tName = "OpsTable_v3"
        mimgui.Columns(cols, tName, true)
        if not tryRestoreColumnWidths(tName, cols) then
            if isAll then mimgui.SetColumnWidth(0, 50) end
            tableWidthsInitialized[tName] = true
        end
        persistColumnWidths(tName, cols)
        if isAll then mimgui.Text("Бизнес"); mimgui.NextColumn() end
        mimgui.Text("Дата/Время"); mimgui.NextColumn()
        mimgui.Text("Кто"); mimgui.NextColumn()
        mimgui.Text("Действие"); mimgui.NextColumn()
        mimgui.Separator()
        for _, row in ipairs(opsToShow) do
            if isAll then mimgui.Text(row.bizLabel); mimgui.NextColumn() end
            mimgui.Text(u8:encode(row.date) or row.date); mimgui.NextColumn()
            mimgui.Text(u8:encode(row.user) or row.user); mimgui.NextColumn()
            local actText = u8:encode(row.action) or row.action
            if row.isWithdraw then mimgui.TextColored(getColor('Red'), actText)
            else mimgui.TextColored(getColor('Green'), actText) end
            mimgui.NextColumn()
        end
        mimgui.Columns(1)
    end
    mimgui.EndChild()
end

local function DrawPatchnotesTab()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.BeginChild("UpdatesScroll", mimgui.ImVec2(0, 0), true)
    local patches = {
        {name = "Version05", lines = {"Версия 0.5 beta:", "- Увеличена скорость сбора инфорамации", "- Рефакторинг кода", "- Улучшение общей производительности"}},
        {name = "Version04", lines = {"Версия 0.4 beta:", "- Добавлена сырная тема оформления!", "- Фикс багов", "- Добавлено больше информативности в процесс загрузки данных"}},
        {name = "Version03", lines = {"Версия 0.3 beta:", "- Исправление мелких ошибок.", "- Улучшение производительности.", "- Обновлена база названий бизнесов."}},
        {name = "Version02", lines = {"Версия 0.2 beta:", "- Исправлен баг с отсутствием запятых в меню Список бизнесов.", "- Улучшение производительности.", "- Обновлена база названий бизнесов."}},
        {name = "Version01", lines = {"Версия 0.1 beta:", "- Финансовая статистика: просмотр списка бизнесов.", "- Список бизнесов: выбор бизнеса для статистики.", "- Финансы: управление банковскими операциями.", "- Операции со счетом: просмотр журнала.", "- Обновления: информация о версиях."}},
    }
    local lineH = mimgui.GetTextLineHeightWithSpacing()
    local sepH = 6
    local padY = 16
    for _, patch in ipairs(patches) do
        local calcH = padY + lineH + sepH + ((#patch.lines - 1) * lineH) + padY * 0.5
        mimgui.PushStyleColor(mimgui.Col.ChildBg, mimgui.ImVec4(0.2, 0.2, 0.3, 0.5))
        mimgui.BeginChild(patch.name, mimgui.ImVec2(0, calcH), false)
        mimgui.Dummy(mimgui.ImVec2(0, 4))
        mimgui.SetCursorPosX(15)
        mimgui.Text(patch.lines[1]); mimgui.Separator()
        for li = 2, #patch.lines do
            mimgui.SetCursorPosX(15)
            mimgui.Text(patch.lines[li])
        end
        mimgui.EndChild(); mimgui.PopStyleColor()
        mimgui.Dummy(mimgui.ImVec2(0, 8))
    end
    mimgui.EndChild()
end

local function DrawSettingsTab()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.Text("Настройки скрипта:"); mimgui.Separator(); mimgui.Dummy(mimgui.ImVec2(0, 20))
    mimgui.PushStyleColor(mimgui.Col.ChildBg, mimgui.GetStyle().Colors[mimgui.Col.FrameBg])
    mimgui.BeginChild("ThemeSettings", mimgui.ImVec2(0, 100), true)
    mimgui.Text("Оформление"); mimgui.Separator(); mimgui.Dummy(mimgui.ImVec2(0, 5))
    if mimgui.Checkbox("Темная тема (Dark)", mimgui.new.bool(settings.theme == 'Dark')) then settings.theme = 'Dark'; saveMasterData() end
    mimgui.SameLine()
    if mimgui.Checkbox("Светлая тема (Light)", mimgui.new.bool(settings.theme == 'Light')) then settings.theme = 'Light'; saveMasterData() end
    mimgui.SameLine()
    if mimgui.Checkbox("Сырная тема! (only for ~cheese~)", mimgui.new.bool(settings.theme == 'Cheese')) then settings.theme = 'Cheese'; saveMasterData() end
    mimgui.EndChild(); mimgui.PopStyleColor()
    mimgui.Dummy(mimgui.ImVec2(0, 10))
    mimgui.PushStyleColor(mimgui.Col.ChildBg, mimgui.GetStyle().Colors[mimgui.Col.FrameBg])
    mimgui.BeginChild("PreserveSettings", mimgui.ImVec2(0, 120), true)
    mimgui.Text("Сохранение настроек (Ширина столбцов)"); mimgui.Separator(); mimgui.Dummy(mimgui.ImVec2(0, 5))
    if mimgui.Checkbox("Адаптивная", mimgui.new.bool(settings.preservation == 'Adaptive')) then
        settings.preservation = 'Adaptive'; saveMasterData(); tableWidthsInitialized = {}
    end
    HelpMarker("adapt", "Адаптивная", "Изменения ширины сбрасываются при перезаходе.")
    if mimgui.Checkbox("Постоянная", mimgui.new.bool(settings.preservation == 'Permanent')) then
        settings.preservation = 'Permanent'; saveMasterData(); tableWidthsInitialized = {}
    end
    HelpMarker("perm", "Постоянная", "Ширина столбцов сохраняется между сессиями.")
    mimgui.EndChild(); mimgui.PopStyleColor()
    mimgui.Dummy(mimgui.ImVec2(0, 20)); mimgui.Separator(); mimgui.Dummy(mimgui.ImVec2(0, 10))
    if getMyNick() == "Spartak_First" then
        if mimgui.Checkbox("Debug CEF (для разработчиков)", debugCef) then
            sampAddChatMessage(u8:decode("[FinStat] Debug CEF: " .. (debugCef[0] and "ВКЛ" or "ВЫКЛ")), 0xAAAAAA)
        end
        mimgui.TextDisabled("Включает вывод отладочной информации о пакетах CEF в консоль SF.")
    end
end

local function DrawProcessOverlay()
    if not processOverlay.active then return end
    local centerX = mainWinPos.x + (mainWinSize.x / 2)
    local centerY = mainWinPos.y + (mainWinSize.y / 2)
    mimgui.SetNextWindowPos(mimgui.ImVec2(centerX, centerY), mimgui.Cond.Always, mimgui.ImVec2(0.5, 0.5))
    mimgui.SetNextWindowSize(mimgui.ImVec2(300, 250), mimgui.Cond.Always)
    mimgui.PushStyleColor(mimgui.Col.WindowBg, mimgui.ImVec4(0.1, 0.1, 0.1, 0.95))
    mimgui.PushStyleVarFloat(mimgui.StyleVar.WindowRounding, 12.0)
    if mimgui.Begin("##ProcessOverlayWindow", nil, mimgui.WindowFlags.NoTitleBar + mimgui.WindowFlags.NoResize + mimgui.WindowFlags.NoMove + mimgui.WindowFlags.NoScrollbar + mimgui.WindowFlags.NoCollapse + mimgui.WindowFlags.NoSavedSettings) then
        local winW = mimgui.GetWindowWidth()
        local winH = mimgui.GetWindowHeight()
        mimgui.Dummy(mimgui.ImVec2(0, 20))
        mimgui.SetCursorPosX((winW - 80) / 2)
        LoadingSpinner(40, 6, 0xFF33CCFF)
        mimgui.Dummy(mimgui.ImVec2(0, 15))
        local txt = processOverlay.text or "Обработка..."
        mimgui.SetCursorPosX((winW - mimgui.CalcTextSize(txt).x) / 2); mimgui.Text(txt)
        if processOverlay.total > 1 then
            local stepTxt = string.format("%d / %d", processOverlay.current, processOverlay.total)
            mimgui.SetCursorPosX((winW - mimgui.CalcTextSize(stepTxt).x) / 2)
            mimgui.TextColored(getColor('LightGray'), stepTxt)
        end
        mimgui.SetCursorPosY(winH - 55)
        mimgui.SetCursorPosX((winW - 120) / 2)
        mimgui.PushStyleColor(mimgui.Col.Button, mimgui.ImVec4(0.8, 0.2, 0.2, 1))
        mimgui.PushStyleColor(mimgui.Col.ButtonHovered, mimgui.ImVec4(0.9, 0.3, 0.3, 1))
        mimgui.PushStyleColor(mimgui.Col.ButtonActive, mimgui.ImVec4(0.6, 0.1, 0.1, 1))
        if mimgui.Button("ОТМЕНА", mimgui.ImVec2(120, 35)) then
            processOverlay.active = false
            if processOverlay.cancelFunc then processOverlay.cancelFunc() end
        end
        mimgui.PopStyleColor(3)
    end
    mimgui.End()
    mimgui.PopStyleColor()
    mimgui.PopStyleVar()
end

mimgui.OnFrame(function() return showFinStat[0] end, function()
    applyTheme()
    local sw, sh = getScreenResolution()
    mimgui.SetNextWindowPos(mimgui.ImVec2(sw / 2, sh / 2), mimgui.Cond.FirstUseEver, mimgui.ImVec2(0.5, 0.5))
    mimgui.SetNextWindowSize(mimgui.ImVec2(WINDOW_WIDTH, WINDOW_HEIGHT), mimgui.Cond.FirstUseEver)
    mimgui.SetNextWindowSizeConstraints(mimgui.ImVec2(WINDOW_WIDTH, WINDOW_HEIGHT), mimgui.ImVec2(20000, 20000))
    mimgui.Begin("FinStat", showFinStat, mimgui.WindowFlags.NoSavedSettings + mimgui.WindowFlags.NoCollapse)
    mainWinPos = mimgui.GetWindowPos()
    mainWinSize = mimgui.GetWindowSize()
    DrawCheeseBg()
    local dl = mimgui.GetForegroundDrawList()
    local titleText = "Financial Statistics by SpencerMSU"
    local textSize = mimgui.CalcTextSize(titleText)
    local sidebarW = 180
    local cx = mainWinPos.x + sidebarW + (mainWinSize.x - sidebarW) / 2
    local cy = mainWinPos.y + (mimgui.GetFrameHeight() / 2)
    dl:AddText(mimgui.ImVec2(cx - textSize.x / 2, cy - textSize.y / 2),
        mimgui.ColorConvertFloat4ToU32(mimgui.GetStyle().Colors[mimgui.Col.TextDisabled]), titleText)
    DrawSidebar()
    mimgui.SameLine()
    mimgui.BeginChild("MainContent", mimgui.ImVec2(0, -35), true)
    if     activeTab == 1 then DrawStatsTab()
    elseif activeTab == 2 then DrawBizTab()
    elseif activeTab == 3 then DrawFinanceTab()
    elseif activeTab == 4 then DrawLogTab()
    elseif activeTab == 5 then DrawPatchnotesTab()
    elseif activeTab == 6 then DrawSettingsTab()
    end
    mimgui.EndChild()
    mimgui.End()
    DrawProcessOverlay()
end)


function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == BANK_DIALOG_ID and autoState.mode == 'bank' then
        local amt = math.floor(autoState.bankAmount)
        if autoState.bankAmount == -1 and autoState.bankTargetBizId then
            local bid = autoState.bankTargetBizId
            local bal = bizBalances[bid]
            if not bal then
                for _, b in ipairs(bizList) do
                    if b.id == bid then bal = parseNumber(b.bank); break end
                end
            end
            amt = bal or 0
        end
        sampSendDialogResponse(BANK_DIALOG_ID, 1, 0, tostring(amt))
        signalEvent('bankDialogDone')
        return false
    end

    if dialogId == LOG_DIALOG_ID then
        print("[FinStat] Detected Operations Log Dialog! ID: " .. dialogId)
        local ops = {}
        local cleanText = text:gsub("{......}", "")
        for line in cleanText:gmatch("[^\r\n]+") do
            local parts = {}
            for v in line:gmatch("%[(.-)%]") do table.insert(parts, v) end
            if #parts >= 3 then
                local d, u2, a = trim(parts[1]), trim(parts[2]), trim(parts[3])
                local isW = a:find(u8:decode("снял")) or a:find("minus") or a:find("-")
                if not (d:find(u8:decode("Дат")) or d:find("Date")) then
                    table.insert(ops, {date = d, user = u2, action = a, isWithdraw = (isW and true or false)})
                end
            end
        end
        if #ops > 0 and currentBiz then
            local curId = tonumber((type(currentBiz) == 'table' and currentBiz.id) or currentBiz)
            if curId then
                print("[FinStat] Captured " .. #ops .. " operations for Biz ID " .. curId)
                operationsLog[tostring(curId)] = ops
                saveMasterData()
                if autoState.mode == 'scan_log' then
                    sampSendDialogResponse(dialogId, 0, -1, "")
                    signalEvent('logDialogParsed')
                    return false
                end
            end
        end
    end

    if dialogId == STATS_DIALOG_ID and style == 5 then
        print("[FinStat] Detected Business Statistics Dialog (ID 0).")
        local cleanText = text:gsub("{......}", "")
        local tempStats, foundAny = {}, false
        for line in cleanText:gmatch("[^\r\n]+") do
            for dayNameCP, dayIndex in pairs(dayMap) do
                if line:find(dayNameCP, 1, true) then
                    local money = line:match("%$([%d,]+)")
                    if money then tempStats[dayIndex] = {day = displayDays[dayIndex], money = money}; foundAny = true end
                    break
                end
            end
        end
        if foundAny then
            local newStats = {}
            for i = 1, 7 do table.insert(newStats, tempStats[i] or {day = displayDays[i], money = "0"}) end
            local targetBid = autoState.bizId
            if targetBid then
                for _, b in ipairs(bizList) do
                    if b.id == targetBid then b.weekStats = newStats; saveMasterData(); break end
                end
            else
                local idx = selectedBizIndex[0]
                if idx > 0 and bizList[idx] then bizList[idx].weekStats = newStats; saveMasterData() end
            end
            if autoState.mode == 'scan_stats_single' or autoState.mode == 'scan_stats_all' then
                sampSendDialogResponse(dialogId, 0, 0, "")
                signalEvent('statsDialogParsed')
                return false
            end
        else
            print("[FinStat] Warning: No stats lines parsed.")
        end
        activeDialogContext = nil
    end
end

function sampev.onServerMessage(color, text)
    if text:find(u8:decode("Не получилось вывести средства на банковский счёт"), 1, true)
       or text:find(u8:decode("превышена максимальная сумма средств на счету"), 1, true) then
        if autoState.mode == 'bank' then
            autoState.cancelRequested = true
            signalEvent('bankDialogDone')
            sampAddChatMessage(u8:decode("[FinStat] Снятие остановлено: Превышен лимит средств на счету."), 0xFF4444)
        end
    end
    if text:find("Вы успешно сняли деньги со счета") then
        local balStr = text:match("Остаток:%s*%$([%d,]+)")
        if balStr then
            local newBal = tonumber(balStr:gsub(",", ""))
            local bid = autoState.bankTargetBizId
            if not bid and currentBiz then bid = (type(currentBiz) == 'table' and currentBiz.id) or currentBiz end
            if bid and newBal then bizBalances[tonumber(bid)] = newBal end
        end
    end
end

if not raknetBitStreamDecodeString then
    function raknetBitStreamDecodeString(bs, len)
        return raknetBitStreamReadString(bs, len)
    end
end

function az.onArizonaDisplay(packet)
    if debugCef[0] then
        local evt = packet.event or "Unknown"
        print(string.format(">>> [IN] CEF Event: %s", evt))
        if packet.json and type(packet.json) == 'table' then
            for k, v in pairs(packet.json) do
                print(string.format("    Key: %s Value: %s", tostring(k), tostring(v)))
                if type(v) == 'table' then
                    for k2, v2 in pairs(v) do print(string.format("        SubKey: %s Value: %s", tostring(k2), tostring(v2))) end
                end
            end
        elseif packet.json then
            print("    Data: " .. tostring(packet.json))
        end
    end
    if not cefCaptureActive and not debugCef[0] then return end
    if os.clock() > cefCaptureDeadline and not debugCef[0] then cefCaptureActive = false; return end
    if debugCef[0] then
        local textStart = (packet.text and packet.text:sub(1, 50) or "nil"):gsub("[%c]", ".")
        print(string.format('[FinStat] TextLen: %d, Start: %s', #(packet.text or ""), textStart))
    end
    if az.decode(packet, hasJson and json.decode or nil) then
        local eventName = packet.event
        local data = packet.json
        if debugCef[0] then print('[FinStat] Decoded: ' .. tostring(eventName)) end
        if eventName:find('setActiveView') then
            if data and data[1] and type(data[1]) == 'string' and data[1]:find('Businesses') then
                if #bizList > 0 then
                    bizDataCache = {}
                    for _, b in ipairs(bizList) do
                        bizDataCache[b.id] = {weekStats = b.weekStats, profitToday = b.profitToday, bank = b.bank}
                    end
                end
                bizList = {}; lastScanResults = {}
                cefBusinessesViewSeen = true
                if autoState.mode ~= 'idle' then
                    cefCaptureActive = true
                    cefCaptureDeadline = os.clock() + 15.0
                end
            end
        end
        if eventName == 'event.business.list.pushItems' then
            cefBusinessesViewSeen = true; cefLastJson = data; cefLastText = eventName
            if tryFillBizListFromJson(data, true) then
                if not processOverlay.active and type(data) == 'table' then
                    local list = nil
                    if #data == 1 and type(data[1]) == 'table' then list = data[1]
                    elseif #data > 0 then list = data
                    elseif type(data.businesses) == 'table' then list = data.businesses
                    elseif type(data.items) == 'table' then list = data.items
                    elseif type(data.data) == 'table' and type(data.data.businesses) == 'table' then list = data.data.businesses end
                    if list then
                        for _, it in ipairs(list) do
                            local b = normalizeBizItem(it)
                            if b and b.id then lastScanResults[b.id] = {id = b.id, bank = b.bank, profitToday = b.profitToday} end
                        end
                    end
                end
                if autoCloseCef then lastCefPacketTime = os.clock() end
                saveMasterData()
                signalEvent('pushItems')
            end
        end
        if eventName == 'event.business.info.initializeBusinessInformation' then
            if type(data) == 'table' and data[1] and type(data[1]) == 'table' then
                local foundId = data[1].id or data[1].biz_id or data[1].businessId
                if foundId then
                    if currentBiz and type(currentBiz) == 'table' then currentBiz.id = tonumber(foundId)
                    else currentBiz = tonumber(foundId) end
                end
            end
            signalEvent('initBizInfo')
        end

        if eventName == 'event.business.info.initializeMenuTabs' then
            if debugCef[0] then print("[FinStat] Menu Tabs Initialized.") end
        end

        if eventName:find('Businesses') or eventName:find('business') then
            cefCaptureDeadline = math.max(cefCaptureDeadline, os.clock() + 5.0)
        end
        if eventName == 'event.business.info.setDetailsGroupData' then
            if type(data) == 'table' then
                for _, group in pairs(data) do
                    if group.items then
                        if group.id == 'finance' then
                            local wday = os.date("*t").wday
                            local arizonaDay = wday - 1; if arizonaDay == 0 then arizonaDay = 7 end
                            local targetItem = group.items[arizonaDay] or group.items[tostring(arizonaDay)]
                            if targetItem and currentBiz then
                                local valStr = (targetItem.value or ""):gsub("[^%d-]", "")
                                local bid = tonumber((type(currentBiz) == 'table' and currentBiz.id) or currentBiz)
                                if bid then
                                    if not lastScanResults[bid] then lastScanResults[bid] = {id = bid} end
                                    lastScanResults[bid].profitToday = valStr
                                    for _, b in ipairs(bizList) do
                                        if b.id == bid then b.profitToday = valStr; saveMasterData(); break end
                                    end
                                end
                            end
                        end
                        for _, item in pairs(group.items) do
                            local checkStr = (item.label or "") .. " " .. (item.title or "")
                            if checkStr:find(u8:encode("Баланс")) or checkStr:find("Balance") then
                                local amount = tonumber((item.value or ""):gsub("[^%d]", ""))
                                if amount and currentBiz then
                                    local bid = tonumber((type(currentBiz) == 'table' and currentBiz.id) or currentBiz)
                                    if bid then
                                        bizBalances[bid] = amount
                                        if not lastScanResults[bid] then lastScanResults[bid] = {id = bid} end
                                        lastScanResults[bid].bank = tostring(amount)
                                    end
                                end
                            elseif checkStr:find(u8:encode("Прибыль за сегодня")) or checkStr:find("Profit") then
                                local amount = (item.value or ""):gsub("[^%d-]", "")
                                if amount and currentBiz then
                                    local bid = tonumber((type(currentBiz) == 'table' and currentBiz.id) or currentBiz)
                                    if bid then
                                        if not lastScanResults[bid] then lastScanResults[bid] = {id = bid} end
                                        lastScanResults[bid].profitToday = amount
                                        for _, b in ipairs(bizList) do
                                            if b.id == bid then b.profitToday = amount; saveMasterData(); break end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            signalEvent('detailsLoaded')
        end
        if debugCef[0] then
            local packetText = packet.text or ""
            local isInteresting = packetText:find("снял со счета") or packetText:find("положил на счет") or packetText:find("пополнил счет")
            if isInteresting or eventName:find('bank') or eventName:find('log') or eventName:find('history') or eventName:find('operation') or eventName:find('setDetailsGroupData') then
                print('[FinStat KEY-LOG] ' .. eventName)
                if hasJson and type(data) == 'table' then
                    local function printTable(t, indent)
                        indent = indent or ""
                        for k, v in pairs(t) do
                            if type(v) == "table" then print(indent .. tostring(k) .. ":"); printTable(v, indent .. "  ")
                            else
                                local vs = tostring(v)
                                if type(v) == "string" then vs = string.format("'%s' (Dec: '%s')", vs, u8:decode(vs) or "?") end
                                print(indent .. tostring(k) .. ": " .. vs)
                            end
                        end
                    end
                    printTable(data, "  ")
                end
            end
        end
    else
        if debugCef[0] then print('[FinStat] az.decode failed.') end
    end
end

function onSendPacket(id, bs, priority, reliability, orderingChannel)
    if id == 220 then
        local len = raknetBitStreamGetNumberOfBytesUsed(bs)
        if len > 2 then
            local pos = raknetBitStreamGetReadOffset(bs)
            raknetBitStreamSetReadOffset(bs, 0)
            local content = ""
            for i = 0, math.min(len - 1, 2048) do
                local byte = raknetBitStreamReadInt8(bs)
                if byte >= 32 and byte <= 126 then content = content .. string.char(byte)
                else content = content .. "." end
            end
            if content:find("business.info.selectTab|" .. LOG_TAB_ID) then
                if debugCef[0] then print("[FinStat] Context: LOG") end
                activeDialogContext = 'log'
            elseif content:find("business.info.selectTab|" .. STATS_TAB_ID) then
                if debugCef[0] then print("[FinStat] Context: STATS") end
                activeDialogContext = 'stats'
            end
            if debugCef[0] then
                print(string.format("<<< [OUT] Packet %d. Len: %d", id, len))
                print("    Content: " .. content)
            end
            raknetBitStreamSetReadOffset(bs, pos)
        end
    end
end


function main()
    while not isSampAvailable() do wait(100) end
    loadMasterData()
    sampAddChatMessage(u8:decode("{55FFA0}[FinStat]{66CCFF} FinancialStatistics By SpencerMSU инициализирован."), 0x66CCFF)
    sampRegisterChatCommand("finstat", function() showFinStat[0] = not showFinStat[0] end)
    sampRegisterChatCommand("fsresults", function()
        sampAddChatMessage(u8:decode("[FinStat] === Result of Last Scan ==="), 0xAAAAAA)
        local sorted = {}
        for _, d in pairs(lastScanResults) do table.insert(sorted, d) end
        table.sort(sorted, function(a, b) return (a.id or 0) < (b.id or 0) end)
        if #sorted == 0 then
            sampAddChatMessage(u8:decode("[FinStat] No results from last scan."), 0xAAAAAA)
        else
            for _, b in ipairs(sorted) do
                sampAddChatMessage(string.format("[FinStat] ID: %d | Bank: %s | Profit: %s", b.id, b.bank or "N/A", b.profitToday or "N/A"), 0xAAAAAA)
            end
        end
    end)
    sampRegisterChatCommand("bizrefresh", function() triggerBizRefresh() end)
    sampRegisterChatCommand('ceflast', function()
        if cefLastText == '' then sampAddChatMessage(u8:decode('[FinStat] CEF: пока пусто.'), 0xAAAAAA)
        else sampAddChatMessage(u8:decode('[FinStat] CEF: ' .. compactForUi(cefLastText, 220)), 0xAAAAAA) end
    end)
    local wasFinStatOpen = false
    while true do
        wait(100)
        if wasFinStatOpen and not showFinStat[0] then
            sampSetCursorMode(0)
        end
        wasFinStatOpen = showFinStat[0]

        if autoCloseCef and lastCefPacketTime > 0 and (os.clock() - lastCefPacketTime) > 0.6 then
            autoCloseCef = false; lastCefPacketTime = 0
            setVirtualKeyDown(27, true) wait(50) setVirtualKeyDown(27, false)
        end
    end
end
