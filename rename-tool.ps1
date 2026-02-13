Add-Type -AssemblyName System.Windows.Forms

$path = if ($args[0] -and (Test-Path $args[0])) { $args[0] } else { Get-Location }

$form = New-Object System.Windows.Forms.Form
$form.Text = "ファイル名0埋め変換ツール"
$form.Width = 300
$form.Height = 150
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Text = "0埋めする桁数を入力:"
$label.Left = 10
$label.Top = 20
$label.Width = 270
$form.Controls.Add($label)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Left = 10
$textbox.Top = 50
$textbox.Width = 270
$textbox.Text = "3"
$form.Controls.Add($textbox)

$button = New-Object System.Windows.Forms.Button
$button.Text = "実行"
$button.Left = 110
$button.Top = 80
$button.Width = 80
$form.Controls.Add($button)

$form.AcceptButton = $button
$button.Add_Click({
    $digits = [int]$textbox.Text
    if ($digits -gt 0) {
        Get-ChildItem -Path $path -File | ForEach-Object {
            if ($_.BaseName -notmatch '^\d+$') {
                return
            }
            $index = [int]($_.BaseName -replace '\D')
            if ($index -ge 0) {
                $newName = "{0:d$digits}$($_.Extension)" -f $index
                Rename-Item -Path $_.FullName -NewName $newName
            }
        }
        [System.Windows.Forms.MessageBox]::Show("変換が完了しました")
        $form.Close()
    }
})

$form.ShowDialog()
