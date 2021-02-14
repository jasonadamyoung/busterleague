require 'sidekiq/web'
require 'admin_constraint'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/queues', :constraints => AdminConstraint.new

  namespace :draft do

    resources :owners

    resources :teams, :only => [:show, :index]  do
    end

    resources :players, :only => [:show, :index] do
      collection do
        get :wanted
        post :findplayer
        get :setdraftstatus
      end

      member do
        post :draft
        post :removewant
        post :wantplayer
        post :sethighlight
        post :set_draft_owner_rank
        put :setnotes
      end
    end

    resources :ranking_values, :only => [:index,:new,:create,:destroy] do
      collection do
        get :setrv
        get :setor
      end
    end


    resources :stat_preferences do
      collection do
        get :setsp
        get :search
      end
    end


    controller :players do
      get '/players/position/:position', action: 'index', :as => 'position_players'
    end

    resources :stats, :only => [:show, :index] do
      collection do
        get :pitching
        get :batting
      end
    end

    resources :uploads, :only => [:new,:create]

    controller :home do
      simple_named_route 'index'
      simple_named_route 'rounds'
      simple_named_route 'search', via: [:get, :post]
    end

    root :to => 'home#index'

  end


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

  get '/teamlogo/:id/:filename', to: "home#teamlogo", :as => 'teamlogo'
  root :to => 'home#index'

  get '/logout' => 'sessions#end', :as => 'logout'
  match '/login' => 'sessions#start', via: [:get,:post], :as => 'login'
  get '/notice' => 'sessions#notice', :as => 'notice'
  get '/token/:token' => 'sessions#token', :as => 'token'

end
