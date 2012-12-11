#!/bin/bash
# UTF-8

#  (c) 2007-2012 Michal Kalewski  <mkalewski at cs.put.poznan.pl>
#
#  This program comes with ABSOLUTELY NO WARRANTY.
#  THIS IS FREE SOFTWARE, AND YOU ARE WELCOME TO REDISTRIBUTE IT UNDER THE
#  TERMS AND CONDITIONS OF THE MIT LICENSE.  YOU SHOULD HAVE RECEIVED A COPY OF
#  THE LICENSE ALONG WITH THIS SOFTWARE; IF NOT, YOU CAN DOWNLOAD A COPY FROM
#  HTTP://WWW.OPENSOURCE.ORG.
#
#  NAME
#    pdflatex.sh
#
#  SYNOPSIS
#    pdflatex.sh  -h | -V
#    pdflatex.sh  [ +3 +b +h +i +o +p +s +sync ]  FILE(.tex)
#    pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
#    pdflatex.sh  -gs | -rs | -gd | -rd  DIR
#    pdflatex.sh  -b | -c | -i | -k | -kk | -l [WIDTH] | -n | -s | -ss
#                 | -sc [LANG]  FILE(.tex)
#
#  DESCRIPTION
#    A bash script to simplify TeX/LaTeX files compilation and more.  Just run
#    the script to get more information: './pdflatex.sh'.
#
#  REPORTING BUGS
#    <https://github.com/mkalewski/pdflatex.sh/issues>
#
#  THE OFFICIAL CODE REPOSITORY
#    <https://github.com/mkalewski/pdflatex.sh>
#
#  (Below, you can customize your settings.)

# VERSION
# =======
VERSION=3.1.3


# PROGRAMS
# ========
ASPELL_PROGRAM="aspell"
BIBTEX_PROGRAM="bibtex"
CHKTEX_PROGRAM="chktex"
DETEX_PROGRAM="detex"
DIA_PROGRAM="dia"
#EPSTOPDF_PROGRAM="epstopdf"  # obsolete
INKSCAPE_PROGRAM="inkscape"
LATEX_PROGRAM="latex"
MAKEINDEX_PROGRAM="makeindex"
PDF_VIEWER_PROGRAM="evince"
PDFLATEX_PROGRAM="pdflatex"
PDFNUP_PROGRAM="pdfnup"
PS4PDF_PROGRAM="ps4pdf"


# OPTIONS
# =======
ASPELL_ENC_OPT="--encoding=utf-8"
ASPELL_LANG_OPT="-l en_GB"
CHKTEX_OPT="-q -v1"
LATEX_BATCHMODE_OPT="-interaction batchmode"
#LATEX_OUTPUT_DIRECTORY_OPT="-output-directory"
PDFLATEX_SYNCTEX_OPT="-synctex=1"
PDFNUP_OPT="--paper a4paper --frame true --scale 0.96 --delta \"2mm 2mm\""
PS4PDF_LATEX_OPT="\AtBeginDocument{\RequirePackage{pst-pdf}}"


# FILE TO BUILD
# =============
FILENAME=
OUTPUT_DIRECTORY=


# SETUP
# =====

# Extensions of auxiliary files:
AUXILIARYEXTS=\
"aux idx ilg ind out toc lot lof loa nav snm vrb bbl blg svn"
  #  + " log dvi synctex.gz"
AUXILIARYEXTS_BIBTEX=\
"aux idx ilg ind out toc lot lof loa nav snm vrb blg svn dvi pdf synctex.gz"
  #  + " log bbl"
AUXILIARYEXTS_INDEX=\
"aux ilg ind out toc lot lof loa nav snm vrb bbl blg svn dvi log pdf synctex.gz"
  #  + " idx"

# Base name of the script:
THENAME="$(basename $0)"
THEREALNAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

# Text color variables:
txtund=$(tput sgr 0 1)  # underline
txtbld=$(tput bold)     # bold
txtred=$(tput setaf 1)  # red
txtgrn=$(tput setaf 2)  # green
txtylw=$(tput setaf 3)  # yellow
txtblu=$(tput setaf 4)  # blue
txtpur=$(tput setaf 5)  # purple
txtcyn=$(tput setaf 6)  # cyan
txtwht=$(tput setaf 7)  # white
txtrst=$(tput sgr0)     # text reset


