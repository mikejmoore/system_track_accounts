require_relative "../../application_controller"

class Api::V1::BaseController < ApplicationController
  before_action :authenticate_token
  
  
end