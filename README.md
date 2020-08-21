# Offculus
Scripts to create offline installer for Oculus Rift

## Creation
 - Install Oculus Software, login and configure your headset (you need a functionnal installation for the creation of the installer)
 - Download this project and execute backup.bat (this will backup the Oculus Software and your user and headset data)
 - The installer is ready (you can copy the whole folder to a safe place)

## Usage
 - This installer is intended for Steam VR use, so Oculus Library will not work out of the box (the OVRLibrary service is not installed)
 - To use the offline installer, execute the install.bat (this will install the oculus software, drivers and services and will block communication with facebook servers)
 - If you chose to modify the install path, make sure that you add a final "\", for instance enter "D:\Programs\Oculus\"
 - To block the oculus/facebook services the installer edits the hosts system file, so you may need to add a security exception in Windows Defender
 - By default the OVRService startup is set to manual, you can use the ovr.bat file to easily start and stop it

## Uninstallation
 - Run the uninstall.bat
