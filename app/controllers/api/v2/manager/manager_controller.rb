class API::V2::Manager::ManagerController < API::V2::APIController
  def auth_token
    headers['X-Auth-Token']
  end

  def authenticate!
    return true if current_user
    not_authorized
  end

  def unauthenticate!
    token = Token.parse(auth_token)
    key   = 'sessions:' + token.id
    $redis.del(key)
    @current_user = nil
  end

  def current_user
    @current_user ||= User.lookup(auth_token)
  end
end
