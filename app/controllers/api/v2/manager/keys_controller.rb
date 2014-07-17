class API::V2::Manager::KeysController < API::V2::Manager::ManagerController
  def index
    keys = current_user.keys.page(params[:page]).per(50).order(id: :desc)
    respond_with keys, meta: pagination_meta(keys), each_serializer: serializer
  end

  def show
    respond_with current_user.keys.find(params[:id]), serializer: serializer
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

  def pagination_meta(scope)
    { total_records: scope.total_count,
      total_pages:   scope.total_pages,
      page_size:     scope.max_per_page,
      current_page:  scope.current_page,
      prev_page:     scope.prev_page,
      next_page:     scope.next_page,
      prev_href:     api_v2_manager_keys_url(page: scope.prev_page, page_size: scope.max_per_page),
      next_href:     api_v2_manager_keys_url(page: scope.next_page, page_size: scope.max_per_page) }
  end

  def serializer
    API::V2::Manager::KeySerializer
  end
end
