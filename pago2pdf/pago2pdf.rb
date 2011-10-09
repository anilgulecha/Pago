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


$LOAD_PATH << './lib'
require 'rubygems'
require 'pdf/writer'
require 'aargvark'

AllArgs = %w{-t }
Args = Aargvark.matches(ARGV, AllArgs)

if ARGV.size == 0
  raise ArgumentError, "Please enter the location of the text document you'd like to convert."
elsif ARGV.size > 2
  raise ArgumentError, "Pago2PDF allows you to convert only one document at a time."
else
  $pago_file = ARGV[0]
  $title_page = ARGV[1]
end

# Check whether the pago document exists
unless File.exist?($pago_file)
  raise ArgumentError, "The pago document that you attempted to convert does not seem to exist.\n" +
                       "Please check the filename and try again."
end

# If a title page was included, check whether it exists#
if $title_page
  unless File.exist?($title_page)
    raise ArgumentError, "The title_page file that you indicated does not seem to exist.\n" +
                         "Please check the filename and try again."
  end
end


class PagoPDF
  attr_accessor :file, :blocks, :title_page, :tp_blocks, :title, :author, :contact, :font, :x_margin,
                :y_margin, :line_count, :page_count

  def initialize(title_page=nil, font="Courier", x_margin = 0.4, y_margin = 1.1)
    @file = PDF::Writer.new
    @file.compressed = true
    @font = font
    @x_margin = PDF::Writer.in2pts(x_margin)
    @y_margin = PDF::Writer.in2pts(y_margin)
    @file.margins_pt(@x_margin, @y_margin)
    if @font != "Courier"
      PDF::Writer::FONT_PATH << "./fonts"
      PDF::Writer::FontMetrics::METRICS_PATH << "./fonts"
    end
    @file.select_font @font
    @file.text("\n")
    
    @blocks = []
    @blocks = File.read($pago_file).gsub(/\302/,"").gsub(/\240/," ").split(/[\n|\r]{2}/).collect {|b| Block.new(b)}
    @line_count = 0
    @page_count = 1

    @title_page = title_page    
    if @title_page
      @tp_blocks = File.read(title_page).split(/[\n|\r]{2,}/)
      @title = @tp_blocks[0]
      @author = @tp_blocks[1]
      @contact = @tp_blocks[@tp_blocks.size - 1]
      unless @contact
        raise "You did not include contact information in the file for your title page.\n" +
               "Please add your contact information to your title page file, or run the\n" +
               "script with the --no-contact-info option to ignore this warning"
      end
    
      create_title_page
    end
  end

  def create_title_page 
    from_top = "\n" * 16
    #Add 16 lines at the top of the page
    @file.text(from_top)
    @file.text(@title, :font_size => 12, :justification => :center)
    @file.text("\nby\n\n", :font_size => 12, :justification => :center)
    @file.text(@author, :font_size => 12, :justification => :center)
    @file.text("\n" * 22)
    if @tp_blocks[3]
      @file.start_columns(2,20)
      @file.text(@tp_blocks[2], :font_size => 12, :left => 32, :justification => :left)
      @file.start_new_page
      @file.text(@tp_blocks[3], :font_size => 12, :justification => :left)
      @file.stop_columns
    else
      shift_right = PDF::Writer.in2pts(3.2)
      @file.text(@tp_blocks[2], :font_size => 12, :left => shift_right)
    end
    @file.start_new_page
  end
  
  def number_page
    if @page_count > 1
      page_number_line = "#{@page_count.to_s}.  \n\n\n"
      @file.text(page_number_line, :font_size => 12, :justification => :right)
    end
  end

  def publish 
    #if there's a title page, take the filename from the title of the screenplay,
    #otherwise strip the base of the filename from the original Pago file.
    filename = @title_page ? @title.downcase.gsub(/(\s)+/,"\_") : $pago_file.gsub(/\.(\w)+$/,"") 
    File.open(filename + ".pdf", "wb") { |f| f.write @file.render }
  end
  
  class Block
    attr_accessor :lines

    def initialize (text_block)
      if text_block.class == String
        @lines = text_block.split(/\n/).collect {|l| l.gsub(/^          /,"").rstrip }
      elsif text_block.class == Array
        @lines = text_block
      end
    end

    def type
      if @lines[0].scan(/^                    [A-Z]+/).size > 0
        return :dialogue
      elsif @lines[0].scan(/^(INT\.|EXT\.|INT\/EXT\.)/).size > 0
        return :heading
      elsif @lines[0].scan(/^s+[A-Za-z\ ]+\:$/).size > 0
        return :transition
      else
        return :action
      end
    end

    def divide(over, type)
      start_at = @lines.size - over
      start_at.times do |n|
        #find the last line in the block that has a period
        inspect_line = start_at - n - 1
        @lp_pos = @lines[inspect_line].rindex(/([^\.A-Z]\.(?![A-Z\.\,]))|\.\"|\?\"?|\!\"?|([A-Z]?[\.]?[^A-Z][^\.][^A-Z][\.]\"?[^\,])/)
        @lp_line = inspect_line
        if @lp_pos
          @lp_pos += 1
          break
        end
      end

      def wrap(txt, col = 80)
        txt.gsub(/(.{1,#{col}})( +|$\n?)|(.{1,#{col}})/,
          "\\1\\3\n") 
      end

      if @lp_pos
        second_block = @lines
        first_block = second_block.slice!(0..@lp_line)
        rest_of_line = first_block[@lp_line]
        beg_of_line = rest_of_line.slice!(0..@lp_pos)
        first_block.slice!(@lp_line)
        first_block.push(beg_of_line)
        second_block.insert(0, rest_of_line.sub(/(\s)+$/," "))

        col = case type
          when :dialogue
            35
          else
            60
        end
        
        second_block_text = second_block.collect {|l| l.lstrip.rstrip }.join(" ")
        # If the carry-over block has parentheticals, split them out,
        # wrap the text between them, rejoin them, and split the array back into
        # lines
        if second_block_text.scan(/\([A-Za-z\ \,\'\-]+\)/) && type == :dialogue
          text_bits = second_block_text.split(/\([A-Za-z\ \,\'\-]+\)/).collect {|t| t.rstrip }
          paren_bits = second_block_text.scan(/\([A-Za-z\ \,\'\-]+\)/)
          text_bits.collect! {|t| wrap(t, col) }
          paren_bits.collect! {|p| wrap(p, 30) }
          second_block = []
          text_bits.size.times do |n|
            second_block << text_bits[n].split(/\n/)
            second_block << paren_bits[n].split(/\n/).collect {|pl| "      #{pl}"} if paren_bits[n]
          end
          second_block.flatten!
        else
          second_block = wrap(second_block_text, col).split("\n")
        end

        if type == :dialogue
          second_block.collect! {|l| "          #{l}"}
          character_line = "#{first_block[0]} (cont'd)"
          second_block.insert(0, character_line)
          catch_block = []
          second_block.size.times do |l|
            x = l - 1
            if second_block[x].scan(/\([A-Za-z\ \,\'\-]+\)/) && x >= 0
              catch_block << second_block[l].gsub!(/^           /,"          ")
            else
              catch_block << second_block[l]
            end
          end
          first_block.push("                    (MORE)")
        end
        
        first_block = Block.new(first_block)
        second_block = Block.new(second_block)

        return [first_block, second_block]
      else
        return [Block.new(@lines)]
      end
    end


    def printable
      @lines.join("\n") + "\n\n"
    end

    def size
      @lines.size
    end
  end
  
end

# pdf.start_page_numbering(50, 50, 12, :right, pattern = nil, 2)
pdf = PagoPDF.new($title_page)

#Process blocks
pdf.blocks.each do |block|
  
  #Add page number
  if pdf.line_count == 0
    pdf.number_page
  end

  if block.size + pdf.line_count <= 53
    if block.type == :heading && pdf.line_count != 0
      print_block = "\n" + block.printable
      pdf.line_count += 1
    else
      print_block = block.printable
    end

    pdf.line_count += block.size + 1
    pdf.file.text(print_block, :font_size => 12) unless pdf.line_count > 51 && block.type == :heading
    
    if pdf.line_count > 51 && block.type == :heading
      pdf.file.start_new_page
      pdf.page_count += 1
      pdf.number_page
      pdf.file.text(block.printable, :font_size => 12)
      pdf.line_count = block.size + 1
    elsif pdf.line_count == 53
      pdf.file.start_new_page
      pdf.line_count = 0
      pdf.page_count += 1
    end
  else
    pdf.page_count += 1
    over = block.size + pdf.line_count - 53
    if over <= 2 && block.size <= 2
      pdf.file.start_new_page
      pdf.number_page
      pdf.line_count = 0 + block.size + 1
      pdf.file.text(block.printable, :font_size => 12)
    else
      new_blocks = block.divide(over, block.type)
      #need to insert the part that re-justifies the
      
      if new_blocks.size == 1
        pdf.file.start_new_page
        pdf.number_page
        pdf.line_count = 0 + new_blocks[0].size + 1
      end      
      pdf.file.text(new_blocks[0].printable, :font_size => 12)
      
      if new_blocks.size > 1
        pdf.file.start_new_page
        pdf.number_page
        pdf.file.text(new_blocks[1].printable, :font => 12)
        pdf.line_count = 0 + new_blocks[1].size + 1
      end
    end
  end  

end

# Create the pdf file
pdf.publish
