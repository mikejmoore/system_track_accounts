require 'devise'
require_relative '../config/boot'
require_relative '../config/environment'
require "database_cleaner"
#require_relative '../app/models/role'

raise "Cannot load test harness onto production system" if ENV['RAILS_ENV'] == "production"

DatabaseCleaner.clean_with :truncation
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
