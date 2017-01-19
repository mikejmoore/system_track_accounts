require_relative '../spec_helper'


describe "Special interface for testing", :type => :api do

  context "Ability to reset data in test/development database" do
    
    it "Can find my machines" do
      session = {}
      response = post "/test/reset", {}
      expect(response.status).to eq 200
      
      super_user = User.find_by_email SystemTrack::TestConstants::SUPER_USER[:email]
      expect(super_user).to_not be nil
      
    end
  end
  
end