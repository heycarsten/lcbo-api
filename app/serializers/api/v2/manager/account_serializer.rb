class API::V2::Manager::AccountSerializer < ApplicationSerializer
  attributes \
    :name,
    :email,
    :auth_token,
    :gravatar_url,
    :unverified_email

  def gravatar_url
    return unless email = (object.email || unverified_email)
    base = email.sub(/\+[^@]+/, '')
    md5  = Digest::MD5.hexdigest(base)
    "https://secure.gravatar.com/avatar/#{md5}?d=identicon"
  end

  def auth_token
    return unless object.email.present?
    object.auth_token
  end

  def unverified_email
    return nil unless (email = object.emails.unverified.first)
    email.address
  end
end
