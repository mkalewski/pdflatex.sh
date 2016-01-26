#!/usr/bin/env bash
# UTF-8

#  (c) 2007-2016 Michal Kalewski  <mkalewski at cs.put.poznan.pl>
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
#    pdflatex.sh  [ +3 +b +g +h +i +n +o +p +s +sync +shell ]  FILE(.tex)
#    pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
#    pdflatex.sh  -gs | -rs | -gd | -rd  DIRECTORY
#    pdflatex.sh  -b | -c | -g | -i | -k | -kk | -l [WIDTH] | -n | -s | -ss
#                 | -sc [LANG]  FILE(.tex)
#
#  DESCRIPTION
#    A bash script to simplify TeX/LaTeX/XeLaTeX files compilation and more.
#    Just run the script to get more information: './pdflatex.sh'.
#
#  REPORTING BUGS
#    <https://github.com/mkalewski/pdflatex.sh/issues>
#
#  THE OFFICIAL CODE REPOSITORY
#    <https://github.com/mkalewski/pdflatex.sh>
#
#  (Below, you may customize your settings.)

# VERSION
# =======
VERSION=3.4.0


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
MAKEGLOSSARIES_PROGRAM="makeglossaries"
PDF_VIEWER_PROGRAM="evince"
PDFLATEX_PROGRAM="pdflatex"
PDFNUP_PROGRAM="pdfnup"
PS4PDF_PROGRAM="ps4pdf"
XELATEX_PROGRAM="xelatex"


# OPTIONS
# =======
ASPELL_ENC_OPT="--encoding=utf-8"
ASPELL_LANG_OPT="-l en_GB"
CHKTEX_OPT="-q -v1"
GREP_COLOR="--color=auto"
LATEX_BATCHMODE_OPT="-interaction batchmode"
LATEX_SHELL_ESCAPE_OPT="-shell-escape"
PDFLATEX_SYNCTEX_OPT="-synctex=1"
PDFNUP_OPT="--paper a4paper --frame true --scale 0.96 --delta \"2mm 2mm\""
PS4PDF_LATEX_OPT="\AtBeginDocument{\RequirePackage{pst-pdf}}"
MAKEGLOSSARIES_OPT="-q"


# FILE TO BUILD
# =============
FILENAME=
OUTPUT_DIRECTORY=


# SETUP
# =====

# Extensions of auxiliary files:
AUXILIARYEXTS_COMMON=\
"acn acr alg aux blg glg glo glsdefs idx ilg ist loa lof lot nav out snm svn toc vrb"
AUXILIARYEXTS="$AUXILIARYEXTS_COMMON bbl gls ind"
AUXILIARYEXTS_BIBTEX="$AUXILIARYEXTS_COMMON dvi gls ind pdf synctex.gz"
AUXILIARYEXTS_INDEX="$AUXILIARYEXTS_COMMON bbl div gls pdf synctex.gz"
AUXILIARYEXTS_GLOSSARIES="$AUXILIARYEXTS_COMMON bbl div ind pdf synctex.gz"

# Options to pass to the latex/pdflatex/xelatex compilers:
LATEX_OPTIONS="$LATEX_BATCHMODE_OPT"

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

# OS X adjustments:
GREP="grep"
if [[ $OSTYPE == *darwin* ]] ; then
  # PDF viewer
  if [[ $PDF_VIEWER_PROGRAM == "evince" ]] ; then
    PDF_VIEWER_PROGRAM="open"
  fi
  # Use GNU grep (i.e., ggrep) instead of BSD grep
  GREP="ggrep"
fi

# Disable ! style history substitution:
set +H


# FUNCTIONS
# =========

