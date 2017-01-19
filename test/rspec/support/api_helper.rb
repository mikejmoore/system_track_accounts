module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end
  
  def set_user_password(user, password)
    user.password = password
    user.password_confirmation = password
    user.save
    return user
  end
  
  def credentials_from_response(response)
    uid = response.headers['uid']
    token = response.headers['access-token']
    client = response.headers['client']
    return {credentials: {uid: uid, 'access-token' => token, client: client}}
  end
  
  def sign_in(user)
    params = { 
      email: user.email,
      password: user.plain_password
    }
    return post_sign_in(params)
  end
  
  def post_sign_in(user_params)
    response = post "/api/v1/auth/sign_in", user_params
    expect(response.status).to eq 200
    credentials = credentials_from_response(response)
    return credentials[:credentials]
  end
    
end



RSpec.configure do |config|
  config.include ApiHelper, :type=>:api #apply to all spec for apis folder
end