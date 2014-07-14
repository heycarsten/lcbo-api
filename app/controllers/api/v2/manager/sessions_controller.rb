class API::V2::Manager::SessionsController < API::V2::Manager::ManagerController
  skip_before_filter :authenticate!, only: :create

  def show
  end

  def create
  end

  def update
  end

  def destroy
  end
end
