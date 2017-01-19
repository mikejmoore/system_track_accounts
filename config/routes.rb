Rails.application.routes.draw do
  
  devise_for :users
  #get  '/api/v1/exports/hosts' => '/api/v1/ho#hosts'
  get "/ping" => "api/v1/accounts#ping"
  
  post "/api/reset_test_data" => 'api/tests#reset_test_data'
  get  "/api/v1/accounts/list", to: "api/v1/accounts#index"
  post "/api/v1/accounts/save"
  get  '/api/v1/accounts/:id', to: 'api/v1/accounts#find'
  
  get  '/api/v1/user/:id', to: 'api/v1/users#show'
  get  '/api/v1/users', to: "api/v1/users#index"
  get  '/api/v1/users/find_by_uid', to: "api/v1/users#find_by_uid"
  post '/api/v1/users/self_register', to: 'api/v1/users#self_register'
  post '/api/v1/users/save', to: 'api/v1/users#save'
  post '/api/v1/users/add_role', to: 'api/v1/users#add_role'
  delete '/api/v1/users/remove_role', to: 'api/v1/users#remove_role'
  
  delete '/api/v1/users/remove_ssh_key', to: 'api/v1/users#remove_ssh_key'
  post '/api/v1/users/add_ssh_key', to: 'api/v1/users#add_ssh_key'
  get '/api/v1/users/find_ssh_key', to: 'api/v1/users#find_ssh_key'
  
  post '/test/reset', to: 'api/tests#reset'
  
  namespace :api do
    scope :v1 do
        mount_devise_token_auth_for "User", at: 'auth'

        as :user do
          # Define routes for api_user within this block.
        end
    end
      
  end
end
