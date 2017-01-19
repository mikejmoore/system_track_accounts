require_relative '../spec_helper'


describe "User services", :type => :api do
  let!(:super_user)  { FactoryGirl.create :super_user}
  let!(:normal_user)  { FactoryGirl.create :user}
  let!(:admin_user)  { FactoryGirl.create :admin_user, account: normal_user.account}

  let!(:acct2_normal_user)  { FactoryGirl.create :user}
  let!(:acct2_admin_user)  { FactoryGirl.create :admin_user, account: acct2_normal_user.account}
  
  context "User information" do
    # it "Test super user - delete" do
    #   user_params = {email: "super.user@company.tst", password: "secret123"}
    #   response = post "/api/v1/auth/sign_in", user_params
    #   expect(response.status).to eq 200
    # end
    
    it "Super user can view user details by providing email" do
      credentials = sign_in(super_user)
      params = {uid: normal_user.email, credentials: credentials}
      response = get "/api/v1/users/find_by_uid", params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      expect(user_json['email']).to eq normal_user.email
      expect(user_json['first_name']).to eq normal_user.first_name
    end
    
    it "Super user can view list of all users" do
      credentials = sign_in(super_user)
      params = {credentials: credentials}
      response = get "/api/v1/users", params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      expect(user_json.select {|u| u['email'] == super_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == normal_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == admin_user.email}.length).to eq 1

      expect(user_json.select {|u| u['email'] == acct2_normal_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == acct2_admin_user.email}.length).to eq 1
    end
    
    it "Super user can view list of users in specific account" do
      credentials = sign_in(super_user)
      params = {credentials: credentials, account_id: normal_user.account.id}
      response = get "/api/v1/users", params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      
      expect(user_json.select {|u| u['email'] == super_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == normal_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == admin_user.email}.length).to eq 1

      expect(user_json.select {|u| u['email'] == acct2_normal_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == acct2_admin_user.email}.length).to eq 0
    end

    it "Admin user can view list of users in own account" do
      credentials = sign_in(admin_user)
      params = {credentials: credentials}
      response = get "/api/v1/users", params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      
      expect(user_json.select {|u| u['email'] == super_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == normal_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == admin_user.email}.length).to eq 1

      expect(user_json.select {|u| u['email'] == acct2_normal_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == acct2_admin_user.email}.length).to eq 0
    end

    it "Admin user cannot view list of users in other account" do
      credentials = sign_in(admin_user)
      params = {credentials: credentials, account_id: acct2_normal_user.account.id}
      response = get "/api/v1/users", params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      
      expect(user_json.select {|u| u['email'] == super_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == normal_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == admin_user.email}.length).to eq 1

      expect(user_json.select {|u| u['email'] == acct2_normal_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == acct2_admin_user.email}.length).to eq 0
    end

    it "Normal user can view list of users from own account" do
      credentials = sign_in(normal_user)
      params = {credentials: credentials, account_id: acct2_normal_user.account.id}
      response = get "/api/v1/users", params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      
      expect(user_json.select {|u| u['email'] == super_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == normal_user.email}.length).to eq 1
      expect(user_json.select {|u| u['email'] == admin_user.email}.length).to eq 1

      expect(user_json.select {|u| u['email'] == acct2_normal_user.email}.length).to eq 0
      expect(user_json.select {|u| u['email'] == acct2_admin_user.email}.length).to eq 0
    end

    
  end
  
  context "User creation" do
    
    it "Super user can create an user for any account" do
      account = FactoryGirl.create :account
      credentials = sign_in(super_user)
      create_params = {
                        user: {
                          account_id: account.id,
                          first_name: RandomWord.nouns.next,
                          last_name: RandomWord.nouns.next,
                          email: "#{RandomWord.nouns.next}@corp.com",
                          password: "secret123"
                          },
                          credentials: credentials
                        }
      response = post "/api/v1/users/save", create_params
      expect(response.status).to eq 200
      user_json = JSON.parse(response.body)
      expect(user_json).to_not be nil
      
      user = User.find_by_email(create_params[:user][:email])
      expect(user).to_not be nil
      expect(user.account.id).to eq account.id

      params = {user: user_json, role: {code: Role::ACCOUNT_ADMIN_CODE}, credentials: credentials}
      response = post "/api/v1/users/add_role", params
      user_json = JSON.parse(response.body)
      admin_roles = user_json['roles'].select {|role|
        role['code'] == Role::ACCOUNT_ADMIN_CODE
      }
      expect(admin_roles.length).to eq 1
    end

    
    it "User can self register and establish account" do 
      create_params = {user: {
                          first_name: RandomWord.nouns.next,
                          last_name: RandomWord.nouns.next,
                          email: "#{RandomWord.nouns.next}@corp.com",
                          password: "secret123"
                          }}
      response = post "/api/v1/users/self_register", create_params
      expect(response.status).to eq 200
      
      response = post "/api/v1/auth/sign_in", {email: create_params[:user][:email], password: create_params[:user][:password]}
      expect(response.status).to eq 200
    end
  end
    
end