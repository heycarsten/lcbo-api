class StoresController < ApplicationController

  def index
    @query = query(:stores)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

  def show
    @query = query(:store)

    respond_to do |wants|
      wants.csv { render :text => @query.as_csv }
      wants.any { render_json @query.as_json }
    end
  end

end
