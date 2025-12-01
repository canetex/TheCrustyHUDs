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
local BASE_PATH = Engine.getScriptsDirectory() .. "/_TheCrustyHUD 2.0"

-- ================================================================
-- FUNÇÕES PRINCIPAIS
-- ================================================================

-- Complexidade: O(n) onde n = tamanho do arquivo JSON
-- Carrega um arquivo JSON e retorna como tabela Lua
-- @param filePath (string) - Caminho do arquivo JSON (relativo ou absoluto)
-- @return (table|nil) - Tabela com os dados do JSON ou nil em caso de erro
function loadJSONFile(filePath)
    if not filePath then
        print("[JSON_LOADER] Erro: Caminho do arquivo não fornecido")
        return nil
    end
    
    -- Verifica se é caminho absoluto ou relativo
    local fullPath = filePath
    if not filePath:match("^[A-Za-z]:") and not filePath:match("^/") then
        fullPath = BASE_PATH .. "/" .. filePath
    end
    
    local file = io.open(fullPath, "r")
    if not file then
        print("[JSON_LOADER] Erro: Não foi possível abrir o arquivo: " .. fullPath)
        return nil
    end
    
    -- Lê o conteúdo do arquivo
    local content = file:read("*all")
    file:close()
    
    if not content or content == "" then
        print("[JSON_LOADER] Erro: Arquivo vazio: " .. fullPath)
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
        print("[JSON_LOADER] Erro ao decodificar JSON: " .. tostring(decodedData))
        return nil
    end
    
    if not decodedData then
        print("[JSON_LOADER] Erro: Dados decodificados são nil")
        return nil
    end
    
    print("[JSON_LOADER] Arquivo carregado com sucesso: " .. fullPath)
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
    
    print("[JSON_LOADER] Variáveis globais criadas a partir de: " .. filePath)
    return data
end

-- Complexidade: O(n) onde n = tamanho da tabela
-- Salva uma tabela Lua como arquivo JSON
-- @param data (table) - Tabela Lua a ser salva
-- @param filePath (string) - Caminho onde salvar o arquivo JSON
-- @return (boolean) - true se salvo com sucesso, false caso contrário
function saveJSONFile(data, filePath)
    if not data then
        print("[JSON_LOADER] Erro: Dados não fornecidos")
        return false
    end
    
    if not filePath then
        print("[JSON_LOADER] Erro: Caminho do arquivo não fornecido")
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
        print("[JSON_LOADER] Erro ao codificar JSON: " .. tostring(jsonString))
        return false
    end
    
    -- Salva o arquivo
    local file = io.open(fullPath, "w")
    if not file then
        print("[JSON_LOADER] Erro: Não foi possível criar o arquivo: " .. fullPath)
        return false
    end
    
    file:write(jsonString)
    file:close()
    
    print("[JSON_LOADER] Arquivo salvo com sucesso: " .. fullPath)
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

print("[JSON_LOADER] Módulo carregado com sucesso")

