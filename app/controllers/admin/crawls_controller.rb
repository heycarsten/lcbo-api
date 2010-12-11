class Admin::CrawlsController < AdminController

  def index
    @crawls = Crawl.order(:id.desc).limit(20).all
  end

  def show
    @crawl = Crawl[params[:id]]
    @events = CrawlEvent.filter(:crawl_id => @crawl.id).limit(100).order(:id.desc).all
  end

end
