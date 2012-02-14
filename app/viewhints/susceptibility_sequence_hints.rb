class SusceptibilitySequenceHints < Hobo::ViewHints

	model_name "Genotypic analysis"
	model_name_plural "Genotypic analyses"
	
	field_names({
		:title => "Title or ID",
		})

	field_help({
		:title => "Unique or reference identifier (optional)",
	})

end
