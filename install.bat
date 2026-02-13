@echo off
chcp 65001 >nul
echo "=========================================="
echo " ファイル名0埋め変換メニュー登録ツール"
echo "=========================================="
echo.

REM "管理者権限チェック"
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo "[エラー] 管理者権限が必要です"
    echo "このファイルを右クリック→「管理者として実行」してください"
    pause
    exit /b 1
)

REM "スクリプトの絶対パスを取得"
set SCRIPT_PATH=%~dp0rename-tool.ps1

REM "レジストリ登録"
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\MyZeroPadding" /ve /d "ファイル名0埋め変換" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\MyZeroPadding" /v "Icon" /d "powershell.exe" /f
reg add "HKEY_CLASSES_ROOT\Directory\Background\shell\MyZeroPadding\command" /ve /d "powershell.exe -ExecutionPolicy Bypass -NoProfile -File \"%SCRIPT_PATH%\" \"%%V\"" /f

echo.
echo "[完了] 右クリックメニューに登録されました"
echo "フォルダを右クリックすると「このフォルダで処理を実行」が表示されます"
echo.
pause