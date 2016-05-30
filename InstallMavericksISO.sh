#!/bin/bash
echo "Verifying Installer is on Desktop... "
# Verify that InstallESD.dmg exists
if [ ! -f ~/Desktop/InstallESD.dmg ]; then
   echo "InstallESD.dmg not found on desktop!"
   echo "Moving from ISO..."
   cp /Applcations/Install OS X Mavericks.app/Contents/SharedSupport/InstallESD.dmg
   exit 1
fi
echo "+ Mounting Installer ESD Image..."
# Mount the installer image
hdiutil attach ~/Desktop/InstallESD.dmg -noverify -nobrowse -mountpoint /Volumes/install_app
echo "- Mounted Installer ESD Image"
echo "+ Creating Blank ISO Image (Size: 7316MB)"
# Create the Blank ISO Image of 7316mb with a Single Partition - Apple Partition Map
hdiutil create -o ~/Desktop/Mavericks.cdr -size 7316m -layout SPUD -fs HFS+J
echo "- Created Blank ISO Image"
echo "+ Mount ISO Image"
# Mount the Blank ISO Image
hdiutil attach ~/Desktop/Mavericks.cdr.dmg -noverify -nobrowse -mountpoint /Volumes/install_build
echo "+ Mounted ISO Image"
echo "+ Restore Base System"
# Restore the Base System into the Blank ISO Image
asr restore -source /Volumes/install_app/BaseSystem.dmg -target /Volumes/install_build -noprompt -noverify -erase
echo "+ Restored Base System"
echo "+ Cleaning Up..."
# Remove Package link and replace with actual files
rm /Volumes/OS\ X\ Base\ System/System/Installation/Packages
echo "+ copying packages from installer to ISO"
cp -rp /Volumes/install_app/Packages /Volumes/OS\ X\ Base\ System/System/Installation/
 
# Copy installer dependencies
echo "+ Copy dependencies"
cp -rp /Volumes/install_app/BaseSystem.chunklist /Volumes/OS\ X\ Base\ System/BaseSystem.chunklist
cp -rp /Volumes/install_app/BaseSystem.dmg /Volumes/OS\ X\ Base\ System/BaseSystem.dmg
echo "+ Unmount installer image"
# Unmount the installer image
hdiutil detach /Volumes/install_app
echo "+ Unmount ISO"
# Unmount the ISO Image
hdiutil detach /Volumes/OS\ X\ Base\ System/
echo "+ Convert DMG to ISO"
# Convert the ISO Image to ISO/CD master (Optional)
hdiutil convert ~/Desktop/Mavericks.cdr.dmg -format UDTO -o ~/Desktop/Mavericks.iso
echo "+ Rename CDR to ISO"
# Rename the ISO Image and move it to the desktop
mv ~/Desktop/Mavericks.iso.cdr ~/Desktop/Mavericks.iso
scp ~/Desktop/Mavericks.iso root@149.56.19.92:/vmfs/volumes/datastore1/iso_store/
