class API::V2::APIController < APIController
  VERSION  = 2
  PER      = 50
  MAX_RATE = 100

  LOOPBACKS = %w[
    0.0.0.0
    127.0.0.1
    localhost
    ::1
  ]

  CORS_HEADERS = {
    'Access-Control-Allow-Origin'  => '*',
    'Access-Control-Allow-Methods' => 'GET',
    'Access-Control-Allow-Headers' => %w[
      Accept
      X-Access-Key
      X-Auth-Token
    ].join(', '),
    'Access-Control-Expose-Headers' => %w[
      X-API-Version
      X-Rate-Limit-Count
      X-Rate-Limit-Max
      X-Rate-Limit-Reset
    ].join(', ')
  }

  rescue_from \
    GCoder::NoResultsError,
    GCoder::OverLimitError,
    GCoder::GeocoderError,
    Magiq::Error, with: :render_exception

  before_filter \
    :rate_limit!,
    :verify_request!,
    :authenticate!, except: :preflight_cors

  after_filter :add_cors_headers

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

  def preflight_cors
    head :ok
  end

  protected

  def rate_limit!
    max = case
    when current_key
      current_key[:max_rate]
    when current_user
      current_user.max_rate
    else
      MAX_RATE
    end

    uniq = case
    when current_key && !current_key[:is_public]
      current_key[:id]
    when current_user
      current_user.id
    else
      request.ip
    end

    rate_limit(max, uniq)
  end

  def verify_request!
    return true unless current_key

    if !current_key[:is_public]
      params.delete(:callback)
      return true
    end

    @enable_cors = true

    if origin && (LOOPBACKS.include?(origin) || origin.include?(current_key[:domain]))
      true
    else
      render_error \
        status: 403,
        code: 'bad_origin',
        detail: I18n.t('bad_origin')
    end
  end

  def authenticate!
    (current_key || current_user) ? true : not_authorized
  end

  def add_cors_headers(allow_origin = '*')
    return true unless @enable_cors
    headers.merge!(CORS_HEADERS)
    headers['Access-Control-Allow-Origin'] = allow_origin
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

  def origin
    @origin ||= begin
      origin = (request.headers['Origin'] || request.headers['Referer'])

      return if origin.blank?

      origin.downcase!

      if origin == 'null'
        origin = 'http://localhost'
      end

      uri = URI.parse(origin)

      case uri.scheme
      when 'http', 'https'
        uri.host
      else
        nil
      end
    rescue URI::InvalidURIError
      nil
    end
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
end