# FUNCTIONS
# =========

# Prints help and additional information
function print_help() {
cat <<EOF

${txtbld}PDFLATEX.SH${txtrst} $VERSION (c) 2007-2012\
 ${txtbld}Michal Kalewski${txtrst} <mkalewski at cs.put.poznan.pl>

        ${txtund}A BASH SCRIPT TO SIMPLIFY TeX/LaTeX FILES COMPILATION AND\
 MORE${txtrst}

NOTE:  If the script is run as 'pdflatex.sh' then 'pdflatex' command is used
(producing PDF output file), otherwise 'latex' command is used (producing DVI
output file).  Thus if necessary, the 'latex.sh' symbolic link can be created
to use the script easily.

${txtbld}For more information, please visit${txtrst}:  \
<https://github.com/mkalewski/pdflatex.sh>

${txtbld}Usage${txtrst}:
  pdflatex.sh  -h | -V
    Print help or version.

  pdflatex.sh  [ +3 +b +h +i +o +p +s +sync ]  FILE(.tex)
    Compile (La)TeX files.

  pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
    PDF documents manipulation.

  pdflatex.sh  -gs | -rs | -gd | -rd  DIR
    Convert images.

  pdflatex.sh  -b | -c | -i | -k | -kk | -l [WIDTH] | -n | -s | -ss
                 | -sc [LANG]  FILE(.tex)
    Miscellaneous operations.

${txtbld}Options${txtrst}:
  -2x1 FILE            put two pages of the PDF FILE on a single A4 sheet
                       (the output will be in FILE-nup.pdf file)
  -2x2 FILE            put four pages of the PDF FILE on a single A4 sheet
                       (the output will be in FILE-nup.pdf file)
  +3                   run 'latex'/'pdflatex' thrice (default is twice)
  -b   FILE            make ONLY BibTeX
  +b                   make ALSO BibTeX
  -c   FILE            cleanup (remove auxiliary files)
  -gs  DIR             convert SVG images in directory DIR
  -rs  DIR             convert SVG images in directory DIR recursively
  -gd  DIR             convert DIA images in directory DIR
  -rd  DIR             convert DIA images in directory DIR recursively
  -h                   print (this) help message and exit
  +h                   make handout from beamer presentation, i.e. without
                       overlays, pauses, and other Beamer effects (the output
                       will be in FILE-handout.pdf file)
  -i   FILE            make ONLY index (MakeIndex)
  +i                   make ALSO index (MakeIndex)
  -k   FILE            run 'chktex' command (if available)
  -kk  FILE            the same as '-k' but only errors are shown
  -l   [WIDTH] FILE    check maximum line width (by default WIDTH=80)
  -n   FILE            check non-breaking spaces
  -s   FILE            check sentence separators
  +s                   print a summary of problems (errors and warnings) after
                       compilation
  -ss  FILE            STRICTLY check sentence separators
  -sc  [LANG] FILE     run interactive spell checker (by default LANG="en_GB"
                       and UTF-8 encoding is used)
  +sync                enable synchronization between source file and the
                       resulting DVI or PDF file
  +o                   open PDF (or DVI) file after compilation
  +p                   use 'ps4pdf' instead of 'pdflatex'/'latex' (PSTricks)
  -V                   print script version

${txtbld}Examples${txtrst}:
  pdflatex.sh file.tex
  pdflatex.sh +b +i +o file.tex
  pdflatex.sh +p file.tex
  pdflatex.sh +h beamer-presentation.tex
  pdflatex.sh -kk file.tex
  pdflatex.sh -gs img/
  pdflatex.sh -2x1 file.pdf

Bug reports:                  <https://github.com/mkalewski/pdflatex.sh/issues>
The official code repository: <https://github.com/mkalewski/pdflatex.sh>

EOF
}

