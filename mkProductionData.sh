#!/bin/bash

if [[ "$1" == "" || "$1" == "--help" ]]; then
	cat <<HELPTEXT
Usage: $0 <output file> [<input file>]
If no input file is given, stdin is used.
If output file is "-" the generated script will be printed to stdout.

Format of input file:
Lines starting with "sysval_" are:
* appended to hw_overlays with <option>_<value>
* parsed into environment variables sysval_<variable name> and assigned <value>
* passed to the device tree as /mec/sysval/<variable_name> and assigned <value>
Line with hw_overlays is parsed and appended to the generated hw_overlays.
The list of overlays is passed to the device tree in /mec/hw_overlays
Every other line is passed into the script

Example:
sysval_case_material="plastic"
sysval_case_form="etouch"
sysval_layout_version="1.3"
hw_overlays=overlay1 overlay2 overlay3
run load_eeprom_overlay_name load_overlay
HELPTEXT
	exit 0
fi

genTempScript() {
	local inputFile="$1"
	local hw_overlays="default"

	while read line; do
		local varname=$(echo $line | cut -d'=' -f1)
		local value=$(echo $line | cut -d'=' -f2-)
		
		if [[ $(echo "$varname" | cut -d'_' -f1) == "sysval" ]]; then
			echo "setenv $varname \"$value\""
			echo "fdt set /mec/sysval $varname \"$value\""
		elif [[ $(echo "$varname" | cut -d'_' -f1) == "hw" ]]; then
			echo "setenv $varname \"$value\""
			echo "fdt set /mec/sysval $varname \"$value\""
			hw_overlays="$hw_overlays $(echo $varname | sed -e 's/hw_//g')_${value}"
		elif [[ "$varname" == "hw_overlays" ]]; then
			hw_overlays="$hw_overlays $value"
		else
			echo "$line"
		fi
	done < "$inputFile"

	if [[ ! -z "$hw_overlays" ]]; then
		echo "setenv hw_overlays ${hw_overlays}"
	fi
}

tempScript=$(mktemp)

genTempScript "${2:-/dev/stdin}" > "$tempScript"

#if output is stdout
if [ "$1" == "-" ]; then
	cat $tempScript
else
	mkimage -T script -C none -A arm -d $tempScript "$1"
	echo "load to emmc with: dd if=$1 of=/dev/mmcblkXbootY bs=32k seek=31"
fi
rm $tempScript
