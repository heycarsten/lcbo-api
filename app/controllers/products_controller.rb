class ProductsController < ApplicationController

  def index
    render_query :products, params
  end

  def show
    render_query :product, params
  end

end
