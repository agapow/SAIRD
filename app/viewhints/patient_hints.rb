class PatientHints < Hobo::ViewHints
	
	# model_name "My Model"
	
	field_names ({
		:antivirals => "Exposure to antivirals"
	})
	
	
	field_names ({
		:date_of_illness => "Date of illness onset"
	})
	
	field_help ({
		:date_of_illness => "When were symptoms detected?"
	})
	
	# field_help :field1 => "Enter what you want in this field"
	# children :primary_collection1, :aside_collection1, :aside_collection2
end
