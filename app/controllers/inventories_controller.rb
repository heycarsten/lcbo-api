class InventoriesController < ApplicationController

  def index
    @query = query(:inventories)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

  def show
    @query = query(:inventory)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

end
