

# A set of thresholds entries for several drugs for a given season.
#
# This would be better called a "Season threshold" as it is for for a given
# season, country & virus type.
#
class Threshold < ActiveRecord::Base
	
	hobo_model # Don't put anything above this
	
   # add in shared behaviour
   include ExtendedModelMixin
   
	## Fields & relationships:
	fields do
		description :text
		
		timestamps
	end
		
	# XXX: shoudl these be checked with :after_add, :conditions
	belongs_to :season
	belongs_to :country
	belongs_to :pathogen_type
	
	has_many :thresholdentries, :dependent => :destroy, :accessible => true
	
	## Validations:
	validates_presence_of :season_id
	validates_presence_of :country_id
	validates_presence_of :pathogen_type_id
	
	validates_uniqueness_of(:pathogen_type_id, :scope => [
			:country_id,
			:season_id,
		],
		:message => 'is already in our database for this season and country.'
	)

	def validate
		res_seen = []
		thresholdentries.each { |t|
			if res_seen.member?(t.resistance_id)
				errors.add('thresholdentries', 'duplicate resistances')
			else
				res_seen << t.resistance_id
			end
		}
		
		# check user has permission for country
		# because validate is sometimes called without a user, we test for this
		if ! acting_user.nil? 
			if acting_user.guest?
				errors.add('country',
					'you do not have permissions to create records for this or any country')
			elsif (! acting_user.administrator?)
				if (! acting_user.countries.member? (country))
					errors.add('country',
						'you do not have permissions to create records for this country')
				end
			end
		end
		
	end

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
		#return "#{virus_type.name} #{season.name} (#{country.name})"

		name_parts = []
		if ! pathogen_type.nil? then name_parts << pathogen_type.name end
		if ! season.nil? then name_parts << season.name end
		if ! country.nil? then name_parts << "(#{country.name})" end

		if 0 < name_parts.length
			return name_parts.join(' ')
		else
			return "No name (FIXME)"
		end
	end

end
