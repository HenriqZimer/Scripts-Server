# Limpa a tela
Clear-Host

#Titulo do Script
Write-Output "Script para Resetar a Senha do Usuário"
Write-Output "--------------------------------------"

# Solicita ao usuário que insira o nome (ou parte dele) do usuário a ser buscado
$nomeUsuario = Read-Host "Por favor, insira o nome do usuário a procurar"

# Busca no AD usando o nome fornecido
try {
    Import-Module ActiveDirectory
    $usuarios = Get-ADUser -Filter "Name -like '*$nomeUsuario*'" -Properties *

    if ($null -ne $usuarios -and $usuarios.Count -gt 0) {
        Write-Output "Usuários encontrados:"
        $i = 1
        foreach ($usuario in $usuarios) {
            Write-Output "$i. Nome de usuário (Nome de Dominio): $($usuario.SamAccountName), Nome completo: $($usuario.Name)"
            $i++
        }

        # Solicita que o usuário escolha um dos usuários listados
        $selecao = Read-Host "Por favor, selecione o número do usuário para resetar a senha (ou 'n' para cancelar)"
        if ($selecao -ne 'n') {
            $indexSelecionado = [int]$selecao - 1
            if ($indexSelecionado -lt $usuarios.Count) {
                $usuarioSelecionado = $usuarios[$indexSelecionado]

                # Confirmação antes de resetar a senha e desbloquear a conta
                $confirmReset = Read-Host "Deseja resetar a senha deste usuário ($($usuarioSelecionado.Name)) para 'trust2024.', desbloqueá-lo e exigir uma nova senha no próximo login? (S/N)"
                if ($confirmReset -eq 'S' -or $confirmReset -eq 's') {
                    # Desbloqueia a conta do usuário
                    Unlock-ADAccount -Identity $usuarioSelecionado

                    # Resetando a senha do usuário selecionado e forçando troca de senha no próximo login
                    Set-ADAccountPassword $usuarioSelecionado -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "trust2024." -Force)
                    Set-ADUser $usuarioSelecionado -ChangePasswordAtLogon $true
                    
                    Write-Output "A senha foi resetada para 'trust2024.', a conta foi desbloqueada, e será exigida uma nova senha no próximo login."
                }
                else {
                    Write-Output "Reset de senha cancelado."
                }
            }
            else {
                Write-Output "Seleção inválida."
            }
        }
        else {
            Write-Output "Operação cancelada pelo usuário."
        }
    }
    else {
        Write-Output "Nenhum usuário encontrado com esse nome."
    }
}
catch {
    Write-Output "Houve um erro ao buscar o usuário ou ao resetar a senha. Verifique suas permissões e se o módulo ActiveDirectory está instalado corretamente." - "Erro: $($_.Exception.Message)" 
}
