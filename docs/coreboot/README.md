# Coreboot on Lenovo X230

This howto describes how to install Coreboot on a Lenovo X230.
This document is still a draft and needs some cleanup.

In order to flash the bios chip on the X230 you need special equipment to read and write to the two BIOS chips.
An easy way which for an in-place flashiung procedure is to use a raspberry pi and a special flashing clip to read from and write to the Bios chip.

The setup looks like this:

Lenovo X230 (target) BIOS Chip <-- Pomodo Flash Clip <-- Raspberry Pi <-- Building Machine.

Because you need to build coreboot and this takes a long time on a raspberry pi, this howto assumes that you have an additional laptop/PC which will be used as building machine.
The building machine will compile the coreboot ROm file and the raspberry pi is only used to read and write from and to the target device.

## Links
I have looked at the following ressources to learn more about coreboot adn write this howto

- https://www.coreboot.org/Build_HOWTO
- https://www.coreboot.org/Supported_Motherboards
- https://www.coreboot.org/Board:lenovo/x230
- https://github.com/bibanon/Coreboot-ThinkPads/wiki/Hardware-Flashing-with-Raspberry-Pi
- [Coreboot on the ThinkPad X220 with a Raspberry Pi](https://tylercipriani.com/blog/2016/11/13/coreboot-on-the-thinkpad-x220-with-a-raspberry-pi/)
- [Karl Cordes - How to flash Coreboot on X220](https://karlcordes.com/coreboot-x220/)
  Gute Anleitung für Anschluss FlashClip an Pi
- [Johannes' Blog - Coreboot on X220](https://wej.k.vu/coreboot/coreboot_on_the_lenovo_thinkpad_x220/)
- [Coreboot X230]( https://blog.noq2.net/corebooting-thinkpad-x230.html)
- [Flashing Coreboot on the T430 with a Raspberry Pi](https://nm-projects.de/2017/08/flashing-coreboot-on-the-t430-with-a-raspberry-pi/)
- https://kennyballou.com/blog/2017/01/coreboot-x230/
- https://www.coreboot.org/SeaBIOS

Additional info has been provided by the Coreboot Mailinglist:

- https://mail.coreboot.org/pipermail/coreboot/2017-September/085173.html
- https://mail.coreboot.org/pipermail/coreboot/2017-September/085182.html
- https://mail.coreboot.org/pipermail/coreboot/2017-September/085185.html


## Summary how to flash CoreBoot to the X230


## Procedure

0) Hardware-assembly to connect the External Flash Clip via female jumper cables to the Raspberry Pi IO-Module.

1) Install Raspberian on Pi using Noobs

2) Update Pi and install additional packages including 'flashrom'

3) Disassemble X230 Laptop. Unmount keyboard and palmrest of your "coreboot target laptop" (target) to access the BIOS Chips

4) Connect the BIOS-Clip to BIOS-chips and read the content from your pi
   (x230-default-part2-4mb.rom / x230-default-part2-8mb.rom)

5) merge the two files into one 12 MB ROM file
   (x230-default-12mb.rom)

6) Copy all three files to your "build laptop" (laptop)
   Build Laptop must run Linux, this howto assumes you are using Ubuntu 16.04.3 LTS
   (could also be installed on an USB thumbdrive or external harddrive)

7) Download & Install Coreboot from GIT

7) Install UEFITool on laptop

8) Extract VGA BLOB from the x230-default-12mb.rom file
   save the file in the coreboot/blobs directory
   (./coreboot/3rdparty/blobs/mainboard/lenovo/x230/pci8086,0166.rom)

9) Build Coreboot Toolchain

10) Compile ifdtool located in the coreboot/utils directory

11) Extract BLOBS from x230-default-12mb.rom using ifdtool
    save the files in the coreboot/blobs directory
    (./coreboot/3rdparty/blobs/mainboard/lenovo/x230/descriptor.bin)
    (./coreboot/3rdparty/blobs/mainboard/lenovo/x230/me.bin)
    (./coreboot/3rdparty/blobs/mainboard/lenovo/x230/gbe.bin)

