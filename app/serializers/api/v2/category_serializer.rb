class API::V2::CategorySerializer < ApplicationSerializer
  attributes \
    :type,
    :id,
    :name,
    :depth,
    :is_dead

  def type
    :category
  end

  def id
    object.id.to_s
  end

  def attributes
    h = super

    h[:links] = {}.tap { |hh|
      hh[:parent_category] = object.parent_category_id.to_s if object.parent_category_id
    }

    h.delete(:links) if h[:links].empty?

    h
  end

  def filter(keys)
    keys.delete(:is_dead) unless scope && scope[:include_dead]
    keys
  end
end
