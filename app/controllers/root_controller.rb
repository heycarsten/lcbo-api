class RootController < ApplicationController
  clear_respond_to
  respond_to :html

  def ember
    index = Rails.root + 'public/manager/index.html'
    send_file index, type: 'text/html', disposition: 'inline'
  end
end