if [[ $# -lt 1 ]] ; then print_help ; exit 0 ; fi

# Quits the script
function mquit() {
  [[ -z $1 ]] && EXIT_STATUS_CODE=0 || EXIT_STATUS_CODE=$1
  # consider the 'source' command:
  if [[ -n $OLDPWD ]] ; then cd - >&- 2>&- ; fi ; echo ; exit $EXIT_STATUS_CODE
}

# Exits the script with status code 1
function die() {
  if [[ -n $1 ]] ; then
    echo "$1  Exiting..."
  else
    echo "${txtred}Unknown error${txtrst}.  Exiting..."
  fi
  mquit 1
}

# Checks programs in the system
function check_programs() {
  for PROGRAMNAME in $1 ; do
    local FILEPATH=`eval which $PROGRAMNAME 2>&-`
    if [[ ! -x $FILEPATH ]] ; then
      die "Program \"${txtylw}$PROGRAMNAME${txtrst}\" missing."
    fi
  done
}

# Removes auxiliary files
function cleanup() {
  if [[ -z $1 ]] ; then
    die "${txtylw}Too few arguments.${txtrst}"
  fi
  echo -ne "CLEANUP..."
  for EXTENSION in $AUXILIARYEXTS ; do
    if [[ $EXTENSION == "-bibtex.log" ]] ; then
      rm -f "${1%.tex}-bibtex.log" >&- 2>&-
    else
      rm -f "${1%.tex}.$EXTENSION" >&- 2>&-
    fi
    echo -ne "."
  done
  if [[ -n $USEPS4PDFARG ]] ; then
    rm -f *-pics.* >&- 2>&-
    echo -ne "."
  fi
  echo -e "\t\t${txtgrn}[done]${txtrst}"
}

# Converts SVG & DIA images
function convert_images() {
  if [[ -z $1 ]] ; then
    die "${txtylw}Too few arguments.${txtrst}"
  fi
  if [[ ! -d $1 ]] ; then
    die "Wrong directory \"${txtylw}$1${txtrst}\" given."
  fi
  if [[ -n $CONVERTIMGARG ]] ; then
    local IMGFILES=`ls $1/*.$CONVERTIMGARG 2>&-`
  elif [[ -n $CONVERTIMGRARG ]] ; then
    local IMGFILES=`find $1 -type f -iname "*.$CONVERTIMGRARG" 2>&-`
  fi
  if [[ $CONVERTIMGARG == "svg" || $CONVERTIMGRARG == "svg" ]] ; then
    check_programs "$INKSCAPE_PROGRAM" #EPSTOPDF_PROGRAM
    echo -ne "CONVERT IMAGES..."
    for IMG in $IMGFILES ; do
      $INKSCAPE_PROGRAM -T -A "${IMG%.svg}.pdf" "$IMG" 2>/dev/null || die
      $INKSCAPE_PROGRAM -T -P "${IMG%.svg}.ps" "$IMG" 2>/dev/null || die
      #$EPSTOPDF_PROGRAM "${IMG%.svg}.eps"
      echo -ne "."
    done
  elif [[ $CONVERTIMGARG == "dia" || $CONVERTIMGRARG == "dia" ]] ; then
    check_programs "$DIA_PROGRAM"
    echo -ne "CONVERT IMAGES..."
    for IMG in $IMGFILES ; do
      $DIA_PROGRAM -t pdf "${IMG}" >&- 2>&-  || die
      $DIA_PROGRAM -t eps "${IMG}" >&- 2>&-  || die
      echo -ne "."
    done
  fi
  echo -e "\t\t\t\t${txtgrn}[done]${txtrst}" ; exit 0
}

# Puts multiple pages of a PDF document on a single A4 sheet
function pdf_manipulation() {
  if [[ -z $1 || -z $2 ]] ; then
    die "${txtylw}Too few arguments.${txtrst}"
  fi
  check_programs "$PDFNUP_PROGRAM"
  echo -ne "${txtund}PDFJAM${txtrst}..."
  local ERR=`eval $PDFNUP_PROGRAM --nup $1 $PDFNUP_OPT $2 2>&1`
  local ERR=`echo $ERR | grep -i error`
  if [[ -n $ERR ]] ; then
    echo -e\
      "\t\t\t\t${txtred}[done]  ${txtbld}(With errors!  No output?)${txtrst}"
  else
    echo -e "\t\t\t\t${txtgrn}[done]${txtrst}"
  fi
}

# Checks line widths
function line_width() {
  local WIDTH=80
  local LINE_NUMBER=0
  if [[ -z $1 ]] ; then
    die "${txtylw}Too few arguments.${txtrst}"
  fi
  if [[ -n $2 ]] ; then
    WIDTH="$1" ; shift
    if [[ ! ($WIDTH =~ ^[0-9]+$) ]] ; then
      die "Numeric argument required, \"${txtylw}$WIDTH${txtrst}\" provided."
    fi
  fi
  if [[ -z $FILENAME ]] ; then FILENAME=$1 ; fi
  if [[ ! -e $FILENAME ]] ; then
    die "Source file ${txtylw}$FILENAME${txtrst} missing."
  fi
  while read LINE ; do
    LINE_NUMBER=$(($LINE_NUMBER+1))
    CHARS=`echo $LINE | wc -m`
    if [[ $CHARS -gt $WIDTH ]] ; then
      echo -e "${txtbld}$LINE_NUMBER${txtrst}:\t$CHARS"
    fi
  done < "$1"
  exit 0
}

# Checks hard-spaces
function hardspaces() {
  if [[ -z $1 ]] ; then
    die "${txtylw}Too few arguments.${txtrst}"
  fi
  local FILE=${1%.tex}
  if [[ ! -e $FILE.tex ]] ; then
    die "Source file ${txtylw}$FILE.tex${txtrst} missing."
  fi
  grep -n\
  "\( [^ ] \)\|\( [^ ]$\)\|\(^[^ ] \)\|\( \$.\$ \)\|\( \$.\$$\)\|\(^\$.\$ \)"\
  "$FILE.tex"\
  | sort | uniq | sort -n | sed "s/:/\t/" | grep -P -v "^[0-9]+\t%"
}

# Checks sentences and periods
function sentences() {
  if [[ -z $2 ]] ; then
    die "${txtylw}Too few arguments.${txtrst}"
  fi
  local FILE=${2%.tex}
  if [[ ! -e $FILE.tex ]] ; then
    die "Source file ${txtylw}$FILE.tex${txtrst} missing."
  fi
  local EXP="\(^\.\)\|\([ ]\.[ ]\)\|\([ ]\.\)\|\(\.[ ][^ ]\)"
  if [[ $1 == "strict" ]] ; then
    local EXP=$EXP"\|\([^\.][ ]+[[:upper:]]\)\|\(\.[^ \\;:]\)"
  fi
  grep -n "$EXP"\
  "$FILE.tex"\
  | sort | uniq | sort -n | sed "s/:/\t/" | grep -P -v "^[0-9]+\t%"\
  | grep "\." --color=auto
}

# Runs spell checker (aspell)
function spell_checker() {
  check_programs "$DETEX_PROGRAM $ASPELL_PROGRAM"
  if [[ -n $2 ]] ; then ASPELL_LANG_OPT="-l $1" ; shift ; fi
  ASPELLOPT="$ASPELL_ENC_OPT $ASPELL_LANG_OPT"
  if [[ -z $FILENAME ]] ; then FILENAME=${1%.tex} ; fi
  if [[ ! -e $FILENAME.tex ]] ; then
    die "Source file ${txtylw}$FILENAME.tex${txtrst} missing."
  fi
  $DETEX_PROGRAM "$FILENAME.tex" > "$FILENAME-tmp.txt" || die
  $ASPELL_PROGRAM $ASPELLOPT -c "$FILENAME-tmp.txt" 2>&- || die
  rm "$FILENAME-tmp.txt" || die
  if [[ -e $FILENAME-tmp.txt.new ]] ; then
    rm "$FILENAME-tmp.txt.new"  || die
  else
    echo -ne "${txtbld}SPELL CHECKER${txtrst}..."
    echo -e "\t\t\t\t${txtgrn}[done]${txtrst}"
    exit 0
  fi
  exit $?
}

# Runs (pdf)latex
function run_pdflatex() {
  echo -ne "$TEXT..."
  if [[ -n $APPENDSYNCTEX ]] ; then
    $LATEX_PROGRAM $PDFLATEX_SYNCTEX_OPT $LATEX_BATCHMODE_OPT \
      "$FILENAME" >&- 2>&-
  else
    $LATEX_PROGRAM $LATEX_BATCHMODE_OPT "$FILENAME" >&- 2>&-
  fi
  local ERR=`grep -i error "$FILENAME".log | grep -v -i infwarerr`
  if [[ -n $ERR ]] ; then
    echo -ne "\t\t\t\t${txtred}[done]"
    if [[ -n $USEPS4PDFARG ]] ; then
      echo "${txtrst}"
    else
      echo "  ${txtbld}(With errors!  See $FILENAME.log file.)${txtrst}"
    fi
  else
    AUXILIARYEXTS="$AUXILIARYEXTS log"
    echo -e "\t\t\t\t${txtgrn}[done]${txtrst}"
  fi
}

# Sets (La)TeX beamer preamble for handouts
function beamer_handout() {
  sed -e 's/\\documentclass\[/\\documentclass[handout,/g'\
  -e 's/\\documentclass{/\\documentclass[handout]{/g'\
  $FILENAME.tex > $FILENAME-handout.tex || die
  FILENAME=$FILENAME-handout
}


# THE SCRIPT
# ==========

# Ctrl+C interrupt
trap "echo ; die \"${txtred}Interrupt from keyboard.${txtrst}\"" INT

THRICE=""

while [[ -n $1 ]] ; do
  case "$1" in
    -2x1)   pdf_manipulation "2x1" "$2" ; exit 0 ;;
    -2x2)   pdf_manipulation "2x2" "$2" ; exit 0 ;;
    +3)     THRICE="2" ; shift ;;
    +b)     MAKEBIBTEXARG="true" ; shift ;;
    -b)     MAKEONLYBIBTEXARG="true" ; shift ; break ;;
    -c)     AUXILIARYEXTS="$AUXILIARYEXTS log dvi synctex.gz -bibtex.log" ; \
            cleanup "$2"; exit 0 ;;
    -gs)    CONVERTIMGARG="svg" ; shift ; convert_images "$@" ; break ;;
    -rs)    CONVERTIMGRARG="svg" ; shift ; convert_images "$@" ; break ;;
    -gd)    CONVERTIMGARG="dia" ; shift ; convert_images "$@" ; break ;;
    -rd)    CONVERTIMGRARG="dia" ; shift ; convert_images "$@" ; break ;;
    -[hH])  print_help ; exit 0 ;;
    --help) print_help ; exit 0 ;;
    +h)     MAKEHANDOUT="true" ; shift ;;
    +i)     MAKEINDEXARG="true" ; shift ;;
    -i)     MAKEONLYINDEXARG="true" ; shift ; break ;;
    -k)     CHKTEX="true" ; shift ; break ;;
    -kk)    CHKTEX_OPT="$CHKTEX_OPT -n all" ; \
            CHKTEX="true" ; shift ; break ;;
    -l)     shift ; line_width "$@" ; break ;;
    -n)     hardspaces "$2" ; exit 0 ;;
    -s)     sentences "basic" "$2" ; exit 0 ;;
    -ss)    sentences "strict" "$2" ; exit 0 ;;
    -sc)    shift ; spell_checker "$@" ; break ;;
    +sync)  APPENDSYNCTEX="true" ; shift ;;
    +o)     OPENPDFARG="true" ; shift ;;
    +p)     USEPS4PDFARG="true" ; shift ;;
    +s)     SHOWSUMMARY="true" ; shift ;;
    -[vV])  echo "$THEREALNAME  $VERSION" ; echo ; exit 0 ;;
    -*)     echo -ne "Unknown switch: ${txtylw}$1${txtrst}." ;
            echo "  Type:  \"${txtbld}$THEREALNAME -h${txtrst}\"  for help." ;
            echo ; exit 1 ;;
    +*)     echo -ne "Unknown switch: ${txtylw}$1${txtrst}." ;
            echo "  Type:  \"${txtbld}$THEREALNAME -h${txtrst}\"  for help." ;
            echo ; exit 1 ;;
    *)      break ;;
  esac
