-- ================================================================
-- Update HUD - Interface de Atualização via GitHub
-- ================================================================
-- VERSION v1.0.0 - Update HUD System
--    --- DRY Principle
--    --- Single Responsibility Principle

-- DESCRIÇÃO:
-- Sistema responsável por criar uma HUD simples com callback
-- para validar e buscar atualizações no GitHub

-- FUNCIONALIDADES:
-- ✅ HUD visual para verificação de atualizações
-- ✅ Callback para buscar updates no GitHub
-- ✅ Feedback visual do status de atualização
-- ✅ Posicionamento arrastável

-- ================================================================
-- VARIÁVEIS GLOBAIS
-- ================================================================

local Engine = rawget(_G or {}, "Engine")
local HUD = rawget(_G or {}, "HUD")
local Game = rawget(_G or {}, "Game")
local Client = rawget(_G or {}, "Client")
local Logger = rawget(_G or {}, "Logger")
local Timer = rawget(_G or {}, "Timer")
local destroyTimer = rawget(_G or {}, "destroyTimer")
local BASE_PATH = Engine.getScriptsDirectory() .. "/_TheCrustyHUD 2.0"
local MODULE_NAME = "UPDATE_HUD"

local updateHUD = nil
local updateHUDText = nil
local isChecking = false

-- ================================================================
-- CONFIGURAÇÕES
-- ================================================================

local HUD_CONFIG = {
    ICON_ID = 34154,  -- ID do ícone (pode ser ajustado)
    X_POSITION = 100,
    Y_POSITION = 100,
    FONT_SIZE = 10,
    TEXT_COLOR = { r = 255, g = 255, b = 255 },
    UPDATE_TEXT = "Atualizar -- 123",
    CHECKING_TEXT = "Verificando... --312",
    UPDATED_TEXT = "Atualizado! -- 31222",
    ERROR_TEXT = "Erro! -- 11"
}

-- ================================================================
-- FUNÇÕES AUXILIARES
-- ================================================================

-- Complexidade: O(1) - operação de I/O
-- Salva a posição do HUD
local function saveHUDPosition(x, y)
    local configPath = BASE_PATH .. "/config/updateHUD_position.json"
    
    local config = {
        x = x,
        y = y
    }
    
    if _G.saveJSONFile then
        -- saveJSONFile já tenta criar o arquivo, se falhar silenciosamente não há problema
        _G.saveJSONFile(config, configPath)
    else
        -- Fallback: salva em formato simples
        -- Tenta criar o arquivo, se falhar (diretório não existe) não faz nada
        local file = io.open(configPath, "w")
        if file then
            file:write('{"x":' .. x .. ',"y":' .. y .. '}')
            file:close()
        end
        -- Se falhar, não imprime erro (diretório pode não existir ainda)
    end
end

