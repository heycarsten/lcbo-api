class StoresController < ApplicationController

  def index
    render_query :stores, params
  end

  def show
    render_resource Store[params[:id]]
  end

  def revisions
  end

end
