class ApplicationController < ActionController::Base

  layout 'application'

  rescue_from Ohm::Model::MissingID, :with => :not_found

  private

  def not_found
    render 'public/404.html', :status => 404
  end

end
