# SYSTEM_TRACK_SHARE_REQUIRE = "require 'system_track_shared'"
# eval(SYSTEM_TRACK_SHARE_REQUIRE)

class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken
  include SystemTrack::ApplicationControllerModule
  
  
  before_action :log_request_info
  before_action :configure_permitted_parameters, if: :devise_controller?  
  before_action :destroy_session
  
  rescue_from Exception do |exception|
    api_exception_handler(exception)
  end  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from SystemTrack::TokenAuthException, with: :token_auth_error
  rescue_from SystemTrack::NotAuthorizedException, with: :unauthorized_error
  
  protected

  def log_request_info
    # Rails.logger.info "Rails env: "
    #
    # Rails.logger.info "HEADERS: "
    # request.headers.env.keys.sort.each do |header_name|
    #  if (header_name.match("^HTTP.*"))
    #      Rails.logger.info "#{header_name} = #{request.env[header_name].to_s.truncate(50)}"
    #       puts "#{header_name} = #{request.env[header_name].to_s.truncate(50)}"
    #  end
    # end
  end

  def not_found
    render :text => 'Not found', status: 404
  end
  
  def unauthorized_error
    render :text => "User authorization with token failed", :status => 401
  end

  def token_auth_error
    render :text => "User authorization with token failed", :status => 401
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :email) }
  end

  def destroy_session
    request.session_options[:skip] = true
  end
  
  def authenticate_token
    raise "No credentials passed for authentication" if (!params[:credentials])
    user = User.find_by_email(params[:credentials][:uid])
    if (!user.valid_token?(params[:credentials]["access-token"], params[:credentials]["client"]))
      raise TokenAuthException.new("Token authentication failed")
    end
  end
  
  def user_from_params
    raise "Cannot find user because credentials were not supplied" if (!params[:credentials])
    user_email = params[:credentials][:uid]
    @user = User.find_by_email(user_email)
    @current_user = @user
  end
  
  def must_be_super_user
    @user = User.find_by_email(params[:credentials][:uid])
    raise NotAuthorizedException.new if (!@user.has_role?("super"))
  end
  
end
