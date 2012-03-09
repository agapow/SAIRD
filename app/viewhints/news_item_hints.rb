class NewsItemHints < Hobo::ViewHints
	
	model_name "News"
	
	field_help({
		:body => "Enter the news item main text here. This supports
			<a href='http://daringfireball.net/projects/markdown/basics'>markdown
			formatting</a>. For example, *emphasized* is <em>emphasized</em> and
			**strong** is <strong>strong</strong>. If in doubt just use plain
			text."
	})
	
end


