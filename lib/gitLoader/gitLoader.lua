-- ================================================================
-- Git Loader - Sistema de Verificação e Atualização via GitHub
-- ================================================================
-- VERSION v1.0.0 - GitHub Version Control System
--    --- DRY Principle
--    --- Single Responsibility Principle
--    --- Version Control

-- DESCRIÇÃO:
-- Sistema responsável por verificar a versão dos arquivos no
-- repositório GitHub e atualizá-los quando necessário

-- FUNCIONALIDADES:
-- ✅ Verificação de versão via GitHub API
-- ✅ Download de arquivos atualizados
-- ✅ Backup automático antes de atualizar
-- ✅ Controle de versão de arquivos

-- ================================================================
-- CONFIGURAÇÕES
-- ================================================================

local GITHUB_CONFIG = {
    REPO_OWNER = "canetex",  -- Usuário/organização do GitHub
    REPO_NAME = "TheCrustyHUDs",  -- Nome do repositório
    BRANCH = "main",  -- Branch padrão
    BASE_URL = "https://api.github.com/repos",
    RAW_URL = "https://raw.githubusercontent.com"
}

-- ================================================================
-- VARIÁVEIS GLOBAIS
-- ================================================================

local Engine = rawget(_G or {}, "Engine")
local JSON = rawget(_G or {}, "JSON")
local Logger = rawget(_G or {}, "Logger")
local BASE_PATH = Engine.getScriptsDirectory() .. "/_TheCrustyHUD 2.0"
local MODULE_NAME = "GIT_LOADER"

-- Tenta carregar dependências HTTP
local http, ltn12
local http_ok, http_result = pcall(function() return require("socket.http") end)
if http_ok then
    http = http_result
end

local ltn12_ok, ltn12_result = pcall(function() return require("ltn12") end)
if ltn12_ok then
    ltn12 = ltn12_result
end

-- ================================================================
-- FUNÇÕES AUXILIARES
-- ================================================================

-- Complexidade: O(1) - operação de string
local function getGitHubApiUrl(path)
    return GITHUB_CONFIG.BASE_URL .. "/" .. GITHUB_CONFIG.REPO_OWNER .. "/" .. GITHUB_CONFIG.REPO_NAME .. "/contents/" .. path .. "?ref=" .. GITHUB_CONFIG.BRANCH
end

-- Complexidade: O(1) - operação de string
local function getRawGitHubUrl(path)
    return GITHUB_CONFIG.RAW_URL .. "/" .. GITHUB_CONFIG.REPO_OWNER .. "/" .. GITHUB_CONFIG.REPO_NAME .. "/" .. GITHUB_CONFIG.BRANCH .. "/" .. path
end

-- Complexidade: O(1) - operação de I/O
local function createBackup(filePath)
    if not filePath then return false end
    
    local file = io.open(filePath, "r")
    if not file then return false end
    
    local content = file:read("*all")
    file:close()
    
    local backupPath = filePath .. ".backup"
    local backupFile = io.open(backupPath, "w")
    if not backupFile then return false end
    
    backupFile:write(content)
    backupFile:close()
    
    return true
end

-- ================================================================
-- FUNÇÕES PRINCIPAIS
-- ================================================================

-- Complexidade: O(1) - operação HTTP
-- Verifica a versão de um arquivo específico no GitHub
-- @param filePath (string) - Caminho relativo do arquivo no repositório
-- @return (string|nil) - SHA do arquivo (versão) ou nil em caso de erro
function checkFileVersion(filePath)
    if not http or not ltn12 or not JSON then
        if Logger then
            Logger.warning(MODULE_NAME, "Dependências HTTP não disponíveis. Modo offline.")
        else
            print("[GIT_LOADER] AVISO: Dependências HTTP não disponíveis. Modo offline.")
        end
        return nil
    end
    
    local url = getGitHubApiUrl(filePath)
    local response_body = {}
    
    local status_code = nil
    local success = pcall(function()
        local _, status = http.request{
            url = url,
            method = "GET",
            sink = ltn12.sink.table(response_body),
            headers = {
                ["User-Agent"] = "TheCrustyHUD-2.0",
                ["Accept"] = "application/vnd.github.v3+json"
            }
        }
        status_code = status
    end)
    
    if not success or not status_code or status_code ~= 200 then
        if Logger then
            Logger.error(MODULE_NAME, "Erro ao verificar versão de %s. Código HTTP: %s", filePath, tostring(status_code or "desconhecido"))
        else
            print("[GIT_LOADER] Erro ao verificar versão de " .. filePath .. ". Código HTTP: " .. tostring(status_code or "desconhecido"))
        end
        return nil
    end
    
    local response_json = table.concat(response_body)
    local data = JSON.decode(response_json)
    
    if data and data.sha then
        return data.sha
    end
    
    return nil
end

