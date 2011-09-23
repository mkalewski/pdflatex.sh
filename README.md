pdflatex.sh
===========

NAME
----
`pdflatex.sh` -- compile (La)TeX files and more.

SYNOPSIS
--------
    pdflatex.sh  -h | -V
    pdflatex.sh  [ +3 +b +i +o +p ]  FILE(.tex)
    pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
    pdflatex.sh  -gs | -rs | -gd | -rd  DIR
    pdflatex.sh  -b | -c | -i | -k | -kk | -l [WIDTH] | -n | -s | -ss
                 | -sc [LANG]  FILE(.tex)

DESCRIPTION
-----------
Bash script to compile (La)TeX files (with BibTeX, indices and PSTricks if
necessary), convert images to include them in (La)TeX files and to manipulate
output PDF documents.  The script also lets you check syntactic and semantic
correctness of (La)TeX source files, e.g. with the use of *ChkTeX*.

It is possible to customize programs (like PDF viewer) and its settings that
are used by the script in **Programs** and **Options** sections in the source
code.

NOTE:  If the script is run as `pdflatex.sh` then `pdflatex` command is used
(producing PDF output file), otherwise `latex` command is used (producing DVI
output file).  Thus if necessary, the `latex.sh` symbolic link can be created
to use the script easily.

OPTIONS
-------
    -2x1 FILE            put two pages of the PDF FILE on a single A4 sheet
                         (the output will be in FILE-nup.pdf file)
    -2x2 FILE            put four pages of the PDF FILE on a single A4 sheet
                         (the output will be in FILE-nup.pdf file)
    +3                   run latex/pdflatex thrice (default is twice)
    +b                   make also bibtex
    -b   FILE            make ONLY bibtex
    -c   FILE            cleanup (remove auxiliary files)
    -gs  DIR             convert SVG images in directory DIR
    -rs  DIR             convert SVG images in directory DIR recursively
    -gd  DIR             convert DIA images in directory DIR
    -rd  DIR             convert DIA images in directory DIR recursively
    -h                   print (this) help message and exit
    +i                   make also index
    -i   FILE            make ONLY index
    -k   FILE            run 'chktex' command (if available)
    -kk  FILE            the same as '-k' but only errors are shown
    -l   [WIDTH] FILE    check maximum line width (by default WIDTH=80)
    -n   FILE            check non-breaking spaces
    -s   FILE            check sentence separators
    -ss  FILE            STRICTLY check sentence separators
    -sc  [LANG] FILE     run interactive spell checker (by default LANG="en_GB"
                         and UTF-8 encoding is used)
    +o                   open PDF (or DVI) file after compilation
    +p                   use 'ps4pdf' instead of 'pdflatex'/'latex' (PSTricks)
    -V                   print script version

EXAMPLES
--------
    pdflatex.sh file.tex

> Compile `file.tex` source file.

    pdflatex.sh +b +i +o file.tex

> Compile `file.tex` with BibTeX and MakeIndex, and open PDF browser with the
> output file after compilation.

    pdflatex.sh +p file.tex

> Compile `file.tex` with the use of PSTricks.

    pdflatex.sh -kk file.tex

> Run `chktex` command but show only errors.

    pdflatex.sh -gs img/

> Convert all SVG images in the directory `img/` (PDF and PS version will be
> produced).

    pdflatex.sh -2x1 file.pdf

> Put two pages of the `file.pdf` on a single A4 sheet (the output should be in
> `FILE-nup.pdf` file).

AUTHOR
------
Written by Michal Kalewski.

REPORTING BUGS
--------------
Bug reports: [https://github.com/mkalewski/pdflatex.sh/issues](https://github.com/mkalewski/pdflatex.sh/issues)

The official code repository: [https://github.com/mkalewski/pdflatex.sh](https://github.com/mkalewski/pdflatex.sh)

COPYRIGHT
---------
    (c) 2007-2011 Michal Kalewski  <mkalewski at cs.put.poznan.pl>

    This program comes with ABSOLUTELY NO WARRANTY.
    THIS IS FREE SOFTWARE, AND YOU ARE WELCOME TO REDISTRIBUTE IT UNDER THE
    TERMS AND CONDITIONS OF THE MIT LICENSE.  YOU SHOULD HAVE RECEIVED A COPY
    OF THE LICENSE ALONG WITH THIS SOFTWARE; IF NOT, YOU CAN DOWNLOAD A COPY
    FROM HTTP://WWW.OPENSOURCE.ORG.
