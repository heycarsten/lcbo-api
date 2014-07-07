class API::V2::StoresController < API::V2::APIController
  def index
    stores = Store.order(:id).page(params[:page]).per_page(params[:per_page] || 50)
    render json: stores, serializer: API::V2::StoreSerializer
  end

  def show
    render json: Store.find(params[:id]), serializer: API::V2::StoreSerializer
  end
end
