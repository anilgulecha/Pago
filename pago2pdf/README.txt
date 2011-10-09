#!/usr/bin/ruby1.8

#= Pago2PDF
#  Version 0.1.11
#  Updated 2009-05-07
#  
#  Maintainer: Mike Zazaian, mike@zop.io, http://zop.io
#  License:  This file is placed in the public domain.
#
#  Pago2PDF is a script that converts a properly-formatted text screenplay into PDF.
#  
#  Before running Pago2PDF you'll have to have the following software installed on
#  your machine:
#
#  -- Ruby1.8
#  -- Rubygems1.8
#  -- The rubygem 'pdf-writer'
#
#  If you're on an ubuntu linux machine, and don't have these installed, you can install
#  them by running the following commands from the command-line:
#
#  sudo aptitude update && sudo aptitude safe-upgrade && sudo aptitude install ruby1.8 rubygems1.8
#
#  Then, once these are installed, you can install the 'pdf-writer' rubygem by
#  running the following command:
#
#  gem install --remote pdf-writer
#
#  This script will be upgraded to Ruby1.9 if the pdf-writer rubygem is upgraded,
#  or if a more suitable pdf-creation library is chosen.
#
#  NOW THAT YOU'VE GOT THE PROPER SOFTWARE INSTALLED...
#
#  You can use Pago2PDF by calling it from a command-line, as such:
#  
#  ruby pago2pdf screenplay.txt
#  
#  Note that screenplay.txt is the name of the text screenplay file that you'd like
#  to convert.  Note that if the screenplay.txt file is not in the same directory as
#  Pago2PDF, you'll have to add the path to the screenplay file as such:
#
#  ruby pago2pdf /home/user/path/to/screenplay.txt
#
#  or
#
#  ruby pago2pdf ~/path/to/screenplay.txt
#
#  Pago2PDF can also add a TITLE PAGE to your screenplay.  To add a title page,
#  simply create a text file containing the following information, formatted with a
#  blank line between each bit:
#
#  Screenplay Title
#  Second Line of Screenplay Title (optional)
#
#  Author Name
#  Second Author Name (optional)
#
#  Copyright Information (optional)
#  Registration Information (optional)
#
#  Author Name
#  Author Address
#  Author Phone
#  Author Email
#
#  When you've created the file, simply add it after the screenplay.txt file when
#  you call the program on the command line:
#
#  ruby pago2pdf screenplay.txt title_page.txt
#
#  Don't worry about adding the correct number of spaces between each piece of
#  information.  Pago2PDF automatically recognizes proper screenplay formatting
#  conventions, and imposes them on the text as such:
#
#  -- Sixteen (16) lines between the top of the page and the TITLE
#  -- TITLE, center-aligned.
#  -- A blank space, the word "by", center-aligned, then another blank space.
#  -- AUTHOR, center-aligned.
#  -- Twenty-two (22) lines of padding.
#  -- The REGISTRATION and AUTHOR INFORMATION blocks, formatted into two columns.
#     -- If included, the REGISTRATION block will appear in the left column, but
#        it's not necessary to include this information.
#     -- The AUTHOR INFORMATION will be left-aligned in the right column.
#
#
