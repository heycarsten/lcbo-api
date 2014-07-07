class API::V2::Manager::AccountSerializer < ApplicationSerializer
  attributes \
    :id,
    :name,
    :email,
    :pending_email,
    :auth_token
end
