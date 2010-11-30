class Admin::CrawlsController < Admin::BaseController

  def index
    @crawls = Crawl.all.sort(:by => :updated_at, :order => 'DESC ALPHA')
  end

  def show
    @crawl = Crawl[params[:id]]
    @events = @crawl.events.sort_by(:created_at, :order => 'ASC')
  end

end
