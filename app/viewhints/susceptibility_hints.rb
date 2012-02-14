class SusceptibilityHints < Hobo::ViewHints
	
	model_name "Susceptibility entry"
	
	field_help({
		:isolate_name => "Use the WHO standard, e.g.
			A/Baden-Wurttemberg/362/2005",
		:comment => "e.g. how were the results obtained"
	})
	
	children :susceptibility_entries
	
end
