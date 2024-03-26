# Solicita ao usuário o nome e sobrenome separadamente
$nome = Read-Host "Insira o nome do usuário"
$sobrenome = Read-Host "Insira o sobrenome do usuário"

# Cria o email usando nome e sobrenome
$email = "$nome.$sobrenome@trust.group"

# Remove espaços e caracteres especiais do samAccountName se necessário
$samAccountName = ($nome + $sobrenome).Replace(" ", "")

# Define o caminho completo no AD onde o usuário será criado
$ouPath = "OU=Cloud,OU=QUALIDADE,OU=`#DEPARTAMENTOS,OU=`"01 - ITJ01 - ITAJAI`",OU=`#TAGLOG,OU=`#EMPRESAS,DC=trustlog,DC=local"

# Cria o usuário no Active Directory
try {
    New-ADUser -Name "$nome $sobrenome" -GivenName $nome -Surname $sobrenome -UserPrincipalName $email -SamAccountName $samAccountName -Path $ouPath -AccountPassword (ConvertTo-SecureString "SenhaInicial123!" -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true -EmailAddress $email
    Write-Host "Usuário $nome $sobrenome criado com o email $email."
} catch {
    Write-Host "Erro ao criar o usuário: $_"
}
