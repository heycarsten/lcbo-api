class API::V2::Manager::KeySerializer < ApplicationSerializer
  attributes \
    :id,
    :label,
    :info,
    :token,
    :created_at,
    :updated_at
end
