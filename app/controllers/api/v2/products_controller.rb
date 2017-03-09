class API::V2::ProductsController < API::V2::APIController
  include JSONAPI::ActsAsResourceController

  # def index
  #   data    = {}
  #   query   = API::V2::ProductsQuery.new(params)
  #   scope   = query.to_scope
  #   results = scope.load

  #   data[:data] = results.map { |p| serialize(p, params) }

  #   if (pagination = pagination_for(scope))
  #     data[:meta] = pagination
  #   end

  #   if data[:data].empty? && params[:q].present?
  #     data[:meta] ||= {}
  #     data[:meta][:search_suggestions] = [Fuzz[:products, params[:q]]]
  #   end

  #   render_json(data)
  # end

  # def show
  #   data    = {}
  #   product = Product.find(params[:id])

  #   data[:data] = serialize(product, include_dead: true)

  #   render_json(data)
  # end

  # private

  # def serialize(product, scope = nil)
  #   API::V2::ProductSerializer.new(product,
  #     scope: scope || params
  #   ).as_json(root: false)
  # end
end
