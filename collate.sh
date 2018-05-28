#!/bin/bash

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
	else
		gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOUTPUTFILE="${tempdir}/OutTemp.pdf" "$outputFile" "$1" > /dev/null
		mv "${tempdir}/OutTemp.pdf" "$outputFile"
	fi
}

exportIndex ()
{
	configfilename="$1"

	rundir="$(pwd)" #The directory that it was written 
	indexdir="$(dirname "$(realpath "$1")")" #The directory that the index file is in
	indexfile="$(realpath "$configfilename")" #The absolute path to the index file
	tempdir="$(mktemp -d)" #The temporary directory

	outputFile="$(realpath "$2")" #The file to output the PDF to.

	rm "$outputFile"
	cd "$indexdir"
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
	done < "${indexfile}"

	rm -r "${tempdir}"
}

printIndex ()
{
	i=1
	
	while read line
	do
		printf "%d: %s\n" $i "$line"
		let i++
	done < "$1"
}

printHelp ()
{
	echo "USAGE:"
	echo ""
	echo "collate init <index>"
	echo "  creates an index file at the given location. The file name must also be provided."
	echo ""
	echo "collate add <index> <filepath>"
	echo "  add the file at <filepath> to the <index> file."
	echo ""
	echo "collate add <index> <filepath> <num>"
	echo "  add the file at <filepath> to the <index> file. It is placed at line number <num>."
	echo ""
	echo "collate view <index>"
	echo "  display a list of all of the files in the index"
	echo ""
	echo "collate clear <index>"
	echo "  clears the <index> of all file paths"
	echo ""
	echo "collate exec <index>"
	echo "  runs the index file at <index>. Output file is the default, Output.pdf in the working directory"
	echo ""
	echo "collate exec <index> <output>"
	echo "  runs the index file at <index>. Output file is <output>."
}

if [ $# -eq 0 ]; then
    echo "Please enter a valid commmand"
	echo ""
	printHelp
	exit 0
elif [[ $1 = "init" ]] && [[ $# -eq 2 ]]; then
    if [[ -e "$2" ]]; then
	    printf "Error: A file already exists at %s\n" "$2"
	else
	    touch "$2"
	    printf "Repository created at %s\n" "$2"
	fi
elif [[ $1 = "view" ]] && [[ $# -eq 2 ]]; then
    printIndex "$2"
elif [[ $1 = "add" ]] && { [[ $# -eq 3 ]] || [[ $# -eq 4 ]]; }; then
    indexdir="$(dirname "$(realpath "$2")")" #The directory that the index file is in
	abspath="$(realpath "$3")"
    filename="$(realpath --relative-to="${indexdir}" "${abspath}")"
    if [[ $# -eq 3 ]]; then
	    echo "${filename}" >> "$2"
	else
	    printf "%di%s %s" $4 "${filename}" "$2"
	    sed -i --expression=""${4}i"${filename}""" "$2" 
	fi
elif [[ $1 = "clear" ]] && [[ $# -eq 2 ]]; then
    echo "Clear not yet implemented"
	exit 1
elif [[ $1 = "exec" ]] && { [[ $# -eq 2 ]] || [[ $# -eq 3 ]]; }; then
    if [[ $# -eq 3 ]]; then
	    exportIndex "$2" "$3"
	else
	    exportIndex "$2" "Output.pdf"
	fi
	exit 0
elif [[ $1 = "help" ]]; then
    printHelp
else
    echo "Please enter a valid commmand"
	echo ""
	printHelp
	exit 0 
fi