boot.cmd-Magie:

Das neue boot.cmd sollte im allgemeinen so funktionieren wie das alte.
Falls jedoch die uEnv.txt oder die overlay.prefix Datei in /boot (bzw. auf der ersten Partition!) vorhanden ist, dann:
* overlay.prefix: Falls diese Datei vorhanden ist (drinnen muss "overlay=AAAA\n\0" stehen!), dann wird
  - 4 bytes aus dem EEPROM ausgelesen und ersetzen das "AAAA" => overlay=d350
  - Geschaut ob es ein dtbo oder ein scr mit diesem Namen gibt (also ${overlay}.dtbo, z.B. AAAA.dtbo) und wenn ja, diese geladen
* uEnv.txt: Die Datei kann alle Environment-Variablen aendern. Format: variable=wert Beispiele:
  - initRdName/initRdAddr: eine initrd verwenden
  - bootCmd: z.B. bootCmd=echo um den Bootvorgang zu unterbrechen, bootz, bootefi, ...
  - kernelName/dtName: Dateinamen von Kernel und Device Tree (z.B. kernelName=fancyKernel => laedt fancyKernel statt uImage)
  - sourceDevType/sourceDevArg: von einem anderen Geraet booten (z.B. sourceDevType=usb sourceDevArg=0:1 => usb0, erste Partition)
  - addBootArgs: Boot argumente hinzufuegen (z.B. addBootArgs=init=/bin/sh)
  - bootargs: Gesamte Kernel cmdline aendern (z.B. bootargs=root=/dev/sda1 rw console=ttyS0,9600)
  - overlayList: Zusaetzliche dtbo oder scr laden (z.B. overlayList=bla blubb => laedt bla.dtbo/bla.scr und blubb.dtbo/blubb.scr)
* dtbo/scr overlays werden nur geladen wenn sie existieren. Gilt sowohl fuer overlay.prefix als auch overlayList
  - d.h. wenn z.B. overlayList=bla blubb, kann z.B. nur bla.dtbo und blubb.scr vorhanden sein


TODO:
* overlay.config hinzufuegen:
  - overlayNameEepromPos variable in der overlay.config setzen, damit man sie leicht veraendern kann.
  - EEPROM bus-nummer, i2c addresse und die laenge des overlayName-Strings in variablen auslagern
