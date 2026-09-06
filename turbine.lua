-- ==========================================
-- MEKANISM INDUSTRIAL TURBINE
-- CONTROL PANEL
-- ==========================================

local functions = require("functions")

--------------------------------------------------
-- CONFIGURAÇÃO
--------------------------------------------------

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
    print("ERRO: Nenhum monitor encontrado.")
    return
end

--------------------------------------------------
-- CONFIGURAR MONITOR
--------------------------------------------------

monitor.setTextScale(0.5)

term.redirect(monitor)

local width, height = term.getSize()

--------------------------------------------------
-- FUNÇÕES AUXILIARES
--------------------------------------------------

local function number(value)

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
-- FORMATAR NÚMERO
--------------------------------------------------

local function formatNumber(value)

    value = number(value)

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

local function percent(value)

    value = number(value)

    if value < 0 then
        value = 0
    end

    if value > 1 then
        value = 1
    end

    return value * 100
end


--------------------------------------------------
-- TEXTO CENTRALIZADO
--------------------------------------------------

local function center(y, text)

    local x = math.floor((width - #text) / 2) + 1

    if x < 1 then
        x = 1
    end

    term.setCursorPos(x, y)
    term.write(text)

end


--------------------------------------------------
-- LINHA HORIZONTAL
--------------------------------------------------

local function horizontalLine(y)

    term.setCursorPos(1, y)
    term.write(string.rep("-", width))

end


--------------------------------------------------
-- ESCREVER CAMPO
--------------------------------------------------

local function writeField(x, y, text, fieldWidth)

    term.setCursorPos(x, y)

    term.write(
        string.rep(" ", fieldWidth)
    )

    term.setCursorPos(x, y)

    term.write(
        tostring(text)
    )

end


--------------------------------------------------
-- BARRA
--------------------------------------------------

local function drawBar(x, y, barWidth, value)

    value = number(value)

    if value < 0 then
        value = 0
    end

    if value > 1 then
        value = 1
    end

    local filled =
        math.floor(barWidth * value)

    term.setCursorPos(x, y)

    term.write("[")

    for i = 1, barWidth do

        if i <= filled then
            term.write("=")
        else
            term.write(" ")
        end

    end

    term.write("]")

end


--------------------------------------------------
-- DESENHAR INTERFACE
-- ISSO ACONTECE SOMENTE UMA VEZ
--------------------------------------------------

local function drawInterface()

    term.clear()
    term.setCursorPos(1, 1)

    --------------------------------------------------
    -- TÍTULO
    --------------------------------------------------

    center(
        1,
        "INDUSTRIAL TURBINE CONTROL"
    )

    horizontalLine(2)

    --------------------------------------------------
    -- STATUS
    --------------------------------------------------

    term.setCursorPos(2, 4)
    term.write("STATUS:")

    --------------------------------------------------
    -- STEAM
    --------------------------------------------------

    term.setCursorPos(2, 6)
    term.write("STEAM")

    term.setCursorPos(2, 7)
    term.write("[")

    term.write(
        string.rep(
            " ",
            math.min(width - 5, 30)
        )
    )

    term.write("]")

    term.setCursorPos(2, 8)
    term.write("")

    --------------------------------------------------
    -- ENERGY
    --------------------------------------------------

    term.setCursorPos(2, 10)
    term.write("ENERGY")

    --------------------------------------------------
    -- PRODUCTION
    --------------------------------------------------

    term.setCursorPos(2, 14)
    term.write("PRODUCTION")

    --------------------------------------------------
    -- STEAM INPUT
    --------------------------------------------------

    term.setCursorPos(2, 18)
    term.write("STEAM INPUT:")

    --------------------------------------------------
    -- FLOW
    --------------------------------------------------

    term.setCursorPos(2, 19)
    term.write("FLOW RATE:")

    --------------------------------------------------
    -- ESTRUTURA
    --------------------------------------------------

    horizontalLine(21)

    center(
        22,
        "TURBINE STRUCTURE"
    )

    term.setCursorPos(2, 24)
    term.write("BLADES:")

    term.setCursorPos(20, 24)
    term.write("VENTS:")

    term.setCursorPos(2, 25)
    term.write("COILS:")

    term.setCursorPos(20, 25)
    term.write("CONDENSERS:")

    term.setCursorPos(2, 26)
    term.write("DISPERSERS:")

    --------------------------------------------------
    -- DUMPING
    --------------------------------------------------

    horizontalLine(28)

    term.setCursorPos(2, 29)
    term.write("DUMPING MODE:")

    --------------------------------------------------
    -- RODAPÉ
    --------------------------------------------------

    if height >= 31 then

        horizontalLine(height - 1)

        term.setCursorPos(2, height)

        term.write(
            "AUTO REFRESH: "
            .. REFRESH_TIME
            .. "s"
        )

    end

end


--------------------------------------------------
-- ATUALIZAR STEAM
--------------------------------------------------

local function updateSteam(turbine)

    local steam =
        functions.getSteam(turbine)

    local capacity =
        functions.getSteamCapacity(turbine)

    local percentage =
        functions.getSteamPercentage(turbine)

    percentage = number(percentage)

    --------------------------------------------------
    -- PORCENTAGEM
    --------------------------------------------------

    writeField(
        10,
        6,
        string.format(
            "%.1f%%",
            percent(percentage)
        ),
        10
    )

    --------------------------------------------------
    -- BARRA
    --------------------------------------------------

    drawBar(
        2,
        7,
        math.min(width - 5, 30),
        percentage
    )

    --------------------------------------------------
    -- QUANTIDADE
    --------------------------------------------------

    writeField(
        2,
        8,
        formatNumber(steam)
        .. " / "
        .. formatNumber(capacity)
        .. " mB",
        math.min(width - 2, 35)
    )

end


--------------------------------------------------
-- ATUALIZAR ENERGY
--------------------------------------------------

local function updateEnergy(turbine)

    local energy =
        functions.getEnergy(turbine)

    local capacity =
        functions.getEnergyCapacity(turbine)

    local percentage =
        functions.getEnergyPercentage(turbine)

    percentage = number(percentage)

    --------------------------------------------------
    -- PORCENTAGEM
    --------------------------------------------------

    writeField(
        10,
        10,
        string.format(
            "%.1f%%",
            percent(percentage)
        ),
        10
    )

    --------------------------------------------------
    -- BARRA
    --------------------------------------------------

    drawBar(
        2,
        11,
        math.min(width - 5, 30),
        percentage
    )

    --------------------------------------------------
    -- QUANTIDADE
    --------------------------------------------------

    if capacity > 0 then

        writeField(
            2,
            12,
            formatNumber(energy)
            .. " / "
            .. formatNumber(capacity)
            .. " FE",
            math.min(width - 2, 35)
        )

    else

        writeField(
            2,
            12,
            "ENERGY DATA UNAVAILABLE",
            math.min(width - 2, 35)
        )

    end

end


--------------------------------------------------
-- ATUALIZAR PRODUÇÃO
--------------------------------------------------

local function updateProduction(turbine)

    local production =
        functions.getProduction(turbine)

    local maxProduction =
        functions.getMaxProduction(turbine)

    local productionPercentage = 0

    if maxProduction > 0 then

        productionPercentage =
            production / maxProduction

    end

    --------------------------------------------------
    -- PORCENTAGEM
    --------------------------------------------------

    writeField(
        14,
        14,
        string.format(
            "%.1f%%",
            percent(productionPercentage)
        ),
        10
    )

    --------------------------------------------------
    -- BARRA
    --------------------------------------------------

    drawBar(
        2,
        15,
        math.min(width - 5, 30),
        productionPercentage
    )

    --------------------------------------------------
    -- VALOR
    --------------------------------------------------

    writeField(
        2,
        16,
        formatNumber(production)
        .. " / "
        .. formatNumber(maxProduction)
        .. " FE/t",
        math.min(width - 2, 35)
    )

end


--------------------------------------------------
-- ATUALIZAR STEAM INPUT
--------------------------------------------------

local function updateSteamInput(turbine)

    local input =
        functions.getSteamInput(turbine)

    writeField(
        15,
        18,
        formatNumber(input)
        .. " mB/t",
        math.max(10, width - 15)
    )

end


--------------------------------------------------
-- ATUALIZAR FLOW
--------------------------------------------------

local function updateFlow(turbine)

    local flow =
        functions.getFlow(turbine)

    local maxFlow =
        functions.getMaxFlow(turbine)

    writeField(
        15,
        19,
        formatNumber(flow)
        .. " / "
        .. formatNumber(maxFlow)
        .. " mB/t",
        math.max(10, width - 15)
    )

end


--------------------------------------------------
-- ATUALIZAR ESTRUTURA
--------------------------------------------------

local function updateStructure(turbine)

    writeField(
        10,
        24,
        functions.getBlades(turbine),
        8
    )

    writeField(
        29,
        24,
        functions.getVents(turbine),
        8
    )

    writeField(
        10,
        25,
        functions.getCoils(turbine),
        8
    )

    writeField(
        34,
        25,
        functions.getCondensers(turbine),
        8
    )

    writeField(
        13,
        26,
        functions.getDispersers(turbine),
        8
    )

end


--------------------------------------------------
-- ATUALIZAR DUMPING
--------------------------------------------------

local function updateDumping(turbine)

    local dumping =
        functions.getDumpingMode(turbine)

    if dumping then

        writeField(
            16,
            29,
            "ACTIVE",
            math.max(10, width - 16)
        )

    else

        writeField(
            16,
            29,
            "IDLE",
            math.max(10, width - 16)
        )

    end

end


--------------------------------------------------
-- ATUALIZAR STATUS
--------------------------------------------------

local function updateStatus(turbine)

    local status =
        functions.getStatus(turbine)

    writeField(
        10,
        4,
        status,
        15
    )

end


--------------------------------------------------
-- DESENHAR A INTERFACE UMA VEZ
--------------------------------------------------

drawInterface()


--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

while true do

    local turbine =
        functions.findTurbine()

    if turbine then

        updateStatus(turbine)

        updateSteam(turbine)

        updateEnergy(turbine)

        updateProduction(turbine)

        updateSteamInput(turbine)

        updateFlow(turbine)

        updateStructure(turbine)

        updateDumping(turbine)

    else

        writeField(
            10,
            4,
            "TURBINE NOT FOUND",
            math.max(15, width - 10)
        )

    end

    sleep(REFRESH_TIME)

end
