#!/usr/bin/ruby1.8
      
#= Aargvark
#  Version 0.0.2
#  Updated 2009-05-05
#  
#  Maintainer: Mike Zazaian, mike@zop.io, http://zop.io
#  License:  This file is placed in the public domain.
#
#  Aargvark is a utility written in Ruby to process arguments for command-line
#  scripts and applications
#


module Aargvark

  def Aargvark.matches(args, all_args)
    matches = {}
    all_args.each do |i|
      if args.index(i)
        if all_args.index(args[args.index(i) + 1])
          matches[args[args.index(i)]] = true
        else
          matches[args[args.index(i)]] = args[args.index(i) + 1]
        end
      end
    end
    
    if matches.size > 0
      return matches
    else
      return nil
    end
  end

end
