module APIHelpers
  def api_headers
    @api_headers ||= { 'Accept' => 'application/vnd.api+json' }
  end

  def log_in_user(user)
    token = user.generate_session_token.to_s
    api_headers['Authorization'] = "Token token=\"#{token}\""
    token
  end

  def auth_user(user)
    api_headers['Authorization'] = "Token token=\"#{user.auth_token}\""
  end

  def json
    @json ||= MultiJson.load(response.body, symbolize_keys: true)
  end

  def last_delivery
    ActionMailer::Base.deliveries.last
  end

  def errors_for(path)
    return [] unless json[:errors]
    json[:errors].select { |e| e[:path] == path.to_s }
  end

  def has_errors_for(path)
    errors_for(path).any?
  end

  [:get, :put, :post, :patch, :delete, :head, :options].each do |action|
    define_method :"api_#{action}" do |path, params = {}|
      send(action, path, params, api_headers)
    end
  end
end
