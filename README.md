# AdGuardHome Magisk Module
 
  This is a AdGuardHome module for Magisk, and includes binaries for arm64.
## Included
* [AdGuardHome](<https://github.com/AdguardTeam/AdGuardHome/releases/latest>)
* [magisk-module-installer](<https://github.com/topjohnwu/magisk-module-installer>)

## Install

You can download the release installer zip file and install it via the Magisk Manager App.

## Usage

### Manage service start / stop

* Use the `AdGuardHome_control` command under andoid termux, the available parameters start|stop|restart, for example, the command for service startup is `AdGuardHome_control start`.

* After startup, please enter the following address in the browser to configure.

* `127.0.0.1:3000`

* `0.0.0.0:3000`

## Uninstall

* Uninstall the module via Magisk Manager App.
