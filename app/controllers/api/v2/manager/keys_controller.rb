class API::V2::Manager::KeysController < API::V2::Manager::ManagerController
  def index
    keys = current_user.keys.page(params[:page]).per(PER).order(id: :desc)
    data = {}

    data[:keys] = keys.map { |k|
      API::V2::Manager::KeySerializer.new(k).as_json(root: false)
    }

    if (pagination = pagination_for(keys))
      data[:meta] = pagination
    end

    render json: data, serializer: nil
  end

  def show
    key = current_user.keys.find(params[:id])
    render json: key, serializer: API::V2::Manager::KeySerializer
  end

  def create
    key = current_user.keys.create(key_params)
    respond_with :api, :v2, :manager, key, serializer: API::V2::Manager::KeySerializer
  end

  def update
    key = current_user.keys.find(params[:id])
    key.update(key_params)
    respond_with :api, :v2, :manager, key, serializer: API::V2::Manager::KeySerializer
  end

  def destroy
    key = current_user.keys.find(params[:id])
    key.destroy
    respond_with :api, :v2, :manager, key, serializer: API::V2::Manager::KeySerializer
  end

  protected

  def key_params
    return {} unless params[:key]

    params.require(:key).permit(
      :label,
      :info,
      :kind
    )
  end
end
