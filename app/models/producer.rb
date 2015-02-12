class Producer < ActiveRecord::Base
  before_save :generate_slug

  has_many :products

  def self.fetch_by_lcbo_name(lcbo_name)
    lcbo_ref = lcbo_name.parameterize

    if (found = where(lcbo_ref: lcbo_ref).first)
      found
    else
      create!(
        name: lcbo_name,
        lcbo_ref: lcbo_ref
      )
    end
  end

  def generate_slug
    write_attribute :slug, read_attribute(:name).parameterize
    true
  end
end
