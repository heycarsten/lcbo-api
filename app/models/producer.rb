class Producer < ActiveRecord::Base
  before_create :generate_lcbo_slug
  before_save :generate_slug

  has_many :products

  def self.fetch(attrs)
    slug_col = if slug_val = attrs[:lcbo_name]
      :lcbo_slug
    elsif slug_val = attrs[:name]
      :slug
    else
      raise "fetch requires :lcbo_name or :name of producer"
    end

    if (found = where(slug_col => slug_val.parameterize).first)
      found
    else
      attrs[:name] ||= attrs[:lcbo_name]
      create!(attrs)
    end
  end

  def generate_lcbo_slug
    if read_attribute(:lcbo_name).blank?
      write_attribute(:lcbo_name, read_attribute(:name))
    end

    write_attribute :lcbo_slug, read_attribute(:lcbo_name).parameterize

    true
  end

  def generate_slug
    write_attribute :slug, read_attribute(:name).parameterize
    true
  end
end
