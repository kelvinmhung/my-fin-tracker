Myapp::Application.routes.draw do

  match 'expenses/import' => 'expenses#import', :as => :import
  resources :expenses
  resources :expenses do
     collection {post :import}
  end

  match 'expenses/import_file' => 'expenses#import_file', :as => :import_file

  authenticated :user do
    root :to => 'expenses#index'
  end
  root :to => "home#index"
  devise_for :users
  resources :users
end