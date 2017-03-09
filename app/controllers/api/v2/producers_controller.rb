class API::V2::ProducersController < API::V2::APIController
  include JSONAPI::ActsAsResourceController

  def index
    data  = {}
    query = API::V2::ProducersQuery.new(params)
    scope = query.to_scope

    data[:data] = scope.map { |p| serialize(p, params) }

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render_json(data)
  end

  def show
    data     = {}
    producer = Producer.find(params[:id])

    data[:data] = serialize(producer, include_dead: true)

    render_json(data)
  end

  private

  def serialize(producer, scope = nil)
    API::V2::ProducerSerializer.new(producer,
      scope: scope || params
    ).as_json(root: false)
  end
end
