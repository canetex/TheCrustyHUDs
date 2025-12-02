-- ================================================================
-- TheCrustyHUD 2.0 - Sistema Unificado de HUD
-- ================================================================
-- VERSION v2.0.0 - Unified HUD System by The Crusty
--    --- DRY Principles
--    --- SOLID Principles
--    --- GitHub Version Control
--    --- Modular Feature Architecture

-- DESCRIÇÃO:
-- Sistema unificado de HUD que agrega múltiplas funcionalidades
-- de scripts descentralizados em uma única interface modular

-- FUNCIONALIDADES:
-- ✅ Sistema de HUD genérico e reutilizável
-- ✅ Sistema de configuração persistente
-- ✅ Atualização automática via GitHub
-- ✅ Arquitetura modular e extensível

-- ================================================================
-- ALIASES PARA GLOBAIS (Core Functions)
-- ================================================================

local Player = rawget(_G or {}, "Player")
local CaveBot = rawget(_G or {}, "CaveBot")
local Client = rawget(_G or {}, "Client")
local Container = rawget(_G or {}, "Container")
local Creature = rawget(_G or {}, "Creature")
local Engine = rawget(_G or {}, "Engine")
local Enums = rawget(_G or {}, "Enums")
local Game = rawget(_G or {}, "Game")
local HotkeyManager = rawget(_G or {}, "HotkeyManager")
local HUD = rawget(_G or {}, "HUD")
local Inventory = rawget(_G or {}, "Inventory")
local Map = rawget(_G or {}, "Map")
local Npc = rawget(_G or {}, "Npc")
local Sound = rawget(_G or {}, "Sound")
local Spells = rawget(_G or {}, "Spells")
local Timer = rawget(_G or {}, "Timer")
local JSON = rawget(_G or {}, "JSON")

-- ================================================================
-- CONFIGURAÇÕES GLOBAIS
-- ================================================================

local SCRIPT_VERSION = "2.0.0"
local SCRIPT_NAME = "TheCrustyHUD"
local BASE_PATH = Engine.getScriptsDirectory() .. "/_TheCrustyHUD 2.0"

-- ================================================================
-- VARIÁVEIS GLOBAIS
-- ================================================================

local loadedModules = {}
local configData = nil

-- ================================================================
-- CONFIGURAÇÃO DE PATHS PARA DEPENDÊNCIAS HTTP
-- ================================================================

-- Complexidade: O(n) onde n = número de paths
-- Configura os paths do package para carregar dependências HTTP
local function setupPackagePaths()
    local pathsBaseDir = Engine.getScriptsDirectory()
    
    -- Função auxiliar para adicionar paths
    local function addPaths(paths, basePath)
        local parsedPaths = basePath
        for _, path in ipairs(paths) do
            parsedPaths = parsedPaths .. ";" .. pathsBaseDir .. "\\dlls_lib\\" .. path
        end
        return parsedPaths
    end
    
    -- Detecta versão do cliente verificando presença de Qt5Core.dll
    -- Se existir, é cliente 13x, senão é 14x+
    local qt, _error = io.open("Qt5Core.dll")
    local luaPaths = {}
    local cpaths = {}
    
    if qt or (_error and (_error:lower()):find("permission")) then
        if qt then
            qt:close()
        end
        -- Cliente 13x
        luaPaths = { "lua\\?.lua", "lua\\socket\\?.lua" }
        cpaths = { "?.dll", "lua\\?.dll" }
    else
        -- Cliente 14x+
        luaPaths = { "64bits\\lua\\?.lua", "64bits\\lua\\socket\\?.lua" }
        cpaths = { "64bits\\?.dll", "64bits\\lua\\?.dll" }
    end
    
    -- Configura package.path e package.cpath
    package.path = addPaths(luaPaths, package.path)
    package.cpath = addPaths(cpaths, package.cpath)
end

-- ================================================================
-- INICIALIZAÇÃO
-- ================================================================

print("\n\n[" .. SCRIPT_NAME .. " v" .. SCRIPT_VERSION .. "] Carregando...\n\n")

