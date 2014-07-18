class API::V2::APIController < APIController
  VERSION = 2
  PER     = 50

  before_filter :rate_limit!, :authenticate!

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

  def serialize(stuff, opts = {})
    root  = opts.delete(:root)
    meta  = opts.delete(:meta) || {}
    merge = opts.delete(:merge)
    data  = {}

    if stuff.respond_to?(:all)
      root   ||= self.class.controller_name.pluralize
      resource = stuff.map { |i|
        self.class.serializer.new(i, opts).as_json(root: false)
      }
      meta.merge!(page_meta(stuff)) if stuff.respond_to?(:next_page)
    else
      root   ||= self.class.controller_name.singularize
      resource = self.class.serializer.new(stuff, opts).as_json(root: false)
    end

    data.merge!(merge) if merge
    data[:meta] = meta unless meta.empty?
    data[root]  = resource

    data
  end

  def render_json(stuff, opts = {})
    status = opts.delete(:status) || 200
    render json: serialize(stuff, opts), status: status
  end

  def page_meta(scope)
    { total_records: scope.total_count,
      total_pages:   scope.total_pages,
      page_size:     scope.max_per_page,
      current_page:  scope.current_page,
      prev_page:     scope.prev_page,
      next_page:     scope.next_page,
      prev_href:     resources_url(page: scope.prev_page, page_size: scope.max_per_page),
      next_href:     resources_url(page: scope.next_page, page_size: scope.max_per_page) }
  end

  def resources_url(*args)
    send(self.class.resources_url_method, *args)
  end
end