done


# Filename and working directory:
if [[ -z $FILENAME && -n $1 ]] ; then FILENAME=$(basename ${1%.tex}) ; fi
if [[ -z $OUTPUT_DIRECTORY && -n $1 ]] ; then
  OUTPUT_DIRECTORY=$(dirname $1)
fi
if [[ -n $OUTPUT_DIRECTORY ]] ; then cd $OUTPUT_DIRECTORY ; fi

# Beamer handouts (part 1 of 2)
if [[ -n $MAKEHANDOUT ]] ; then
  if [[ ! -e $FILENAME.tex ]] ; then
    die "Source file ${txtylw}$FILENAME.tex${txtrst} missing."
  fi
  beamer_handout
fi

# 'chktex' command
if [[ -n $CHKTEX ]] ; then
  check_programs "$CHKTEX_PROGRAM"
  if [[ -z $FILENAME ]] ; then FILENAME=${1%.tex} ; fi
  if [[ ! -e $FILENAME.tex ]] ; then
    die "Source file ${txtylw}$FILENAME.tex${txtrst} missing."
  fi
  $CHKTEX_PROGRAM $CHKTEX_OPT "$FILENAME.tex" || die
  mquit $?
fi

# Command to use: 'latex' or 'pdflatex':
if [[ $THENAME == "latex.sh" ]] ; then
  LATEX_PROGRAM=$LATEX_PROGRAM
