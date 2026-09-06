-- ==========================================
-- MEKANISM TURBINE CC
-- FUNCTIONS
-- ==========================================

local functions = {}

--------------------------------------------------
-- LOCALIZAR TURBINA
--------------------------------------------------

function functions.findTurbine()

    local names = peripheral.getNames()

    for _, name in ipairs(names) do

        local methods = peripheral.getMethods(name)

        if methods then

            for _, method in ipairs(methods) do

                if method == "getSteamFilledPercentage" then

                    return peripheral.wrap(name), name

                end

            end

        end

    end

    return nil, nil
end


--------------------------------------------------
-- VALOR SEGURO
--------------------------------------------------

function functions.safeCall(peripheralObject, method, default)

    if not peripheralObject then
        return default
    end

    if type(peripheralObject[method]) == "function" then

        local ok, result = pcall(
            peripheralObject[method]
        )

        if ok and result ~= nil then
            return result
        end

    end

    return default
end


--------------------------------------------------
-- STEAM
--------------------------------------------------

function functions.getSteam(turbine)

    return functions.safeCall(
        turbine,
        "getSteam",
        0
    )

end


function functions.getSteamCapacity(turbine)

    return functions.safeCall(
        turbine,
        "getSteamCapacity",
        0
    )

end


function functions.getSteamPercentage(turbine)

    return functions.safeCall(
        turbine,
        "getSteamFilledPercentage",
        0
    )

end


--------------------------------------------------
-- STEAM INPUT
--------------------------------------------------

function functions.getSteamInput(turbine)

    return functions.safeCall(
        turbine,
        "getLastSteamInputRate",
        0
    )

end


--------------------------------------------------
-- FLOW RATE
--------------------------------------------------

function functions.getFlow(turbine)

    return functions.safeCall(
        turbine,
        "getFlowRate",
        0
    )

end


function functions.getMaxFlow(turbine)

    return functions.safeCall(
        turbine,
        "getMaxFlowRate",
        0
    )

end


--------------------------------------------------
-- ENERGY
--------------------------------------------------

function functions.getEnergy(turbine)

    return functions.safeCall(
        turbine,
        "getEnergy",
        0
    )

end


function functions.getEnergyCapacity(turbine)

    return functions.safeCall(
        turbine,
        "getEnergyCapacity",
        0
    )

end


function functions.getEnergyPercentage(turbine)

    local energy = functions.getEnergy(turbine)
    local capacity = functions.getEnergyCapacity(turbine)

    if capacity > 0 then
        return energy / capacity
    end

    return 0

end


--------------------------------------------------
-- PRODUÇÃO
--------------------------------------------------

function functions.getProduction(turbine)

    return functions.safeCall(
        turbine,
        "getProductionRate",
        0
    )

end


function functions.getMaxProduction(turbine)

    return functions.safeCall(
        turbine,
        "getMaxProduction",
        0
    )

end


--------------------------------------------------
-- ÁGUA
--------------------------------------------------

function functions.getMaxWaterOutput(turbine)

    return functions.safeCall(
        turbine,
        "getMaxWaterOutput",
        0
    )

end


--------------------------------------------------
-- COMPONENTES
--------------------------------------------------

function functions.getBlades(turbine)

    return functions.safeCall(
        turbine,
        "getBlades",
        0
    )

end


function functions.getVents(turbine)

    return functions.safeCall(
        turbine,
        "getVents",
        0
    )

end


function functions.getCoils(turbine)

    return functions.safeCall(
        turbine,
        "getCoils",
        0
    )

end


function functions.getCondensers(turbine)

    return functions.safeCall(
        turbine,
        "getCondensers",
        0
    )

end


function functions.getDispersers(turbine)

    return functions.safeCall(
        turbine,
        "getDispersers",
        0
    )

end


--------------------------------------------------
-- DUMPING MODE
--------------------------------------------------

function functions.getDumpingMode(turbine)

    return functions.safeCall(
        turbine,
        "getDumpingMode",
        false
    )

end


--------------------------------------------------
-- STATUS
--------------------------------------------------

function functions.getStatus(turbine)

    local steam = functions.getSteam(turbine)
    local capacity = functions.getSteamCapacity(turbine)
    local production = functions.getProduction(turbine)

    if capacity <= 0 then
        return "OFFLINE"
    end

    if production > 0 then
        return "RUNNING"
    end

    if steam > 0 then
        return "IDLE"
    end

    return "OFFLINE"

end


return functions
