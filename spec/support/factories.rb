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

  def create_verified_user!(attrs = {})
    e = create_user!.new_email
    e.verify!
    e.user
  end
end
