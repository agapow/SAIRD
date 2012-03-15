#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Tool for graphing susceptibility data.

### IMPORTS


### IMPLEMENTATION

module ToolForms

	# Just a way of encapsulating different results that tools may return
	#
	# Note that we don
	class BaseToolResult
		attr_accessor :content
		
		def initialize (content)
			@content = content
		end
		
	end

	class ImageResult < BaseToolResult
		attr_accessor :caption
		
		def initialize (content, kwargs={})
	      ## Preconditions:
	      opts = OpenStruct.new({
	         :caption => nil,
	      }.merge(kwargs))
	      
	      ## Main:
			super(content)
			@caption = opts.caption
		end
		
	end
end


### END
