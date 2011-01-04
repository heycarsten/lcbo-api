class StoresController < ApplicationController

  def index
    render_query :stores, params
  end

  def show
    render_query :store, params
  end

end
