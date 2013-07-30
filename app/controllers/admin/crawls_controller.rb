class Admin::CrawlsController < AdminController

  def index
    @crawls = Crawl.order(Sequel.desc(:id)).limit(20).all
  end

  def show
    @crawl = Crawl[params[:id]]
    @events = CrawlEvent.where(crawl_id: @crawl.id).limit(100).order(Sequel.desc(:id)).all
  end

end
