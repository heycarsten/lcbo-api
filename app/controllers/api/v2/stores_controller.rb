class API::V2::StoresController < API::V2::APIController
  def index
    data    = {}
    query   = API::V2::StoresQuery.new(params)
    scope   = query.to_scope.all
    product = query.product

    data[:stores] = scope.map { |r| serializer.new(r).as_json(root: false) }
    data.merge! API::V2::ProductSerializer.new(product).as_json if product

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render json: data, callback: params[:callback]
  end

  def show
    respond_with :api, :v2, Store.find(params[:id]),
      serializer: serializer,
      callback:   params[:callback]
  end
end
