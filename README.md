# TheCrustyHUD 2.0

Sistema unificado de HUD para ZeroBot que agrega múltiplas funcionalidades de scripts descentralizados em uma única interface modular.

## Características

- **Princípios DRY**: Alto nível de abstração para máxima reutilização
- **Princípios SOLID**: Funções com responsabilidades claras (Single Responsibility Principle)
- **Controle de Versão**: Atualização automática via GitHub
- **Arquitetura Modular**: Sistema extensível e fácil de manter

## Estrutura do Projeto

```
_TheCrustyHUD 2.0/
├── main.lua                    # Script principal de inicialização
├── lib/
│   ├── gitLoader/
│   │   └── gitLoader.lua       # Sistema de verificação e atualização via GitHub
│   └── mainFunctions/
│       ├── jsonLoader.lua       # Sistema de leitura e conversão de JSON
│       └── updateHUD.lua        # HUD de atualização com callback
└── README.md                    # Este arquivo
```

## Funcionalidades

### 1. Main.lua
- Carrega todas as classes globais do core
- Inicializa os módulos principais
- Gerencia o carregamento de scripts

### 2. Git Loader
- Verifica versões de arquivos no GitHub
- Baixa e atualiza arquivos automaticamente
- Cria backups antes de atualizar
- Controle de versão por SHA

### 3. JSON Loader
- Lê arquivos JSON e converte para tabelas Lua
- Cria variáveis globais a partir de JSON
- Valida e salva arquivos JSON
- Tratamento robusto de erros

### 4. Update HUD
- Interface visual para verificação de atualizações
- Callback para buscar updates no GitHub
- Feedback visual do status
- Posicionamento arrastável e persistente

## Instalação

1. Copie a pasta `_TheCrustyHUD 2.0` para o diretório de scripts do ZeroBot
2. Execute o `main.lua` através do ZeroBot
3. Configure o repositório GitHub no `gitLoader.lua` (linha 24-25)

## Configuração

### GitHub Repository

Edite o arquivo `lib/gitLoader/gitLoader.lua` e configure:

```lua
local GITHUB_CONFIG = {
    REPO_OWNER = "SEU_USUARIO_GITHUB",
    REPO_NAME = "Zerobot-TheCrustyHUD",
    BRANCH = "main"
}
```

## Uso

### Verificar Atualizações

Clique no ícone de atualização na HUD ou use a função:

```lua
checkForUpdates()  -- Verifica e atualiza arquivos do GitHub
```

### Carregar Configuração JSON

```lua
local config = loadJSONFile("config/config.json")
-- ou
loadJSONAsGlobals("config/config.json", "CONFIG_")
```

## Requisitos

- ZeroBot com acesso às funções do core
- Dependências HTTP (socket.http, ltn12) para funcionalidades de rede
- JSON parser (disponível no core)

## Versão

**v2.0.0** - Versão inicial do sistema unificado

## Licença

Este projeto é propriedade de The Crusty.

