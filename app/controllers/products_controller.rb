class ProductsController < ApplicationController

  def index
    render_query :products, params
  end

  def show
    render_resource Product[params[:id]]
  end

  def revisions
  end

end