# Prints help and additional information
function print_help() {
cat <<EOF

${txtbld}PDFLATEX.SH${txtrst} $VERSION (c) 2007-2016\
 ${txtbld}Michal Kalewski${txtrst} <mkalewski at cs.put.poznan.pl>

    ${txtund}A BASH SCRIPT TO SIMPLIFY TeX/LaTeX/XeLaTeX FILES COMPILATION\
 AND MORE${txtrst}

NOTE:  If the script is run as 'pdflatex.sh', then the 'pdflatex' command is
       used (producing PDF output files).  However, if the script is run as
       'latex.sh', then the 'latex' command is used (producing DVI output
       files), and if the script is run as 'xelatex.sh', then the 'xelatex'
       command is used (producing PDF output files).  Thus, if necessary,
       symbolic links may be created to use the script easily.

${txtbld}For more information, please visit${txtrst}:  \
<https://github.com/mkalewski/pdflatex.sh>

${txtbld}Usage${txtrst}:
  pdflatex.sh  -h | -V
    Print help or version.

  pdflatex.sh  [ +3 +b +g +h +i +n +o +p +s +sync +shell ]  FILE(.tex)
    Compile (La)TeX files.

  pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
    PDF documents manipulation.

  pdflatex.sh  -gs | -rs | -gd | -rd  DIRECTORY
    Convert images.

  pdflatex.sh  -b | -c | -g | -i | -k | -kk | -l [WIDTH] | -n | -s | -ss
               | -sc [LANG]  FILE(.tex)
    Miscellaneous operations.

${txtbld}Options${txtrst}:
  -2x1 FILE          put two pages of the PDF FILE on a single A4 sheet (the
                     output will be in a FILE-nup.pdf file)
  -2x2 FILE          put four pages of the PDF FILE on a single A4 sheet (the
                     output will be in a FILE-nup.pdf file)
  +3                 run 'latex'/'pdflatex'/'xelatex' thrice (default is twice)
  -b   FILE          make ONLY BibTeX
  +b                 make ALSO BibTeX
  -c   FILE          cleanup (remove auxiliary files)
  -g   FILE          make ONLY glossaries (MakeGlossaries)
  +g                 make ALSO glossaries (MakeGlossaries)
  -gs  DIRECTORY     convert SVG images in directory DIRECTORY
  -rs  DIRECTORY     convert SVG images in directory DIRECTORY recursively
  -gd  DIRECTORY     convert DIA images in directory DIRECTORY
  -rd  DIRECTORY     convert DIA images in directory DIRECTORY recursively
  -h                 print (this) help message and exit
  +h                 make a handout from a beamer presentation, i.e., without
                     overlays, pauses, and other Beamer effects (the output
                     will be in a FILE-handout.pdf file)
  -i   FILE          make ONLY index (MakeIndex)
  +i                 make ALSO index (MakeIndex)
  -k   FILE          run the 'chktex' command (if available)
  -kk  FILE          the same as '-k' but only errors are shown
  -l   [WIDTH] FILE  check if the length of each line in FILE does not exceed
                     the given width (by default WIDTH=80)
  -n   FILE          check non-breaking spaces
  +n                 disable output coloring during the compilation
  +o                 open the resulting PDF (or DVI) file after the compilation
  +p                 use 'ps4pdf' instead of 'latex'/'pdflatex'/'xelatex'
                     (the PSTricks package)
  -s   FILE          check sentence separators
  +s                 print a summary of problems (errors and warnings) after
                     the compilation
  -sc  [LANG] FILE   start the interactive 'aspell' spell checker (by default
                     LANG="en_GB" and UTF-8 encoding is used)
  +shell             enable the shell escape option of 'latex'/'pdflatex'/
                     'xelatex'
  -ss  FILE          STRICTLY check sentence separators
  +sync              enable the synchronization between the source file and the
                     resulting DVI or PDF file
  -V                 print the script version

${txtbld}Examples${txtrst}:
  pdflatex.sh file.tex
  pdflatex.sh +o file.tex
  pdflatex.sh +b +g +i file.tex
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
  # enable ! style history substitution:
  set -H
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

# Disables output coloring
function disable_colors() {
  txtund=
  txtbld=
  txtred=
  txtgrn=
  txtylw=
  txtblu=
  txtpur=
  txtcyn=
  txtwht=
  txtrst=
  GREP_COLOR=
}

# Checks programs availability in the system
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
  local EXTENSIONS=$(echo "$AUXILIARYEXTS" | tr " " "\n" | sort | uniq | tr "\n" " ")
  local EXTENSIONS=${EXTENSIONS% }
  for EXTENSION in $EXTENSIONS ; do
    if [[ $EXTENSION == "-bibtex.log" ]] ; then
      rm -f "${1%.tex}-bibtex.log" >&- 2>&-
    else
      rm -f "${1%.tex}.$EXTENSION" >&- 2>&-
    fi
  done
  if [[ -n $USEPS4PDFARG ]] ; then
    rm -f *-pics.* >&- 2>&-
  fi
  echo -e "\t\t\t\t${txtgrn}[done]${txtrst}"
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
  check_programs "$PDFNUP_PROGRAM $GREP"
  echo -ne "${txtund}PDFJAM${txtrst}..."
  local ERR=`eval $PDFNUP_PROGRAM --nup $1 $PDFNUP_OPT $2 2>&1`
  local ERR=`echo $ERR | $GREP -a -i error`
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
  while read -r LINE ; do
    LINE_NUMBER=$(($LINE_NUMBER+1))
    CHARS=`echo -n "$LINE" | wc -m | tr -d ' '`
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
  check_programs "$GREP"
  local EXP="\( [^ ] \)\|\( [^ ]$\)\|\(^[^ ] \)\|\( \$.\$ \)\|\( \$.\$$\)\|\(^\$.\$ \)"
  $GREP -a -n "$EXP" "$FILE.tex"\
  | sort | uniq | sort -n | awk -F: -v a=${txtbld} -v b=${txtrst}\
    '{printf "%s%s%s%s\t%s\n", a, $1, b, ":", $2}'\
  | $GREP -a -P -v "^[0-9]+\t%"
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
  check_programs "$GREP"
  local EXP="\(^\.\)\|\([ ]\.[ ]\)\|\([ ]\.\)\|\(\.[ ][^ ]\)"
  if [[ $1 == "strict" ]] ; then
    local EXP=$EXP"\|\([^\.][ ]+[[:upper:]]\)\|\(\.[^ \\;:]\)"
  fi
  $GREP -a -n "$EXP" "$FILE.tex"\
  | sort | uniq | sort -n | awk -F: -v a=${txtbld} -v b=${txtrst}\
    '{printf "%s%s%s%s\t%s\n", a, $1, b, ":", $2}'\
  | $GREP -a -P -v "^[0-9]+\t%" | $GREP -a "\." $GREP_COLOR
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
  $ASPELL_PROGRAM $ASPELLOPT -c "$FILENAME-tmp.txt" 2>&- ||\
    { rm "$FILENAME-tmp.txt" ; die ; }
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
  check_programs "$GREP"
  echo -ne "$TEXT..."
  $LATEX_PROGRAM $LATEX_OPTIONS "$FILENAME" >&- 2>&-
  local ERR=`$GREP -a -i error "$FILENAME".log | $GREP -a -v -i infwarerr`
  if [[ -z $ERR ]] ; then
    local ERR=`$GREP -a -i "^\!" "$FILENAME".log`
  fi
  if [[ -n $ERR ]] ; then
    echo -ne "\t\t\t\t${txtred}[done]"
    if [[ -n $USEPS4PDFARG ]] ; then
      echo "${txtrst}"
    else
      echo "  ${txtbld}(With errors!  See $FILENAME.log file.)${txtrst}"
    fi
  else
    AUXILIARYEXTS="$AUXILIARYEXTS log"
    AUXILIARYEXTS_INDEX="$AUXILIARYEXTS_INDEX log"
    AUXILIARYEXTS_GLOSSARIES="$AUXILIARYEXTS_GLOSSARIES log"
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
    -c)     AUXILIARYEXTS="$AUXILIARYEXTS log dvi synctex.gz -bibtex.log bbl gls ind" ; \
            cleanup "$2"; exit 0 ;;
    +g)     MAKEGLOSSARIESARG="true" ; shift ;;
    -g)     MAKEONLYGLOSSARIESARG="true" ; shift ; break ;;
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
    +n)     disable_colors ; shift ;;
    +o)     OPENPDFARG="true" ; shift ;;
    +p)     USEPS4PDFARG="true" ; shift ;;
    -s)     sentences "basic" "$2" ; exit 0 ;;
    +s)     SHOWSUMMARY="true" ; shift ;;
    -sc)    shift ; spell_checker "$@" ; break ;;
    +shell) LATEX_OPTIONS="$LATEX_OPTIONS $LATEX_SHELL_ESCAPE_OPT" ; shift ;;
    -ss)    sentences "strict" "$2" ; exit 0 ;;
    +sync)  LATEX_OPTIONS="$LATEX_OPTIONS $PDFLATEX_SYNCTEX_OPT" ; shift ;;
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

