class CrawlRunner

  def initialize(crawl)
    @crawl = crawl
    check_crawl!
  end

  def finished
    CrawlRunnerJob.perform
  end

  def check_crawl!
    @crawl.is_runnable?
  end

end
