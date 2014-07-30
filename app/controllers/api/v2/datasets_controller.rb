class API::V2::DatasetsController < API::V2::APIController
  def index
    query = API::V2::DatasetsQuery.new(params)
    scope = query.to_scope
    data  = {}

    data[:datasets] = scope.map do |r|
      API::V2::DatasetSerializer.new(r, scope: :index).as_json(root: false)
    end

    if (pagination = pagination_for(scope))
      data[:meta] = pagination
    end

    render json: data, callback: params[:callback]
  end

  def show
    dataset = Crawl.finished.find(params[:id])
    respond_with :api, :v2, dataset, serializer: serializer, callback: params[:callback]
  end
end
