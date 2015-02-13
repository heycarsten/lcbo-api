class API::V2::CategoriesController < API::V2::APIController
  def index
    query = API::V2::CategoriesQuery.new(params)
    scope = query.to_scope.order(:depth, :name)
    data  = {}

    data[:categories] = scope.map { |c|
      API::V2::CategorySerializer.new(c, scope: params).as_json(root: false)
    }

    render json: data, callback: params[:callback], serializer: nil
  end

  def show
    category = Category.find(params[:id])
    render json: category,
      callback: params[:callback],
      serializer: API::V2::CategorySerializer,
      scope: { include_dead: true }
  end
end