-- Complexidade: O(1) - operação de I/O
-- Carrega a posição salva do HUD
local function loadHUDPosition()
    local configPath = BASE_PATH .. "/config/updateHUD_position.json"
    
    if _G.loadJSONFile then
        local config = _G.loadJSONFile(configPath)
        if config and config.x and config.y then
            return config.x, config.y
        end
    else
        -- Fallback: tenta ler arquivo simples
        local file = io.open(configPath, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local x = content:match('"x":(%d+)')
            local y = content:match('"y":(%d+)')
            if x and y then
                return tonumber(x), tonumber(y)
            end
        end
    end
    
    return HUD_CONFIG.X_POSITION, HUD_CONFIG.Y_POSITION
end

-- Complexidade: O(1) - operação de atualização de texto
-- Atualiza o texto do HUD
local function updateHUDTextDisplay(text, color)
    if updateHUDText then
        updateHUDText:setText(text)
        if color then
            updateHUDText:setColor(color.r, color.g, color.b)
        end
    end
end

-- ================================================================
-- FUNÇÃO DE CALLBACK PARA BUSCAR ATUALIZAÇÕES
-- ================================================================

-- Complexidade: O(n) onde n = número de arquivos a verificar
-- Callback chamado quando o HUD é clicado para buscar atualizações
local function checkForUpdates()
    if isChecking then
        if Logger then
            Logger.warning(MODULE_NAME, "Verificação já em andamento...")
        else
            print("[UPDATE_HUD] Verificação já em andamento...")
        end
        return
    end
    
    isChecking = true
    if updateHUDText then
        updateHUDText:setText(HUD_CONFIG.CHECKING_TEXT)
        updateHUDText:setColor(255, 255, 0)  -- Amarelo
    end
    
    if Logger then
        Logger.info(MODULE_NAME, "Iniciando verificação de atualizações...")
    else
        print("[UPDATE_HUD] Iniciando verificação de atualizações...")
    end
    
    -- Verifica se as funções do gitLoader estão disponíveis
    if not _G.checkFileVersion or not _G.updateFileFromGitHub then
        if Logger then
            Logger.error(MODULE_NAME, "Funções do gitLoader não estão disponíveis")
        else
            print("[UPDATE_HUD] ERRO: Funções do gitLoader não estão disponíveis")
        end
        updateHUDText:setText(HUD_CONFIG.ERROR_TEXT)
        updateHUDText:setColor(255, 0, 0)  -- Vermelho
        isChecking = false
        return
    end
    
    -- Lista de arquivos para verificar atualizações
    local filesToCheck = {
        { filePath = "main.lua", localPath = BASE_PATH .. "/main.lua" },
        { filePath = "lib/gitLoader/gitLoader.lua", localPath = BASE_PATH .. "/lib/gitLoader/gitLoader.lua" },
        { filePath = "lib/mainFunctions/jsonLoader.lua", localPath = BASE_PATH .. "/lib/mainFunctions/jsonLoader.lua" },
        { filePath = "lib/mainFunctions/updateHUD.lua", localPath = BASE_PATH .. "/lib/mainFunctions/updateHUD.lua" }
    }
    
    local hasUpdates = false
    local updatedFiles = 0
    
    -- Verifica cada arquivo
    for _, fileInfo in ipairs(filesToCheck) do
        if _G.hasUpdateAvailable then
            if _G.hasUpdateAvailable(fileInfo.filePath, fileInfo.localPath) then
                hasUpdates = true
                if Logger then
                    Logger.info(MODULE_NAME, "Atualização disponível para: %s", fileInfo.filePath)
                else
                    print("[UPDATE_HUD] Atualização disponível para: " .. fileInfo.filePath)
                end
                
                -- Atualiza o arquivo
                if _G.updateFileFromGitHub(fileInfo.filePath, fileInfo.localPath) then
                    updatedFiles = updatedFiles + 1
                    if Logger then
                        Logger.info(MODULE_NAME, "Arquivo atualizado: %s", fileInfo.filePath)
                    else
                        print("[UPDATE_HUD] Arquivo atualizado: " .. fileInfo.filePath)
                    end
                end
            end
        end
    end
    
    -- Atualiza feedback visual
    if hasUpdates and updatedFiles > 0 then
        if updateHUDText then
            updateHUDText:setText(HUD_CONFIG.UPDATED_TEXT)
            updateHUDText:setColor(0, 255, 0)  -- Verde
        end
        if Logger then
            Logger.info(MODULE_NAME, "%d arquivo(s) atualizado(s) com sucesso!", updatedFiles)
        else
            print("[UPDATE_HUD] " .. updatedFiles .. " arquivo(s) atualizado(s) com sucesso!")
        end
        
        -- Restaura texto original após 3 segundos usando Timer
        local timerName = "updateHUD_restoreText_" .. os.time()
        local restoreTimer = Timer.new(timerName, function()
            if updateHUDText then
                updateHUDText:setText(HUD_CONFIG.UPDATE_TEXT)
                updateHUDText:setColor(HUD_CONFIG.TEXT_COLOR.r, HUD_CONFIG.TEXT_COLOR.g, HUD_CONFIG.TEXT_COLOR.b)
            end
            -- Destroi o timer após executar uma vez
            destroyTimer(timerName)
        end, 3000, true)  -- 3000ms de delay, autoStart = true
    else
        if updateHUDText then
            updateHUDText:setText(HUD_CONFIG.UPDATE_TEXT)
            updateHUDText:setColor(HUD_CONFIG.TEXT_COLOR.r, HUD_CONFIG.TEXT_COLOR.g, HUD_CONFIG.TEXT_COLOR.b)
        end
        if Logger then
            Logger.info(MODULE_NAME, "Nenhuma atualização disponível")
        else
            print("[UPDATE_HUD] Nenhuma atualização disponível")
        end
    end
    
    isChecking = false
end

-- ================================================================
-- FUNÇÃO PRINCIPAL DE CRIAÇÃO DO HUD
-- ================================================================

-- Complexidade: O(1) - criação de elementos HUD
-- Cria a HUD de atualização
-- @param x (number|nil) - Posição X (opcional)
-- @param y (number|nil) - Posição Y (opcional)
-- @return (table) - Tabela com referências aos elementos HUD criados
function createUpdateHUD(x, y)
    if updateHUD then
        if Logger then
            Logger.debug(MODULE_NAME, "HUD já existe, retornando instância existente")
        else
            print("[UPDATE_HUD] HUD já existe, retornando instância existente")
        end
        return { icon = updateHUD, text = updateHUDText }
    end
    
    -- Carrega posição salva ou usa valores padrão
    local hudX, hudY = loadHUDPosition()
    if x then hudX = x end
    if y then hudY = y end
    
    -- Cria ícone HUD
    updateHUD = HUD(hudX, hudY, HUD_CONFIG.ICON_ID, true)
    if not updateHUD then
        if Logger then
            Logger.error(MODULE_NAME, "Não foi possível criar o ícone HUD")
        else
            print("[UPDATE_HUD] ERRO: Não foi possível criar o ícone HUD")
        end
        return nil
    end
    
    -- Define callback para o ícone
    updateHUD.callback = checkForUpdates
    
    -- Cria texto HUD
    updateHUDText = HUD(hudX, hudY + 30, HUD_CONFIG.UPDATE_TEXT, true)
    if not updateHUDText then
        if Logger then
            Logger.error(MODULE_NAME, "Não foi possível criar o texto HUD")
        else
            print("[UPDATE_HUD] ERRO: Não foi possível criar o texto HUD")
        end
        return nil
    end
    
    updateHUDText:setFontSize(HUD_CONFIG.FONT_SIZE)
    updateHUDText:setColor(HUD_CONFIG.TEXT_COLOR.r, HUD_CONFIG.TEXT_COLOR.g, HUD_CONFIG.TEXT_COLOR.b)
    updateHUDText.callback = checkForUpdates
    
    -- Registra evento de arrastar para salvar posição
    if Game and Game.registerEvent then
        -- Usa evento de drag se disponível
        local function onHUDDrag(id, x, y)
            if id == updateHUD:getId() or (updateHUDText and id == updateHUDText:getId()) then
                -- Atualiza posição do outro elemento
                if id == updateHUD:getId() then
                    updateHUDText:setPos(x, y + 30)
                else
                    updateHUD:setPos(x, y - 30)
                end
                saveHUDPosition(x, y)
            end
        end
        
        -- Tenta registrar evento de drag (pode não estar disponível em todas as versões)
        if Game.Events and Game.Events.HUD_DRAG then
            Game.registerEvent(Game.Events.HUD_DRAG, onHUDDrag)
        end
    end
    
    if Logger then
        Logger.info(MODULE_NAME, "HUD criada com sucesso em (%d, %d)", hudX, hudY)
    else
        print("[UPDATE_HUD] HUD criada com sucesso em (" .. hudX .. ", " .. hudY .. ")")
    end
    return { icon = updateHUD, text = updateHUDText }
end

if Logger then
    Logger.info("UPDATE_HUD", "Módulo carregado com sucesso")
else
    print("[UPDATE_HUD] Módulo carregado com sucesso")
end

