class NewsItemHints < Hobo::ViewHints

  model_name "News"
  
	field_help({
		:body => '
      Supports markdown formatting (
			*emphasized* = <em>emphasized</em><br />
      	**strong** = <strong>strong</strong><br />).
		Go <a href="http://daringfireball.net/projects/markdown/syntax">here</a>
      for more information.'
	})
	
end


