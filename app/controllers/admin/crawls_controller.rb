class Admin::CrawlsController < Admin::BaseController

  def index
    @crawls = Crawl.all.sort_by(:updated_at, :order => 'ALPHA DESC')
  end

  def show
    @crawl = Crawl[params[:id]]
    @events = @crawl.events.sort { |a,b|  a.created_at <=> b.created_at }
  end

end
