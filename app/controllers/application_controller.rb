class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception

  HTTPS = 'https'

  def https?
    return false unless scheme = request.headers['X-Forwarded-Proto']
    return false unless scheme.downcase == HTTPS
    true
  end

  def http?
    !https?
  end
end
