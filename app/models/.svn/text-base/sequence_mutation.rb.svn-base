
# And individual mutation  like 'H275Y'
#
# These do not exist independentally, only when associated with a sequence.
# Their only data is the descriptive string, which is required. They should
# not be empty (undescribed).
#
class SequenceMutation < ActiveRecord::Base
	
	## Model & relations:
	hobo_model # Don't put anything above this
	
	fields do
		description   :string, :required, :limit => 6
		magnitude     :integer, :limit => 3
	end
	
	belongs_to :susceptibility_sequence

	## Validations:
	#validates_numericality_of :magnitude, :greater_than => 1 
	#validates_numericality_of :magnitude, :less_than_or_equal_to => 100
	
	# C
	def clean_description (raw_arg)
		clean_arg = raw_arg.upcase().strip()
		if (clean_arg =~ /^[A-Z]?\d+[A-Z]$/) != 0
			errors.add('description', 'of mutations must be like H275Y, 274X etc.')
		end
		return clean_arg
	end
	
	def clean_magnitude (raw_arg)
		if raw_arg.nil?
			return raw_arg
		elsif (0 < raw_arg) and (raw_arg <= 100)
			return raw_arg
		else
			errors.add('magnitude', 'of mutations must be more than 0 and up to 100%')
			return raw_arg
		end
	end
	
	## Permissions:
	def create_permitted?
		 true
	end
	
	def update_permitted?
		 true
	end
	
	def destroy_permitted?
		 true
	end
	
	def view_permitted?(field)
		 true
	end

end
