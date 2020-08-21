# Offculus
Scripts to create offline installer for Oculus Rift

## Creation
 - Install Oculus Software, login and configure your headset (you need a functionnal installation for the creation of the installer)
 - Download this project and execute backup.bat (this will backup the Oculus Software and your user and headset data)
 - You may need to change the locale in oculus.reg (look for the used keys in your registry)
 - The installer is ready (you can copy the whole folder to a safe place)

## Usage
 - To use the offline installer, execute the install.bat (this will install the oculus software, drivers and services and will block communication with facebook servers)
 - By default the OVRService startup is set to manual, you can use the ovr.bat file to easily start and stop it

## Uninstallation
 - Execute the oculus setup in C:\Program Files\Oculus and select uninstall
 - Remove the Facebook and oculus entries in C:\Windows\System32\drivers\etc\hosts
