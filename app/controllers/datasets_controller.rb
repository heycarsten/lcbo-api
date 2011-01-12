class DatasetsController < ApplicationController

  def index
    @query = QueryHelper(:datasets)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

  def show
    @query = QueryHelper(:dataset)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.zip { redirect_to @query.dataset[:csv_dump] }
      wants.any { render_json @query.as_json }
    end
  end

end
