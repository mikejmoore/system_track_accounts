require_relative "./base_controller"

module Api
  module V1
    class AccountsController < V1::BaseController
      before_filter :user_from_params, except: [:ping]
      before_filter :must_be_super_user, only: [:create]
      skip_before_action :authenticate_token, only: [:ping]
      

      def index
        accounts = []
        if (@user.has_role?("super"))
          accounts = Account.all
        else
          accounts = [@user.account]
        end
        list_hash = []
        accounts.each do |account|
          list_hash << account_to_hash(account)
        end
        render text: list_hash.to_json
      end
      
      def save
        account_hash = params[:account]
        account_id = account_hash['id']
        if (account_id == nil) && (!@user.has_role?("super"))
          raise SystemTrack::NotAuthorizedException.new("Only super user can create accounts")
        end
        
        default_settings = {
              environments: [
                {code: "prod", name: "Production", category: "production"},
                {code: "test", name: "Test", category: "test"}
                ]}
        account = Account.new if (!account_id)
        account = Account.find(account_id.to_i) if (account_id)
        account.name = account_hash["name"]
        account.code = account_hash["code"]
        if (account_hash['settings'])
          account.settings = account_hash['settings'].to_json
        else
          account.settings = default_settings.to_json
        end
        account.save! if (account.name)
        render text: account_to_hash(account).to_json
      end
  
      def find
        account = @user.account
        if (params[:id])
          account_id = params[:id].to_i
          if (@user.has_role?("super")) || (account_id == @user.account.id)
            account = Account.find(account_id)
          end
        end
        render text: account_to_hash(account).to_json
      end
      
      def ping
        render text: {status: "ok"}.to_json
      end
      
      private
      def account_to_hash(account)
        settings = account.settings
        account_hash = JSON.parse(account.to_json)
        account_hash['settings'] = JSON.parse(settings)
        return account_hash
      end
    end
    
  end
end
