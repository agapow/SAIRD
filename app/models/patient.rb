class Patient < ActiveRecord::Base

	## Model & relationships:
	hobo_model # Don't put anything above this

	# what can the user do with the country?
	Gender = HoboFields::EnumString.for(:male, :female)
	TriState = HoboFields::EnumString.for(:yes, :no, :unknown)
	AntiviralExposure = HoboFields::EnumString.for(
		:patientTreated, :patientPostExposureProphylaxis,
		:contactTreated, :contactPostExposureProphylaxis,
		:no,
		:unknown,
	)
	Progression = HoboFields::EnumString.for(:complicated, :uncomplicated, :unknown)
	
	fields do
		date_of_birth         :date
		gender                Patient::Gender
		date_of_illness       :date
		location              :string
		vaccinated            Patient::TriState
		antivirals            Patient::AntiviralExposure
		household_contact     Patient::TriState
		disease_progression   Patient::Progression
		disease_complication  :string
		hospitalized          Patient::TriState
		death                 Patient::TriState
		
		timestamps
	end
	
	# belongs_to :resistance, :dependent => :destroy, :accessible => true

	belongs_to :susceptibility
	
	## Validations:
	
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
