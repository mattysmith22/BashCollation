#!/bin/bash

configfilename="$1"

rundir="$(pwd)" #The directory that it was written 
indexdir="$(dirname "$(realpath "$1")")" #The directory that the index file is in
tempdir="$(mktemp -d)" #The temporary directory

outputFile="$(pwd)/Output.pdf" #The file to output the PDF to.

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
	if [ ! -e "$outputFile" ]; then
		mv "$1" "$outputFile" 
		echo "first file"
	else
		gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOUTPUTFILE="${tempdir}/OutTemp.pdf" "$outputFile" "$1" > /dev/null
		mv "${tempdir}/OutTemp.pdf" "$outputFile"
	fi
}

rm "$outputFile"
cd "$indexdir"
pwd
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
done < "$(realpath "$configfilename")"

rm -r "${tempdir}"