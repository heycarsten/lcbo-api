module Bot
  module Crawler

    class Error < StandardError; end
    class CrawlInProgressError < Error; end

    def self.included(mod)
      mod.send(:include, Botness)
      mod.send(:attr_reader, :crawl)

      mod.on(:before_all) do
        @crawl = Crawl.spawn
        if @crawl.did_start?
          log ">> Resuming crawler from: #{@crawl.state}"
          @starting_job = @crawl.state
        else
          log ">> Starting crawler bot: #{self.class}"
          @crawl.start!
        end
      end

      mod.on(:failure) do |job, time, exception|
        log "!! FAIL: #{job} failed [#{time}]", job, exception
        @crawl.fail!
      end

      mod.on(:before_each) do |job|
        log "** Starting #{job}", job
        @crawl.state = job.to_s
        @crawl.save
      end

      mod.on(:after_each) do |job, time|
        log "   Finished #{job} [#{time}]", job
        @crawl.save
      end

      mod.on(:after_all) do
        log ">> Complete"
        @crawl.finish!
      end
    end

    def log(message, job = nil, exception = nil)
      STDOUT.puts(message)
      Rails.logger.info(message)
      @crawl.log(message, job, exception)
    end

  end
end