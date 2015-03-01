class Admin::PlansController < ApplicationController
  def index
    @plans = Plan.with_users_count.order(kind: :asc, created_at: :desc)
  end

  def show
    @plan = Plan.with_users_count.find(params[:id])
  end

  def destroy
    @plan = Plan.with_users_count.find(params[:id])

    if @plan.users_count == 0
      @plan.destroy
      redirect_to admin_plans_url
    else
      redirect_to admin_plan_url(@plan)
    end
  end

  def new
    @plan = Plan.new
    render :show
  end

  def create
    @plan = Plan.create(plan_params)

    if @plan.valid?
      redirect_to admin_plan_url(@plan)
    else
      render :show
    end
  end

  def update
    @plan = Plan.find(params[:id])

    if @plan.update(plan_params)
      redirect_to admin_plan_url(@plan)
    else
      render :show
    end
  end

  def clone
    plan = Plan.find(params[:id])
    clone = @plan.clone
    redirect_to admin_plan_url(clone)
  end

  private

  def plan_params
    params.require(:plan).permit(
      :title,
      :kind,
      :stripe_uid,
      :request_pool_size,
      :fee_in_cents,
      :has_cors,
      :has_ssl,
      :has_upc_lookup,
      :has_upc_value,
      :has_history
    )
  end
end
