class DatasetsController < ApplicationController

  def index
    render_query :datasets, params
  end

  def show
    render_query :datasets, params
  end

end
