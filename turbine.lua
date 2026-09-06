-- ==========================================
-- MEKANISM INDUSTRIAL TURBINE
-- DOUBLE BUFFER CONTROL PANEL
-- ==========================================

local functions = require("functions")

local REFRESH_TIME = 1

--------------------------------------------------
-- PROCURAR MONITOR
--------------------------------------------------

local monitor = nil

for _, name in ipairs(peripheral.getNames()) do
    if peripheral.getType(name) == "monitor" then
        monitor = peripheral.wrap(name)
        break
    end
end

if not monitor then
    print("ERRO: Monitor nao encontrado.")
    return
end

--------------------------------------------------
-- CONFIGURAR MONITOR
--------------------------------------------------

monitor.setTextScale(0.5)

local width, height = monitor.getSize()

--------------------------------------------------
-- BUFFER
--------------------------------------------------

local buffer = window.create(
    monitor,
    1,
    1,
    width,
    height,
    false
)

--------------------------------------------------
-- FUNCOES
--------------------------------------------------

local function safeNumber(value)

    if type(value) == "number" then
        return value
    end

    if type(value) == "table" then

        if type(value.amount) == "number" then
            return value.amount
        end

        if type(value.value) == "number" then
            return value.value
        end

        if type(value[1]) == "number" then
            return value[1]
        end
    end

    return 0
end


--------------------------------------------------
-- FORMATAR NUMEROS
--------------------------------------------------

local function formatNumber(value)

    value = safeNumber(value)

    if value >= 1000000000 then
        return string.format("%.2f B", value / 1000000000)

    elseif value >= 1000000 then
        return string.format("%.2f M", value / 1000000)

    elseif value >= 1000 then
        return string.format("%.2f K", value / 1000)

    else
        return string.format("%.0f", value)
    end

end


--------------------------------------------------
-- PORCENTAGEM
--------------------------------------------------

local function getPercent(value)

    value = safeNumber(value)

    if value < 0 then
        value = 0
    end

    if value > 1 then
        value = 1
    end

    return value * 100
end


--------------------------------------------------
-- LIMPAR LINHA DO BUFFER
--------------------------------------------------

local function clearLine(y)

    buffer.setCursorPos(1, y)

    buffer.write(
        string.rep(" ", width)
    )

end


--------------------------------------------------
-- ESCREVER TEXTO
--------------------------------------------------

local function writeAt(x, y, text)

    buffer.setCursorPos(x, y)
    buffer.write(tostring(text))

end


--------------------------------------------------
-- CENTRALIZAR
--------------------------------------------------

