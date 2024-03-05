# Limpa a tela
Clear-Host

#Titulo do Script
Write-Output "Script para Mudar o Telefone do Usuário"
Write-Output "--------------------------------------"

# Pedir ao usuário para inserir o nome de pesquisa
$nomePesquisa = Read-Host "Insira o nome do usuário para pesquisa"

# Buscar usuários que correspondam ao nome de pesquisa
$usuarios = Get-ADUser -Filter "Name -like '*$nomePesquisa*'" -Properties DisplayName, TelephoneNumber, Mobile

# Verificar se foram encontrados usuários
if ($usuarios.Count -eq 0) {
    Write-Host "Nenhum usuário encontrado com o nome fornecido."
    exit
}

# Listar usuários encontrados
Write-Host "Usuários encontrados:"
$index = 1
foreach ($usuario in $usuarios) {
    Write-Host "$index. $($usuario.DisplayName)"
    $index++
}

# Pedir ao usuário para selecionar um usuário
$selecaoUsuario = Read-Host "Selecione o número do usuário para alterar o telefone/mobile"
$usuarioSelecionado = $usuarios[$selecaoUsuario - 1]

# Pedir ao usuário para fornecer o número de telefone (será usado tanto para telefone quanto para mobile)
$numeroBase = Read-Host "Insira o novo número de telefone (sem o prefixo 55) para $($usuarioSelecionado.DisplayName)"

# Formatar o telefone corretamente
$numeroFormatado = $numeroBase -replace '(\d{2})(\d{5})(\d{4})', '+55 $1 $2-$3'
$novoTelefone = $numeroFormatado
$novoMobile = "55$numeroBase"

# Atualizar os valores de telefone e mobile no AD
Set-ADUser $usuarioSelecionado -Replace @{TelephoneNumber=$novoTelefone; Mobile=$novoMobile}

Write-Host "Os dados de telefone e mobile foram atualizados com sucesso para o usuário $($usuarioSelecionado.DisplayName)."
