class Susceptibility < ActiveRecord::Base

	hobo_model # Don't put anything above this
	
   # add in shared behaviour
   include ExtendedModelMixin
   
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
				errors.add('susceptibility_sequences', 'contains duplicate genes')
			else
				genes_seen << s.gene_id
			end
		}
		
		
		# Check that date falls within season
		if ! season.date_within (collected)
			errors.add('collected', 'date must be within the given season')
		end
		
		# check user has permission for country
		if ! acting_user.nil? 
			if acting_user.guest?
				errors.add('country',
					'you do not have permissions to create records for this or any country')
			elsif (! acting_user.administrator?)
				pp country
				pp acting_user.countries
				if (! acting_user.countries.member? (country))
					errors.add('country',
						'you do not have permissions to create records for this country')
				end
			end
		end
		
	end
	
	#
	
	## Permissions:
	def create_permitted?
		if acting_user.guest?
			return false
		end
		if acting_user.administrator? or (0 < acting_user.user_countries.length)
			return true
		else
			return false
		end
	end

	def update_permitted?
		return create_permitted?()
	end

	def destroy_permitted?
		return create_permitted?()
	end

	def view_permitted?(field)
		if acting_user.guest?
			return false
		end
		if acting_user.administrator?
			return true
		end
		if country.nil? or acting_user.is_country_member?(country)
			return true
		else
			return false
		end
	end
	
	def country_view_permitted?
		true
	end
	
	## Accessors:
	def name
		return isolate_name
	end

	def find_all_permitted
		if acting_user.administrator?
			all
		else
			country_ids = [1, 5]
			scope(:conditions=>{:country_id => country_ids})
			
		end
	end
	
end
