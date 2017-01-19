require_relative '../spec_helper'


describe "Account", :type => :api do
  let!(:super_user)  { FactoryGirl.create :super_user}
  let!(:normal_user)  { FactoryGirl.create :user}
  

  context "Create an account" do
    
    it "Super user can create an account" do
      account_in = {name: "My Account", code: "account.1"}
      
      expect(super_user.has_role?("super")).to eq true
      credentials = sign_in(super_user)
      response = post "/api/v1/accounts/save", {account: account_in, credentials: credentials}
      expect(response.status).to eq 200
      
      account = Account.find_by_code("account.1")
      expect(account).to_not be_nil
      expect(account.name).to eq account_in[:name]
    end

    it "Non-super user cannot create an account" do
      expect(normal_user.has_role?("super")).to eq false
      credentials = sign_in(normal_user)
      account_in = {account: {name: "My Account", code: "account.1"}}
      
      response = post "/api/v1/accounts/save", {account: account_in, credentials: credentials}
      expect(response.status).to eq 401
    end
    
    it "Account is created with default settings, including environments" do
      account_in = {name: "My Account", code: "account.1"}
      
      expect(super_user.has_role?("super")).to eq true
      credentials = sign_in(super_user)
      response = post "/api/v1/accounts/save", {account: account_in, credentials: credentials}
      expect(response.status).to eq 200
      account = JSON.parse(response.body)

      expect(account['settings']).to_not be nil
      settings = account['settings']
      expect(settings['environments']).to_not be nil
      expect(settings['environments'].length).to eq 3
      expect(settings['environments'].first['code']).to_not be nil
      expect(settings['environments'].first['name']).to_not be nil
      expect(settings['environments'].first['category']).to_not be nil
    end
    
    
  end
    
  context "View account details" do
    it "Can view an account's details" do
      credentials = sign_in(super_user)
      
      account = FactoryGirl.create :account
      response = get "/api/v1/accounts/#{account.id}", {credentials: credentials}
      expect(response.status).to eq 200
      response_json = JSON.parse(response.body)
      expect(response_json["name"]).to eq account.name
      expect(response_json["code"]).to eq account.code
      
      expect(account['settings']).to_not be nil
      settings = JSON.parse(account['settings'])
      expect(settings['environments']).to_not be nil
      expect(settings['environments'].length).to eq 3
      
    end

    it "Non-super user can view own account's details" do
      credentials = sign_in(normal_user)
      account = normal_user.account
      response = get "/api/v1/accounts/#{account.id}", credentials: credentials
      expect(response.status).to eq 200
      response_json = JSON.parse(response.body)
      expect(response_json["name"]).to eq account.name
      expect(response_json["code"]).to eq account.code
    end

    it "Non-super user cannot view other accounts" do
      user = normal_user
      credentials = sign_in(user)
      
      account = FactoryGirl.create :account
      response = get "/api/v1/accounts/#{account.id}", credentials: credentials
      expect(response.status).to eq 200
      account_json = JSON.parse(response.body)
      expect(account_json['id']).to_not eq account.id
      expect(account_json['id']).to eq user.account.id
    end
  end
  
  context "View list of accounts" do  
    it "Super user can view all accounts" do
      accounts = []
      (1..5).each do |i|
        accounts << FactoryGirl.create(:account)
      end
      credentials = sign_in(super_user)
      response = get "/api/v1/accounts/list", {credentials: credentials}
      expect(response.status).to eq 200
      accounts_json = JSON.parse(response.body)
      accounts.each do |account|
        found_account_json = accounts_json.find {|a| a["code"] == account.code}
        expect(found_account_json).to_not be nil
      end
    end

    it "Non super user can only see own account" do
      accounts = []
      (1..5).each do |i|
        accounts << FactoryGirl.create(:account)
      end
      credentials = sign_in(normal_user)
      response = get "/api/v1/accounts/list", credentials: credentials
      expect(response.status).to eq 200
      accounts_json = JSON.parse(response.body)
      accounts.each do |account|
        found_account_json = accounts_json.find {|a| a["code"] == account.code}
        expect(found_account_json).to be nil
      end
      
      found_account_json = accounts_json.find {|a| a["code"] == normal_user.account.code}
      expect(found_account_json).to_not be nil
    end
    
  end

end