class Product < ActiveRecord::Base
  include PgSearch

  pg_search_scope :search,
    against:  :tags,
    ignoring: :accents,
    using: {
      tsearch: {
        prefix: true,
        tsvector_column: :tag_vectors
      }
    }

  belongs_to :crawl
  has_many :inventories

  def self.place(attrs)
    attrs[:updated_at] = Time.now.utc
    attrs[:tags]       = attrs[:tags].any? ? attrs[:tags].join(' ') : nil
    attrs[:is_dead]    = false

    if 0 == where(id: attrs[:id]).update_all(attrs)
      create!(attrs)
    end
  end
end
