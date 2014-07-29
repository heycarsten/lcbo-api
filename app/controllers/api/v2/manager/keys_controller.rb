class API::V2::Manager::KeysController < API::V2::Manager::ManagerController
  def index
    keys = current_user.keys.page(params[:page]).per(PER).order(id: :desc)
    render json: serialize(keys)
  end

  def show
    key = current_user.keys.find(params[:id])
    respond_with :api, :v2, :manager, key, serializer: serializer
  end

  def create
    key = current_user.keys.create(key_params)
    respond_with :api, :v2, :manager, key, serializer: serializer
  end

  def update
    key = current_user.keys.find(params[:id])
    key.update(key_params)
    respond_with :api, :v2, :manager, key, serializer: serializer
  end

  def destroy
    key = current_user.keys.find(params[:id])
    key.destroy
    respond_with :api, :v2, :manager, key, serializer: serializer
  end

  protected

  def key_params
    return {} unless params[:key]

    params.require(:key).permit(
      :label,
      :info
    )
  end

  def serializer
    API::V2::Manager::KeySerializer
  end
end
