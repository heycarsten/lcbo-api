class API::V2::ProductsController < API::V2::APIController
  def index
    data    = {}
    query   = API::V2::ProductsQuery.new(params)
    scope   = query.to_scope
    results = scope.load

    data[:products] = results.map { |r|
      API::V2::ProductSerializer.new(r).as_json(root: false)
    }

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render json: data, callback: params[:callback], serializer: nil
  end

  def show
    product = Product.find(params[:id])
    data    = API::V2::ProductSerializer.new(product).as_json(root: false)

    render json: { product: data }, callback: params[:callback], serializer: nil
  end
end
