require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/queues', :constraints => AdminConstraint.new

  root :to => 'welcome#home'

  resources :owners

  # resources :teams, :only => [:show, :index]  do
  #   collection do
  #     get :wingraphs
  #     get :gbgraphs
  #     get :crash
  #   end
  # end
  
  resources :games, :only => [:show, :index] do
    collection do 
      get :batting
    end
  end

  resources :boxscores, :only => [:show, :index]
  resources :uploads, :only => [:index,:create]
  resources :stat_sheets, :only => [:index,:create]

  scope "/(:season)", :defaults => {:season => 'all'} do
    resources :standings, :only => [:index]
    resources :dmbexport, :only => [:index]
    resources :players, :only => [:show, :index]   
    resources :teams, :only => [:show, :index]  do
      member do 
        get :playingtime
      end
      collection do
        get :playingtime
        get :wingraphs
        get :gbgraphs
      end
    end
    resources :leaders, :only => [:index] do
      collection do
        get :batting
        get :pitching
      end
    end
  end

  get '/teamlogo/:id/:filename', to: "welcome#teamlogo", :as => 'teamlogo'
  
  get '/ss', to: "welcome#ss", :as => 'setseason'

  get '/logout' => 'sessions#end', :as => 'logout'
  match '/login' => 'sessions#start', via: [:get,:post], :as => 'login'
  get '/notice' => 'sessions#notice', :as => 'notice'
  get '/token/:token' => 'sessions#token', :as => 'token'

end
