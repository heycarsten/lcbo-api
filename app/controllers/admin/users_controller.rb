class Admin::UsersController < ApplicationController
  def index
    @users = User.order(created_at: :desc)
  end

  def show
    @user = User.includes(:emails, :keys, :plan).find(params[:id])
  end
end
