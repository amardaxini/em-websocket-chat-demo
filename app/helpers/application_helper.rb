module ApplicationHelper
	def clearing_span
		content_tag(:span, '', :class => 'clear')
	end
	def title(text)
		content_tag(:h1,text,:class=>'page-title')
	end
	# Returns true if sidebar disabled for current page/controller
	def sidebar_enabled?
		current_page = "#{controller.controller_name}.#{controller.action_name}"
		current_controller = controller.controller_name
		pages = %w()

		return pages.include?(current_page) || pages.include?(current_controller)
	end
	def main_content_css_class
		sidebar_enabled? ? "grid_12" : "grid_16"
	end

	# Returns the CSS class for the 'sidebar' div depending on sidebar requirement
	def sidebar_css_class
		sidebar_enabled? ? "grid_4" : "dont-show"
	end

	def active_class
		classes = {
						'home' => 'home',
						"chat.index" => 'chat',
						"registrations.edit" =>'home',
						"registrations.new" =>'register',
						"sessions.new"=>"login"
		}
		#debugger
		classes[controller.controller_name + '.' + controller.action_name] || classes[controller.controller_name] || ''
	end
end
