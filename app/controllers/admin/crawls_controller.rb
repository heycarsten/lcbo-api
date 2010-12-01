class Admin::CrawlsController < AdminController

  def index
    @crawls = Crawl.all(:order => 'id DESC')
  end

  def show
    @crawl = Crawl.find(params[:id])
  end

end
