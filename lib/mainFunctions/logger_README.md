# Logger - Sistema Centralizado de Controle de Logs

## Descrição

Sistema responsável por controlar e padronizar todas as mensagens de log e prints do sistema TheCrustyHUD 2.0, permitindo controle de verbosidade, níveis de log e formatação padronizada.

## Funcionalidades

- ✅ **Níveis de log**: DEBUG, INFO, WARNING, ERROR
- ✅ **Controle de verbosidade** por módulo
- ✅ **Formatação padronizada** de mensagens
- ✅ **Filtros** por módulo e nível
- ✅ **Suporte a salvamento em arquivo** (opcional)
- ✅ **Timestamps** nas mensagens

## Uso Básico

### Importar o Logger

O logger é carregado automaticamente no `main.lua` e fica disponível globalmente como `Logger`.

### Exemplos de Uso

```lua
-- Log de informação
Logger.info("MODULE_NAME", "Mensagem de informação")

-- Log de debug
Logger.debug("MODULE_NAME", "Mensagem de debug")

-- Log de aviso
Logger.warning("MODULE_NAME", "Mensagem de aviso")

-- Log de erro
Logger.error("MODULE_NAME", "Mensagem de erro")

-- Com formatação (similar ao string.format)
Logger.info("MODULE_NAME", "Carregado %d arquivo(s)", count)
```

## Níveis de Log

| Nível | Valor | Descrição |
|-------|-------|-----------|
| DEBUG | 1 | Mensagens de debug detalhadas |
| INFO | 2 | Informações gerais (padrão) |
| WARNING | 3 | Avisos e alertas |
| ERROR | 4 | Erros e exceções |
| NONE | 5 | Desabilita todos os logs |

## Configuração

### Definir Nível de Log

```lua
-- Por string
Logger.setLevel("DEBUG")  -- Mostra todos os logs
Logger.setLevel("INFO")    -- Mostra INFO, WARNING e ERROR
Logger.setLevel("WARNING") -- Mostra apenas WARNING e ERROR
Logger.setLevel("ERROR")   -- Mostra apenas ERROR
Logger.setLevel("NONE")    -- Desabilita todos os logs

-- Por número
Logger.setLevel(Logger.LOG_LEVELS.DEBUG)
```

### Habilitar/Desabilitar Timestamp

```lua
Logger.setTimestamp(true)   -- Mostra timestamp [HH:MM:SS]
Logger.setTimestamp(false)  -- Oculta timestamp
```

### Habilitar/Desabilitar Nome do Módulo

```lua
Logger.setShowModule(true)  -- Mostra [MODULE_NAME]
Logger.setShowModule(false) -- Oculta nome do módulo
```

### Filtrar por Módulos

```lua
-- Habilitar apenas módulos específicos
Logger.enableModules({"MODULE1", "MODULE2"})

-- Desabilitar módulos específicos
Logger.disableModules({"MODULE3", "MODULE4"})

-- Limpar filtros (habilitar todos)
Logger.enableModules({})
Logger.disableModules({})
```

### Salvar Logs em Arquivo

```lua
-- Habilitar salvamento em arquivo
Logger.setSaveToFile(true, "logs/thecrustyhud.log")

-- Desabilitar salvamento
Logger.setSaveToFile(false)
```

## Formato das Mensagens

### Padrão Completo
```
[HH:MM:SS] [MODULE_NAME] Mensagem
```

### Sem Timestamp
```
[MODULE_NAME] Mensagem
```

### Sem Módulo
```
[HH:MM:SS] Mensagem
```

### Mínimo
```
Mensagem
```

## Exemplos Práticos

### Exemplo 1: Log Simples
```lua
Logger.info("JSON_LOADER", "Arquivo carregado com sucesso")
-- Saída: [HH:MM:SS] [JSON_LOADER] Arquivo carregado com sucesso
```

### Exemplo 2: Log com Formatação
```lua
local count = 5
Logger.info("GIT_LOADER", "Atualizados %d arquivo(s)", count)
-- Saída: [HH:MM:SS] [GIT_LOADER] Atualizados 5 arquivo(s)
```

### Exemplo 3: Log de Erro
```lua
Logger.error("UPDATE_HUD", "Erro ao verificar atualizações: %s", errorMessage)
-- Saída: [HH:MM:SS] [UPDATE_HUD] Erro ao verificar atualizações: <mensagem>
```

### Exemplo 4: Log de Debug
```lua
Logger.debug("CONFIG_MANAGER", "Valor da chave '%s': %s", key, value)
-- Saída: [HH:MM:SS] [CONFIG_MANAGER] Valor da chave 'hudPosition': {x=100, y=100}
```

## Migração de Prints Antigos

### Antes
```lua
print("[" .. MODULE_NAME .. "] Mensagem")
print("[MODULE_NAME] Erro: " .. errorMessage)
```

### Depois
```lua
Logger.info(MODULE_NAME, "Mensagem")
Logger.error(MODULE_NAME, "Erro: %s", errorMessage)
```

## Boas Práticas

1. **Use o nome do módulo consistente**: Sempre use o mesmo nome para o mesmo módulo
2. **Escolha o nível apropriado**: 
   - DEBUG para informações detalhadas de desenvolvimento
   - INFO para informações gerais
   - WARNING para situações que merecem atenção
   - ERROR para erros e exceções
3. **Use formatação quando necessário**: Para mensagens com variáveis, use `%s`, `%d`, etc.
4. **Não use print() diretamente**: Sempre use o Logger para manter consistência

## API Completa

```lua
-- Funções de log
Logger.debug(moduleName, message, ...)
Logger.info(moduleName, message, ...)
Logger.warning(moduleName, message, ...)
Logger.error(moduleName, message, ...)

-- Configuração
Logger.setLevel(level)
Logger.getLevel()
Logger.setTimestamp(enabled)
Logger.setShowModule(enabled)
Logger.enableModules(modules)
Logger.disableModules(modules)
Logger.setSaveToFile(enabled, filePath)
Logger.getConfig()
Logger.cleanup()

-- Constantes
Logger.LOG_LEVELS.DEBUG
Logger.LOG_LEVELS.INFO
Logger.LOG_LEVELS.WARNING
Logger.LOG_LEVELS.ERROR
Logger.LOG_LEVELS.NONE
```

## Complexidade

- Todas as funções de log: **O(1)** - operações de string e I/O
- Filtros de módulos: **O(n)** onde n = número de módulos na lista