11b) [Optionally] Use ME_Cleaner on me.bin file )
     (also it seems that ME_Cleaner is included in Coreboot:
     Coreboot nconfig:
     Chipset > Add Intel descriptor.bin file > Add Intel ME/TXE firmware
     --> Strip down the Intel ME/TXE firmware )
     I've choosen to leave the me.bin as is until everything is working.

12) Configure Coreboot (make nconfig)
    choose parameters/features and add the 4 binary blobs (step 8 and 11)

13) build coreboot image
    (./coreboot/build/coreboot.rom)

14) Split coreboot.rom into two separate files to flash them to your 2 chips
    (x230-coreboot-8mb.rom and x230-coreboot-4mb.rom)

15) copy both files to your Raspberry Pi

16) flash both files via Raspberry Pi using flashrom again

17) Reboot target laptop

18) be happy with coreboot ;-)



## Hardware needed to built Flashing device (Pi) for Coreboot:
the following parts are needed to build a Coreboot flashing devices:

- Raspberry Pi 3 ~ 35 Eur
  https://www.amazon.de/dp/B01CD5VC92/
- 32 GB SDCard ~ 17 Eur
  https://www.amazon.de/dp/B073S8LQSL/
- Jumper Cables ~ 7 Eur
  https://www.amazon.de/dp/B072NSLB98/
- Pomona 5250 8-Pin Flash Clip ~ 12 Eur
  https://www.digikey.de/product-detail/de/pomona-electronics/5250/501-1311-ND/745102

