class API::V2::Manager::ManagerController < API::V2::APIController
  skip_before_filter :rate_limit!

  protected

  def authenticate!
    current_user ? true : not_authorized
  end

  def unauthenticate!
    current_user.destroy_session_token(auth_token)
    @current_user = nil
  end

  def serialize(stuff, opts = {})
    root = opts.delete(:root)
    data = {}

    if stuff.respond_to?(:all)
      root ||= self.class.controller_name.pluralize
      resource = stuff.map { |i|
        self.class.serializer.new(i, opts).as_json(root: false)
      }

      if (pagination = pagination_for(stuff))
        data[:meta] = pagination
      end
    else
      root ||= self.class.controller_name.singularize
      resource = self.class.serializer.new(stuff, opts).as_json(root: false)
    end

    data[root] = resource
    data
  end

  def render_session(token, ttl = User::SESSION_TTL)
    render json: { session: {
      token:      token.to_s,
      expires_at: Time.now + ttl
    } }, status: 200
  end
end
