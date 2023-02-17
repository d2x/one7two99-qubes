 Template for general a productivity VM
=======================================

## fedora based general AppVM
```
Template=fedora-35-minimal
TemplateName=t_fedora-35-apps

qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
#qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf -y update'
  
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf install -y \
	qubes-core-agent-networking \
	qubes-usb-proxy \
	pulseaudio-qubes \
	qubes-gpg-split \
	qubes-mgmt-salt-vm-connector \
	zenity \
	keepassxc \
	klavaro \
	libreoffice \
	gedit \
	gimp \
	firefox \
	nautilus \
	qubes-core-agent-nautilus \
	nautilus-search-tool \
	evince \
	evince-nautilus \
	pinentry-gtk \
	unzip \
	nano \
	git \
	mc \
	less \
	wget \
	borgbackup'
```

### Problem installing qubes-pulseaudio under fedora-36
```
qvm-run --auto --pass-io --no-gui --user root $TemplateName 'dnf install -y \
	--allowerasing pulseaudio-qubes pulseaudio'
```

### Set this template as Template for a disposable VM
Create a new Disposable App-VM which is based on a custom template t-fedora-2
```
template4dvm=t_fedora-35-apps
newdvmtemplatename=my-dvm
qvm-create --template $template4dvm --label red --property template_for_dispvms=True --class=AppVM $newdvmtemplatename
```

Fix menu entry from Domain: my-dvm to Disposable: my-dvm
- https://groups.google.com/forum/#!msg/qubes-users/gfBfqTNzUIg/sbPp-pyiCAAJ
- https://github.com/QubesOS/qubes-issues/issues/1339#issuecomment-338813581
```
qvm-features $newdvmtemplatename appmenus-dispvm 1
qvm-sync-appmenus --regenerate-only $newdvmtemplatename
```

## debian based general AppVM
```
Template=debian-10-minimal
TemplateName=t-debian-10-apps

qvm-kill $TemplateName
qvm-remove --force $TemplateName
qvm-clone $Template $TemplateName
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'apt-get update && apt-get -y upgrade'

qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'apt-get install -y keepass2 klavaro libreoffice gedit gimp \
  firefox-esr qubes-usb-proxy pulseaudio-qubes nano git mc evince \
  less qubes-gpg-split qubes-core-agent unzip \
  nautilus wget qubes-core-agent-nautilus evince pinentry-gtk2 borgbackup'
```
additional apps which might be useful in a general AppVM template
```
qvm-run --auto --pass-io --no-gui --user root $TemplateName \
  'dnf install -y emacs transmission transmission-cli \
  gnome-terminal-nautilus polkit e2fsprogs gnome-terminal \
  terminus-fonts dejavu-sans-fonts dejavu-sans-mono-fonts xclip'
```

## Shutdown
```
qvm-shutdown --wait $TemplateName
```

## Further usefull commands to setup defaults

### Set DVM-template as default DispVM for AppVMs
```
qubes-prefs --set default_dispvm $newdvmtemplatename
```
### Set App-template as default template for new AppVMs
```
qubes-prefs --set default_template $TemplateName
```
### Use this template as template for the Qubes management VM
```
qvm-prefs --set default-mgmt-dvm template $TemplateName
```

## AppVM specific commands
### Change the Disp-VM from an AppVM (here: my-untrusted)
```
appvmname=my-untrusted
qvm-prefs --set $appvmname default_dispvm $newdvmtemplatename
```
Try to start something from this AppVM in a disposable VM
This should start a new dispvm which is based on your dvm-App
```
qvm-run --auto $appvmname 'qvm-open-in-dvm https:/google.de'
```

### Start an App in a DispVM from dom0
```
qvm-run --dispvm=<DISPVM> --service qubes.StartApp+<COMMAND>
```

### Set this template as Template for specific AppVMs
```
MyAppVM=my-untrusted
qvm-prefs --set $MyAppVM template $TemplateName
```
