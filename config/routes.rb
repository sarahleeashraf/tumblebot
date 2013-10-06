Thing::Application.routes.draw do
  resources :blogs do
    collection do
      get 'authorize'
    end
  end
end
