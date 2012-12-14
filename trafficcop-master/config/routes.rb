Trafficcop::Application.routes.draw do

  resources :leads
  #not sure what these are, check with shirlee
  get '/adcreative-local' => 'leads#adcreative-local', :as => :creatives
  get '/adcreative-staging' => 'leads#adcreative-staging', :as => :creatives
  get '/adcreative-production' => 'leads#adcreative-production', :as => :creatives

  resources :zip_codes do
    collection do
      match 'show_by_zip/:zip_code/parties' => 'parties#index'
    end
    resources :parties
  end
 
  get '/adwords/new_estimation' 
  resources :adwords do
    member do 

    end
  end

  resources :line_items
 
  
#  resources :buyer_leads_zip_codes do 
#    collection do 
#      get "estimate_zips"
#    end
#  end

  get "/buyer_leads_zip_codes/estimate_zips" 
#  get "/parties/purchase" 
  resources :parties do
    resources :buyer_leads_zip_codes do 
#      collection do 
#        get "estimate_zips"
#      end
    end
  end
  
  match '/auth/admin/callback', to: 'sessions#authenticate_admin'
  
  constraints :subdomain => 'admin' do
    scope :module => 'admin', :as => 'admin' do
      root :to => 'users#index'
      resources :users
    end
  end
    
  get "main/index"
  
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'main#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
