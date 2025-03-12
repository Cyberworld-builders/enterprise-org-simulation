#Requires -RunAsAdministrator
# PowerShell script to install GNS3 and prep network simulation environment

# Set execution policy (if needed)
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction SilentlyContinue

# Define paths and URLs
$GNS3Url = "https://github.com/GNS3/gns3-gui/releases/download/v2.2.44/GNS3-2.2.44-all-in-one.exe"
$GNS3Installer = "$env:USERPROFILE\Downloads\GNS3-2.2.44-all-in-one.exe"
$pfSenseUrl = "https://atxfiles.pfsense.org/mirror/downloads/pfSense-CE-2.7.2-RELEASE-amd64.iso.gz"
$pfSenseGz = "$env:USERPROFILE\Downloads\pfSense-CE-2.7.2-RELEASE-amd64.iso.gz"
$pfSenseIso = "$env:USERPROFILE\Downloads\pfSense-CE-2.7.2-RELEASE-amd64.iso"
$ImagesDir = "C:\GNS3\images"
$ProjectsDir = "C:\GNS3\projects"

# Function to check if 7-Zip is installed (for unzipping pfSense)
function Install-7Zip {
    if (-not (Test-Path "C:\Program Files\7-Zip\7z.exe")) {
        Write-Host "Installing 7-Zip for unzipping..."
        $7ZipUrl = "https://www.7-zip.org/a/7z2301-x64.exe"
        $7ZipInstaller = "$env:USERPROFILE\Downloads\7z2301-x64.exe"
        Invoke-WebRequest -Uri $7ZipUrl -OutFile $7ZipInstaller
        Start-Process -FilePath $7ZipInstaller -ArgumentList "/S" -Wait -NoNewWindow
        Write-Host "7-Zip installed."
    }
}

try {
    # Step 1: Download GNS3
    Write-Host "Downloading GNS3 installer..."
    Invoke-WebRequest -Uri $GNS3Url -OutFile $GNS3Installer -ErrorAction Stop

    # Step 2: Install GNS3 silently
    Write-Host "Installing GNS3..."
    Start-Process -FilePath $GNS3Installer -ArgumentList "/S" -Wait -NoNewWindow -ErrorAction Stop

    # Step 3: Verify GNS3 install
    if (Test-Path "C:\Program Files\GNS3\gns3.exe") {
        Write-Host "GNS3 installed successfully at C:\Program Files\GNS3"
    } else {
        throw "GNS3 install failed—check $GNS3Installer or run manually."
    }

    # Step 4: Create directories for images and projects
    Write-Host "Setting up GNS3 directories..."
    New-Item -Path $ImagesDir -ItemType Directory -Force | Out-Null
    New-Item -Path $ProjectsDir -ItemType Directory -Force | Out-Null

    # Step 5: Download pfSense ISO
    Write-Host "Downloading pfSense ISO..."
    Invoke-WebRequest -Uri $pfSenseUrl -OutFile $pfSenseGz -ErrorAction Stop

    # Step 6: Install 7-Zip if not present, then unzip pfSense
    Install-7Zip
    Write-Host "Unzipping pfSense ISO..."
    & "C:\Program Files\7-Zip\7z.exe" x $pfSenseGz -o"$env:USERPROFILE\Downloads" -y
    if (Test-Path $pfSenseIso) {
        Move-Item -Path $pfSenseIso -Destination "$ImagesDir\pfSense-CE-2.7.2-RELEASE-amd64.iso" -Force
        Write-Host "pfSense ISO moved to $ImagesDir"
    } else {
        throw "Failed to unzip pfSense ISO."
    }

    # Step 7: Prompt for Cisco IOS image (can’t download legally via script)
    Write-Host "Please place a Cisco IOS image (e.g., c7200-adventerprisek9-mz.152-4.S5.image) in $ImagesDir"
    Write-Host "Source it legally from a router or Cisco VIRL. Press Enter when ready..."
    Read-Host

    # Step 8: Launch GNS3
    Write-Host "Launching GNS3—configure appliances manually next."
    Start-Process "C:\Program Files\GNS3\gns3.exe" -NoNewWindow

    Write-Host "Setup complete! Next steps:"
    Write-Host "1. In GNS3 GUI, add Cisco IOS (Preferences > Dynamips > IOS Routers)."
    Write-Host "2. Add pfSense (Preferences > QEMU > QEMU VMs)."
    Write-Host "3. Build topology: Router > Switch > pfSense > VPCS."
} catch {
    Write-Error "Error occurred: $_"
    Write-Host "Check logs or rerun with tweaks."
}

# Keep window open for review
Write-Host "Script finished. Press Enter to exit."
Read-Host