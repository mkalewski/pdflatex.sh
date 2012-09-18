===========
pdflatex.sh
===========

:Author:  Michał Kalewski
:Source:  https://github.com/mkalewski/pdflatex.sh
:Version: 3.1.0


Name
====
`pdflatex.sh` -- compile (La)TeX files and more.

Synopsis
========
::

  pdflatex.sh  -h | -V
  pdflatex.sh  [ +3 +b +h +i +o +p +s +sync ]  FILE(.tex)
  pdflatex.sh  -2x1 | -2x2  FILE(.pdf)
  pdflatex.sh  -gs | -rs | -gd | -rd  DIR
  pdflatex.sh  -b | -c | -i | -k | -kk | -l [WIDTH] | -n | -s | -ss
               | -sc [LANG]  FILE(.tex)

Description
===========
A bash script to simplify (La)TeX files compilation with BibTeX, indices and
PSTricks if necessary.  In the simplest case, the script is run as follows::

  $ pdflatex.sh file.tex

It can be also use to convert images to include them in (La)TeX files and to
manipulate output PDF documents.  The script also lets you check syntactic and
semantic correctness of (La)TeX source files, e.g. with the use of *ChkTeX*,
and create handouts from beamer slides.  (See all options_.)

It is possible to customize programs (like PDF viewer) and its settings that
are used by the script in **Programs** and **Options** sections in the source
code.

.. note::

  If the script is run as `pdflatex.sh` then `pdflatex` command is used
  (producing PDF output file), otherwise `latex` command is used (producing DVI
  output file).  Thus if necessary, the `latex.sh` symbolic link can be created
  to use the script easily.

**Arch Linux** users can use tdi's `AUR package
<http://aur.archlinux.org/packages.php?ID=55739>`_ to obtain the script.

Options
=======
``-2x1 FILE``
  Put two pages of the PDF FILE on a single A4 sheet (the output will be in
  FILE-nup.pdf file).
``-2x2 FILE``
  Put four pages of the PDF FILE on a single A4 sheet (the output will be in
  FILE-nup.pdf file).
``+3``
  Run ``latex``/``pdflatex`` thrice (default is twice).
``-b FILE``
  Make ONLY BibTeX.
``+b``
  Make ALSO BibTeX.
``-c FILE``
  Cleanup: remove auxiliary files.
``-gs DIR``
  Convert SVG images in directory DIR.
``-rs DIR``
  Convert SVG images in directory DIR recursively.
``-gd DIR``
  Convert DIA images in directory DIR.
``-rd DIR``
  Convert DIA images in directory DIR recursively.
``-h``
  Print help message and exit.
``+h``
  Make handout from beamer presentation, i.e. without  overlays, pauses, and
  other Beamer effects (the output will be in FILE-handout.pdf file).
``-i FILE``
  Make ONLY index (MakeIndex).
``+i``
  Make ALSO index (MakeIndex).
``-k FILE``
  Run ``chktex`` command (if available).
``-kk FILE``
  The same as '``-k``' but only errors are shown.
``-l [WIDTH] FILE``
  Check maximum line width (by default ``WIDTH=80``).
``-n FILE``
  Check non-breaking spaces.
``-s FILE``
  Check sentence separators.
``+s``
  Print a summary of problems (errors and warnings) after compilation.
``-ss FILE``
  STRICTLY check sentence separators.
``-sc [LANG] FILE``
  Run interactive spell checker (by default ``LANG="en_GB"`` and UTF-8 encoding
  is used).
``+sync``
  Enable synchronization between source file and the resulting DVI or PDF file.
``+o``
  Open PDF (or DVI) file after compilation.
``+p``
  Use ``ps4pdf`` instead of ``pdflatex``/``latex`` (PSTricks).
``-V``
  Print script version.

(About `+sync` option see also `"Direct and reverse synchronization with
SyncTEX" <http://www.tug.org/TUGboat/tb29-3/tb93laurens.pdf>`_.)

Examples
========
* Compile ``file.tex`` source file::

    $ pdflatex.sh file.tex

* Compile ``file.tex`` with BibTeX and MakeIndex, and open PDF browser with the
  output file after compilation::

    $ pdflatex.sh +b +i +o file.tex

* Compile ``file.tex`` with the use of PSTricks::

    $ pdflatex.sh +p file.tex

* Compile ``beamer-presentation.tex`` beamer presentation file and make a
  handout of it (the output should be in ``beamer-presentation-handout.pdf``
  file)::

    $ pdflatex.sh +h beamer-presentation.tex

* Run ``chktex`` command but show only errors::

    $ pdflatex.sh -kk file.tex

* Convert all SVG images in directory ``img/`` (PDF and PS files will be
  produced)::

    $ pdflatex.sh -gs img/

* Put two pages of the ``file.pdf`` on a single A4 sheet (the output should be
  in ``FILE-nup.pdf`` file)::

    $ pdflatex.sh -2x1 file.pdf


Reporting Bugs
==============
Bug reports: https://github.com/mkalewski/pdflatex.sh/issues

Copyright
=========
| (c) 2007-2012 Michal Kalewski  <mkalewski at cs.put.poznan.pl>
|
| This program comes with ABSOLUTELY NO WARRANTY.
| THIS IS FREE SOFTWARE, AND YOU ARE WELCOME TO REDISTRIBUTE IT UNDER THE TERMS
| AND CONDITIONS OF THE MIT LICENSE.  YOU SHOULD HAVE RECEIVED A COPY OF THE
| LICENSE ALONG WITH THIS SOFTWARE; IF NOT, YOU CAN DOWNLOAD A COPY FROM
| HTTP://WWW.OPENSOURCE.ORG.