else
  LATEX_PROGRAM=$PDFLATEX_PROGRAM
fi
TEXT=`echo $LATEX_PROGRAM | tr "a-z" "A-Z"`

# First (pdf)latex compilation
check_programs "$LATEX_PROGRAM"
if [[ ! -e $FILENAME.tex ]] ; then
  die "Source file ${txtylw}$FILENAME.tex${txtrst} missing."
fi
for X in `seq 1 $THRICE` ; do run_pdflatex ; done


# Bibtex
if [[ -n $MAKEBIBTEXARG || -n $MAKEONLYBIBTEXARG ]] ; then
  check_programs "$BIBTEX_PROGRAM"
  echo -ne "${txtund}BIBTEX${txtrst}..."
  rm -f "$FILENAME-bibtex.log" >&- 2>&-  # old BibTeX log file
  BIBOUT=`$BIBTEX_PROGRAM "$FILENAME" 2>&-`
  BIBERR=`echo $BIBOUT | egrep -i "error|warning"`
  if [[ -n $BIBERR ]] ; then
    echo "$BIBOUT" > $FILENAME-bibtex.log
    echo -ne "\t\t\t\t${txtred}[done]"
    echo "  ${txtbld}(With errors!  See $FILENAME-bibtex.log file.)${txtrst}"
  else
      echo -e "\t\t\t\t${txtgrn}[done]${txtrst}"
      AUXILIARYEXTS_BIBTEX="$AUXILIARYEXTS_BIBTEX log"
  fi
  run_pdflatex
