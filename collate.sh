#!/bin/bash

configfilename="$1"

exportLibreoffice () 
{
	soffice --headless --convert-to pdf --outdir temp "$1" &> /dev/null
	mv "temp/$(ls temp)" toAppend.pdf	
}

appendFile ()
{
	if [ ! -e "Output.pdf" ]; then
		mv "$1" Output.pdf
	else
		gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOUTPUTFILE=OutputTemp.pdf Output.pdf "$1" > /dev/null
		mv OutputTemp.pdf Output.pdf
	fi
}

rm Output.pdf

while read line
do
	filename=$(basename -- "$line")
	fileextension="${filename##*.}"
	if [[ "$fileextension" = "odt" ]] || [[ "$fileextension" = "ods" ]]; then
		printf "Adding %s (libreoffice export) ... " "$line"
		exportLibreoffice "$line"
		appendFile toAppend.pdf
		printf "done\n"
	elif [[ "$fileextension" = "pdf" ]]; then
		printf "Adding %s (pdf append) ... " "$line"
		appendFile "$line"
		printf "done\n"
	else
		printf "Error: Don't know how to process .%s files, cannot export %s\n" "$fileextension" "$filename"
	fi
done < "$configfilename"

rm -r temp
