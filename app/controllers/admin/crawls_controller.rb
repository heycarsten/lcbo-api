class Admin::CrawlsController < AdminController
  def index
    @crawls = Crawl.order(id: :desc).limit(20).all
  end

  def show
    @crawl  = Crawl.find(params[:id])
    @events = @craw.crawl_events.order(id: :desc).limit(100).all
  end
end
