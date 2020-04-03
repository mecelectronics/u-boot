boot.cmd-Magie:

Das neue boot.cmd sollte im Allgemeinen so funktionieren wie das alte.
Was anders ist:
* mecetouchv3.dtb nur mehr über uEnv.txt einstellbar (nicht mehr load ... devicetree.dtb || load ... mecetouchv3.dtb)
* boot.scr nimmt als root-Device automatisch die SD/eMMC von der u-boot gestartet wurde.

Falls jedoch die uEnv.txt oder die overlay.prefix Datei in /boot (bzw. auf der ersten Partition!) vorhanden ist, dann:
* overlay.prefix: Falls diese Datei vorhanden ist (drinnen muss "overlay=AAAA\n\0" stehen!), dann wird:
  - 4 bytes aus dem EEPROM ausgelesen und ersetzen das "AAAA" => z.B. overlay=d350
  - Geschaut ob es ein dtbo oder ein scr mit diesem Namen gibt (also ${overlay}.dtbo, z.B. AAAA.dtbo) und wenn ja, diese geladen
  - Falls in uEnv.txt die overlay Variable gesetzt ist, wird das Auslesen aus dem EEPROM übersprungen.
* uEnv.txt: Die Datei kann alle Environment-Variablen ändern. Format: variable=wert Beispiele:
  - initRdName/initRdAddr: eine initrd verwenden
  - bootCmd: z.B. bootCmd=echo um den Bootvorgang zu unterbrechen, bootz, bootefi, ...
  - kernelName/dtName: Dateinamen von Kernel und Device Tree (z.B. kernelName=fancyKernel => lädt fancyKernel statt uImage)
  - sourceDevType/sourceDevArg: von einem anderen Gerät booten (z.B. sourceDevType=usb sourceDevArg=0:1 => usb0, erste Partition)
  - addBootArgs: Boot Argumente hinzufügen (z.B. addBootArgs=init=/bin/sh)
  - bootargs: Gesamte Kernel cmdline ändern (z.B. bootargs=root=/dev/sda1 rw console=ttyS0,9600)
  - overlayList: Zusätzliche dtbo oder scr laden (z.B. overlayList=bla blubb => lädt bla.dtbo/bla.scr und blubb.dtbo/blubb.scr)
  - recoveryCmd: Zusätzliches Boot Argument, dass hinzugefügt wird, während der schalter gehalten wird.
* dtbo/scr overlays werden nur geladen wenn sie existieren. Gilt sowohl für overlay.prefix als auch overlayList
  - d.h. wenn z.B. overlayList=bla blubb, kann z.B. nur bla.dtbo und blubb.scr vorhanden sein

Beispiel uEnv.txt um von USB zu booten:
```
sourceDevType=usb
sourceDevArg=0:1
bootargs=console=ttyS0,115200 root=/dev/sda3 rootwait panic=10 sysfs.deprecated=0 ro
dtName=mecetouchv3.dtb
```

Beispiel uEnv.txt um Overlay Namen aus EEPROM zu konfigurieren:
(3 Zeichen von Offset 0x24 am EEPROM)
```
hwoNameEepromPos=0x24
hwoNameEepromBusNr=0x1
hwoNameEepromI2cAddr=0x50
hwoNameEepromLength=0x4
```

TODO:
* boot unterbrechen explodiert

# Production Data

## Aktuell
proddata.txt:
```
sysval_xyz=abc
sysval_axpoffset=2.9
hw_overlay=mt40 hdc100x
```

boot.itb:
```
mt40.scr
mt40.dtbo
hdc100x.dtbo
```

Kompiliertes boot0/1 script:
```
setenv sysval_xyz=abc
fdt set /mec/sysval xyz "abc"
...
setenv hw_overlays=mt40 hdc100x
```

Im u-boot:
`environment: sysval_xyz=abc, sysval_axpoffset=2.9, hw_overlays="mt40 hdc100x"`
"logik" (pseudo code):
```
for i in hw_overlays; do
  load $i.scr from boot.itb
  load $i.dtbo from boot.itb
  load $i.scr from p1/overlays/$i.scr
  load $i.dtbo from p1/overlays/$i.dtbo
```

Im Linux: In /proc/device-tree/mec/sysval alle Variablen die mit sysval_ anfangen. In /proc/mec/device-tree/mec/hw_overlays alle Overlays die erfolgreich geladen wurden.
```
Datei: /proc/device-tree/mec/sysval/xyz, Inhalt "abc"
Datei: /proc/device-tree/mec/sysval/axpoffset, Inhalt "2.9"
Datei: /proc/device-tree/mec/overlays/mt40.scr, Leer
Datei: /proc/device-tree/mec/overlays/mt40.dtbo, Leer
Datei: /proc/device-tree/mec/overlays/hdc100x.dtbo, Leer
```

## Zukunft (vorschlag)
proddata.txt:
```
sysval_pcb=14
sysval_display=mt40
sysval_sensor_1=hdc100x
sysval_wlan=wl200
sysval_onboard_rgb_led=y
sysval_case_material=abs
sysval_battery_charging=n
```

boot.itb:
```
sensor_1_hdc100x.dtbo
display_mt40.scr
display_mt40.dtbo
wlan_wl200.dtbo
```

kompilierung:
```
hw_overlays="default"
for sysval_$option=$value in proddata.txt:
    hw_overlays="${option}_${value} $hw_overlays"
    echo "setenv sysval_$option "$value""
    echo "fdt set ..."
```

Kompiliertes boot0/1 script:
```
hw_overlays="pcb_14 display_mt40 sensor_1_hdc100x wlan_wl200 onboard_rgb_led_y case_material_abc battery_charging_n"
setenv sysval_pcb 14
fdt set /mec/sysval pcb 14
setenv sysval_sensor_1 hdc100x
fdt set /mec/sysval sensor_1 hdc100x
...
```
U-Boot Logik und Layout in Linux wie oben


