class API::V2::Manager::AccountsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :create

  def serializer
    API::V2::Manager::AccountSerializer
  end

  def show
    render json: current_user
  end

  def create
    user = User.create(user_params)
    respond_with :api, :v2, :manager, user
  end

  def update
    user = current_user
    user.update_attributes(user_params)
    respond_with :api, :v2, :manager, user
  end

  def destroy
    user = current_user
    user.destroy
    respond_with :api, :v2, :manager, user
  end

  protected

  def user_params
    params.require(:account).permit(
      :name,
      :email
    )
  end
end
