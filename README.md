# Introduction
This is meant to be a bash script for the collating of documents into one large PDF. This is useful for large projects, where the output will consist of multiple documents.

This is intended only for bash on linux. Any other platforms are unsupported.

<span style="color:red">**WARNING:**</span> this is an alpha program. While it should not do damage to documents, I would seriously recommend backing up the documents before performing the operation. In addition to this, check the output to check that it is correct.

# Usage

To create an index file, you should run `collate init <index>`. This creates an index file at file path `<index>`, which is blank.

To add a file to the index, run `collate add <index> <file>`, which adds the file at filepath `<file>` to the index at `index`. To add a file in-between other files, you can put a line number at the end of this command, so the command will look like `collate add <index> <file> <num>` where num is the line number where you would like to place the file.

To view all files at the index, you should run the command `collate view <index>`, where `<index>` is the index that you would like to view the documents of.

To clear an index, you should run `collate clear <index>`.

To export an index file and get the resulting pdf, `collate exec <index>` should be run. By default, the output file will be a file called Output.pdf, though if you want, an output file can be chosen using `collate exec <index> <outpath>`.

## Supported files

* .odt files
* .ods files
* .pdf files