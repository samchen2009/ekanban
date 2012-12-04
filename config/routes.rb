# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

RedmineApp::Application.routes.draw do
	resources :projects do
		resources  :kanbans do
			resources :kanban_panes do
				resources :kanban_cards
			end
		end
	end
end