-- Configura paths para dependências HTTP
setupPackagePaths()

-- Carrega funções principais
local function loadMainFunctions()
    local mainFunctionsPath = BASE_PATH .. "/lib/mainFunctions"
    
    -- Carrega jsonLoader
    local jsonLoaderPath = mainFunctionsPath .. "/jsonLoader.lua"
    local file = io.open(jsonLoaderPath, "r")
    if file then
        file:close()
        dofile(jsonLoaderPath)
        print("[" .. SCRIPT_NAME .. "] jsonLoader carregado")
    else
        print("[" .. SCRIPT_NAME .. "] AVISO: jsonLoader não encontrado em " .. jsonLoaderPath)
    end
    
    -- Carrega updateHUD
    local updateHUDPath = mainFunctionsPath .. "/updateHUD.lua"
    file = io.open(updateHUDPath, "r")
    if file then
        file:close()
        dofile(updateHUDPath)
        print("[" .. SCRIPT_NAME .. "] updateHUD carregado")
    else
        print("[" .. SCRIPT_NAME .. "] AVISO: updateHUD não encontrado em " .. updateHUDPath)
    end
end

-- Carrega sistema de atualização do GitHub
local function loadGitLoader()
    local gitLoaderPath = BASE_PATH .. "/lib/gitLoader/gitLoader.lua"
    local file = io.open(gitLoaderPath, "r")
    if file then
        file:close()
        dofile(gitLoaderPath)
        print("[" .. SCRIPT_NAME .. "] gitLoader carregado")
    else
        print("[" .. SCRIPT_NAME .. "] AVISO: gitLoader não encontrado em " .. gitLoaderPath)
    end
end

-- Carrega funções de features
local function loadFeatures()
    local featuresPath = BASE_PATH .. "/lib/featuresFunctions"
    
    -- Carrega demoImplementation
    local demoImplementationPath = featuresPath .. "/demoImplementation.lua"
    local file = io.open(demoImplementationPath, "r")
    if file then
        file:close()
        dofile(demoImplementationPath)
        print("[" .. SCRIPT_NAME .. "] demoImplementation carregado")
    else
        print("[" .. SCRIPT_NAME .. "] AVISO: demoImplementation não encontrado em " .. demoImplementationPath)
    end
end

-- ================================================================
-- FUNÇÃO PRINCIPAL DE CARREGAMENTO
-- ================================================================

local function initialize()
    -- Carrega funções principais primeiro
    loadMainFunctions()
    
    -- Carrega sistema de atualização do GitHub
    loadGitLoader()
    
    -- Carrega funções de features
    loadFeatures()
    
    -- Inicializa HUD de atualização se a função existir
    if _G.createUpdateHUD and type(_G.createUpdateHUD) == "function" then
        _G.createUpdateHUD()
    end
    
    -- Inicializa demo implementation se a função existir
    if _G.initDemoImplementation and type(_G.initDemoImplementation) == "function" then
        -- Define posições customizadas (opcional - pode ser nil para usar padrão)
        local demoPositions = {
            small_icon = {x = 300, y = 300},
            big_icon = {x = 350, y = 350},
            text = {x = 350, y = 350}
        }
        _G.initDemoImplementation(demoPositions)
        print("[" .. SCRIPT_NAME .. "] demoImplementation inicializado")
    end
    
    print("[" .. SCRIPT_NAME .. "] Inicialização concluída!\n")
end

-- Executa inicialização
initialize()

local hudTeste = HUD.new(400,400,3108,true)
hudTeste:setDraggable(true)
hudTeste:setCallback(function()
    if _G.updatePositionsDemoImplementation and type(_G.updatePositionsDemoImplementation) == "function" then
        _G.updatePositionsDemoImplementation({
            small_icon = {x = 600, y = 400},
            big_icon = {x = 450, y = 450},
            text = {x = 450, y = 450}
        })
    end
end)

print("[" .. SCRIPT_NAME .. "] Carregado com sucesso!\n")

