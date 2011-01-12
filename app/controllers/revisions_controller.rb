class RevisionsController < ApplicationController

  def index
    @query = QueryHelper(:revisions, params)

    respond to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

end