fi
if [[ -n $MAKEONLYBIBTEXARG ]] ; then
  AUXILIARYEXTS=$AUXILIARYEXTS_BIBTEX
  cleanup "$FILENAME"
  mquit $?
fi

# Index
INDEXFILENAME="$FILENAME.idx"
if [[ -n $MAKEINDEXARG || -n $MAKEONLYINDEXARG ]] ; then
  check_programs "$MAKEINDEX_PROGRAM"
  if [[ -e $INDEXFILENAME ]] ; then
    echo -ne "${txtund}MAKEINDEX${txtrst}...\t\t\t\t"
    $MAKEINDEX_PROGRAM "$INDEXFILENAME" 2>&- || die
    echo "${txtgrn}[done]${txtrst}"
    run_pdflatex
  else
    echo -ne "Index file \"${txtylw}$INDEXFILENAME${txtrst}\" missing."
    echo "  Skiping index..."
  fi
fi
if [[ -n $MAKEONLYINDEXARG ]] ; then
  AUXILIARYEXTS=$AUXILIARYEXTS_INDEX
  cleanup "$FILENAME"
  mquit $?
fi

# Final (pdf)latex compilation
if [[ -z $USEPS4PDFARG ]] ; then
  run_pdflatex
else
# Ps4pdf
  check_programs "$PS4PDF_PROGRAM"
  if [[ ! -e $FILENAME.tex ]] ; then
    die "Source file ${txtylw}$FILENAME${txtrst} missing."
  fi
  echo -ne "${txtund}PS4PDF${txtrst}...\t\t\t\t"
  $PS4PDF_PROGRAM "$FILENAME" >&- 2>&-
  ERR=`egrep -i "error|emergency stop" "$FILENAME".log | grep -v -i infwarerr`
  if [[ -n $ERR ]] ; then
    echo -ne "${txtred}[done]"
    echo "  ${txtbld}(With errors! See $FILENAME.log file.)${txtrst}"
  else
    echo "${txtgrn}[done]${txtrst}"
    echo -ne "$TEXT...\t\t\t\t"
    if [[ -n $APPENDSYNCTEX ]] ; then
      $LATEX_PROGRAM $PDFLATEX_SYNCTEX_OPT $LATEX_BATCHMODE_OPT \
        "$PS4PDF_LATEX_OPT \input{$FILENAME}" >&- 2>&-
    else
      $LATEX_PROGRAM $LATEX_BATCHMODE_OPT "$PS4PDF_LATEX_OPT \
        \input{$FILENAME}" >&- 2>&-
    fi
    echo "${txtgrn}[done]${txtrst}"
    AUXILIARYEXTS="$AUXILIARYEXTS log"
  fi
