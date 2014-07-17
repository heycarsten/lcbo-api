class API::V2::APIController < APIController
  VERSION  = 2
  RATE_MAX = 1800

  before_filter :rate_limit!, :authenticate!

  self.responder = Class.new(ActionController::Responder) do
    def json_resource_errors
      errs = []

      resource.errors.each do |field, messages|
        Array(messages).each do |msg|
          errs << { code: 'invalid', path: field, detail: msg }
        end
      end

      { errors: errs }
    end
  end

  protected

  def api_version
    VERSION
  end

  def api_token
    @api_token ||= Token.parse(request.headers['X-API-Key'] || params[:api_key])
  end

  def auth_token
    @auth_token ||= Token.parse(request.headers['X-Auth-Token'])
  end

  def current_user
    @current_user ||= User.lookup(auth_token)
  end

  def current_key
    @current_key ||= Key.lookup(api_token)
  end

  def authenticate!
    (current_key || current_user) ? true : not_authorized
  end
end
