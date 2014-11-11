class APISentryService
  class Error < StandardError; end

  def initialize(access_key, request)
    @request    = request
    @access_key = access_key
    @key_id     = access_key[:id]
    @user_id    = access_key[:user_id]
    @key_kind   = access_key[:kind]

    load_user
  end

  def verify!
  end

  def web_client?
    @key_kind == 'web_client'
  end

  def native_client?
    @key_kind == 'native_client'
  end

  def private_server?
    @key_kind == 'private_server'
  end

  private

  def load_user
    @user = User.redis_load(@user_id)
  end
end
