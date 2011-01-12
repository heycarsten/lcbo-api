class InventoriesController < ApplicationController

  def index
    @query = QueryHelper(:inventories)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

  def show
    @query = QueryHelper(:inventory)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

end
