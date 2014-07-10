module Factories
  def build_user(attrs = {})
    User.new({
      name: 'Carsten Nielsen',
      email: "#{rand 99999}@example.com",
      password: 'password'
    }.merge(attrs))
  end

  def create_user(attrs = {})
    u = build_user(attrs)
    u.save
    u
  end

  def create_user!(attrs = {})
    u = build_user(attrs)
    u.save!
    u
  end
end
