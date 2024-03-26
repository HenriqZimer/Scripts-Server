@echo off
cls
:menu
echo.
echo ==========================
echo    Menu Principal
echo ==========================
echo.
echo 1 - Trocar senha do usuario
echo 2 - Trocar telefone do usuario
echo 3 - Sair
echo.
echo Escolha uma opcao:
set /p opcao=

if "%opcao%"=="1" goto trocarSenha
if "%opcao%"=="2" goto trocarTelefone
if "%opcao%"=="3" goto fim

echo Opcao invalida! Por favor, escolha uma opcao valida.
pause
goto menu

:trocarSenha
PowerShell.exe -ExecutionPolicy Bypass -File Scripts\ADUserPasswordReset.ps1
goto menu

:trocarTelefone
PowerShell.exe -ExecutionPolicy Bypass -File Scripts\ADPhoneMobile.ps1
goto menu

:fim
exit
