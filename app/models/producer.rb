class Producer < ActiveRecord::Base
  before_save :generate_slug

  has_many :products

  def self.mark_dead!(&each)
    Producer.find_each do |producer|
      each.(producer) if each

      all_count = producer.products.count

      if all_count == 0
        producer.update(is_dead: true)
        next
      end

      if all_count == producer.products.where(is_dead: true).count
        producer.update(is_dead: true)
        next
      end

      if producer.is_dead
        producer.update(is_dead: false)
      end
    end
  end

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
