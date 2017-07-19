class AdminMailer < ApplicationMailer
  def crawl_cancelled_message(crawl_id)
    @crawl = Crawl.find(crawl_id)
    @error = @crawl.crawl_events.where(level: 'cancelled').order(created_at: :desc).first

    mail \
      subject: "[LCBO API] Crawl ##{@crawl.id} was cancelled",
      to: 'carsten@lcboapi.com'
  end
end