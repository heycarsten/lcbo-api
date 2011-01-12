class RevisionsController < ApplicationController

  def index
    @query = case
      when params[:product_id] && params[:store_id]
        query(:inventory_revisions)
      when params[:product_id]
        query(:product_revisions)
      when params[:store_id]
        query(:store_revisions)
      end

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

end
