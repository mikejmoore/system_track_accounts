class User < ActiveRecord::Base
  include UserLogic
  
  belongs_to :account
  has_and_belongs_to_many :roles
  has_many :ssh_keys
  
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable, :omniauthable
  include DeviseTokenAuth::Concerns::User
  
  
end
