#!/bin/bash

# Limpar a tela
clear

# Mensagem de boas-vindas
echo -e "\e[1;33mBem-vindo ao script de criação de usuário no Active Directory!\e[0m"
echo -e "Por favor, forneça as seguintes informações:"

read -p "Digite o nome do usuário: " nome
read -p "Digite o sobrenome do usuário: " sobrenome
read -p "Digite o setor (Grass, Water, Fire): " setor

# Converter o primeiro caractere do nome e sobrenome para maiúscula
nome=$(echo "$nome" | sed 's/\b\(.\)/\u\1/g')  # \u converte para maiúsculas
sobrenome=$(echo "$sobrenome" | sed 's/\b\(.\)/\u\1/g')  # \u converte para maiúsculas

# Converter setor para minúsculas para tornar a comparação insensível a maiúsculas/minúsculas
setor=$(echo "$setor" | tr '[:upper:]' '[:lower:]')

# Defina o email baseado no nome de exibição ou padrão
nome_exibicao="${nome}.${sobrenome}"

# Forçar todas as letras de nome_exibicao para minúsculas
nome_exibicao=$(echo "$nome_exibicao" | tr '[:upper:]' '[:lower:]')

# Limpar a tela novamente
clear

# Exibir informações inseridas com variáveis coloridas
echo -e "\e[1;36mAs seguintes informações foram inseridas:\e[0m"
echo -e "Nome: \e[1;32m$nome\e[0m"
echo -e "Sobrenome: \e[1;32m$sobrenome\e[0m"
echo -e "Setor: \e[1;32m$setor\e[0m"
echo -e "Nome de Exibição: \e[1;32m$nome_exibicao\e[0m"

# Pedir confirmação
read -p "Confirmar a criação do usuário com as informações acima? (y/n): " confirmacao

# Verificar a confirmação
if [ "$confirmacao" != "y" ]; then
    echo "Criação do usuário cancelada."
    exit 0
fi

# Continuar com a criação do usuário
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

echo -e "\e[1;32mUsuário criado com sucesso!\e[0m"
