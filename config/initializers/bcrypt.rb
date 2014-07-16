BCrypt::Engine.cost = Rails.env.test? ? 1 : 10
