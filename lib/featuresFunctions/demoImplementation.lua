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
-- Main Variables
-- ================================================================

local icon_id = 3108
local bg_id = 12746
local text_value = "teste"
local check_function = Engine.isMagicShooterEnabled
local toggle_function = Engine.enableMagicShooter

local colors = {
    enabled = {r = 0, g = 255, b = 0},
    disabled = {r = 255, g = 0, b = 0},
    opacity = {
        neutral = 1,
        bg = 0.45,
        active = 1,
        inactive = 0.7,
    }
}
local sizes = {
    natural = 32,
    factor_reductor = 0.8,
    font_size = 10,
}

local offScreen = 300

-- Posições padrão (podem ser sobrescritas por parâmetros)
local default_positions = {
    small_icon = {x = offScreen, y = offScreen},
    big_icon = {x = offScreen +50, y = offScreen +50},
    text = {x = offScreen +50, y = offScreen +50},
}

local positions = {}

local relative_offsets = {
    small_icon = {x = 0, y = 0},
    big_icon = {x = 50, y = 50},
    text = {x = sizes.natural * 1.4, y = sizes.natural*0.2},
    textbg = {x = sizes.natural * 1.2, y = 0},
}

local text_bg_repeats = math.max(1, math.ceil((string.len(text_value)*sizes.font_size)/sizes.natural))
-- ================================================================
-- Main Assets
-- ================================================================

local huds = {
    bg_small_icon = nil,
    bg_big_icon = nil,
    bg_text = {},
    small_icon = nil,
    big_icon = nil,
    text = nil,
}

local status = check_function()

-- ================================================================
-- Visual Functions
-- ================================================================

local function toggle_style(current_status)
    if not huds.small_icon or not huds.big_icon or not huds.text then
        return
    end
    
    local small_size = sizes.natural * sizes.factor_reductor
    if current_status then
        huds.small_icon:setOpacity(colors.opacity.active)
        huds.big_icon:setOpacity(colors.opacity.active)
        huds.text:setColor(colors.enabled.r, colors.enabled.g, colors.enabled.b)
        huds.text:setOpacity(colors.opacity.active)
        
    else
        huds.small_icon:setOpacity(colors.opacity.inactive)
        huds.big_icon:setOpacity(colors.opacity.inactive)
        huds.text:setColor(colors.disabled.r, colors.disabled.g, colors.disabled.b)
        huds.text:setOpacity(colors.opacity.inactive)
    end
    huds.small_icon:setSize(small_size, small_size)
    huds.bg_small_icon:setSize(small_size, small_size)
    huds.big_icon:setSize(sizes.natural, sizes.natural)
    huds.bg_big_icon:setSize(sizes.natural, sizes.natural)        
    huds.text:setFontSize(sizes.font_size)
    huds.bg_big_icon:setOpacity(colors.opacity.bg)
    huds.bg_small_icon:setOpacity(colors.opacity.bg)
    for i = 1, text_bg_repeats do
        if huds.bg_text[i] then
            huds.bg_text[i]:setOpacity(colors.opacity.bg)
            huds.bg_text[i]:setSize(sizes.natural, sizes.natural)
        end
    end
end


-- ================================================================
-- Action Functions
-- ================================================================

local function toggleAction()
    status = not status
    toggle_function(status)
    toggle_style(status)
end


local function mainAction()
    toggleAction()
end


-- ================================================================
-- Create Functions
-- ================================================================

-- Complexidade: O(1) - criação de elementos HUD
-- Inicializa os elementos HUD da demo
-- @param posParams (table|nil) - Tabela opcional com posições customizadas:
--   - small_icon: {x = number, y = number}
--   - big_icon: {x = number, y = number}
--   - text: {x = number, y = number}
-- @return (table) - Tabela com referências aos HUDs criados
local function init(posParams)
    -- Usa posições fornecidas ou padrão
    if posParams then
        positions.small_icon = posParams.small_icon or default_positions.small_icon
        positions.big_icon = posParams.big_icon or default_positions.big_icon
        positions.text = posParams.text or default_positions.text
    else
        -- Usa posições padrão
        positions.small_icon = default_positions.small_icon
        positions.big_icon = default_positions.big_icon
        positions.text = default_positions.text
    end
    
    local function small_icon()
        huds.bg_small_icon = HUD.new(positions.small_icon.x, positions.small_icon.y, bg_id, true)
        huds.small_icon = HUD.new(positions.small_icon.x, positions.small_icon.y, icon_id, true)
        huds.small_icon.callback = mainAction
    end
    local function big_icon()
        huds.bg_big_icon = HUD.new(positions.big_icon.x, positions.big_icon.y, bg_id, true)
        huds.big_icon = HUD.new(positions.big_icon.x, positions.big_icon.y, icon_id, true)
        huds.big_icon.callback = mainAction
    end
    local function text()
        for i = 1, text_bg_repeats do
            huds.bg_text[i] = HUD.new(positions.text.x+relative_offsets.textbg.x+(i-1)*sizes.natural, positions.text.y+relative_offsets.textbg.y, bg_id, true)
        end
        huds.text = HUD.new(positions.text.x+relative_offsets.text.x, positions.text.y+relative_offsets.text.y, text_value, true)
        huds.text.callback = mainAction
    end
    
    -- Cria todos os HUDs primeiro
    small_icon()
    big_icon()
    text()
    
    -- Aplica o estilo inicial após criar todos os HUDs
    toggle_style(status)
    
    return huds
end

-- Complexidade: O(1) - atualização de posições dos HUDs
-- Atualiza as posições dos HUDs existentes
-- @param posParams (table|nil) - Tabela opcional com novas posições:
--   - small_icon: {x = number, y = number}
--   - big_icon: {x = number, y = number}
--   - text: {x = number, y = number}
local function updatePositions(posParams)
    if not posParams then
        return
    end
    
    -- Atualiza as posições na tabela
    if posParams.small_icon then
        positions.small_icon = posParams.small_icon
    end
    if posParams.big_icon then
        positions.big_icon = posParams.big_icon
    end
    if posParams.text then
        positions.text = posParams.text
    end
    
    -- Reposiciona os HUDs existentes
    if huds.small_icon and positions.small_icon then
        huds.small_icon:setPos(positions.small_icon.x, positions.small_icon.y)
        if huds.bg_small_icon then
            huds.bg_small_icon:setPos(positions.small_icon.x, positions.small_icon.y)
        end
    end
    
    if huds.big_icon and positions.big_icon then
        huds.big_icon:setPos(positions.big_icon.x, positions.big_icon.y)
        if huds.bg_big_icon then
            huds.bg_big_icon:setPos(positions.big_icon.x, positions.big_icon.y)
        end
    end
    
    if huds.text and positions.text then
        -- Reposiciona o texto principal
        huds.text:setPos(
            positions.text.x + relative_offsets.text.x, 
            positions.text.y + relative_offsets.text.y
        )
        
        -- Reposiciona os backgrounds do texto
        for i = 1, text_bg_repeats do
            if huds.bg_text[i] then
                huds.bg_text[i]:setPos(
                    positions.text.x + relative_offsets.textbg.x + (i-1) * sizes.natural,
                    positions.text.y + relative_offsets.textbg.y
                )
            end
        end
    end
end

-- Exporta as funções para uso externo
_G.initDemoImplementation = init
_G.updatePositionsDemoImplementation = updatePositions