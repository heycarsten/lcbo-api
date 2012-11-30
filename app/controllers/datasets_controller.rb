class DatasetsController < ApplicationController

  def index
    @query = query(:datasets)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

  def show
    @query = query(:dataset)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.tsv { render :text => @query.as_tsv }
      wants.zip { redirect_to @query.as_json[:result][:csv_dump] }
      wants.any(:js, :json) { render_json @query.as_json }
    end
  end

end
