#!/bin/bash

while true; do

    clear
    # Exibir menu
    echo -e "\e[1;33mBem-vindo ao script de ferramentas de usuário no Active Directory!\e[0m"
    echo "-----------------------------"
    echo "Selecione uma opção:"
    echo "1. Criar novo usuário"
    echo "2. Trocar senha do usuário"
    echo "3. Sair"

    # Ler a opção do usuário
    read -p "Digite opção desejada: " opcao

    # Verificar a opção escolhida
    case $opcao in
        1)
            echo "Opção 1 selecionada: Criar usuário"
            ./NewUsersAD.sh 
            ;;
        2)
            echo "Opção 2 selecionada: Trocar senha"
            ./ChangePasswordAD.sh
            ;;
        3)
            echo "Saindo do script"
            exit 0
            ;;
        *)
            echo "Opção inválida. Tente novamente."
            ;;
    esac
done
