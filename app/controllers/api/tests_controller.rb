require_relative "../application_controller"

module Api
  class TestsController < ApplicationController
    def reset
      if (ENV['RAILS_ENV'] == "development") || (ENV['RAILS_ENV'] == "test")
        require "database_cleaner"
        DatabaseCleaner.clean_with :truncation
        Role.create_standard_roles

        account = Account.new
        account.name = SystemTrack::TestConstants::MAIN_ACCOUNT[:name]
        account.code = SystemTrack::TestConstants::MAIN_ACCOUNT[:code]
        account.save!


        super_user = User.new
        super_user.account = account
        super_user.roles << Role.super_user_role
        super_user.first_name = "Super"
        super_user.last_name = "User"
        super_user.nickname = "super"
        super_user.email = SystemTrack::TestConstants::SUPER_USER[:email]
        super_user.password = SystemTrack::TestConstants::SUPER_USER[:password]
        super_user.password_confirmation = SystemTrack::TestConstants::SUPER_USER[:password]
        super_user.confirmed_at = Time.now
        super_user.confirmation_sent_at = Time.now
        super_user.save!
      else
        raise "Cannot set up test data in production"
      end
      render text: super_user.to_json
    end
  end
    
end