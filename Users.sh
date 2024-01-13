#!/bin/bash

# Limpar a tela
clear

# Mensagem de boas-vindas
echo -e "\e[1;33mBem-vindo ao script de criação de usuário no Active Directory!\e[0m"
echo -e "Por favor, forneça as seguintes informações:"

# Etapa 1: Coletar informações do usuário
read -p "Digite o nome do usuário: " nome
read -p "Digite o sobrenome do usuário: " sobrenome

# Apresentar opções numeradas para o setor
echo "Escolha o setor:"
echo "1. TI"
echo "2. Comercial"
echo "3. Outro"

# Etapa 2: Coletar escolha do setor
read -p "Digite o número correspondente ao setor desejado: " escolha_setor

# Tratamento de erros ao solicitar informações
if [ -z "$nome" ] || [ -z "$sobrenome" ] || [ -z "$escolha_setor" ]; then
    echo "Erro: Todas as informações são necessárias. Saindo..."
    exit 1
fi

# Solicitar o valor do cargo
read -p "Digite o cargo: " cargo

# Etapa 3: Formatar e manipular informações do usuário
nome=$(echo "$nome" | sed 's/\b\(.\)/\u\1/g')  # \u converte para maiúsculas
sobrenome=$(echo "$sobrenome" | sed 's/\b\(.\)/\u\1/g')  # \u converte para maiúsculas

nome_exibicao="${nome} ${sobrenome}"
nome_exibicao=$(echo "$nome_exibicao" | awk '{for(i=1;i<=NF;i++)$i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

nome_ad="${nome}.${sobrenome}"
nome_ad=$(echo "$nome_ad" | tr '[:upper:]' '[:lower:]')

# Etapa 4: Coletar escolha da filial
echo "Escolha a filial:"
echo "1. Fazenda"
echo "2. Salseiros"

read -p "Digite o número correspondente à filial desejada: " escolha_filial

# Tratamento de erros ao solicitar informações
if [ -z "$escolha_filial" ]; then
    echo "Erro: A escolha da filial é necessária. Saindo..."
    exit 1
fi

# Etapa 5: Mapear escolhas do usuário para setor e filial
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

case "$escolha_filial" in
  1)
    filial="Fazenda"
    escritorio="Fazenda"
    rua="Avenida Emanoel Pinto"
    caixa_postal="123"
    cidade="Itajaí"
    estado="Santa Catarina"
    cep="88380-000";;
  2)
    filial="Salseiros"
    escritorio="Salseiros"
    rua="Avenida 2350"
    caixa_postal="123"
    cidade="Itajaí"
    estado="Santa Catarina"
    cep="88380-000";;
  *)
    echo "Erro: Escolha inválida para filial."
    exit 1;;
esac

# Etapa 6: Apresentar informações ao usuário
echo -e "Setor: \e[1;32m$setor\e[0m"
echo -e "Filial: \e[1;32m$filial\e[0m"
echo -e "Nome de Exibição (AD): \e[1;32m$nome_ad\e[0m"
echo -e "Nome de Exibição (Computador): \e[1;32m$nome_exibicao\e[0m"

# Etapa 7: Confirmar criação do usuário
read -p "Confirmar a criação do usuário com as informações acima? (y/n): " confirmacao

# Verificar a confirmação
if [ "$confirmacao" != "y" ]; then
    echo "Criação do usuário cancelada."
    exit 0
fi

# Etapa 8: Continuar com a criação do usuário no Active Directory
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

# Etapa 9: Configurar informações e criar usuário no AD
sam_account_name=$(echo "$nome_ad" | tr -cd 'A-Za-z0-9' | tr '[:upper:]' '[:lower:]')
senha_temporaria='senha@123'
senha_encriptada=$(pwsh -Command "ConvertTo-SecureString -AsPlainText '$senha_temporaria' -Force | ConvertFrom-SecureString")

pwsh -Command "
New-ADUser -GivenName '$nome' -Surname '$sobrenome' -Name '$nome_ad' -DisplayName '$nome_exibicao' -SamAccountName '$sam_account_name' -UserPrincipalName '$nome_ad@henriqzimer.local' -Path 'OU=Usuários,$ou,OU=Setores,DC=henriqzimer,DC=local' -StreetAddress '$rua' -City '$cidade' -State '$estado' -PostalCode '$cep' -POBox '$caixa_postal' -Country 'BR' -Office '$escritorio' -Title '$cargo' -Department '$setor' -AccountPassword (ConvertTo-SecureString -AsPlainText '$senha_temporaria' -force) -ChangePasswordAtLogon \$true -Enabled \$true
"

# Etapa 10: Mensagem de sucesso
echo -e "\e[1;32mUsuário criado com sucesso!\e[0m"
