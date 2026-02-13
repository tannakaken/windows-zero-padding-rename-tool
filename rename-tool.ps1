Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$path = if ($args[0] -and (Test-Path $args[0])) { $args[0] } else { Get-Location }

# フォルダ内のすべてのファイルを取得
$files = Get-ChildItem -Path $path -File

# プレフィックスと拡張子を格納するハッシュセット(重複を避ける)
$prefixes = New-Object System.Collections.Generic.HashSet[string]
$extensions = New-Object System.Collections.Generic.HashSet[string]

# 正規表現パターン: 文字列(プレフィックス) + 数字 + . + 拡張子
$pattern = '^(.+?)(\d+)\.([^.]+)$'

foreach ($file in $files) {
    $fileName = $file.Name
    
    # 正規表現でマッチング
    if ($fileName -match $pattern) {
        $prefix = $Matches[1]      # 最初のキャプチャグループ(プレフィックス)
        $number = $Matches[2]      # 2番目のキャプチャグループ(数字)
        $extension = $Matches[3]   # 3番目のキャプチャグループ(拡張子)
        
        # ハッシュセットに追加(自動的に重複が排除される)
        [void]$prefixes.Add($prefix)
        [void]$extensions.Add($extension)
        
        Write-Verbose "ファイル: $fileName -> プレフィックス: $prefix, 数字: $number, 拡張子: $extension"
    }
}

# ソートされたリストを作成
$sortedPrefixes = $prefixes | Sort-Object
$sortedExtensions = $extensions | Sort-Object

$form = New-Object System.Windows.Forms.Form
$form.Text = "ファイル名0埋め変換ツール"
$form.Size = New-Object System.Drawing.Size(500, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# スクロール可能なパネルを作成
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(10, 10)
$panel.Size = New-Object System.Drawing.Size(460, 500)
$panel.AutoScroll = $true
$panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$form.Controls.Add($panel)

$yPosition = 10

# プレフィックスセクション
$prefixLabel = New-Object System.Windows.Forms.Label
$prefixLabel.Text = "接頭語を選択:"
$prefixLabel.Location = New-Object System.Drawing.Point(10, $yPosition)
$prefixLabel.Size = New-Object System.Drawing.Size(400, 20)
$prefixLabel.Font = New-Object System.Drawing.Font("MS UI Gothic", 10, [System.Drawing.FontStyle]::Bold)
$panel.Controls.Add($prefixLabel)


$yPosition += 30

# プレフィックスのチェックボックスを作成
$prefixCheckboxes = @{}
foreach ($prefix in $sortedPrefixes) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $prefix
    $checkbox.Location = New-Object System.Drawing.Point(30, $yPosition)
    $checkbox.Size = New-Object System.Drawing.Size(400, 20)
    $checkbox.Checked = $true  # デフォルトで全選択
    $panel.Controls.Add($checkbox)
    $prefixCheckboxes[$prefix] = $checkbox
    $yPosition += 25
}


$yPosition += 20

# 拡張子セクション
$extensionLabel = New-Object System.Windows.Forms.Label
$extensionLabel.Text = "拡張子を選択:"
$extensionLabel.Location = New-Object System.Drawing.Point(10, $yPosition)
$extensionLabel.Size = New-Object System.Drawing.Size(400, 20)
$extensionLabel.Font = New-Object System.Drawing.Font("MS UI Gothic", 10, [System.Drawing.FontStyle]::Bold)
$panel.Controls.Add($extensionLabel)

$yPosition += 30


# 拡張子のチェックボックスを作成
$extensionCheckboxes = @{}
foreach ($extension in $sortedExtensions) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = ".$extension"
    $checkbox.Location = New-Object System.Drawing.Point(30, $yPosition)
    $checkbox.Size = New-Object System.Drawing.Size(400, 20)
    $checkbox.Checked = $true  # デフォルトで全選択
    $panel.Controls.Add($checkbox)
    $extensionCheckboxes[$extension] = $checkbox
    $yPosition += 25
}

$yPosition += 30

$label = New-Object System.Windows.Forms.Label
$label.Text = "0埋めする桁数を入力:"
$label.Left = 10
$label.Top = $yPosition
$label.Width = 270
$panel.Controls.Add($label)

$yPosition += 30

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Left = 10
$textbox.Top = $yPosition
$textbox.Width = 270
$textbox.Text = "3"
$panel.Controls.Add($textbox)

$yPosition += 30

$button = New-Object System.Windows.Forms.Button
$button.Text = "実行"
$button.Left = 110
$button.Top = $yPosition
$button.Width = 80
$panel.Controls.Add($button)

$form.AcceptButton = $button
$button.Add_Click({
    # 選択されたプレフィックスを取得
    $selectedPrefixes = @()
    foreach ($key in $prefixCheckboxes.Keys) {
        if ($prefixCheckboxes[$key].Checked) {
            $selectedPrefixes += $key
        }
    }
    # 選択された拡張子を取得
    $selectedExtensions = @()
    foreach ($key in $extensionCheckboxes.Keys) {
        if ($extensionCheckboxes[$key].Checked) {
            $selectedExtensions += $key
        }
    }
    # 変換する桁数を取得
    $digits = [int]$textbox.Text
    Write-Host "Number of digits: $digits"
    if ($digits -gt 0) {
        foreach ($file in $files) {
            $fileName = $file.Name
            Write-Host "File: $fileName"
            if ($fileName -match $pattern) {
                $prefix = $Matches[1]
                $index = [int]($Matches[2])
                $extension = $Matches[3]
                if (!$selectedPrefixes.Contains($prefix) -or !$selectedExtensions.Contains($extension)) {
                    continue
                }
                if ($index -ge 0) {
                    $newName = "$prefix{0:d$digits}$($file.Extension)" -f $index
                    Write-Host "$fileName -> $newName"
                    Rename-Item -Path $file.FullName -NewName $newName
                }
            }
        }
        [System.Windows.Forms.MessageBox]::Show("変換が完了しました")
        $form.Close()
    }
})

$form.ShowDialog()
