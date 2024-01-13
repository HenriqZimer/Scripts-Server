#!/bin/bash

# Solicita o nome do usuário
read -p "Digite o nome do usuário: " nomeUsuario

# Executa o PowerShell diretamente no Bash
pwsh -Command "
# Tenta realizar a busca no Active Directory
try {
    # Carrega a assembly System.DirectoryServices.AccountManagement
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    # Cria um objeto PrincipalContext para o domínio atual
    \$context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain)

    # Cria um objeto UserPrincipal para a busca
    \$userPrincipal = New-Object System.DirectoryServices.AccountManagement.UserPrincipal(\$context)
    \$userPrincipal.SamAccountName = '*$nomeUsuario*'

    # Cria um objeto PrincipalSearcher para a busca
    \$searcher = New-Object System.DirectoryServices.AccountManagement.PrincipalSearcher(\$userPrincipal)

    # Armazena os usuários encontrados em uma variável
    \$users = \$searcher.FindAll()

    # Exibe as informações dos usuários encontrados
    \$usersInfo = @()
    foreach (\$user in \$users) {
        \$userInfo = @{
            'Nome' = \$user.DisplayName
            'SamAccountName' = \$user.SamAccountName
            'Email' = \$user.EmailAddress
        }
        \$usersInfo += \$userInfo
    }

    # Exibe as opções para o usuário
    Write-Host 'Usuários encontrados:'
    for (\$i=0; \$i -lt \$usersInfo.Count; \$i++) {
        Write-Host \"[\$i] Nome: \$(\$usersInfo[\$i]['Nome']), SamAccountName: \$(\$usersInfo[\$i]['SamAccountName']), Email: \$(\$usersInfo[\$i]['Email'])\"
    }

    # Solicita a escolha do usuário
    \$escolha = Read-Host 'Escolha o número do usuário para alterar a senha:'
    
    # Verifica se a escolha é um número válido e se o SamAccountName fornecido está entre os usuários encontrados
    if (\$escolha -ge 0 -and \$escolha -lt \$usersInfo.Count) {
        # Obtém o SamAccountName escolhido
        \$samAccountName = \$usersInfo[\$escolha]['SamAccountName']

        # Solicita a nova senha
        \$novaSenha = Read-Host 'Digite a nova senha para o usuário:'

        # Altera a senha do usuário
        Set-ADAccountPassword -Identity \$samAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText \$novaSenha -Force) -ErrorAction Stop
        Write-Host 'Senha alterada com sucesso!'
    } else {
        Write-Host 'Escolha inválida. Operação cancelada.'
    }

} catch {
    # Se ocorrer um erro, exibe uma mensagem
    Write-Host 'Erro ao buscar ou alterar a senha do usuário.'
}
"
