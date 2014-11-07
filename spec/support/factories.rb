module Factories
  def build_user(attrs = {})
    User.new({
      name: 'Carsten Nielsen',
      email: "#{rand 99999}@example.com",
      password: 'password',
      does_agree_to_terms: true
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

  def build_key(attrs = {})
    Key.new({
      label: "Access Key ##{rand 99999}",
      info: ('LOL ' * 30).chop
    }.merge(attrs))
  end

  def create_key(attrs = {})
    k = build_key(attrs)
    k.save
    k
  end

  def create_key!(attrs = {})
    k = build_key(attrs)
    k.save!
    k
  end
end
