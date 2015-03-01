class AdminController < ApplicationController
  before_action :authenticate

  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      Rails.application.secrets.admin_username == username &&
      Rails.application.secrets.admin_password == password
    end
  end
end
