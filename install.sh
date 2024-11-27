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
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=false

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

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
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
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
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "QcomRxWakelockFix"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  configs=$(find /system /vendor -name WCNSS_qcom_cfg.ini)
  for CONFIG in $configs
  do
    [[ -f $CONFIG ]] && [[ ! -L $CONFIG ]] && {
      SELECTED_CONFIG=$CONFIG
      mkdir -p `dirname $MODPATH$CONFIG`

      ui_print "Found $CONFIG"
      [[ -f /sbin/.magisk/mirror$SELECTED_CONFIG ]] && cp -af /sbin/.magisk/mirror$SELECTED_CONFIG $MODPATH$SELECTED_CONFIG || cp -af $SELECTED_CONFIG $MODPATH$SELECTED_CONFIG

      add_line_if_not_exists() {
        local line="$1"
        local file="$2"
        grep -qF -- "$line" "$file" || sed -i "1s/^/$line\n/" "$file"
      }

      add_line_if_not_exists "RoamRssiDiff=3" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "g11dSupportEnabled=0" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gEnablePowerSaveOffload=5" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gRuntimePM=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "RTSThreshold=1048576" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gMCAddrListEnable=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gActiveMaxChannelTime=40" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gActiveMinChannelTime=20" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gMaxConcurrentActiveSessions=2" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gReorderOffloadSupported=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gEnableIpTcpUdpChecksumOffload=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "TSOEnable=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "GROEnable=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gEnablePowerSaveOffload=2" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gRoamOffloadEnabled=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "hostArpOffload=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "hostNSOffload=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gActiveModeOffload=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gEnableActiveModeOffload=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gEnableP2pListenOffload=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gEnablePowerSaveOffload=5" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gMCAddrListEnable=1" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gActiveMinChannelTime=20" $MODPATH$SELECTED_CONFIG
      add_line_if_not_exists "gActiveMaxChannelTime=40" $MODPATH$SELECTED_CONFIG

      # Existing parameters (apply sed replacements)
      sed -i 's/RoamRssiDiff=[0-9]*/RoamRssiDiff=3/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/g11dSupportEnabled=[0-9]*/g11dSupportEnabled=0/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gEnablePowerSaveOffload=[0-9]*/gEnablePowerSaveOffload=5/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gRuntimePM=[0-9]*/gRuntimePM=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/RTSThreshold=[0-9]*/RTSThreshold=1048576/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gMCAddrListEnable=[0-9]*/gMCAddrListEnable=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gActiveMaxChannelTime=[0-9]*/gActiveMaxChannelTime=40/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gActiveMinChannelTime=[0-9]*/gActiveMinChannelTime=20/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gMaxConcurrentActiveSessions=[0-9]*/gMaxConcurrentActiveSessions=2/g' $MODPATH$SELECTED_CONFIG
      sed -i '/RoamRssiDiff/i gEnablePowerSaveOffload=5' $MODPATH$SELECTED_CONFIG
      sed -i '/RoamRssiDiff/i gMCAddrListEnable=1' $MODPATH$SELECTED_CONFIG
      sed -i '/gActiveMaxChannelTime/a gActiveMinChannelTime=20' $MODPATH$SELECTED_CONFIG
      sed -i 's/gReorderOffloadSupported=[0-9]*/gReorderOffloadSupported=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gEnableIpTcpUdpChecksumOffload=[0-9]*/gEnableIpTcpUdpChecksumOffload=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/TSOEnable=[0-9]*/TSOEnable=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/GROEnable=[0-9]*/GROEnable=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gEnablePowerSaveOffload=[0-9]*/gEnablePowerSaveOffload=2/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gRoamOffloadEnabled=[0-9]*/gRoamOffloadEnabled=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/hostArpOffload=[0-9]*/hostArpOffload=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/hostNSOffload=[0-9]*/hostNSOffload=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gMCAddrListEnable=[0-9]*/gMCAddrListEnable=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gActiveModeOffload=[0-9]*/gActiveModeOffload=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gEnableActiveModeOffload=[0-9]*/gEnableActiveModeOffload=1/g' $MODPATH$SELECTED_CONFIG
      sed -i 's/gEnableP2pListenOffload=[0-9]*/gEnableP2pListenOffload=1/g' $MODPATH$SELECTED_CONFIG

    }
  done
  [[ -z $SELECTED_CONFIG ]] && abort "WCNSS_qcom_cfg.ini not found" || { mkdir -p $MODPATH/system; mv -f $MODPATH/vendor $MODPATH/system/vendor;}
}



# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code
