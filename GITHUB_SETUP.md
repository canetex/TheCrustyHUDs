# Instruções para Sincronizar com GitHub

## Passo 1: Criar Repositório no GitHub

1. Acesse https://github.com
2. Clique em "New repository"
3. Nome do repositório: `Zerobot-TheCrustyHUD`
4. Deixe como **público** ou **privado** (sua escolha)
5. **NÃO** inicialize com README, .gitignore ou license (já temos)
6. Clique em "Create repository"

## Passo 2: Conectar Repositório Local ao GitHub

Execute os seguintes comandos no terminal, dentro da pasta `_TheCrustyHUD 2.0`:

```bash
# Adiciona o remote do GitHub (substitua SEU_USUARIO pelo seu usuário GitHub)
git remote add origin https://github.com/SEU_USUARIO/Zerobot-TheCrustyHUD.git

# Renomeia a branch para main (se necessário)
git branch -M main

# Envia o código para o GitHub
git push -u origin main
```

## Passo 3: Configurar gitLoader.lua

Após criar o repositório, edite o arquivo `lib/gitLoader/gitLoader.lua` e atualize:

```lua
local GITHUB_CONFIG = {
    REPO_OWNER = "SEU_USUARIO_GITHUB",  -- Seu usuário do GitHub
    REPO_NAME = "Zerobot-TheCrustyHUD",
    BRANCH = "main"
}
```

## Passo 4: Verificar Funcionamento

1. Execute o `main.lua` no ZeroBot
2. Clique no ícone de atualização na HUD
3. O sistema deve verificar atualizações no GitHub

## Comandos Úteis

### Enviar alterações para o GitHub
```bash
git add .
git commit -m "Descrição das alterações"
git push
```

### Baixar alterações do GitHub
```bash
git pull
```

### Verificar status
```bash
git status
```

## Notas Importantes

- O repositório já foi inicializado e o commit inicial foi feito
- Todos os arquivos necessários já estão commitados
- O `.gitignore` está configurado para ignorar arquivos temporários e backups

