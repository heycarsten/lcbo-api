class InventoriesController < ApplicationController

  def index
    render_query :inventories, params
  end

  def show
    render_query :inventory, params
  end

end
