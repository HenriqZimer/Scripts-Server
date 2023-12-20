#!/bin/bash

read -p "Digite o nome do usuário: " nome
read -p "Digite o sobrenome do usuário: " sobrenome
read -p "Digite o setor (Grass, Water, Fire): " setor

# Converter o primeiro caractere do nome e sobrenome para maiúscula
nome=$(echo "$nome" | sed 's/\b\(.\)/\l\1/g')  # \l converte para minúsculas
sobrenome=$(echo "$sobrenome" | sed 's/\b\(.\)/\l\1/g')  # \l converte para minúsculas

# Converter setor para minúsculas para tornar a comparação insensível a maiúsculas/minúsculas
setor=$(echo "$setor" | tr '[:upper:]' '[:lower:]')

# Defina o email baseado no nome de exibição ou padrão
nome_exibicao="${nome}.${sobrenome}"

case "$setor" in
  "grass")
    ou="OU=Grass";;
  "water")
    ou="OU=Water";;
  "fire")
    ou="OU=Fire";;
  *)
    echo "Setor inválido."
    exit 1;;
esac

pw='senha@123'

pw_encrypted=$(pwsh -Command "ConvertTo-SecureString -AsPlainText '$pw' -Force | ConvertFrom-SecureString")

pwsh -Command "
New-ADUser -GivenName '$nome' -Surname '$sobrenome' -Name '$nome_exibicao' -DisplayName '$nome_exibicao' -SamAccountName '$nome.$sobrenome' -UserPrincipalName '$nome_exibicao@henriquezimer.local' -Path 'OU=Usuários,$ou,OU=Pokémon,DC=henriqzimer,DC=local' -AccountPassword (ConvertTo-SecureString -AsPlainText '$pw' -force) -Enabled \$true
"
