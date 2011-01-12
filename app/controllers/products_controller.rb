class ProductsController < ApplicationController

  def index
    @query = query(:products)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

  def show
    @query = query(:product)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

end