## physical setup
using a Raspberry Pi 3 Model B V1.2 the GPIO Layout looks like this:
(Hint you can get a very good overview of the layout by entering the `pinout` command on your pi:
```
,--------------------------------.
| oooooooooooooooooooo J8     +====
| 1ooooooooooooooooooo        | USB
|                             +====
|      Pi Model 3B V1.2          |
|      +----+                 +====
| |D|  |SoC |                 | USB
| |S|  |    |                 +====
| |I|  +----+                    |
|                   |C|     +======
|                   |S|     |   Net
| pwr        |HDMI| |I||A|  +======
`-| |--------|    |----|V|-------'

Revision           : a02082
SoC                : BCM2837
RAM                : 1024Mb
Storage            : MicroSD
USB ports          : 4 (excluding power)
Ethernet ports     : 1
Wi-fi              : True
Bluetooth          : True
Camera ports (CSI) : 1
Display ports (DSI): 1

J8:
   3V3  (1) (2)  5V    
 GPIO2  (3) (4)  5V    
 GPIO3  (5) (6)  GND   
 GPIO4  (7) (8)  GPIO14
   GND  (9) (10) GPIO15
GPIO17 (11) (12) GPIO18
GPIO27 (13) (14) GND   
GPIO22 (15) (16) GPIO23
   3V3 (17) (18) GPIO24
GPIO10 (19) (20) GND   
 GPIO9 (21) (22) GPIO25
GPIO11 (23) (24) GPIO8 
   GND (25) (26) GPIO7 
 GPIO0 (27) (28) GPIO1 
 GPIO5 (29) (30) GND   
 GPIO6 (31) (32) GPIO12
GPIO13 (33) (34) GND   
GPIO19 (35) (36) GPIO16
GPIO26 (37) (38) GPIO20
   GND (39) (40) GPIO21

For further information, please refer to https://pinout.xyz/
```

Layout of pins if you look on the pi and, the GPIO pins are located on the left side, so that USB and ethernet ports are at the top:
```
        | USB |  | USB |    | RJ45 |
        |     |  |     |    |      |
        +-----+  +-----+    +------+

e       +-----+
d       | o o <-  GND
g       | o o |
e       | o o |
        | o o |
o       | o o |
f       | o o |
        | o o |
R       | o o |
a  CS  -> o o <-  CLK
s       | o o <-  MISO
p       | o o <-  MOSI
b       | o o <-  3.3V 
e       | o o |
r       | o o |
r       | o o |
y       | o o |
        | o o |
P       | o o |
i       | o o |
        | o o |
        +-----+
```
We need to connect 6 pins to the Pomona SOIC8 5250 Test Clip using the jumper cables.
you can take any color you want, to make it simpler for you, I'll add the colors I have used:

connect 6 jumper cables to the raspberry pi GPIO pins:

- GND	black
- CS	green
- CLK	gray
- MISO	white
- MOSI	purple
- 3.3V	blue

Now connect the other end of the jumper cables to the Pomona Clip:
```
    MOSI (purple) 5 =|  |= 4  GND  (black)
     CLK (gray)   6 =|  |= 3  NC   (empty)
      NC (empt    7 =|  |= 2  MISO (white)
3.3V/VCC (blue)   8 =|_*|= 1  CS   (green)
                              (dot on top of the chip)
```

```
----- not sure if needed -----
# Get BLOBs
https://www.coreboot.org/downloads.html
wget https://coreboot.org/releases/coreboot-blobs-4.6.tar.xz
wget https://coreboot.org/releases/coreboot-blobs-4.6.tar.xz.sig
gpg --verify coreboot-blobs-4.6.tar.xz.sig
tar -xf coreboot-blobs-4.6.tar.xz --strip-components=1 -C coreboot
------------------------------
```

## Prepare Build machine
You can use another Qubes Laptop as Building machine.
1) Clone the Debian template
```
qvm-clone debian-9 t-coreboot
```
2) launch a terminal in this template an install the following packages
```
sudo apt-get install git wget build-essential gnat flex bison libncurses5-dev zlib1g-dev libfreetype6-dev unifont python3
```
3) Create an AppVM bases on this template
Important: increase private storage size, as the build process and the git repositories need some storage capacity.
private storage size = 20480

## Setting up Raspberry Pi

1. Download Noobs
2. Install Raspbian
3. Enable SSH

## Install FlashROM on Raspberry Pi
Flashrom is used to read the current ROM from the Bios Chip and make a backup of it.
It will also be used to flash the new coreboot Bios.
1) Install build enviroment and dependencies for flashrom
   ```
   sudo apt-get install libftdi1 libftdi-dev libusb-dev libpci-dev m4 bison flex libncurses5-dev  libncurses5 build-essential pciutils usbutils libpci-dev libusb-dev libftdi1 libftdi-dev zlib1g-dev subversion libusb-1.0 gnat wget zlib1g-dev
   ```
   Problem: some packackes could not be installed:
   [...]
   Package flex is not available, but is referred to by another package.
   This may mean that the package is missing, has been obsoleted, or
   is only available from another source
   [...]

   Solution:
   delete all files in /var/lib/apt/lists
   
2) Download and install Flashrom
   ```
   git clone https://github.com/flashrom/flashrom
   cd flashrom
   make
   sudo make install
   ```
3) Enable the SPI device on the Raspberry Pi.
   ```
   sudo raspi-config
   # In the menu choose:
   # - 5 Interfacing Options  Configure connections to peripherals 
   # - P4 SPI Enable/Disable automatic loading of SPI kernel module
   # - Would you like the SPI interface to be enabled?
   # - Yes 
   sudo reboot
   ```
4) Modprobe SPI driver
   ```
   sudo modprobe spi_bcm2835
   sudo modprobe spidev
   ```


## Prepare Build machine (the AppVM NOT the template)
### Setup Coreboot
Cloning the coreboot git. and recursively clone the necessary other gits.
```
git clone --recursive https://github.com/coreboot/coreboot
cd ~/coreboot/3rdparty
git clone http://review.coreboot.org/p/blobs.git
```

or:

8< ---
# Building Coreboot
git clone https://review.coreboot.org/coreboot
cd coreboot
git submodule update --init --checkout
--- 8<

### Setup Extraction Tool for binary blobs
Build and install the extraction tool for the binary blobs.
```
cd ~/coreboot/util/ifdtool
make
sudo make install
```

## on Raspberry Pi
read existing BIOS and transfer it to build machine

1) Read upper bios chip (4MB)
   ```
   pi@raspberrypi:~ $ flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=1000 -c "MX25L3206E/MX25L3208E" -r x230-bios-top1.bin
   flashrom p1.0-69-g3f7e341 on Linux 4.14.30-v7+ (armv7l)
   flashrom is free software, get the source code at https://flashrom.org

   Using clock_gettime for delay loops (clk_id: 1, resolution: 1ns).
   Found Macronix flash chip "MX25L3205D/MX25L3208D" (4096 kB, SPI) on linux_spi.
   Reading flash... done.
   
   ```
   Repeat this two more times creating: x230-bios-top2.bin and x230-bios-top3.bin

2) Read lower bios chip (8MB)
   ```
   pi@raspberrypi:~ $ flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=1000 -c "MX25L6406E/MX25L6408E" -r x230-bios-bottom1.bin
   flashrom p1.0-69-g3f7e341 on Linux 4.14.30-v7+ (armv7l)
   flashrom is free software, get the source code at https://flashrom.org

   Using clock_gettime for delay loops (clk_id: 1, resolution: 1ns).
   Found Eon flash chip "EN25QH64" (8192 kB, SPI) on linux_spi.
   Reading flash... done.

   ```
   Repeat this 2 more times and create two more copies x230-bios-bottom2.bin and x230-bios-bottom3.bin

3) verify that all files are identical
   for the top 4MB bios chip:
   ```
   pi@raspberrypi:~ $ md5sum x230-bios-top?.bin
   54bfde566dffa17760a6115f27309681  x230-bios-top1.bin
   54bfde566dffa17760a6115f27309681  x230-bios-top2.bin
   54bfde566dffa17760a6115f27309681  x230-bios-top3.bin

   ```
   for the lower 8MB bios chip:
   ```
   pi@raspberrypi:~ $ md5sum x230-bios-bottom?.bin
   ac7dffb64f7d11ec9b13cc9449e48a64  x230-bios-bottom1.bin
   ac7dffb64f7d11ec9b13cc9449e48a64  x230-bios-bottom2.bin
   ac7dffb64f7d11ec9b13cc9449e48a64  x230-bios-bottom3.bin

   ```   

## on build machine: copy ROM files from raspberry pi

4) Copy the ROMs from raspberry pi to the "build machine"
   ```
   user@my-coreboot:~/coreboot/ROM$ scp pi@192.168.200.107:~/x230-bios-* .
   pi@192.168.200.107's password: 
   x230-bios-bottom1.bin                                                                        100% 8192KB  10.8MB/s   00:00    
   x230-bios-top1.bin                                                                           100% 4096KB  11.1MB/s   00:00    
   ```

5) Merge two files into one ROM file
   ```
   cat x230-bios-bottom1.bin x230-bios-top1.bin > x230-bios.rom
   ```

6) move all rom files to ~/coreboot/ROM
   ```
   mkdir ~/coreboot/ROM
   mv x230-* ~/coreboot/ROM
   ```


### Extract Blobs from extracted ROM
```
user@my-coreboot:~/coreboot/ROM$ cd ~/coreboot/ROM
user@my-coreboot:~/coreboot/ROM$ ifdtool -x x230-bios.rom
File x230-bios-bottom1.bin is 8388608 bytes
  Flash Region 0 (Flash Descriptor): 00000000 - 00000fff 
  Flash Region 1 (BIOS): 00500000 - 00bfffff 
Error while writing: Success
  Flash Region 2 (Intel ME): 00003000 - 004fffff 
  Flash Region 3 (GbE): 00001000 - 00002fff 
  Flash Region 4 (Platform Data): 00fff000 - 00000fff (unused)
```
you will now find the following files:
```
user@my-coreboot:~/coreboot/ROM$ ls -la
total 36872
drwxr-xr-x  2 user user     4096 Apr  6 00:48 .
drwxr-xr-x 10 user user     4096 Apr  6 00:43 ..
-rw-r--r--  1 user user     4096 Apr  6 00:48 flashregion_0_flashdescriptor.bin
-rw-r--r--  1 user user  7340032 Apr  6 00:48 flashregion_1_bios.bin
-rw-r--r--  1 user user  5230592 Apr  6 00:48 flashregion_2_intel_me.bin
-rw-r--r--  1 user user     8192 Apr  6 00:48 flashregion_3_gbe.bin
-rw-r--r--  1 user user 12582912 Apr  6 00:30 x230-bios.bin
-rw-r--r--  1 user user  8388608 Apr  5 23:38 x230-bios-bottom1.bin
-rw-r--r--  1 user user  4194304 Apr  5 23:38 x230-bios-top1.bin
```

## Extract VGA Blob
https://www.coreboot.org/VGA_support#UEFI_Method

```
cd ~/coreboot
sudo apt-get install qt5-default
#sudo apt-get install qt5-make
git clone http://github.com/LongSoft/UEFITool.git
cd UEFITool
qmake
make
```
Start UEFITool
```
./UEFITool
```
File > Open BIOS Image File
Open the ROM-file from the 4MB BIOS-Chip (x230-bios-top1.bin) or the merged ROM (x230-bios.bin)

will generate the following messages:
"parseVolume: unknown file system FFF12B8D-7696-4C8B-A985-2747075B4F50
parseBios: volume size stored in header 61000h (397312) differs from calculated using block map 40000h (262144)
parseVolume: unknown file system 00504624-8A59-4EEB-BD0F-6B36E96128E0
parseBios: volume size stored in header 2F000h (192512) differs from calculated using block map 30000h (196608)
parseFile: invalid data checksum"


- Hit CTRL+F (Search...), 3rd Tab (Text)
- Search for: VGA Compatible BIOS
  (Uncheck Unicode)
- Will show the following message in the lower part of the window:
  ASCII text "VGA Compatible BIOS" found in Raw section at offset 22h
- Double click on the line in the message windows which bring you to the raw section
- Right Click on "Raw section" and choose "Extract Body"
- Save file as ~/coreboot/ROM/vga.rom

## Copy the blobs to coreboot dir

Create the "blob-directory" where coreboot looks for BLOBs:
```
mkdir -p ~/coreboot/3rdparty/blobs/mainboard/lenovo/x230
```
In order to have the blobs available for coreboot the easiest way is to rename and copy them to the default locations:
```
cp ~/coreboot/ROM/flashregion_0_flashdescriptor.bin ~/coreboot/3rdparty/blobs/mainboard/lenovo/x230/descriptor.bin
cp ~/coreboot/ROM/flashregion_2_intel_me.bin        ~/coreboot/3rdparty/blobs/mainboard/lenovo/x230/me.bin
cp ~/coreboot/ROM/flashregion_3_gbe.bin             ~/coreboot/3rdparty/blobs/mainboard/lenovo/x230/gbe.bin
cp ~/coreboot/ROM/vga.rom                           ~/coreboot/3rdparty/blobs/mainboard/lenovo/x230/pci8086,0166.rom
```

## Configure and build Coreboot

1) Launch Configuration menu
   ```
   cd ~/coreboot/
   make nconfig
   ```

   Enter to open Submenu, Escape to switch back.
   F6 saves config to /home/user/coreboot/.config
   F9 quits config menu
   
   ###FIXME: needs more information about which options to choose and how to import the Blobs
   As a workarround, look at the config-file from my succesfull X230 Coreboot installation.
   This file has to be places in ~/coreboot/.config

```
8< ---
# Configuration
cd coreboot
make menuconfig

general  --|
           |-[*] Compress ramstage with LZMA
           |-[*] Include the coreboot .config file into the ROM image
mainboard -|
           |-Mainboard vendor (Lenovo)
           |-Mainboard model (ThinkPad X230)
           |-ROM chip size (12288 KB (12 MB))
           |-(0x100000) Size of CBFS filesystem in ROM
devices ---|
           |-[*] Use native graphics initialization
generic ---|
           |-[*] PS/2 keyboard init
console ---|
           |-[*] Squelch AP CPUs from early console.
           |-[*] Send console output to a CBMEM buffer
           |-[*] Send POST codes to an external device
           |-[*] Send POST codes to an IO port
sys table -|
           |-[*] Generate SMBIOS tables
payload ---|
           |-Add a payload (SeaBIOS)
           |-SeaBIOS version (master)
           |-(10) PS/2 keyboard controller initialization timeout (milliseconds)
           |-[*] Hardware init during option ROM execution
           |-[*] Include generated option rom that implements legacy VGA BIOS compatibility
           |-[*] Use LZMA compression for payloads
--- 8<
```

2) build build-chain using 7 from total 8 cores on my W540 (adapt this to your possibilities)
   and finally build coreboot
   ```
   echo CPU Cores = $(nproc)
   make crossgcc-i386 CPUS=7
   make iasl
   #make -j2
   make
   ```

The coreboot file should be located at ~/coreboot/build/coreboot.rom


## Split coreboot ROM
after building coreboot you need to the 12mb file into a 4mb and 8mb file, which we can reflash to two Bios chips.

```
mkdir ~/coreboot/ROM-ready
# Split first 8MB of coreboot.rom (bottom-chip)
dd if=~/coreboot/build/coreboot.rom of=~/coreboot/ROM-ready/x230-coreboot-8mb.rom bs=1024 count=$[1024*8] skip=0

# Split last 4MB of coreboot.rom (top-chip)
dd if=~/coreboot/build/coreboot.rom of=~/coreboot/ROM-ready/x230-coreboot-4mb.rom bs=1024 count=$[1024*4] skip=$[1024*8]

```

## Copy ROM to raspberry pi and flash 
Transfer the two new ROM files over to the raspberry pi
```
scp x230-coreboot-* pi@192.168.200.107:~/
```
I have moved the coreboot-ROM files to a new directory ~/ROM-ready on the raspberry pi


Logon to the pi and flash both chips:
```
# write top chip (4MB)
pi@raspberrypi:~/ROM-ready $ sudo flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=1000 -c "MX25L3206E/MX25L3208E" -w x230-coreboot-4mb.rom 
flashrom p1.0-69-g3f7e341 on Linux 4.14.30-v7+ (armv7l)
flashrom is free software, get the source code at https://flashrom.org

Using clock_gettime for delay loops (clk_id: 1, resolution: 1ns).
Found Macronix flash chip "MX25L3205D/MX25L3208D" (4096 kB, SPI) on linux_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.

# write bottom chip (8MB)
pi@raspberrypi:~/ROM-ready $ sudo flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=1000 -c "MX25L6406E/MX25L6408E" -w x230-coreboot-8mb.rom 
flashrom p1.0-69-g3f7e341 on Linux 4.14.30-v7+ (armv7l)
flashrom is free software, get the source code at https://flashrom.org

Using clock_gettime for delay loops (clk_id: 1, resolution: 1ns).
Found Eon flash chip "EN25QH64" (8192 kB, SPI) on linux_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.

```
## Test drive
now it is time to cross fingers and try if you was able to flash coreboot.
Remove the Pomodo-Clip, put your keyboard back, put your battery in and power on.
In case you run into any problems, you can always reflash your stock rom.

If you have comments or need help, feel free to contact me:
https://github.com/one7two99
- ...
