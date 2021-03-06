class SusceptibilityEntryHints < Hobo::ViewHints

	model_name "Reported resistance"
	
	field_names ({
		:measure => "IC50",
	})
	
	field_help({
		:resistance => "Which drug resistance was assessed and how",
	})
	
  # field_names :field1 => "First Field", :field2 => "Second Field"
  # field_help :field1 => "Enter what you want in this field"
  # children :primary_collection1, :aside_collection1, :aside_collection2
end
