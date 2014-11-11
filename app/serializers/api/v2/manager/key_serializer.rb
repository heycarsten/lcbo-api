class API::V2::Manager::KeySerializer < ApplicationSerializer
  attributes \
    :id,
    :label,
    :info,
    :kind,
    :domain,
    :token,
    :created_at,
    :updated_at

  def token
    object.token.to_s
  end
end
