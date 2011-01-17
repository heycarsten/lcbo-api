class AdminController < ApplicationController

  before_filter :authenticate

  layout 'admin'

  protected

  def cacheable?
    false
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      LCBOAPI[:admin][:username] == username &&
      LCBOAPI[:admin][:password] == password
    end
  end

end
