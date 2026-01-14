Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- UI Setup ---
$form = New-Object Windows.Forms.Form
$form.Text = "Subnet Calculator"
$form.Size = New-Object Drawing.Size(420, 540)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"

$font = New-Object Drawing.Font("Segoe UI", 10)
$form.Font = $font

# IP Input with Validation
$labelIP = New-Object Windows.Forms.Label
$labelIP.Text = "IP Address:"
$labelIP.Location = New-Object Drawing.Point(20, 20)
$form.Controls.Add($labelIP)

$inputIP = New-Object Windows.Forms.TextBox
$inputIP.Location = New-Object Drawing.Point(20, 45)
$inputIP.Size = New-Object Drawing.Size(150, 25)
$inputIP.Text = "192.168.1.1"
$form.Controls.Add($inputIP)

# CIDR Dropdown
$labelCIDR = New-Object Windows.Forms.Label
$labelCIDR.Text = "CIDR Mask:"
$labelCIDR.Location = New-Object Drawing.Point(200, 20)
$form.Controls.Add($labelCIDR)

$comboCIDR = New-Object Windows.Forms.ComboBox
$comboCIDR.Location = New-Object Drawing.Point(200, 45)
$comboCIDR.Size = New-Object Drawing.Size(100, 25)
$comboCIDR.DropDownStyle = [Windows.Forms.ComboBoxStyle]::DropDownList
for ($i = 0; $i -le 32; $i++) { [void]$comboCIDR.Items.Add("/$i") }
$comboCIDR.SelectedItem = "/24"
$form.Controls.Add($comboCIDR)

# Buttons
$btnCalc = New-Object Windows.Forms.Button
$btnCalc.Text = "Calculate"
$btnCalc.Location = New-Object Drawing.Point(20, 90)
$btnCalc.Size = New-Object Drawing.Size(170, 40)
$btnCalc.BackColor = [Drawing.Color]::AliceBlue
$form.Controls.Add($btnCalc)

$btnCopy = New-Object Windows.Forms.Button
$btnCopy.Text = "Copy Results"
$btnCopy.Location = New-Object Drawing.Point(200, 90)
$btnCopy.Size = New-Object Drawing.Size(170, 40)
$btnCopy.Enabled = $false
$form.Controls.Add($btnCopy)

# Results Display
$outputBox = New-Object Windows.Forms.RichTextBox
$outputBox.Location = New-Object Drawing.Point(20, 150)
$outputBox.Size = New-Object Drawing.Size(360, 300)
$outputBox.ReadOnly = $true
$outputBox.Font = New-Object Drawing.Font("Consolas", 10)
$form.Controls.Add($outputBox)

# --- Logic & Math --- #

function To-IPString ([uint64]$val) {
    $o1 = ($val -shr 24) -band 0xFF
    $o2 = ($val -shr 16) -band 0xFF
    $o3 = ($val -shr 8) -band 0xFF
    $o4 = $val -band 0xFF
    return "$o1.$o2.$o3.$o4"
}

# Real-time Validation
$inputIP.Add_TextChanged({
    $valid = [System.Net.IPAddress]::TryParse($inputIP.Text.Trim(), [ref]$null)
    if ($valid) {
        $inputIP.BackColor = [Drawing.Color]::White
        $btnCalc.Enabled = $true
    } else {
        $inputIP.BackColor = [Drawing.Color]::MistyRose
        $btnCalc.Enabled = $false
    }
})

$btnCalc.Add_Click({
    try {
        $ipParts = $inputIP.Text.Trim().Split('.')
        if ($ipParts.Count -ne 4) { throw "Invalid IP format" }
        
        # Build 64-bit IP integer
        [uint64]$ipUint = ([uint64]$ipParts[0] -shl 24) + ([uint64]$ipParts[1] -shl 16) + ([uint64]$ipParts[2] -shl 8) + [uint64]$ipParts[3]
        
        # Get CIDR from dropdown
        $cidr = [int]$comboCIDR.SelectedItem.ToString().Replace("/", "")

        # Use Power of 2 to create the mask and wildcard to avoid -1 bitwise errors
        [uint64]$totalAddresses = [Math]::Pow(2, (32 - $cidr))
        [uint64]$maskUint = [uint64]([Math]::Pow(2, 32) - $totalAddresses)
        [uint64]$wildcard = $totalAddresses - 1
        
        if ($cidr -eq 0) { $maskUint = 0; $wildcard = 0xFFFFFFFF }

        $netUint = $ipUint -band $maskUint
        $broadUint = $netUint -bor $wildcard

        $outputBox.Clear()
        $res = "Network:      " + (To-IPString $netUint) + "`n"
        $res += "Netmask:      " + (To-IPString $maskUint) + "`n"
        $res += "Broadcast:    " + (To-IPString $broadUint) + "`n"
        
        if ($cidr -le 30) {
            $res += "First Usable: " + (To-IPString ($netUint + 1)) + "`n"
            $res += "Last Usable:  " + (To-IPString ($broadUint - 1)) + "`n"
            $res += "Total Hosts:  " + ($totalAddresses - 2) + "`n"
        } elseif ($cidr -eq 31) {
            $res += "Type:         P2P Link (RFC 3021)`n"
            $res += "Usable IPs:   " + (To-IPString $netUint) + " and " + (To-IPString $broadUint) + "`n"
        } else {
            $res += "Type:         Single Host IP`n"
        }

        $outputBox.Text = $res
        $btnCopy.Enabled = $true

    } catch {
        [Windows.Forms.MessageBox]::Show("Error: " + $_.Exception.Message)
    }
})

$btnCopy.Add_Click({
    [Windows.Forms.Clipboard]::SetText($outputBox.Text)
    $btnCopy.Text = "Copied!"
    $timer = New-Object Windows.Forms.Timer
    $timer.Interval = 1000
    $timer.Add_Tick({ $btnCopy.Text = "Copy Results"; $this.Stop() })
    $timer.Start()
})

$form.ShowDialog()