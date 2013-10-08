module ApplicationHelper
	def full_title(page)
		base_title= "Ruby on Rails Tutorial Sample App"
		if page.empty?
			base_title
		else
			"#{base_title} | #{page}"
		end
	end
end