-- Complexidade: O(n) onde n = tamanho do arquivo
-- Baixa e atualiza um arquivo do GitHub
-- @param filePath (string) - Caminho relativo do arquivo no repositório
-- @param localPath (string) - Caminho local onde salvar o arquivo
-- @return (boolean) - true se atualizado com sucesso, false caso contrário
function updateFileFromGitHub(filePath, localPath)
    if not http or not ltn12 then
        if Logger then
            Logger.warning(MODULE_NAME, "Dependências HTTP não disponíveis. Modo offline.")
        else
            print("[GIT_LOADER] AVISO: Dependências HTTP não disponíveis. Modo offline.")
        end
        return false
    end
    
    -- Cria backup antes de atualizar
    if localPath then
        createBackup(localPath)
    end
    
    local url = getRawGitHubUrl(filePath)
    local response_body = {}
    
    local status_code = nil
    local success = pcall(function()
        local _, status = http.request{
            url = url,
            method = "GET",
            sink = ltn12.sink.table(response_body),
            headers = {
                ["User-Agent"] = "TheCrustyHUD-2.0"
            }
        }
        status_code = status
    end)
    
    if not success or not status_code or status_code ~= 200 then
        if Logger then
            Logger.error(MODULE_NAME, "Erro ao baixar %s. Código HTTP: %s", filePath, tostring(status_code or "desconhecido"))
        else
            print("[GIT_LOADER] Erro ao baixar " .. filePath .. ". Código HTTP: " .. tostring(status_code or "desconhecido"))
        end
        return false
    end
    
    local content = table.concat(response_body)
    
    -- Salva o arquivo localmente
    if localPath then
        -- Tenta abrir o arquivo em modo de escrita (sobrescreve se existir)
        local file = io.open(localPath, "w")
        if file then
            -- Escreve o conteúdo
            file:write(content)
            -- Força flush para garantir que o conteúdo seja escrito
            file:flush()
            file:close()
            
            -- Verifica se o arquivo foi salvo corretamente lendo-o de volta
            local verifyFile = io.open(localPath, "r")
            if verifyFile then
                local savedContent = verifyFile:read("*all")
                verifyFile:close()
                
                -- Compara o conteúdo salvo com o conteúdo baixado
                if savedContent == content then
                    if Logger then
                        Logger.info(MODULE_NAME, "Arquivo atualizado e verificado: %s", localPath)
                    else
                        print("[GIT_LOADER] Arquivo atualizado e verificado: " .. localPath)
                    end
                    
                    -- Salva a versão (SHA) do arquivo atualizado
                    local remoteSha = checkFileVersion(filePath)
                    if remoteSha then
                        local versionFile = io.open(localPath .. ".version", "w")
                        if versionFile then
                            versionFile:write(remoteSha)
                            versionFile:flush()
                            versionFile:close()
                        end
                    end
                    
                    return true
                else
                    if Logger then
                        Logger.error(MODULE_NAME, "Erro: Conteúdo do arquivo não corresponde após salvar: %s", localPath)
                    else
                        print("[GIT_LOADER] ERRO: Conteúdo do arquivo não corresponde após salvar: " .. localPath)
                    end
                    return false
                end
            else
                if Logger then
                    Logger.error(MODULE_NAME, "Erro: Não foi possível verificar arquivo salvo: %s", localPath)
                else
                    print("[GIT_LOADER] ERRO: Não foi possível verificar arquivo salvo: " .. localPath)
                end
                return false
            end
        else
            if Logger then
                Logger.error(MODULE_NAME, "Erro ao abrir arquivo para escrita: %s", localPath)
            else
                print("[GIT_LOADER] Erro ao abrir arquivo para escrita: " .. localPath)
            end
            return false
        end
    end
    
    return false
end

-- Complexidade: O(1) - operação de comparação
-- Compara versões locais com versões remotas
-- @param filePath (string) - Caminho relativo do arquivo no repositório
-- @param localPath (string) - Caminho local do arquivo
-- @return (boolean) - true se há atualização disponível, false caso contrário
function hasUpdateAvailable(filePath, localPath)
    local remoteSha = checkFileVersion(filePath)
    if not remoteSha then
        return false
    end
    
    -- Lê SHA local se existir arquivo de versão
    local versionFile = io.open(localPath .. ".version", "r")
    local localSha = nil
    if versionFile then
        localSha = versionFile:read("*line")
        versionFile:close()
    end
    
    if localSha ~= remoteSha then
        return true
    end
    
    return false
end

-- Complexidade: O(n) onde n = número de arquivos
-- Atualiza múltiplos arquivos do GitHub
-- @param fileList (table) - Tabela com {filePath, localPath}
-- @return (table) - Tabela com resultados {filePath, success}
function updateMultipleFiles(fileList)
    local results = {}
    
    for _, fileInfo in ipairs(fileList) do
        local filePath = fileInfo.filePath
        local localPath = fileInfo.localPath
        
        local success = updateFileFromGitHub(filePath, localPath)
        
        if success then
            -- Salva versão atualizada
            local versionFile = io.open(localPath .. ".version", "w")
            if versionFile then
                local remoteSha = checkFileVersion(filePath)
                if remoteSha then
                    versionFile:write(remoteSha)
                end
                versionFile:close()
            end
        end
        
        table.insert(results, {
            filePath = filePath,
            success = success
        })
    end
    
    return results
end

if Logger then
    Logger.info("GIT_LOADER", "Módulo carregado com sucesso")
else
    print("[GIT_LOADER] Módulo carregado com sucesso")
end

