-- ================================================================
-- Logger - Sistema Centralizado de Controle de Logs e Prints
-- ================================================================
-- VERSION v1.0.0 - Centralized Logging System
--    --- DRY Principle
--    --- Single Responsibility Principle
--    --- Centralized Message Control

-- DESCRIÇÃO:
-- Sistema responsável por controlar e padronizar todas as mensagens
-- de log e prints do sistema TheCrustyHUD 2.0, permitindo controle
-- de verbosidade, níveis de log e formatação padronizada

-- FUNCIONALIDADES:
-- ✅ Níveis de log (DEBUG, INFO, WARNING, ERROR)
-- ✅ Controle de verbosidade por módulo
-- ✅ Formatação padronizada de mensagens
-- ✅ Filtros por módulo e nível
-- ✅ Suporte a salvamento em arquivo (opcional)
-- ✅ Timestamps nas mensagens

-- ================================================================
-- CONFIGURAÇÕES
-- ================================================================

local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4,
    NONE = 5  -- Desabilita todos os logs
}

local DEFAULT_CONFIG = {
    level = LOG_LEVELS.INFO,  -- Nível padrão
    showTimestamp = true,     -- Mostrar timestamp
    showModule = true,        -- Mostrar nome do módulo
    saveToFile = false,       -- Salvar em arquivo
    logFile = nil,           -- Caminho do arquivo de log
    enabledModules = {},     -- Módulos habilitados (vazio = todos)
    disabledModules = {}     -- Módulos desabilitados
}

-- ================================================================
-- VARIÁVEIS GLOBAIS
-- ================================================================

local Engine = rawget(_G or {}, "Engine")
local BASE_PATH = Engine.getScriptsDirectory() .. "/_TheCrustyHUD 2.0"

local loggerConfig = {}
local logFileHandle = nil

-- Inicializa configuração com valores padrão
for key, value in pairs(DEFAULT_CONFIG) do
    loggerConfig[key] = value
end

-- ================================================================
-- FUNÇÕES AUXILIARES
-- ================================================================

-- Complexidade: O(1) - operação de string
-- Obtém timestamp formatado
local function getTimestamp()
    if not loggerConfig.showTimestamp then
        return ""
    end
    
    local time = os.date("%H:%M:%S")
    return "[" .. time .. "] "
end

-- Complexidade: O(1) - operação de string
-- Formata nome do módulo
local function formatModule(moduleName)
    if not loggerConfig.showModule or not moduleName then
        return ""
    end
    
    return "[" .. (moduleName or "SYSTEM") .. "] "
end

-- Complexidade: O(1) - operação de I/O
-- Abre arquivo de log se necessário
local function openLogFile()
    if not loggerConfig.saveToFile or logFileHandle then
        return
    end
    
    if loggerConfig.logFile then
        logFileHandle = io.open(loggerConfig.logFile, "a")
        if not logFileHandle then
            loggerConfig.saveToFile = false
            print("[LOGGER] AVISO: Não foi possível abrir arquivo de log: " .. tostring(loggerConfig.logFile))
        end
    end
end

-- Complexidade: O(1) - operação de I/O
-- Fecha arquivo de log
local function closeLogFile()
    if logFileHandle then
        logFileHandle:close()
        logFileHandle = nil
    end
end

-- Complexidade: O(1) - operação de I/O
-- Escreve no arquivo de log
local function writeToFile(message)
    if logFileHandle then
        logFileHandle:write(message .. "\n")
        logFileHandle:flush()
    end
end

-- Complexidade: O(n) onde n = número de módulos desabilitados
-- Verifica se o módulo está habilitado
local function isModuleEnabled(moduleName)
    -- Se há lista de módulos habilitados e o módulo não está nela, desabilita
    if #loggerConfig.enabledModules > 0 then
        for _, enabled in ipairs(loggerConfig.enabledModules) do
            if enabled == moduleName then
                return true
            end
        end
        return false
    end
    
    -- Se há lista de módulos desabilitados e o módulo está nela, desabilita
    for _, disabled in ipairs(loggerConfig.disabledModules) do
        if disabled == moduleName then
            return false
        end
    end
    
    return true
end

-- ================================================================
-- FUNÇÕES PRINCIPAIS
-- ================================================================

-- Complexidade: O(1) - operação de string e I/O
-- Função principal de log
-- @param level (number) - Nível do log (LOG_LEVELS)
-- @param moduleName (string) - Nome do módulo
-- @param message (string) - Mensagem a ser logada
-- @param ... (any) - Argumentos adicionais para formatação
local function log(level, moduleName, message, ...)
    -- Verifica se o nível está habilitado
    if level < loggerConfig.level then
        return
    end
    
    -- Verifica se o módulo está habilitado
    if not isModuleEnabled(moduleName) then
        return
    end
    
    -- Formata mensagem com argumentos adicionais
    local formattedMessage = message
    if select("#", ...) > 0 then
        formattedMessage = string.format(message, ...)
    end
    
    -- Monta mensagem completa
    local timestamp = getTimestamp()
    local module = formatModule(moduleName)
    local fullMessage = timestamp .. module .. formattedMessage
    
    -- Imprime no console
    print(fullMessage)
    
    -- Salva em arquivo se configurado
    if loggerConfig.saveToFile then
        openLogFile()
        writeToFile(fullMessage)
    end
