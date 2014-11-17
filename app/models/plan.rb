class Plan < ActiveRecord::Base
  enum kind: [
    :free,
    :supporter,
    :developer,
    :enterprise
  ]

  has_many :users

  after_save :recache_users

  private

  def recache_users
    users.find_each(&:redis_cache)
  end
end
