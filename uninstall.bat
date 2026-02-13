@echo off
chcp 65001 >nul
echo "=========================================="
echo " ファイル名0埋め変換メニュー削除ツール"
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

REM "レジストリ削除"
reg delete "HKEY_CLASSES_ROOT\Directory\Background\shell\MyZeroPadding" /f

echo.
echo "[完了] 右クリックメニューから削除されました"
echo.
pause