local function center(y, text)

    local x =
        math.floor(
            (width - #text) / 2
        ) + 1

    if x < 1 then
        x = 1
    end

    writeAt(x, y, text)

end


--------------------------------------------------
-- LINHA
--------------------------------------------------

local function line(y)

    writeAt(
        1,
        y,
        string.rep("-", width)
    )

end


--------------------------------------------------
-- BARRA
--------------------------------------------------

local function bar(x, y, barWidth, value)

    value = safeNumber(value)

    if value < 0 then
        value = 0
    end

    if value > 1 then
        value = 1
    end

    local filled =
        math.floor(barWidth * value)

    local empty =
        barWidth - filled

    writeAt(
        x,
        y,
        "["
        .. string.rep("=", filled)
        .. string.rep(" ", empty)
        .. "]"
    )

end


--------------------------------------------------
-- CONSTRUIR INTERFACE
--------------------------------------------------

local function draw(turbine)

    --------------------------------------------------
    -- LIMPAR SOMENTE O BUFFER
    --------------------------------------------------

    buffer.setBackgroundColor(
        colors.black
    )

    buffer.setTextColor(
        colors.white
    )

    buffer.clear()

    --------------------------------------------------
    -- TITULO
    --------------------------------------------------

    center(
        1,
        "INDUSTRIAL TURBINE CONTROL"
    )

    line(2)

    --------------------------------------------------
    -- STATUS
    --------------------------------------------------

    writeAt(
        2,
        4,
        "STATUS:"
    )

    local status =
        functions.getStatus(turbine)

    writeAt(
        10,
        4,
        status
    )

    --------------------------------------------------
    -- STEAM
    --------------------------------------------------

    writeAt(
        2,
        6,
        "STEAM"
    )

    local steam =
        functions.getSteam(turbine)

    local steamCapacity =
        functions.getSteamCapacity(turbine)

    local steamPercent =
        safeNumber(
            functions.getSteamPercentage(turbine)
        )

    writeAt(
        10,
        6,
        string.format(
            "%.1f%%",
            getPercent(steamPercent)
        )
    )

    bar(
        2,
        7,
        math.min(30, width - 5),
        steamPercent
    )

    writeAt(
        2,
        8,
        formatNumber(steam)
        .. " / "
        .. formatNumber(steamCapacity)
        .. " mB"
    )

    --------------------------------------------------
    -- ENERGY
    --------------------------------------------------

    writeAt(
        2,
        10,
        "ENERGY"
    )

    local energy =
        functions.getEnergy(turbine)

    local energyCapacity =
        functions.getEnergyCapacity(turbine)

    local energyPercent =
        functions.getEnergyPercentage(turbine)

    energyPercent =
        safeNumber(energyPercent)

    writeAt(
        10,
        10,
        string.format(
            "%.1f%%",
            getPercent(energyPercent)
        )
    )

    bar(
        2,
        11,
        math.min(30, width - 5),
        energyPercent
    )

    if energyCapacity > 0 then

        writeAt(
            2,
            12,
            formatNumber(energy)
            .. " / "
            .. formatNumber(energyCapacity)
            .. " FE"
        )

    else

        writeAt(
            2,
            12,
            "ENERGY DATA UNAVAILABLE"
        )

    end

    --------------------------------------------------
    -- PRODUCAO
    --------------------------------------------------

    writeAt(
        2,
        14,
        "PRODUCTION"
    )

    local production =
        functions.getProduction(turbine)

    local maxProduction =
        functions.getMaxProduction(turbine)

    local productionPercent = 0

    if maxProduction > 0 then
        productionPercent =
            production / maxProduction
    end

    writeAt(
        14,
        14,
        string.format(
            "%.1f%%",
            getPercent(productionPercent)
        )
    )

    bar(
        2,
        15,
        math.min(30, width - 5),
        productionPercent
    )

    writeAt(
        2,
        16,
        formatNumber(production)
        .. " / "
        .. formatNumber(maxProduction)
        .. " FE/t"
    )

    --------------------------------------------------
    -- STEAM INPUT
    --------------------------------------------------

    writeAt(
        2,
        18,
        "STEAM INPUT:"
    )

    writeAt(
        15,
        18,
        formatNumber(
            functions.getSteamInput(turbine)
        )
        .. " mB/t"
    )

    --------------------------------------------------
    -- FLOW
    --------------------------------------------------

    writeAt(
        2,
        19,
        "FLOW RATE:"
    )

    writeAt(
        15,
        19,
        formatNumber(
            functions.getFlow(turbine)
        )
        .. " / "
        .. formatNumber(
            functions.getMaxFlow(turbine)
        )
        .. " mB/t"
    )

    --------------------------------------------------
    -- ESTRUTURA
    --------------------------------------------------

    line(21)

    center(
        22,
        "TURBINE STRUCTURE"
    )

    writeAt(
        2,
        24,
        "BLADES:"
    )

    writeAt(
        10,
        24,
        functions.getBlades(turbine)
    )

    writeAt(
        20,
        24,
        "VENTS:"
    )

    writeAt(
        28,
        24,
        functions.getVents(turbine)
    )

    writeAt(
        2,
        25,
        "COILS:"
    )

    writeAt(
        10,
        25,
        functions.getCoils(turbine)
    )

    writeAt(
        20,
        25,
        "CONDENSERS:"
    )

    writeAt(
        33,
        25,
        functions.getCondensers(turbine)
    )

    writeAt(
        2,
        26,
        "DISPERSERS:"
    )

    writeAt(
        13,
        26,
        functions.getDispersers(turbine)
    )

    --------------------------------------------------
    -- DUMPING
    --------------------------------------------------

    line(28)

    writeAt(
        2,
        29,
        "DUMPING MODE:"
    )

    local dumping =
        functions.getDumpingMode(turbine)

    if dumping then

        writeAt(
            16,
            29,
            "ACTIVE"
        )

    else

        writeAt(
            16,
            29,
            "IDLE"
        )

    end

    --------------------------------------------------
    -- RODAPE
    --------------------------------------------------

    if height >= 31 then

        line(height - 1)

        writeAt(
            2,
            height,
            "AUTO REFRESH: "
            .. REFRESH_TIME
            .. "s"
        )

    end

end


--------------------------------------------------
-- COPIAR BUFFER PARA O MONITOR
--------------------------------------------------

local function updateMonitor()

    monitor.setCursorPos(1, 1)

    for y = 1, height do

        buffer.setCursorPos(1, y)

        local text,
              textColor,
              backgroundColor =
            buffer.getLine(y)

        monitor.setCursorPos(1, y)

        monitor.blit(
            text,
            textColor,
            backgroundColor
        )

    end

end


--------------------------------------------------
-- LOOP
--------------------------------------------------

while true do

    local turbine =
        functions.findTurbine()

    if turbine then

        --------------------------------------------------
        -- MONTA A TELA COMPLETA NA MEMORIA
        --------------------------------------------------

        draw(turbine)

        --------------------------------------------------
        -- JOGA A TELA PRONTA NO MONITOR
        --------------------------------------------------

        updateMonitor()

    else

        buffer.clear()

        center(
            5,
            "TURBINE NOT FOUND"
        )

        center(
            7,
            "Waiting for Mekanism turbine..."
        )

        updateMonitor()

    end

    sleep(REFRESH_TIME)

end
