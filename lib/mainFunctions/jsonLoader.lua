-- ================================================================
-- JSON Loader - Sistema de Leitura e Conversão de JSON
-- ================================================================
-- VERSION v1.0.0 - JSON Loader System
--    --- DRY Principle
--    --- Single Responsibility Principle

-- DESCRIÇÃO:
-- Sistema responsável por ler arquivos JSON e converter em
-- tabelas e variáveis que possam ser manipuladas pelo main.lua

-- FUNCIONALIDADES:
-- ✅ Leitura de arquivos JSON
-- ✅ Conversão para tabelas Lua
-- ✅ Validação de dados
-- ✅ Tratamento de erros

-- ================================================================
-- VARIÁVEIS GLOBAIS
-- ================================================================

local Engine = rawget(_G or {}, "Engine")
local JSON = rawget(_G or {}, "JSON")
local Logger = rawget(_G or {}, "Logger")
local BASE_PATH = Engine.getScriptsDirectory() .. "/_TheCrustyHUD 2.0"
local MODULE_NAME = "JSON_LOADER"

-- ================================================================
-- FUNÇÕES AUXILIARES
-- ================================================================

-- Complexidade: O(1) - operação de I/O
-- Tenta garantir que o diretório existe (cria arquivo temporário se necessário)
-- @param dirPath (string) - Caminho do diretório
-- @return (boolean) - true se o diretório existe ou foi criado, false caso contrário
local function ensureDirectoryExists(dirPath)
    if not dirPath then return false end
    
    -- Tenta criar um arquivo temporário no diretório para forçar sua criação
    -- Isso funciona porque alguns sistemas criam o diretório automaticamente
    local tempPath = dirPath .. "/.temp_check"
    local tempFile = io.open(tempPath, "w")
    if tempFile then
        tempFile:close()
        -- Tenta remover o arquivo temporário (pode falhar se remove estiver desabilitado)
        pcall(function() 
            local removeFile = io.open(tempPath, "r")
            if removeFile then
                removeFile:close()
                -- Se chegou aqui, o diretório existe
            end
        end)
        return true
    end
    
    return false
end

-- ================================================================
-- FUNÇÕES PRINCIPAIS
-- ================================================================

-- Complexidade: O(n) onde n = tamanho do arquivo JSON
-- Carrega um arquivo JSON e retorna como tabela Lua
-- @param filePath (string) - Caminho do arquivo JSON (relativo ou absoluto)
-- @return (table|nil) - Tabela com os dados do JSON ou nil em caso de erro
function loadJSONFile(filePath)
    if not filePath then
        if Logger then
            Logger.error(MODULE_NAME, "Caminho do arquivo não fornecido")
        else
            print("[JSON_LOADER] Erro: Caminho do arquivo não fornecido")
        end
        return nil
    end
    
    -- Verifica se é caminho absoluto ou relativo
    local fullPath = filePath
    if not filePath:match("^[A-Za-z]:") and not filePath:match("^/") then
        fullPath = BASE_PATH .. "/" .. filePath
    end
    
    local file = io.open(fullPath, "r")
    if not file then
        -- Não imprime erro se o arquivo não existir (é esperado em alguns casos)
        return nil
    end
    
    -- Lê o conteúdo do arquivo
    local content = file:read("*all")
    file:close()
    
    if not content or content == "" then
        if Logger then
            Logger.error(MODULE_NAME, "Arquivo vazio: %s", fullPath)
        else
            print("[JSON_LOADER] Erro: Arquivo vazio: " .. fullPath)
        end
        return nil
    end
    
    -- Limpa valores problemáticos do JSON
    content = content:gsub(":%-?inf[^,}%]]*", ":0")
    content = content:gsub(":inf[^,}%]]*", ":0")
    content = content:gsub(":%-?Infinity[^,}%]]*", ":0")
    content = content:gsub(":Infinity[^,}%]]*", ":0")
    content = content:gsub(":NaN[^,}%]]*", ":0")
    
    -- Decodifica JSON
    local success, decodedData = pcall(function()
        return JSON.decode(content)
    end)
    
    if not success then
        if Logger then
            Logger.error(MODULE_NAME, "Erro ao decodificar JSON: %s", tostring(decodedData))
        else
            print("[JSON_LOADER] Erro ao decodificar JSON: " .. tostring(decodedData))
        end
        return nil
    end
    
    if not decodedData then
        if Logger then
            Logger.error(MODULE_NAME, "Dados decodificados são nil")
        else
            print("[JSON_LOADER] Erro: Dados decodificados são nil")
        end
        return nil
    end
    
    if Logger then
        Logger.info(MODULE_NAME, "Arquivo carregado com sucesso: %s", fullPath)
    else
        print("[JSON_LOADER] Arquivo carregado com sucesso: " .. fullPath)
    end
    return decodedData