fi

# Problems summary (part 1 of 2)
if [[ -n $SHOWSUMMARY ]] ; then
  ERRORSNUM=`grep -c -i "^\!" "$FILENAME".log`
  ERRORS=`grep -A2 -i "^\!" "$FILENAME".log`
  WARNINGS=`grep -i warning "$FILENAME".log | grep -v -i infwarerr`
  WARNINGSNUM=`echo "$WARNINGS" | grep -c -i warning`
fi

# Cleanup
if [[ $LATEX_PROGRAM != "latex" ]] ; then
  AUXILIARYEXTS="$AUXILIARYEXTS dvi"
fi
cleanup "$FILENAME"

# Beamer handouts (part 2 of 2)
if [[ -n $MAKEHANDOUT ]] ; then
  pdf_manipulation "2x2" "$FILENAME.pdf"
  echo -ne "BEAMER HANDOUTS..."
  mv -f $FILENAME-nup.pdf $FILENAME.pdf 2>&- || die
  rm -f $FILENAME.tex 2>&- || die
  echo -e "\t\t\t${txtgrn}[done]${txtrst}"
fi

# PDF browser
if [[ -n $OPENPDFARG && -e $FILENAME.pdf ]] ; then
  check_programs "$PDF_VIEWER_PROGRAM"
  echo -en "${txtbld}BROWSER${txtrst}...\t\t\t\t"
  $PDF_VIEWER_PROGRAM "$FILENAME.pdf" 2>/dev/null &
  echo "${txtgrn}${txtbld}[done]${txtrst}"
fi

# Problems summary (part 2 of 2)
if [[ -n $SHOWSUMMARY && ( $ERRORSNUM > 0 || $WARNINGSNUM > 0 ) ]] ; then
  echo
  echo \
    "${txtund}${txtbld}SUMMARY:                                      ${txtrst}"
  if [[ $ERRORSNUM > 0 ]] ; then
    echo -e "${txtcyn}${txtbld}Errors ($ERRORSNUM):${txtrst}"
    echo "$ERRORS" | grep -A2 -i "^\!" --color=auto
    echo "______________________________________________"
  fi
  if [[ $WARNINGSNUM > 0 ]] ; then
    echo -e "${txtblu}${txtbld}Warnings ($WARNINGSNUM):${txtrst}"
    echo "$WARNINGS" | grep -i "warning"  --color=auto
  fi
fi

mquit $?
