class API::V2::ProducerSerializer < ApplicationSerializer
  attributes \
    :type,
    :id,
    :name,
    :is_ocb,
    :is_dead,
    :created_at,
    :updated_at

  def type
    :producer
  end

  def id
    object.id.to_s
  end

  def filter(keys)
    keys.delete(:is_dead) unless scope && scope[:include_dead]
    keys
  end
end
