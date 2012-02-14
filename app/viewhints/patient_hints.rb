class PatientHints < Hobo::ViewHints
	
	# model_name "My Model"
	
	field_names :na_sequence => "NAN Sequence"
	
	
	field_names ({
		:date_of_illness => "Date of illness"
	})
	
	field_help ({
		:date_of_illness => "When was the onset of symptoms?"
	})
	
	# field_help :field1 => "Enter what you want in this field"
	# children :primary_collection1, :aside_collection1, :aside_collection2
end
