class API::V2::DatasetsController < API::V2::APIController
  def index
    crawls = Crawl.is(:finished).page(params[:page]).per(PER)
    render_json crawls, scope: :index
  end

  def show
    render_json Crawl.finished.find(params[:id])
  end
end
