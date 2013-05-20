Myapp::Application.routes.draw do
  resources :expenses
  resources :expenses do
     collection {post :import}
  end

  authenticated :user do
    root :to => 'expenses#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end