end

-- Complexidade: O(1)
-- Log de nível DEBUG
-- @param moduleName (string) - Nome do módulo
-- @param message (string) - Mensagem
-- @param ... (any) - Argumentos adicionais
function Logger.debug(moduleName, message, ...)
    log(LOG_LEVELS.DEBUG, moduleName, message, ...)
end

-- Complexidade: O(1)
-- Log de nível INFO
-- @param moduleName (string) - Nome do módulo
-- @param message (string) - Mensagem
-- @param ... (any) - Argumentos adicionais
function Logger.info(moduleName, message, ...)
    log(LOG_LEVELS.INFO, moduleName, message, ...)
end

-- Complexidade: O(1)
-- Log de nível WARNING
-- @param moduleName (string) - Nome do módulo
-- @param message (string) - Mensagem
-- @param ... (any) - Argumentos adicionais
function Logger.warning(moduleName, message, ...)
    log(LOG_LEVELS.WARNING, moduleName, message, ...)
end

-- Complexidade: O(1)
-- Log de nível ERROR
-- @param moduleName (string) - Nome do módulo
-- @param message (string) - Mensagem
-- @param ... (any) - Argumentos adicionais
function Logger.error(moduleName, message, ...)
    log(LOG_LEVELS.ERROR, moduleName, message, ...)
end

-- Complexidade: O(1)
-- Configura o nível de log
-- @param level (string|number) - Nível de log ("DEBUG", "INFO", "WARNING", "ERROR", "NONE" ou número)
function Logger.setLevel(level)
    if type(level) == "string" then
        level = level:upper()
        if LOG_LEVELS[level] then
            loggerConfig.level = LOG_LEVELS[level]
        else
            Logger.warning("LOGGER", "Nível de log inválido: " .. level)
        end
    elseif type(level) == "number" then
        loggerConfig.level = level
    end
end

-- Complexidade: O(1)
-- Obtém o nível de log atual
-- @return (number) - Nível de log atual
function Logger.getLevel()
    return loggerConfig.level
end

-- Complexidade: O(1)
-- Habilita/desabilita timestamp
-- @param enabled (boolean) - Habilitar timestamp
function Logger.setTimestamp(enabled)
    loggerConfig.showTimestamp = enabled ~= false
end

-- Complexidade: O(1)
-- Habilita/desabilita exibição do módulo
-- @param enabled (boolean) - Habilitar exibição do módulo
function Logger.setShowModule(enabled)
    loggerConfig.showModule = enabled ~= false
end

-- Complexidade: O(n) onde n = número de módulos
-- Habilita módulos específicos (apenas estes serão logados)
-- @param modules (table) - Lista de nomes de módulos
function Logger.enableModules(modules)
    loggerConfig.enabledModules = modules or {}
end

-- Complexidade: O(n) onde n = número de módulos
-- Desabilita módulos específicos
-- @param modules (table) - Lista de nomes de módulos
function Logger.disableModules(modules)
    loggerConfig.disabledModules = modules or {}
end

-- Complexidade: O(1)
-- Habilita/desabilita salvamento em arquivo
-- @param enabled (boolean) - Habilitar salvamento
-- @param filePath (string|nil) - Caminho do arquivo (opcional)
function Logger.setSaveToFile(enabled, filePath)
    loggerConfig.saveToFile = enabled ~= false
    
    if enabled and filePath then
        loggerConfig.logFile = filePath
        closeLogFile()  -- Fecha arquivo anterior se existir
    elseif not enabled then
        closeLogFile()
    end
end

-- Complexidade: O(1)
-- Obtém configuração atual
-- @return (table) - Cópia da configuração atual
function Logger.getConfig()
    local configCopy = {}
    for key, value in pairs(loggerConfig) do
        if type(value) == "table" then
            configCopy[key] = {}
            for k, v in pairs(value) do
                configCopy[key][k] = v
            end
        else
            configCopy[key] = value
        end
    end
    return configCopy
end

-- Complexidade: O(1)
-- Limpa recursos (fecha arquivo de log)
function Logger.cleanup()
    closeLogFile()
end

-- ================================================================
-- INICIALIZAÇÃO
-- ================================================================

-- Cria tabela Logger global
Logger = {
    debug = Logger.debug,
    info = Logger.info,
    warning = Logger.warning,
    error = Logger.error,
    setLevel = Logger.setLevel,
    getLevel = Logger.getLevel,
    setTimestamp = Logger.setTimestamp,
    setShowModule = Logger.setShowModule,
    enableModules = Logger.enableModules,
    disableModules = Logger.disableModules,
    setSaveToFile = Logger.setSaveToFile,
    getConfig = Logger.getConfig,
    cleanup = Logger.cleanup,
    LOG_LEVELS = LOG_LEVELS
}

-- Exporta para global
_G.Logger = Logger

print("[LOGGER] Sistema de logs carregado com sucesso")

