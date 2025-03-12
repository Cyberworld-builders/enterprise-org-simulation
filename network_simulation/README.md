# Network Simulation

## GNS3
I'm going to start with GNS3 for network simulation. The idea is to be able to simulate end devices on vms that exist on an entirely simulated network.

Yes, you can download and install GNS3 entirely from PowerShell on Windows 11, though it’s a bit of a manual process since GNS3 doesn’t have an official PowerShell installer script. We’ll use PowerShell to grab the installer, run it silently, and set up the basics. Here’s how:

---

### **Step 1: Prep PowerShell**
- Open PowerShell as Administrator (right-click Start > Terminal (Admin)).  
- Set execution policy to allow scripts (if needed):  
  ```powershell
  Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
  ```

---

### **Step 2: Download GNS3 Installer**
- GNS3’s latest version (as of March 2025) is around 2.2.44, but check [gns3.com](https://www.gns3.com/software/download) for the exact URL. I’ll use a recent example—adjust if the version shifts:  
  ```powershell
  $url = "https://github.com/GNS3/gns3-gui/releases/download/v2.2.44/GNS3-2.2.44-all-in-one.exe"
  $output = "$env:USERPROFILE\Downloads\GNS3-2.2.44-all-in-one.exe"
  Invoke-WebRequest -Uri $url -OutFile $output
  ```

---

### **Step 3: Install GNS3 Silently**
- The GNS3 installer is an NSIS-based .exe. Run it silently with `/S` (silent) and optional flags:  
  ```powershell
  Start-Process -FilePath $output -ArgumentList "/S" -Wait -NoNewWindow
  ```
- This installs GNS3 to `C:\Program Files\GNS3` (default) with all components (GUI, Dynamips, QEMU, etc.). Takes a minute or two.  
- **Note:** It might still prompt for Npcap/WinPCAP—silent mode skips user prompts but assumes “yes.” If it hangs, you may need to run it once manually to accept Npcap’s license, then script the rest.

---

### **Step 4: Verify Install**
- Check it’s there:  
  ```powershell
  Test-Path "C:\Program Files\GNS3\gns3.exe"
  ```
- If `True`, you’re golden. Launch it to confirm:  
  ```powershell
  Start-Process "C:\Program Files\GNS3\gns3.exe"
  ```

---

### **Step 5: Add Device Images (Optional Automation)**
- **Cisco IOS:** Assuming you’ve got `c7200-adventerprisek9-mz.152-4.S5.image` somewhere (e.g., `C:\GNS3\images`), you’d normally add it via GUI. PowerShell can’t configure GNS3 internals directly, but you can prep files:  
  ```powershell
  New-Item -Path "C:\GNS3\images" -ItemType Directory -Force
  Move-Item -Path "path\to\your\image" -Destination "C:\GNS3\images\c7200-adventerprisek9-mz.152-4.S5.image"
  ```
- **pfSense ISO:** Download it:  
  ```powershell
  Invoke-WebRequest -Uri "https://atxfiles.pfsense.org/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz" -OutFile "$env:USERPROFILE\Downloads\pfSense.iso.gz"
  # Unzip (needs 7-Zip installed)
  & "C:\Program Files\7-Zip\7z.exe" x "$env:USERPROFILE\Downloads\pfSense.iso.gz" -o"$env:USERPROFILE\Downloads"
  ```
- You’ll still need to add these in GNS3 GUI once (Preferences > Add appliances), but files are ready.

---

### **Step 6: Full Script Example**
Here’s it all together—run as Admin:
```powershell
# Download GNS3
$url = "https://github.com/GNS3/gns3-gui/releases/download/v2.2.44/GNS3-2.2.44-all-in-one.exe"
$output = "$env:USERPROFILE\Downloads\GNS3-2.2.44-all-in-one.exe"
Invoke-WebRequest -Uri $url -OutFile $output

# Install silently
Start-Process -FilePath $output -ArgumentList "/S" -Wait -NoNewWindow

# Verify
if (Test-Path "C:\Program Files\GNS3\gns3.exe") {
    Write-Host "GNS3 installed successfully!"
    Start-Process "C:\Program Files\GNS3\gns3.exe"
} else {
    Write-Host "Install failed—check logs or run manually."
}

# Prep image folder (optional)
New-Item -Path "C:\GNS3\images" -ItemType Directory -Force
```

---

### **Caveats**
- **Npcap Prompt:** If silent install stalls (Npcap GUI pops up), kill it, install Npcap separately first (`Invoke-WebRequest` its installer + `/S`), then rerun GNS3 install.  
- **Post-Install Config:** Adding IOS/pfSense and building topology needs GUI or API scripting later—not PowerShell-friendly out of the box.  
- **WSL2 Bonus:** If you want GNS3 server in WSL2, install it there separately (`wsl -d Ubuntu-22.04 sudo apt install gns3-server`), but Windows native is fine for now.

Run this, and GNS3 should be on your system. Launch it, set up your router/firewall via GUI, and you’re off! Want to test the script or jump to topology next? Over.