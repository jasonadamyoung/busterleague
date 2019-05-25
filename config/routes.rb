require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/queues', :constraints => AdminConstraint.new

  root :to => 'teams#index'

  resources :owners

  resources :teams, :only => [:show, :index]  do
    collection do
      get :wingraphs
      get :gbgraphs
      get :crash
    end
  end

  resources :players, :only => [:show, :index]
  
  resources :games, :only => [:show, :index]
  resources :boxscores, :only => [:show, :index]
  resources :uploads, :only => [:index,:create]
  resources :stat_sheets, :only => [:index,:create]


  get '/dmb', to: "welcome#dmb", :as => 'dmbexport'
  get '/ss', to: "welcome#ss", :as => 'setseason'

  get '/logout' => 'sessions#end', :as => 'logout'
  match '/login' => 'sessions#start', via: [:get,:post], :as => 'login'
  get '/notice' => 'sessions#notice', :as => 'notice'
  get '/token/:token' => 'sessions#token', :as => 'token'

end
