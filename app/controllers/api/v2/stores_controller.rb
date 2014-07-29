class API::V2::StoresController < API::V2::APIController
  def index
    data    = {}
    query   = API::V2::StoresQuery.new(params)
    stores  = query.to_scope.all
    product = query.product
    serializer = API::V2::StoreSerializer

    data.merge! stores: stores.map { |s| serializer.new(s).as_json(root: false) }
    data.merge! API::V2::ProductSerializer.new(product).as_json if product

    if (meta = page_meta(stores))
      data.merge! meta: { pagination: meta }
    end

    render json: data
  end

  def show
    render json: Store.find(params[:id]), serializer: API::V2::StoreSerializer
  end
end
