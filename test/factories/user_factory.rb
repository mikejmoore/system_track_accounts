FactoryGirl.define do
  factory :user, :class => TestUser do 
    account                { FactoryGirl.create :account }
    first_name             { "#{RandomWord.adjs.next}" } 
    last_name              { "#{RandomWord.nouns.next}" }
    email                  { "#{first_name}.#{last_name}@corp.com" }
    #uid:                   { email }
    plain_password         { "secret123" }
#    password               { User.new.send(:password_digest, plain_password) }
    password               { "secret123" }
    password_confirmation  { password }
    nickname               { RandomWord.nouns.next }
    confirmed_at           { Time.now }
    confirmation_sent_at   { Time.now }
    
    after(:create) do |user|
      user.roles << Role.staff_role
      user.save
    end
    
    factory :super_user do
      
      after(:create) do |user|
        user.roles << Role.super_user_role
        user.save
      end
    end
    
    factory :admin_user do
      
      after(:create) do |user|
        user.roles << Role.account_admin_user_role
        user.save
      end
    end
    
  end
  
end