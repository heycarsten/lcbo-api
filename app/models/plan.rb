class Plan < ActiveRecord::Base
  enum kind: [
    :free,
    :supporter,
    :developer,
    :enterprise
  ]

  has_many :users

  after_save :recache_users

  scope :with_users_count, -> {
    select('plans.*, count(users.id) AS users_count').
    joins('LEFT OUTER JOIN users ON users.plan_id = plans.id').
    group('plans.id')
  }

  def self.select_options
    with_users_count.order(updated_at: :desc).map { |plan|
      ["#{plan.title} (#{plan.kind.titlecase}, #{plan.users_count} users)", plan.id]
    }
  end

  def clone(params = {})
    Plan.create!({
      kind:              kind,
      is_active:         is_active,
      title:             title,
      has_cors:          has_cors,
      has_ssl:           has_ssl,
      has_upc_lookup:    has_upc_lookup,
      has_upc_value:     has_upc_value,
      has_history:       has_history,
      request_pool_size: request_pool_size,
      fee_in_cents:      fee_in_cents
    }.merge(params))
  end

  private

  def recache_users
    users.find_each(&:redis_cache)
  end
end
