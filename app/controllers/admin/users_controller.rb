class Admin::UsersController < ApplicationController
  def index
    if params[:plan_id]
      @plan = Plan.with_users_count.find(params[:plan_id])
      @users = @plan.users.with_keys_count.order(created_at: :desc)
    else
      @users = User.with_keys_count.order(created_at: :desc)
    end
  end

  def show
    @user = User.includes(:emails, :keys, :plan).find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)
      redirect_to admin_user_url(@user)
    else
      render :show
    end
  end

  def destroy
    @user = User.find(params[:id])

    if @user.is_disabled? || @user.email.blank?
      @user.destroy
      redirect_to admin_users_url
    else
      redirect_to admin_user_url(@user)
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :plan_id,
      :is_disabled
    )
  end
end
