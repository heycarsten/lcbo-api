class API::V2::ProducerSerializer < ApplicationSerializer
  attributes \
    :id,
    :slug,
    :name,
    :is_ocb,
    :is_dead,
    :created_at,
    :updated_at

  def filter(keys)
    keys.delete(:is_dead) unless scope && scope[:include_dead]
    keys
  end
end
