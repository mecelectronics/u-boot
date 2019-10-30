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