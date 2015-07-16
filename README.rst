===========
pdflatex.sh
===========

:Author:  Michał Kalewski
:Version: 3.3.1
:License: MIT License
:Bug reports: https://github.com/mkalewski/pdflatex.sh/issues


Synopsis
========
::

  pdflatex.sh  -h | -V
  pdflatex.sh  [ +3 +b +g +h +i +n +o +p +s +sync ]  FILE(.tex)
  pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
  pdflatex.sh  -gs | -rs | -gd | -rd  DIR
  pdflatex.sh  -b | -c | -g | -i | -k | -kk | -l [WIDTH] | -n | -s
               | -ss | -sc [LANG]  FILE(.tex)

Description
===========
A bash script to simplify TeX, LaTeX, and XeLaTeX files compilation with
bibliographies (BibTeX), glossaries (MakeGlossaries), indices (MakeIndex),
PSTricks, and more.  In the simplest case, the script is run as follows::

  $ pdflatex.sh file.tex

Then, the ``file.tex`` file will be compiled twice with the use of the
``pdflatex`` command and all auxiliary files will be removed after the
compilation.

The ``pdflatex.sh`` script can also be used to convert images to the PDF format
and to manipulate output PDF documents.  The script also lets you check
syntactic and semantic correctness of (La)TeX source files, e.g. with the use
of *ChkTeX*, and create handouts from beamer slides (for more information see
options_ and examples_).

It is possible to customize the programs (like PDF viewer), which are used by
the script in the **Programs** and **Options** sections in the source code.

Note
----

If the script is run as `pdflatex.sh`, then the `pdflatex` command is used
(producing PDF output files).  However, if the script is run as `latex.sh`,
then the `latex` command is used (producing DVI output files), and if the
script is run as `xelatex.sh`, then the `xelatex` command is used (producing
PDF output files).  Thus, if necessary, symbolic links may be created to use
the script easily, e.g.::

  $ ln -s ./pdflatex.sh ./latex.sh
  $ ln -s ./pdflatex.sh ./xelatex.sh

**Arch Linux** users may use `tdi <https://github.com/tdi>`_'s `AUR package
<http://aur.archlinux.org/packages.php?ID=55739>`_ to obtain the script.

**OS X** users need to install GNU grep, i.e., ``ggrep``, which is required for
the script to work correctly.

Options
=======
``-2x1 FILE``
  Put two pages of the PDF FILE on a single A4 sheet (the output will be in a
  FILE-nup.pdf file).
``-2x2 FILE``
  Put four pages of the PDF FILE on a single A4 sheet (the output will be in a
  FILE-nup.pdf file).
``+3``
  Run ``latex``/``pdflatex`` thrice (default is twice).
``-b FILE``
  Make ONLY BibTeX.
``+b``
  Make ALSO BibTeX.
``-c FILE``
  Cleanup: remove auxiliary files.
``-g FILE``
  Make ONLY glossaries (MakeGlossaries).
``+g``
  Make ALSO glossaries (MakeGlossaries).
``-gs DIR``
  Convert SVG images in directory DIR.
``-rs DIR``
  Convert SVG images in directory DIR recursively.
``-gd DIR``
  Convert DIA images in directory DIR.
``-rd DIR``
  Convert DIA images in directory DIR recursively.
``-h``
  Print the help message and exit.
``+h``
  Make a handout from a beamer presentation -- without overlays, pauses, and
  other Beamer effects (the output will be in a FILE-handout.pdf file).
``-i FILE``
  Make ONLY index (MakeIndex).
``+i``
  Make ALSO index (MakeIndex).
``-k FILE``
  Run the ``chktex`` command (if available).
``-kk FILE``
  The same as '``-k``' but only errors are shown.
``-l [WIDTH] FILE``
  Check if the length of each line in FILE does not exceed the given width (by
  default ``WIDTH=80``)
``-n FILE``
  Check non-breaking spaces.
``+n``
  Disable output coloring during the compilation.
``+o``
  Open the resulting PDF (or DVI) file after the compilation.
``+p``
  Use ``ps4pdf`` instead of ``pdflatex``/``latex`` (PSTricks).
``-s FILE``
  Check sentence separators.
``+s``
  Print a summary of problems (errors and warnings) after the compilation.
``-sc [LANG] FILE``
  Start the interactive ``aspell`` spell checker (by default ``LANG="en_GB"``
  and UTF-8 encoding is used).
``-ss FILE``
  STRICTLY check sentence separators.
``+sync``
  Enable the synchronization between the source file and the resulting DVI or
  PDF file.  (About the option see also `"Direct and reverse synchronization
  with SyncTEX" <http://www.tug.org/TUGboat/tb29-3/tb93laurens.pdf>`_.)
``-V``
  Print the script version.


Examples
========
* Compile a (La)TeX source file named ``file.tex`` (this example shows also the
  script's output messages)::

    $ pdflatex.sh file.tex
    PDFLATEX...                         [done]
    PDFLATEX...                         [done]
    CLEANUP...                          [done]

* Compile ``file.tex`` with BibTeX, MakeGlossaries, and MakeIndex, and open a
  PDF browser with the output file after the compilation::

    $ pdflatex.sh +b +g +i +o file.tex

* Compile ``file.tex`` with the use of PSTricks::

    $ pdflatex.sh +p file.tex

* Compile a beamer presentation file named ``beamer-presentation.tex`` and make
  a handout of it (the output should be in a file named
  ``beamer-presentation-handout.pdf``)::

    $ pdflatex.sh +h beamer-presentation.tex

* Run the ``chktex`` command, but show errors only::

    $ pdflatex.sh -kk file.tex

* Convert all SVG images in directory ``images/`` (PDF and PS files will be
  produced within that directory)::

    $ pdflatex.sh -gs images/

* Put two pages of a file named ``file.pdf`` on a single A4 sheet (the output
  should be in a file named ``file-nup.pdf``)::

    $ pdflatex.sh -2x1 file.pdf


Copyright
=========
| (c) 2007-2015 Michal Kalewski  <mkalewski at cs.put.poznan.pl>
|
| This program comes with ABSOLUTELY NO WARRANTY.
| THIS IS FREE SOFTWARE, AND YOU ARE WELCOME TO REDISTRIBUTE IT UNDER THE TERMS
| AND CONDITIONS OF THE MIT LICENSE.  YOU SHOULD HAVE RECEIVED A COPY OF THE
| LICENSE ALONG WITH THIS SOFTWARE; IF NOT, YOU CAN DOWNLOAD A COPY FROM
| HTTP://WWW.OPENSOURCE.ORG.
