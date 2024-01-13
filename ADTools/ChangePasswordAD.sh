#!/bin/bash

# Limpar a tela
clear

# Mensagem de boas-vindas
echo -e "\e[1;33mBem-vindo ao script de alteração de senha de usuários no Active Directory!\e[0m"
echo -e "Por favor, forneça as seguintes informações:"
echo -e "----------------------------------------------"
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
    \$userPrincipal.DisplayName = '*$nomeUsuario*'

    # Cria um objeto PrincipalSearcher para a busca
    \$searcher = New-Object System.DirectoryServices.AccountManagement.PrincipalSearcher(\$userPrincipal)

    # Armazena os usuários encontrados em uma variável
    \$users = \$searcher.FindAll()

    # Exibe as informações dos usuários encontrados
    \$usersInfo = @()
    foreach (\$user in \$users) {
        \$userInfo = @{
            'Nome de Exibição (Computador)' = \$user.DisplayName
            'SamAccountName' = \$user.SamAccountName
        }
        \$usersInfo += \$userInfo
    }

    # Exibe as opções para o usuário
    Write-Host 'Usuários encontrados:'
    for (\$i=0; \$i -lt \$usersInfo.Count; \$i++) {
        Write-Host \"[\$i] Nome de Exibição (Computador): \$(\$usersInfo[\$i]['Nome de Exibição (Computador)'])\"
    }

    # Solicita a escolha do usuário
    \$escolha = Read-Host 'Escolha o número do usuário para alterar a senha'
    
    # Verifica se a escolha é um número válido e se o Nome de Exibição fornecido está entre os usuários encontrados
    if (\$escolha -ge 0 -and \$escolha -lt \$usersInfo.Count) {
        # Obtém o SamAccountName escolhido
        \$samAccountName = \$usersInfo[\$escolha]['SamAccountName']

        # Solicita a nova senha
        do {
            \$novaSenha = Read-Host -AsSecureString 'Digite a nova senha para o usuário'
            \$confirmacaoSenha = Read-Host -AsSecureString 'Confirme a nova senha'
            \$novaSenhaTexto = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(\$novaSenha))
            \$confirmacaoSenhaTexto = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(\$confirmacaoSenha))
            if (\$novaSenhaTexto -ne \$confirmacaoSenhaTexto) {
                Write-Host 'As senhas não correspondem. Tente novamente.'
            }
        } while (\$novaSenhaTexto -ne \$confirmacaoSenhaTexto)

        # Altera a senha do usuário
        Set-ADAccountPassword -Identity \$samAccountName -Reset -NewPassword (\$novaSenha | ConvertTo-SecureString -AsPlainText -Force) -ErrorAction Stop
        Write-Host 'Senha alterada com sucesso!'
    } else {
        Write-Host 'Escolha inválida. Operação cancelada.'
    }

} catch {
    # Se ocorrer um erro, exibe uma mensagem
    Write-Host 'Erro ao buscar ou alterar a senha do usuário.'
}
"