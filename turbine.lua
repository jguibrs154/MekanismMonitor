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
-- LOCALIZAR MONITOR
--------------------------------------------------

local monitor = nil
local monitorName = nil

for _, name in ipairs(peripheral.getNames()) do

    if peripheral.getType(name) == "monitor" then

        monitor = peripheral.wrap(name)
        monitorName = name
        break

    end

end


--------------------------------------------------
-- VERIFICAR MONITOR
--------------------------------------------------

if not monitor then

    print("ERRO: Nenhum monitor encontrado.")
    print("")
    print("Conecte um monitor ao computador.")
    print("")

    return

end


--------------------------------------------------
-- CONFIGURAR MONITOR
--------------------------------------------------

monitor.setTextScale(0.5)

term.redirect(monitor)

term.clear()
term.setCursorPos(1, 1)


--------------------------------------------------
-- FORMATAR NÚMEROS
--------------------------------------------------

local function formatNumber(number)

    if not number then
        return "0"
    end

    if number >= 1000000000 then

        return string.format(
            "%.2f B",
            number / 1000000000
        )

    elseif number >= 1000000 then

        return string.format(
            "%.2f M",
            number / 1000000
        )

    elseif number >= 1000 then

        return string.format(
            "%.2f K",
            number / 1000
        )

    else

        return string.format(
            "%.0f",
            number
        )

    end

end


--------------------------------------------------
-- PORCENTAGEM
--------------------------------------------------

local function percentage(value)

    if not value then
        return 0
    end

    if value < 0 then
        value = 0
    end

    if value > 1 then
        value = 1
    end

    return math.floor(value * 1000) / 10

end


--------------------------------------------------
-- BARRA
--------------------------------------------------

local function drawBar(
    x,
    y,
    width,
    value
)

    if value < 0 then
        value = 0
    end

    if value > 1 then
        value = 1
    end

    local filled =
        math.floor(width * value)

    term.setCursorPos(x, y)

    term.write("[")

    for i = 1, width do

        if i <= filled then

            term.write("=")

        else

            term.write(" ")

        end

    end

    term.write("]")

end


--------------------------------------------------
-- CENTRALIZAR TEXTO
--------------------------------------------------

