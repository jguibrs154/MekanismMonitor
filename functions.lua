-- ==========================================
-- MEKANISM TURBINE CC
-- FUNCTIONS
-- ==========================================

local functions = {}

--------------------------------------------------
-- CONVERTER VALORES DO MEKANISM
--------------------------------------------------

function functions.toNumber(value)

    if type(value) == "number" then
        return value
    end

    if type(value) == "table" then

        -- Alguns valores podem vir como:
        -- {amount = 1000, capacity = 2000}

        if type(value.amount) == "number" then
            return value.amount
        end

        if type(value.value) == "number" then
            return value.value
        end

        -- Caso seja uma tabela numérica
        if type(value[1]) == "number" then
            return value[1]
        end

    end

    return 0
end


--------------------------------------------------
-- LOCALIZAR TURBINA
--------------------------------------------------

function functions.findTurbine()

    for _, name in ipairs(peripheral.getNames()) do

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
-- CHAMAR MÉTODO COM SEGURANÇA
--------------------------------------------------

function functions.safeCall(turbine, method, default)

    if not turbine then
        return default
    end

    if type(turbine[method]) ~= "function" then
        return default
    end

    local ok, result = pcall(function()
        return turbine[method]()
    end)

    if not ok or result == nil then
        return default
    end

    return result
end


--------------------------------------------------
-- STEAM
--------------------------------------------------

function functions.getSteam(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getSteam",
            0
        )
    )

end


function functions.getSteamCapacity(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getSteamCapacity",
            0
        )
    )

end


function functions.getSteamPercentage(turbine)

    local value = functions.safeCall(
        turbine,
        "getSteamFilledPercentage",
        0
    )

    return functions.toNumber(value)

end


--------------------------------------------------
-- STEAM INPUT
--------------------------------------------------

function functions.getSteamInput(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getLastSteamInputRate",
            0
        )
    )

end


--------------------------------------------------
-- FLOW
--------------------------------------------------

function functions.getFlow(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getFlowRate",
            0
        )
    )

end


function functions.getMaxFlow(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getMaxFlowRate",
            0
        )
    )

end


--------------------------------------------------
-- ENERGY
--------------------------------------------------

function functions.getEnergy(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getEnergy",
            0
        )
    )

end


function functions.getEnergyCapacity(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getEnergyCapacity",
            0
        )
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

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getProductionRate",
            0
        )
    )

end


function functions.getMaxProduction(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getMaxProduction",
            0
        )
    )

end


--------------------------------------------------
-- ÁGUA
--------------------------------------------------

function functions.getMaxWaterOutput(turbine)

    return functions.toNumber(
        functions.safeCall(
            turbine,
            "getMaxWaterOutput",
            0
        )
    )

end


--------------------------------------------------
-- COMPONENTES
--------------------------------------------------

function functions.getBlades(turbine)

    return functions.toNumber(
        functions.safeCall(turbine, "getBlades", 0)
    )

end


function functions.getVents(turbine)

    return functions.toNumber(
        functions.safeCall(turbine, "getVents", 0)
    )

end


function functions.getCoils(turbine)

    return functions.toNumber(
        functions.safeCall(turbine, "getCoils", 0)
    )

end


function functions.getCondensers(turbine)

    return functions.toNumber(
        functions.safeCall(turbine, "getCondensers", 0)
    )

end


function functions.getDispersers(turbine)

    return functions.toNumber(
        functions.safeCall(turbine, "getDispersers", 0)
    )

end


--------------------------------------------------
-- DUMPING
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
