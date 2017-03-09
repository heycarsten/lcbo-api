class API::V2::CategoriesController < API::V2::APIController
  include JSONAPI::ActsAsResourceController

  def index
    data  = {}
    query = API::V2::CategoriesQuery.new(params)
    scope = query.to_scope.order(:depth, :name)

    data[:data] = scope.map { |c| serialize(c) }

    render_json(data)
  end

  def show
    data     = {}
    category = Category.find(params[:id])

    data[:data] = serialize(category, include_dead: true)

    render_json(data)
  end

  private

  def serialize(category, scope = nil)
    API::V2::CategorySerializer.new(category,
      scope: scope || params
    ).as_json(root: false)
  end
end
