require_relative '../spec_helper'


describe "Account", :type => :api do

  context "Create an account" do
    
    it "Can log in as bootstrapped test super user" do
      account = Account.new
      account.name = "Owner Test Account"
      account.code = "owner.account"
      account.save!


      super_user = User.new
      super_user.account = account
      super_user.roles << Role.super_user_role
      super_user.email = "super.user@company.tst"
      super_user.password = "secret123"
      super_user.password_confirmation = super_user.password
      super_user.confirmed_at = Time.now
      super_user.confirmation_sent_at = Time.now
      super_user.save!
      
      credentials = post_sign_in({email: super_user.email, password: "secret123"})
      expect(credentials[:uid]).to_not be nil
      expect(credentials[:client]).to_not be nil
      expect(credentials["access-token"]).to_not be nil
    end
  end

end