# Command to use: 'latex', 'pdflatex', or 'xelatex':
if [[ $THENAME == "latex.sh" ]] ; then
  LATEX_PROGRAM=$LATEX_PROGRAM
elif [[ $THENAME == "xelatex.sh" ]] ; then
  LATEX_PROGRAM=$XELATEX_PROGRAM
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
  check_programs "$BIBTEX_PROGRAM $GREP"
  echo -ne "${txtund}BIBTEX${txtrst}..."
  rm -f "$FILENAME-bibtex.log" >&- 2>&-  # old BibTeX log file
  BIBOUT=`$BIBTEX_PROGRAM "$FILENAME" 2>&-`
  BIBERR=`echo $BIBOUT | $GREP -a -E -i "error|warning"`
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

# Glossary
GLOSSARYFILENAME="$FILENAME.glo"
if [[ -n $MAKEGLOSSARIESARG || -n $MAKEONLYGLOSSARIESARG ]] ; then
  check_programs "$MAKEGLOSSARIES_PROGRAM"
  if [[ -e $GLOSSARYFILENAME ]] ; then
    echo -ne "${txtund}MAKEGLOSSARIES${txtrst}...\t\t\t"
    $MAKEGLOSSARIES_PROGRAM $MAKEGLOSSARIES_OPT "$GLOSSARYFILENAME" 2>&- || die
    echo "${txtgrn}[done]${txtrst}"
    run_pdflatex
  else
    echo -ne "Glossary file \"${txtylw}$GLOSSARYFILENAME${txtrst}\" missing."
    echo "  Skipping glossary..."
  fi
