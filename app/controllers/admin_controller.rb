class AdminController < ApplicationController

  layout 'admin'

  def cacheable?
    false
  end

end
