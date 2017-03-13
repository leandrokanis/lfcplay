Rails.application.routes.draw do
  get 'team/index'

  root 'team#index'  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
