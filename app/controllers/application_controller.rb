class ApplicationController < ActionController::Base

  layout 'application'

  private

  def not_found
    render 'public/404.html', :status => 404
  end

end