end

-- Complexidade: O(n) onde n = número de chaves na tabela
-- Carrega um arquivo JSON e cria variáveis globais a partir das chaves
-- @param filePath (string) - Caminho do arquivo JSON
-- @param prefix (string|nil) - Prefixo opcional para as variáveis globais
-- @return (table|nil) - Tabela com os dados do JSON ou nil em caso de erro
function loadJSONAsGlobals(filePath, prefix)
    local data = loadJSONFile(filePath)
    if not data then
        return nil
    end
    
    prefix = prefix or ""
    
    -- Cria variáveis globais a partir das chaves do JSON
    for key, value in pairs(data) do
        local globalKey = prefix .. key
        _G[globalKey] = value
    end
    
    if Logger then
        Logger.info(MODULE_NAME, "Variáveis globais criadas a partir de: %s", filePath)
    else
        print("[JSON_LOADER] Variáveis globais criadas a partir de: " .. filePath)
    end
    return data
end

-- Complexidade: O(n) onde n = tamanho da tabela
-- Salva uma tabela Lua como arquivo JSON
-- @param data (table) - Tabela Lua a ser salva
-- @param filePath (string) - Caminho onde salvar o arquivo JSON
-- @return (boolean) - true se salvo com sucesso, false caso contrário
function saveJSONFile(data, filePath)
    if not data then
        if Logger then
            Logger.error(MODULE_NAME, "Dados não fornecidos")
        else
            print("[JSON_LOADER] Erro: Dados não fornecidos")
        end
        return false
    end
    
    if not filePath then
        if Logger then
            Logger.error(MODULE_NAME, "Caminho do arquivo não fornecido")
        else
            print("[JSON_LOADER] Erro: Caminho do arquivo não fornecido")
        end
        return false
    end
    
    -- Verifica se é caminho absoluto ou relativo
    local fullPath = filePath
    if not filePath:match("^[A-Za-z]:") and not filePath:match("^/") then
        fullPath = BASE_PATH .. "/" .. filePath
    end
    
    -- Codifica tabela para JSON
    local success, jsonString = pcall(function()
        return JSON.encode(data)
    end)
    
    if not success then
        if Logger then
            Logger.error(MODULE_NAME, "Erro ao codificar JSON: %s", tostring(jsonString))
        else
            print("[JSON_LOADER] Erro ao codificar JSON: " .. tostring(jsonString))
        end
        return false
    end
    
    -- Extrai o diretório do caminho e tenta garantir que existe
    local dirPath = fullPath:match("(.+)/")
    if dirPath then
        ensureDirectoryExists(dirPath)
    end
    
    -- Salva o arquivo
    -- Nota: Se o diretório não existir, o arquivo não será criado
    -- Isso é aceitável pois a posição do HUD não é crítica
    local file = io.open(fullPath, "w")
    if not file then
        -- Se falhar, não imprime erro (diretório pode não existir ainda)
        -- Retorna false silenciosamente
        return false
    end
    
    file:write(jsonString)
    file:close()
    
    if Logger then
        Logger.info(MODULE_NAME, "Arquivo salvo com sucesso: %s", fullPath)
    else
        print("[JSON_LOADER] Arquivo salvo com sucesso: " .. fullPath)
    end
    return true
end

-- Complexidade: O(1) - operação de validação
-- Valida se uma string é um JSON válido
-- @param jsonString (string) - String JSON a ser validada
-- @return (boolean, table|string) - true e tabela se válido, false e mensagem de erro caso contrário
function validateJSON(jsonString)
    if not jsonString or jsonString == "" then
        return false, "String JSON vazia"
    end
    
    local success, decodedData = pcall(function()
        return JSON.decode(jsonString)
    end)
    
    if not success then
        return false, tostring(decodedData)
    end
    
    return true, decodedData
end

if Logger then
    Logger.info("JSON_LOADER", "Módulo carregado com sucesso")
else
    print("[JSON_LOADER] Módulo carregado com sucesso")
end

