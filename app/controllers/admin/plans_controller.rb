class Admin::PlansController < ApplicationController
  def index
    @plans = plan_with_count.order(kind: :asc, created_at: :desc)
  end

  def show
    @plan = plan_with_count.find(params[:id])
  end

  private

  def plan_with_count
    Plan.select('plans.*, count(users.id) AS users_count').
      joins('LEFT OUTER JOIN users ON users.plan_id = plans.id').
      group('plans.id')
  end
end
