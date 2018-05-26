#!/bin/bash

configfilename="$1"

tempdir="$(mktemp -d)"

# return the name of the file entered, without directory or file extension

getFileName ()
{
	filename="$(basename "$1")"
	touch running.txt
	printf "(%s) to (%s)" "$filename" "${filename%.*}" >> test.txt
	echo "${filename%.*}"
}

# return the file extension of the file entered

getFileExt ()
{
	filename="$(basename "$1")"
	echo "${filename##*.}"
}

# Export a libreoffice file

exportLibreoffice () 
{
	soffice --headless --convert-to pdf --outdir "${tempdir}" "$1" &> /dev/null
	filename="$(getFileName "$1")"
	appendFile "${tempdir}"/"${filename}".pdf
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
	filename="$(basename -- "$line")"
	fileextension="$(getFileExt "${line}")"
	if [[ "$fileextension" = "odt" ]] || [[ "$fileextension" = "ods" ]]; then
		printf "Adding %s (libreoffice export) ... " "$line"
		exportLibreoffice "$line"
		printf "done\n"
	elif [[ "$fileextension" = "pdf" ]]; then
		printf "Adding %s (pdf append) ... " "$line"
		appendFile "$line"
		printf "done\n"
	else
		printf "Error: Don't know how to process .%s files, cannot export %s\n" "$fileextension" "$filename"
	fi
done < "$configfilename"

rm -r "${tempdir}"