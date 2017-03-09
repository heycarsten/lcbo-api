class API::V2::SnapshotsController < API::V2::APIController
  include JSONAPI::ActsAsResourceController

  def index
    data  = {}
    query = API::V2::SnapshotsQuery.new(params)
    scope = query.to_scope

    data[:data] = scope.map { |d| serialize(d, :index) }

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render_json(data)
  end

  def show
    data    = {}
    dataset = Crawl.is(:finished).where(id: params[:id]).first!

    data[:data] = serialize(dataset, :show)

    render_json(data)
  end

  private

  def serialize(dataset, scope)
    API::V2::DatasetSerializer.new(dataset,
      scope: scope || :index
    ).as_json(root: false)
  end
end
