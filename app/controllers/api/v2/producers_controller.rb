class API::V2::ProducersController < API::V2::APIController
  def index
    query = API::V2::ProducersQuery.new(params)
    scope = query.to_scope
    data  = {}

    data[:producers] = scope.map { |c|
      API::V2::ProducerSerializer.new(c, scope: params).as_json(root: false)
    }

    render json: data, callback: params[:callback], serializer: nil
  end

  def show
    producer = Producer.find(params[:id])

    render json: producer,
      callback: params[:callback],
      serializer: API::V2::ProducerSerializer,
      scope: { include_dead: true }
  end
end