local function centerText(
    y,
    text
)

    local width = select(
        1,
        term.getSize()
    )

    local x =
        math.floor(
            (width - #text) / 2
        ) + 1

    if x < 1 then
        x = 1
    end

    term.setCursorPos(x, y)

    term.write(text)

end


--------------------------------------------------
-- LINHA
--------------------------------------------------

local function line(y)

    local width = select(
        1,
        term.getSize()
    )

    term.setCursorPos(1, y)

    term.write(
        string.rep(
            "-",
            width
        )
    )

end


--------------------------------------------------
-- DESENHAR PAINEL
--------------------------------------------------

local function draw(turbine)

    term.clear()
    term.setCursorPos(1, 1)

    local width, height =
        term.getSize()


    --------------------------------------------------
    -- TÍTULO
    --------------------------------------------------

    centerText(
        1,
        "INDUSTRIAL TURBINE CONTROL"
    )

    line(2)


    --------------------------------------------------
    -- STATUS
    --------------------------------------------------

    local status =
        functions.getStatus(turbine)

    term.setCursorPos(2, 3)

    term.write(
        "STATUS: "
        .. status
    )


    --------------------------------------------------
    -- STEAM
    --------------------------------------------------

    local steam =
        functions.getSteam(turbine)

    local steamCapacity =
        functions.getSteamCapacity(turbine)

    local steamPercentage =
        functions.getSteamPercentage(turbine)

    term.setCursorPos(2, 5)

    term.write(
        "STEAM "
        .. string.format(
            "%.1f%%",
            percentage(steamPercentage)
        )
    )

    drawBar(
        2,
        6,
        math.min(width - 15, 30),
        steamPercentage
    )

    term.setCursorPos(2, 7)

    term.write(
        formatNumber(steam)
        .. " / "
        .. formatNumber(steamCapacity)
        .. " mB"
    )


    --------------------------------------------------
    -- ENERGY
    --------------------------------------------------

    local energy =
        functions.getEnergy(turbine)

    local energyCapacity =
        functions.getEnergyCapacity(turbine)

    local energyPercentage =
        functions.getEnergyPercentage(turbine)

    term.setCursorPos(2, 9)

    term.write(
        "ENERGY "
        .. string.format(
            "%.1f%%",
            percentage(energyPercentage)
        )
    )

    drawBar(
        2,
        10,
        math.min(width - 15, 30),
        energyPercentage
    )

    term.setCursorPos(2, 11)

    if energyCapacity > 0 then

        term.write(
            formatNumber(energy)
            .. " / "
            .. formatNumber(energyCapacity)
            .. " FE"
        )

    else

        term.write(
            "ENERGY DATA UNAVAILABLE"
        )

    end


    --------------------------------------------------
    -- PRODUÇÃO
    --------------------------------------------------

    local production =
        functions.getProduction(turbine)

    local maxProduction =
        functions.getMaxProduction(turbine)

    local productionPercentage = 0

    if maxProduction > 0 then

        productionPercentage =
            production / maxProduction

    end

    term.setCursorPos(2, 13)

    term.write(
        "PRODUCTION "
        .. string.format(
            "%.1f%%",
            percentage(productionPercentage)
        )
    )

    drawBar(
        2,
        14,
        math.min(width - 15, 30),
        productionPercentage
    )

    term.setCursorPos(2, 15)

    term.write(
        formatNumber(production)
        .. " / "
        .. formatNumber(maxProduction)
        .. " FE/t"
    )


    --------------------------------------------------
    -- STEAM INPUT
    --------------------------------------------------

    local steamInput =
        functions.getSteamInput(turbine)

    term.setCursorPos(2, 17)

    term.write(
        "STEAM INPUT: "
        .. formatNumber(steamInput)
        .. " mB/t"
    )


    --------------------------------------------------
    -- FLOW
    --------------------------------------------------

    local flow =
        functions.getFlow(turbine)

    local maxFlow =
        functions.getMaxFlow(turbine)

    term.setCursorPos(2, 18)

    term.write(
        "FLOW RATE: "
        .. formatNumber(flow)
        .. " / "
        .. formatNumber(maxFlow)
        .. " mB/t"
    )


    --------------------------------------------------
    -- ESTRUTURA
    --------------------------------------------------

    line(20)

    centerText(
        21,
        "TURBINE STRUCTURE"
    )

    term.setCursorPos(2, 23)

    term.write(
        "BLADES: "
        .. functions.getBlades(turbine)
    )

    term.setCursorPos(2, 24)

    term.write(
        "COILS: "
        .. functions.getCoils(turbine)
    )

    term.setCursorPos(20, 23)

    term.write(
        "VENTS: "
        .. functions.getVents(turbine)
    )

    term.setCursorPos(20, 24)

    term.write(
        "CONDENSERS: "
        .. functions.getCondensers(turbine)
    )

    term.setCursorPos(2, 25)

    term.write(
        "DISPERSERS: "
        .. functions.getDispersers(turbine)
    )


    --------------------------------------------------
    -- DUMPING
    --------------------------------------------------

    local dumping =
        functions.getDumpingMode(turbine)

    term.setCursorPos(2, 27)

    if dumping then

        term.write(
            "DUMPING MODE: ACTIVE"
        )

    else

        term.write(
            "DUMPING MODE: IDLE"
        )

    end


    --------------------------------------------------
    -- RODAPÉ
    --------------------------------------------------

    line(height - 1)

    term.setCursorPos(2, height)

    term.write(
        "AUTO REFRESH: "
        .. REFRESH_TIME
        .. "s"
    )

end


--------------------------------------------------
-- LOOP PRINCIPAL
--------------------------------------------------

while true do

    local turbine, turbineName =
        functions.findTurbine()

    if not turbine then

        term.clear()
        term.setCursorPos(1, 1)

        centerText(
            3,
            "TURBINE NOT FOUND"
        )

        centerText(
            5,
            "Waiting for Mekanism turbine..."
        )

        sleep(2)

    else

        draw(turbine)

        sleep(REFRESH_TIME)

    end

end
