# Introduction
This is meant to be a bash script for the collating of documents into one large PDF. This is useful for large projects, where the output will consist of multiple documents.

This is intended only for bash on linux. Any other platforms are unsupported.

<span style="color:red">**WARNING:**</span> this is a pre-alpha program. While it should not do damage to documents, I would seriously recommend backing up the documents before performing the operation. In addition to this, check the output to check that it is correct.

# Usage

Please make sure that the following software packages are installed:
* Libreoffice (for exporting office files)
* Ghostscript (for the appending of PDF files)

Then in the root directory of the project, we need to create our index file. This contains an in order list of file paths to documents, in the order that they should be collated. The best way to do this is using the following command to create the file:

```touch index.txt```

Then to add a file onto the file use the following terminal:

```echo "##" >> index.txt```

Inside the quotation marks, instead of the ## you should put the file path that you would like to add to the index. Luckily, most terminals support file path completion in this, speeding up the entry process and reducing possible data entry errors.

To run the script, with the folder that the index is stored in as your working directory (make sure you are ```cd```'ed into the folder with the index) run the following command

```bash collate.sh index.txt```

where collate.sh is the path to the bash script, and index.txt is the path to your index file.

## Supported files

* .odt files
* .ods files
* .pdf files