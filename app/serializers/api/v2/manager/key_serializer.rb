class API::V2::Manager::KeySerializer < ApplicationSerializer
  attributes \
    :id,
    :label,
    :info,
    :kind,
    :token,
    :created_at,
    :updated_at
end