fi
if [[ -n $MAKEONLYGLOSSARIESARG ]] ; then
  AUXILIARYEXTS=$AUXILIARYEXTS_GLOSSARIES
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
    echo "  Skipping index..."
  fi
fi
if [[ -n $MAKEONLYINDEXARG ]] ; then
  AUXILIARYEXTS=$AUXILIARYEXTS_INDEX
  cleanup "$FILENAME"
  mquit $?
fi

# Final (pdf)latex compilation
for X in `seq 1 $THRICE` ; do
  if [[ -z $USEPS4PDFARG ]] ; then
    run_pdflatex
  else
  # Ps4pdf
    check_programs "$PS4PDF_PROGRAM"
    if [[ ! -e $FILENAME.tex ]] ; then
      die "Source file ${txtylw}$FILENAME${txtrst} missing."
    fi
    check_programs "$GREP"
    echo -ne "${txtund}PS4PDF${txtrst}...\t\t\t\t"
    $PS4PDF_PROGRAM "$FILENAME" >&- 2>&-
    ERR=`$GREP -a -E -i "error|emergency stop" "$FILENAME".log | $GREP -a -v -i infwarerr`
    if [[ -n $ERR ]] ; then
      echo -ne "${txtred}[done]"
      echo "  ${txtbld}(With errors! See $FILENAME.log file.)${txtrst}"
      AUXILIARYEXTS=${AUXILIARYEXTS// log}
    else
      echo "${txtgrn}[done]${txtrst}"
      echo -ne "$TEXT...\t\t\t\t"
      $LATEX_PROGRAM $LATEX_OPTIONS "$PS4PDF_LATEX_OPT \
        \input{$FILENAME}" >&- 2>&-
      echo "${txtgrn}[done]${txtrst}"
      AUXILIARYEXTS="$AUXILIARYEXTS log"
    fi
  fi
done

# Problems summary (part 1 of 2)
if [[ -n $SHOWSUMMARY ]] ; then
  check_programs "$GREP"
  ERRORSNUM=`$GREP -a -c -i "^\!" "$FILENAME".log`
  ERRORS=`$GREP -a -A2 -i "^\!" "$FILENAME".log`
  WARNINGS=`$GREP -a -A2 -i warning "$FILENAME".log | $GREP -a -v -i infwarerr`
  WARNINGSNUM=`echo "$WARNINGS" | $GREP -a -c -i warning`
fi

# Cleanup
if [[ $LATEX_PROGRAM != "latex" ]] ; then
  AUXILIARYEXTS="$AUXILIARYEXTS dvi"
else
  AUXILIARYEXTS="$AUXILIARYEXTS pdf"
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
    echo -e "${txtblu}${txtbld}Errors ($ERRORSNUM):${txtrst}"
    echo "$ERRORS" | $GREP -a -E -v "^[[:space:]]*$" |\
      $GREP -a -A2 -i "^\!" $GREP_COLOR
    echo "${txtund}                                              ${txtrst}"
  fi
  if [[ $WARNINGSNUM > 0 ]] ; then
    echo -e "${txtcyn}${txtbld}Warnings ($WARNINGSNUM):${txtrst}"
    echo "$WARNINGS" | $GREP -a -E -v "^[[:space:]]*$" |\
      $GREP -a -A2 -i "warning" $GREP_COLOR
  fi
fi

mquit $?
