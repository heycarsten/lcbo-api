class RevisionsController < ApplicationController

  def index
    render_query :revisions, params
  end

end
