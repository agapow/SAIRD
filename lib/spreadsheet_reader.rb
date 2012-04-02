# Spreadsheet reading and value normalization.
#
module SpreadsheetReader
	
	# The reader should read a row from the passed spreadsheet and pass a hash of
	# value-pairs to a block. It should expect a heading, but must allow for
	# variable order of columns,allow for inconsistencies in naming, translate
	# data into the most appropriate format. allow overriding for specific columns.
	
	# NOTE: doco is a bit sketchy
	# TODO: check file extensions?
	
	
	### IMPORTS
	
	require 'roo'
	require 'pp'
	
	
	### CONSTANTS & DEFINES	
	
	### IMPLEMENTATION ###
	
	# A Excel spreadsheet reader that can clean up column names and convert data.
	#
	# Assumptions: The data is read off the first sheet of the workbook. The sheet
	# has column headers. Column names are cleaned up, so as to tolerate small
	# errors (see "read_headers"). Each row has the same number of entries /
	# columns.
	#
	# This happens Excel95 (xls) and Excel XML (xlsx).
	#
	# @example How to use this class
	#    rdr = XlsReader('my-excel.xls')
	#    rdr.read() { |rec| print rec }
	#
	class ExcelReader
		
		attr_accessor :wbook, :syn_dict, :headers
		
		# Initialise the reader.
		#
		# @param [String] infile   the path to the spreadsheet to be read in.
		# @param [Hash] syn_dict   a remapping of column names, to allow synonyms
		#
		# @example How to create a reader
		#    rdr = XlsReader('my-excel.xls')
		#    rdr = XlsReader('my-excel.xls', {'foo_bar'=> 'foobar'})
		#
		def initialize(infile, file_type)
			pp "path is #{infile}"
			pp file_type
			
			# NOTE: roo insists that files end with the right extension
			tmpfile = Tempfile.new(['excel', ".#{file_type}"])
			tmpfile_hndl = tmpfile.open()
			tmpfile_hndl.write (open(infile, 'r').read)
			tmpfile_hndl.close()
			
			if file_type == 'xls'
				@wbook = Excel.new(tmpfile.path)
			elsif file_type == 'xlsx'
				@wbook = Excelx.new(tmpfile.path)
			else
				raise ArgumentError("unrecognised filetype '#{file_type}'")
			end
			# NOTE: in roo, you don't select a worksheet, you name the current one
			@wbook.default_sheet = wbook.sheets.first
			@syn_dict = {}
		end
		
		# Read the sheet, and return each non-header row to the passed block.
		#
		# This first reads the headers and cleans them up (see "read_headers"). When
		# each row is read, the values are stored in a hash with the cleaned up
		# column names as keys. If a method exists called "method_<key>", this is
		# used to convert the value. Spreadsheet seems to convert floats but dates
		# are returned as Excel serial values.
		#
		# @param [Block] blk  An executable block
		#
		def read(&blk)
			## Preconditions:
			# NOTE: you can't grab a row or just read a line in roo, you have to ask
			# about the bounds and explcitly iter over the cell contents. 
			row_start = @wbook.first_row
			row_stop = @wbook.last_row
			col_start = @wbook.first_column
			col_stop = @wbook.last_column
			if row_start != 1
				raise RuntimeError, "data must start on the first row not #{row_start}"
			end
			if col_start != 1
				raise RuntimeError, "data must start in the first column not #{col_start}"
			end      
			# Main:
			# grab and parse headers
			@headers = read_headers(col_stop)
			# read each row
			(2..row_stop).each { |i|
				row_data = (1..col_stop).collect { |j| @wbook.cell(i,j) }   
				row_zip = @headers.zip(row_data).flatten()
				row_hash = Hash[*row_zip]
				row_hash.each_pair { |k,v|
					meth_name = "convert_#{k}"
					if (self.respond_to?(meth_name))
						row_hash[k] = self.send(meth_name, v)
					else
						row_hash[k] = convert(v)
					end
				}
				blk.call(row_hash)
			}
		end
		
		# Clean up the title of a column to something reasonable
		#
		# If the header is recognised or a synonym, return it in the canonical
		# i.e. a symbol. Otherwise send back the raw form (a string with space
		# stripped from flanks)
		#
		def clean_col_header (hdr)
			# Conversion is:
			# - strip flanking space
			# - convert all internal non-alphanumerics to underscores
			# reduce consequetive underscores to a single one
			# TODO: strip flanking underscores
			clean_str = hdr.downcase.strip.gsub(/\W+/, '_')
			return clean_str.gsub(/_+/, '_')
		end
		
		
		# Return the canonical set of headers.
		#
		# This makes everything lowercase, strips flankning space, and substitutes
		# underscores for spaces. Override to validate or for further process headers.
		#
		def read_headers (col_stop)
			# collect header row
			headers = (1..col_stop).collect { |j|
				@wbook.cell(1,j)
			}
			# drop case, strip flanking spaces, replace gaps with underscores
			return headers.collect { |h|
				raw_val = h.strip()
				h_str = clean_col_header (raw_val)
				@syn_dict.fetch(h_str, raw_val)
			}
		end
		
		# General conversion of spreadsheet cell values 
		#
		def convert(val)
			# clean up strings and return nil for 
			if val.class == String
				val.strip!()
				if ["?", "unknown"].member?(val.downcase())
					return nil
				end
			end
			return val
		end
		
	end
	
end


### END ###