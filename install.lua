-- ==========================================
-- MEKANISM TURBINE CC
-- INSTALLER
-- ==========================================

local BASE_URL =
    "https://raw.githubusercontent.com/SEU_USUARIO/Mekanism-Turbine-CC/main/"

print("======================================")
print("   MEKANISM TURBINE CONTROL")
print("           INSTALLER")
print("======================================")
print("")

local files = {
    "functions.lua",
    "turbine.lua",
    "startup.lua"
}

for _, file in ipairs(files) do

    print("Baixando " .. file .. "...")

    local success = shell.run(
        "wget",
        BASE_URL .. file,
        file
    )

    if not success then
        print("")
        print("ERRO ao baixar: " .. file)
        print("")
        print("Verifique:")
        print("- Internet do ComputerCraft")
        print("- URL do GitHub")
        print("- Nome do repositorio")
        print("")

        return
    end

end

print("")
print("======================================")
print("        INSTALACAO CONCLUIDA")
print("======================================")
print("")

print("Arquivos instalados:")
print("- functions.lua")
print("- turbine.lua")
print("- startup.lua")
print("")

print("Reiniciando computador...")
sleep(3)

os.reboot()
