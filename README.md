**PowerShell Subnet Calculator**

A lightweight, Windows-native GUI application built with PowerShell and WinForms. It simplifies IPv4 subnetting by providing instant calculations for network addresses, broadcast addresses, and usable host ranges.

🚀 Features:
> Real-time Validation: The IP address input field automatically validates format as you type. If the format is incorrect, the background turns MistyRose (light red) and the calculate button is disabled.

> CIDR Dropdown: Includes a pre-populated dropdown for masks from /0 to /32, eliminating manual entry errors.

> Precision Math Engine: Uses 64-bit integer processing to prevent the "Value too large/small for UInt32" errors common in standard PowerShell bitwise operations.

> Clipboard Integration: A one-click "Copy Results" button captures all calculated data for easy pasting into documentation or tickets.

> Monospaced Output: Results are displayed in Consolas font to ensure perfect alignment of IP addresses and labels.

🛠️ How to Use:
1. Copy the Script: Copy the final version of the PowerShell script provided in our conversation.

2. Save the File: Save the code as Subnet_Calculator.ps1

3. Run with PowerShell:

    3a. Right-click Subnet_Calculator.ps1 and select 'Run with PowerShell'.

    3b. Note: If you get an execution policy error, run Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser in your terminal first.

4. Calculate: Enter your target IP, select your CIDR mask from the dropdown, and click Calculate.

🔬 Technical Specifications:
Mathematical Reliability
The calculator avoids the standard PowerShell -shl (shift-left) and -not (bitwise NOT) operators on 32-bit integers, which are known to cause signed-integer overflow errors (interpreting bit patterns as negative numbers like -1 or -256). Instead, it utilizes:

[Math]::Pow: For clean, overflow-free power-of-two calculations.

[uint64] Casting: All bitwise math is performed in a 64-bit space to ensure the 32nd bit (the sign bit in 32-bit integers) does not trigger an error.

Layout Logic
Language: PowerShell 5.1+

Framework: .NET System.Windows.Forms & System.Drawing

Compatibility: Windows 10 / 11

📝 Example Output:

Network:      192.168.1.0
Netmask:      255.255.255.0
Broadcast:    192.168.1.255
First Usable: 192.168.1.1
Last Usable:  192.168.1.254
Total Hosts:  254
