class Admin::CrawlsController < AdminController

  def index
    @crawls = Crawl.all(:order => 'id DESC')
  end

  def show
    @crawl = Crawl.find(params[:id])
    @events = @crawl.crawl_events.all(:limit => 100, :order => 'id DESC')
  end

end
