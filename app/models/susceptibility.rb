class Susceptibility < ActiveRecord::Base

	hobo_model # Don't put anything above this

	## Db model & relationships:
	fields do
		isolate_name   :string, :required, :unique
		collected      :date
		comment        :text

		timestamps
	end
	
	belongs_to :season
	belongs_to :country
	belongs_to :pathogen_type
	has_many :susceptibility_entries, :dependent => :destroy, :accessible => true
	has_many :susceptibility_sequences, :dependent => :destroy, :accessible => true
	has_many :patients, :limit => 1, :dependent => :destroy, :accessible => true
	
	## Validation:
	# TODO: validate that no resistance or sequence appears twice
	validates_presence_of :season_id 
	validates_presence_of :country_id 
	validates_presence_of :pathogen_type_id
	validates_length_of :patients, :maximum => 1, :message => "only one patient can be attached to a report"

	def validate
		# check for duplicate drug resistances
		res_seen = []
		susceptibility_entries.each { |t|
			if res_seen.member?(t.resistance_id)
				errors.add('susceptibility_entries', 'duplicate resistances')
			else
				res_seen << t.resistance_id
			end
		}
		
		# check for duplicate sequences
		genes_seen = []
		susceptibility_sequences.each { |s|
			if genes_seen.member?(s.gene_id)
				errors.add('susceptibility_sequences', 'duplicate genes')
			else
				genes_seen << s.gene_id
			end
		}
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
	
	## Accessors:
	def name
		return isolate_name
	end

end
