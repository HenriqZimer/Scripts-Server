#!/bin/bash

echo "Instalando TeamViewer..."
echo y | winget install -e --id TeamViewer.TeamViewer

echo "Instalando Google Chrome..."
echo y | winget install -e --id Google.Chrome

echo "Instalando Microsoft Office..."
echo y | winget install -e --id Microsoft.Office

echo "Instalando WinRAR..."
echo y | winget install -e --id RARLab.WinRAR

echo "Instalando FortiClient VPN..."
echo y | winget install -e --id Fortinet.FortiClientVPN

echo "Instalação concluída."
