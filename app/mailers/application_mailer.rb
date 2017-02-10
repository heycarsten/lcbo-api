class ApplicationMailer < ActionMailer::Base
  default from: 'LCBO API <help@lcboapi.com>'
  layout 'mailer'
end
