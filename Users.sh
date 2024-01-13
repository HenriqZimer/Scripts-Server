#!/bin/bash

# Limpar a tela
clear

# Mensagem de boas-vindas
echo -e "\e[1;33mBem-vindo ao script de criação de usuário no Active Directory!\e[0m"
echo -e "Por favor, forneça as seguintes informações:"

read -p "Digite o nome do usuário: " nome
read -p "Digite o sobrenome do usuário: " sobrenome

# Apresentar opções numeradas para o setor
echo "Escolha o setor:"
echo "1. TI"
echo "2. Comercial"
echo "3. Outro"

read -p "Digite o número correspondente ao setor desejado: " escolha_setor

# Tratamento de erros ao solicitar informações
if [ -z "$nome" ] || [ -z "$sobrenome" ] || [ -z "$escolha_setor" ]; then
    echo "Erro: Todas as informações são necessárias. Saindo..."
    exit 1
fi

# Converter o primeiro caractere do nome e sobrenome para maiúscula
nome=$(echo "$nome" | sed 's/\b\(.\)/\u\1/g')  # \u converte para maiúsculas
sobrenome=$(echo "$sobrenome" | sed 's/\b\(.\)/\u\1/g')  # \u converte para maiúsculas

# Defina o email baseado no nome de exibição ou padrão
nome_exibicao="${nome} ${sobrenome}"

# Forçar a primeira letra de nome_exibicao para maiúscula
nome_exibicao=$(echo "$nome_exibicao" | awk '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

# Defina o nome de exibição no AD baseado em uma convenção específica
nome_ad="${nome}.${sobrenome}"

# Forçar todas as letras de nome_ad para minúsculas
nome_ad=$(echo "$nome_ad" | tr '[:upper:]' '[:lower:]')

# Apresentar opções numeradas para a filial
echo "Escolha a filial:"
echo "1. Fazenda"
echo "2. Salseiros"

read -p "Digite o número correspondente à filial desejada: " escolha_filial

# Tratamento de erros ao solicitar informações
if [ -z "$escolha_filial" ]; then
    echo "Erro: A escolha da filial é necessária. Saindo..."
    exit 1
fi

# Mapear a escolha do usuário para o setor correspondente
case "$escolha_setor" in
  1)
    setor="TI"
    ou="OU=TI";;
  2)
    setor="Comercial"
    ou="OU=Comercial";;
  3)
    read -p "Digite o nome do setor personalizado: " setor
    ou="OU=$setor";;
  *)
    echo "Erro: Escolha inválida para setor."
    exit 1;;
esac

# Mapear a escolha da filial para o escritório correspondente
case "$escolha_filial" in
  1)
    filial="Fazenda"
    escritorio="Fazenda";;
  2)
    filial="Salseiros"
    escritorio="Salseiros";;
  *)
    echo "Erro: Escolha inválida para filial."
    exit 1;;
esac

echo -e "Setor: \e[1;32m$setor\e[0m"
echo -e "Filial: \e[1;32m$filial\e[0m"
echo -e "Nome de Exibição (AD): \e[1;32m$nome_ad\e[0m"
echo -e "Nome de Exibição (Computador): \e[1;32m$nome_exibicao\e[0m"

# Pedir confirmação
read -p "Confirmar a criação do usuário com as informações acima? (y/n): " confirmacao

# Verificar a confirmação
if [ "$confirmacao" != "y" ]; then
    echo "Criação do usuário cancelada."
    exit 0
fi

# Continuar com a criação do usuário
case "$setor" in
  "comex" | "Comex")
    ou="OU=Comex";;
  "comercial" | "Comercial")
    ou="OU=Comercial";;
  "ti" | "TI")
    ou="OU=TI";;
  *)
    echo "Erro: Setor inválido."
    exit 1;;
esac

# Remover caracteres inválidos para SamAccountName
sam_account_name=$(echo "$nome_ad" | tr -cd 'A-Za-z0-9' | tr '[:upper:]' '[:lower:]')

# Senha temporária (ajuste conforme necessário)
senha_temporaria='senha@123'

senha_encriptada=$(pwsh -Command "ConvertTo-SecureString -AsPlainText '$senha_temporaria' -Force | ConvertFrom-SecureString")

pwsh -Command "
New-ADUser -GivenName '$nome' -Surname '$sobrenome' -Name '$nome_ad' -DisplayName '$nome_exibicao' -SamAccountName '$sam_account_name' -UserPrincipalName '$nome_ad@henriqzimer.local' -Path 'OU=Usuários,$ou,OU=Setores,DC=henriqzimer,DC=local' -AccountPassword (ConvertTo-SecureString -AsPlainText '$senha_temporaria' -force) -Enabled \$true
"

echo -e "\e[1;32mUsuário criado com sucesso!\e[0m"