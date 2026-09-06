-- ==========================================
-- MEKANISM TURBINE CC - STARTUP
-- ==========================================

local BASE_URL = "https://raw.githubusercontent.com/SEU_USUARIO/Mekanism-Turbine-CC/main/"

print("================================")
print("  MEKANISM TURBINE CONTROLLER")
print("================================")
print("")

print("Baixando functions.lua...")

shell.run(
    "wget",
    BASE_URL .. "functions.lua",
    "functions.lua"
)

print("Baixando turbine.lua...")

shell.run(
    "wget",
    BASE_URL .. "turbine.lua",
    "turbine.lua"
)

print("")
print("Arquivos atualizados.")
print("Iniciando sistema...")
sleep(1)

shell.run("turbine.lua")
