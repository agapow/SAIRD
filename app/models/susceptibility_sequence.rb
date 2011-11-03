class SusceptibilitySequence < ActiveRecord::Base

	## Model & relations:
	hobo_model # Don't put anything above this
	
	fields do
		title :string
	end
	
	belongs_to :susceptibility
	belongs_to :gene
	has_many :sequence_mutations, :dependent => :destroy, :accessible => true
	
	## Validations:
	def validate
		# check for duplicate sequence mutations
		mutations_seen = []
		sequence_mutations.each { |t|
			if mutations_seen.member?(t.description)
				errors.add('sequence_mutations', 'duplicate mutations')
			else
				mutations_seen << t.description
			end
		}
		
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
