class ProductsController < ApplicationController

  def index
    render_query :products, params
  end

  def show
    @product = if (p = Product[params[:id]])
      p
    else
      raise 
    end

    render_resource @product
  end

end
