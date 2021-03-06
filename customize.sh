##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into post-fs-data.sh or service.sh
# 5. Add your additional or modified system properties into system.prop
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
##########################################################################################

##########################################################################################
# SKIPUNZIP
##########################################################################################

# If you need even more customization and prefer to do everything on your own, declare SKIPUNZIP=1 in customize.sh to skip the extraction and applying default permissions/secontext steps.
# Be aware that by doing so, your customize.sh will then be responsible to install everything by itself.
SKIPUNZIP=1

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"
##########################################################################################
# Install
##########################################################################################

if [ $BOOTMODE ! = true ]; then
   abort "! Please install in Magisk Manager"
fi

ui_print "- Extracting module files"
unzip -o "$ZIPFILE" -x 'META-INF/*' -d $MODPATH >&2

AdGuardHome_link="https://github.com/AdguardTeam/AdGuardHome/releases"
latest_version=`curl -k -s -I "${AdGuardHome_link}/latest" | grep -i location | grep -o "tag.*" | grep -o "v[0-9.]*"`
if [ "${latest_version}" = "" ] ; then
  abort "Error: Connect AdGuardHome download link failed."
fi
ui_print "- Download latest AdGuardHome ${latest_version}-${ARCH}"
case "${ARCH}" in
  arm)
    download_AdGuardHome_link="${AdGuardHome_link}/download/${latest_version}/AdGuardHome_linux_armv7.tar.gz"
    ;;
  arm64)
    download_AdGuardHome_link="${AdGuardHome_link}/download/${latest_version}/AdGuardHome_linux_arm64.tar.gz"
    ;;
  x86)
    download_AdGuardHome_link="${AdGuardHome_link}/download/${latest_version}/AdGuardHome_linux_386.tar.gz"
    ;;
  x64)
    download_AdGuardHome_link="${AdGuardHome_link}/download/${latest_version}/AdGuardHome_linux_amd64.tar.gz"
    ;;
esac
curl "${download_AdGuardHome_link}" -k -L -o "$MODPATH/AdGuardHome.tar.gz" >&2
if [ "$?" != "0" ] ; then
  abort "Error: Download AdGuardHome core failed."
fi
tar zxvf $MODPATH/AdGuardHome.tar.gz -C $MODPATH >&2
mv -f $MODPATH/AdGuardHome/AdGuardHome $MODPATH/core/AdGuardHome

ui_print "- Generate module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=AdGuardHome_For_Magisk" > $MODPATH/module.prop
echo "name=AdGuardHome For Magisk" >> $MODPATH/module.prop
echo -n "version=" >> $MODPATH/module.prop
echo ${latest_version} >> $MODPATH/module.prop
echo "versionCode=$(date +%Y%m%d)" >> $MODPATH/module.prop
echo "author=Module by AiSauce.Core by AdGuardTeam." >> $MODPATH/module.prop
echo "description=Network-wide ads & trackers blocking DNS server." >> $MODPATH/module.prop

# Delete extra files
rm -rf \
$MODPATH/system/placeholder $MODPATH/customize.sh \
$MODPATH/*.md $MODPATH/.git* $MODPATH/LICENSE $MODPATH/AdGuardHome $MODPATH/AdGuardHome.tar.gz 5>/dev/null

##########################################################################################
# Permissions
##########################################################################################

  # Remove this if adding to this function

  # Note that all files/folders in magisk module directory have the $MODPATH prefix - keep this prefix on all of your files/folders
  # Some examples:
  
  # For directories (includes files in them):
  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm_recursive $MODPATH/system/lib 0 0 0755 0644
  # set_perm_recursive $MODPATH/system/vendor/lib/soundfx 0 0 0755 0644

  # For files (not in directories taken care of above)
  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  
  # set_perm $MODPATH/system/lib/libart.so 0 0 0644
  # set_perm /data/local/tmp/file.txt 0 0 644
  
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $MODPATH/core 0 0 0755 0755
  set_perm $MODPATH/core/AdGuardHome 0 0 6755
  set_perm $MODPATH/system/bin/AdGuardHome_control 0 0 777

