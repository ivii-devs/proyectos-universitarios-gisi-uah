@echo off
title Lanzador Cafeteria PECL
cls
echo ==============================================================
echo       SIMULACION CAFETERIA - PARADIGMAS DE PROGRAMACION.
echo ==============================================================

REM 1. COMPILACION
echo.
echo [1/3] Compilando el proyecto con Maven...
call mvn compile

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [INFO] Maven no encontrado en PATH. Compilando directamente con javac...
    if not exist target\classes mkdir target\classes
    javac -d target/classes src/main/java/poo/peclcafeteria/*.java
    if %ERRORLEVEL% NEQ 0 (
        echo [AVISO] Fallo javac. Intentando ejecutar usando target/classes existente...
    ) else (
        echo [OK] Compilacion con javac completada con exito.
    )
    echo.
) else (
    echo [OK] Compilacion completada con Maven.
)

REM 2. EJECUTAR SERVIDOR
echo.
echo [2/3] Lanzando el SERVIDOR...
REM 'start' abre una nueva ventana. Usamos el classpath target/classes
start "SERVIDOR CAFETERIA (Parte 1)" javaw -cp target/classes poo.peclcafeteria.ServidorCafeteria

REM Esperamos unos segundos para asegurar que el registro RMI arranca antes que el cliente
echo Esperando 3 segundos para arranque del RMI...
timeout /t 3 /nobreak >nul

REM 3. EJECUTAR CLIENTE
echo.
echo [3/3] Lanzando el CLIENTE REMOTO...
start "CLIENTE MONITOR (Parte 2)" javaw -cp target/classes poo.peclcafeteria.ClienteMonitor

echo.
echo ========================================================
echo    EJECUCION INICIADA CORRECTAMENTE
echo ========================================================
echo.
echo Presiona CUALQUIER TECLA para CERRAR TODO (Matar Java).
pause >nul

echo.
echo Cerrando procesos Java...
REM /F = Forzar, /IM = Image Name (Nombre del proceso)
taskkill /F /IM javaw.exe

echo.
echo Procesos cerrados.
timeout /t 2 /nobreak >nul
exit
