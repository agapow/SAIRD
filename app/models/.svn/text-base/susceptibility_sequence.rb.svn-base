class SusceptibilitySequence < ActiveRecord::Base

	## Model & relations:
	# don't put anything above this
	hobo_model
	
	Assay = HoboFields::EnumString.for(:sequencing, :pyrosequencing,
		:snpPcr, :other)
	
	fields do
		title         :string
		assay         SusceptibilitySequence::Assay
		assay_other   :string
	end
	
	belongs_to :susceptibility
	belongs_to :gene
	has_many :sequence_mutations, :dependent => :destroy, :accessible => true
	
	## Validations:
	
	def clean_assay_other (raw_arg)
		if raw_arg == ''
			return nil
		else
			return raw_arg
		end
	end
	# Check that there are no (exact) duplicate mutations and that an "other"
	# description is only provided if assay type is other
	def clean_all (raw_args)
		# check for duplicate sequence mutations
		#sequence_mutations = raw_args[:sequence_mutations]
		mutations_seen = []
		sequence_mutations.each { |t|
			if mutations_seen.member?(t.description)
				errors.add('sequence_mutations', 'contains duplicates')
			else
				mutations_seen << t.description
			end
		}
		
		if ((! raw_args['assay_other'].nil?) and (raw_args['assay'] != 'other'))
			errors.add('assay_other', "should only be provided if assay type is
				marked as 'other'")
		end
	end
	
	## Permissions
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
	
	## Accessors:
	def name
		return "%s %s" % [
			gene.name,
			title
		]
	end

end
