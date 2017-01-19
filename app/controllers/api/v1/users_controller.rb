require_relative "./base_controller"
require 'digest'

module Api
  module V1

    class UsersController < V1::BaseController
      before_filter :user_from_params, except: [:self_register, :find_ssh_key, :self_register]
      skip_before_action :authenticate_token, only: [:self_register, :find_ssh_key]
#      before_filter :user_from_params, only: [:add_role, :create, :find_by_uid, index]
      

      def index
        account_id = params[:account_id]
        account_id = account_id.to_i if (account_id)
        users = []
        if (@current_user.is_super_user?)
          if (account_id)
            users = User.where(account_id: account_id)
          else
            users = User.all
          end
        else
          users = User.where(account_id: @current_user.account.id)
        end
        render text: users.to_json
      end
      
      def save
        item_json = params[:user]
        user_email = item_json[:email]
        account_id = item_json[:account_id].to_i
        account = Account.find(account_id)
        user = User.find_by_email(user_email)
        if (user != nil)
          render text: {message: "Email already belongs to a user"}.to_json, status: 400
        else
          user = User.new
          user.account = account
          user.first_name = item_json["first_name"]
          user.last_name = item_json["last_name"]
          user.email = user_email
          user.password = item_json["password"]
          user.password_confirmation = item_json["password"]
          user.confirmed_at = 0.days.ago
          user.confirmation_sent_at = 0.days.ago
          user.roles << Role.staff_role
          user.save!
        end
        json = user.to_json(:include=> [:roles])
#        json['roles'] = user.roles.to_json
        render text: json
      end
  
      def find_by_uid
        user = User.find_by_email(params[:uid])
        user_json = user.to_json(:include=> [:roles])
        render text: user_json
      end
  
      def show
        user = User.find(params[:id].to_i)

        if (@user.has_role?(Role::SUPER_USER_CODE))
          # OK
        elsif (user.account.id == @user.account.id)
          # OK
        else
          raise NotAuthorizedException.new
        end
        
        render text: user.to_json(:include=> [:roles])
      end
      
      def self_register
        email = params[:user][:email]
        user = User.find_by_email(email)
        if (user != nil)
          render text: {message: "Email in use"}, status: 400
        end
        
        user = User.new
        user.email = email
        user.first_name = params[:user][:first_name]
        user.last_name = params[:user][:last_name]
        user.password = params[:user][:password]
        user.password_confirmation = user.password
        user.confirmed_at  = Time.now
        user.roles << Role.staff_role
        user.roles << Role.account_admin_user_role
        user.confirmation_sent_at = Time.now
        

        account = Account.new
        account.name = user.email
        account.code = user.email
        account.save!
        user.account = account
        user.save!
        
        render text: user.to_json(:include=> [:roles])
      end
      
      def add_role
        role_code = params[:role][:code]
        role = Role.find_by_code(role_code)
        user = User.find_by_email(params[:user][:email])
        raise NotAuthorizedException.new("User must be account admin or super user") if (!current_user_can_admin?(user.account.id))
        user.roles << role
        
        render text: user.to_json(:include=> [:roles])
      end
      
      def add_ssh_key
        user_id = params[:user_id].to_i
        public_key = params[:ssh_key][:public_key]
        user = User.find(user_id)
        
        public_key_hash = CryptUtils.sha_hash_hex(public_key)
                
        ssh_key = SshKey.find_by_public_key_hash(public_key_hash)
        ssh_key = SshKey.new if (!ssh_key)
        ssh_key.user = user
        ssh_key.public_key = public_key
        ssh_key.public_key_hash = public_key_hash
        ssh_key.code = params[:ssh_key][:code]
        ssh_key.save!
        
        render text: ssh_key.to_json
      end
      
      def find_ssh_key
        public_key_hash = params[:public_key_hash]
        ssh_key = SshKey.find_by_public_key_hash(public_key_hash)
        
        user = ssh_key.user
        account = user.account
        return_data = {public_key: ssh_key.public_key, user: {email: user.email, id: user.id}, account: {id: account.id}}
        render text: return_data.to_json
      end
      
      def remove_ssh_key
        user_id = params[:user_id].to_i
        ssh_key_id = params[:ssh_key_id].to_i
        ssh_key = SshKey.find(ssh_key_id)
        ssh_key.destroy
        render text: {message: "SSH Key deleted"}.to_json
      end
      
      private 
      
      
      def current_user_can_admin?(account)
        raise "current user not detected" if (!@current_user)
        return (@current_user.is_super_user?) || ((@current_user.account.id == account.id) && (@current_user.is_admin?))
      end
      
    end
    
    
  end
end