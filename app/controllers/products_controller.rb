class ProductsController < ApplicationController

  def index
    @query = QueryHelper(:products)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

  def show
    @query = QueryHelper(:product)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

end
