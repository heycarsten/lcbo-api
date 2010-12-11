class CrawlsController < ApplicationController

  def index
    @crawls = Crawl.paginate(params[:page], 50)
  end

  def show
    @crawl = Crawl[params[:id]]
  end

  def latest
    @crawl = Crawl.latest
    render :show
  end

end
