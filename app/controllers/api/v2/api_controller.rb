class API::V2::APIController < APIController
  VERSION = 2
  PER     = 50

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    Magiq::Error,
    with: :render_exception

  before_filter :rate_limit!, :authenticate!, :verify_api_key!

  self.responder = Class.new(responder) do
    def json_resource_errors
      errors = []

      resource.errors.each do |field, messages|
        Array(messages).each do |msg|
          errors << { code: 'invalid', path: field, detail: msg }
        end
      end

      { errors: errors }
    end
  end

  def self.resources_url_method
    @resources_url ||= begin
      to_s.
        sub('Controller', '').
        split('::').
        map { |s| s.underscore }.
        join('_') + '_url'
    end
  end

  def self.serializer_name
    @serializer_name ||= controller_name.singularize
  end

  def self.module_path
    @module_path ||= to_s.sub(/::[^::]+\Z/, '')
  end

  def self.serializer
    @serializer ||= begin
      serializer_class_name = "#{serializer_name.to_s.classify}Serializer"
      Object.const_get("#{module_path}::#{serializer_class_name}")
    end
  end

  protected

  def verify_api_key!
    return true unless current_key

    STDOUT.puts(request.headers['Origin'].inspect)
    true
    # if current_key.has_domain?
    #   request.origin
    # end

    # /stores
    # X-API-Key: k_329394448-asdlkfn03nfwefh2389ne
    # =>
    #   k = Key.lookup 329394448
    #     checks redis if not there checks db and caches in redis
    #
    #   if no key, then 401
    #
    #   if key has domain
    #     check origin matches domain
    #     allow cors (set headers)
    #     allow json-p
    #   else
    #     disable cors
    #     disable json-p
  end

  def render_exception(error)
    render_error \
      status: 400,
      code:   error.class.to_s.demodulize.underscore.sub('_error', ''),
      detail: error.message
    false
  end

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

  def pagination_for(scope)
    return nil if !scope.respond_to?(:next_page)

    { pagination: {
        total_records: scope.total_count,
        total_pages:   scope.total_pages,
        page_size:     scope.limit_value,
        current_page:  scope.current_page,
        prev_page:     scope.prev_page,
        next_page:     scope.next_page,
        prev_href:     resources_url(page: scope.prev_page, page_size: scope.max_per_page),
        next_href:     resources_url(page: scope.next_page, page_size: scope.max_per_page)
    } }
  end

  def resources_url(*args)
    send(self.class.resources_url_method, *args)
  end

  # def set_response_format
  #   return true unless params.key?(:callback)
  #   response.format = :js
  #   true
  # end
end
