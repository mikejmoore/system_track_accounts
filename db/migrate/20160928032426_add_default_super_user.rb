class AddDefaultSuperUser < ActiveRecord::Migration
  def change
    account = Account.new
    account.name = "Owner Account"
    account.code = "owner.account"
    account.save!

    super_user = User.new
    super_user.account = account
    super_user.roles << Role.super_user_role
    super_user.first_name = "Super"
    super_user.last_name = "User"
    super_user.email = SystemTrack::TestConstants::SUPER_USER[:email]
    super_user.password = SystemTrack::TestConstants::SUPER_USER[:password]
    super_user.password_confirmation = super_user.password
    super_user.nickname = "super"
    super_user.confirmed_at = 3.days.ago
    super_user.confirmation_sent_at = 3.days.ago
    super_user.save!
  end
  
end
