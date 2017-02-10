class Category < ApplicationRecord
  include PgSearch

  after_save :update_parent_category_ids

  pg_search_scope :search,
    against:  :name,
    ignoring: :accents,
    using: {
      tsearch: {
        prefix: true,
        tsvector_column: :name_vectors
      }
    }

  has_many :categories, foreign_key: :parent_category_id

  belongs_to :parent_category, class_name: 'Category'

  scope :by_ids, ->(*raw_ids) {
    ids   = raw_ids.flatten.map(&:to_i)
    scope = where(id: ids)

    if ids.empty?
      scope
    else
      sql = ids.each_with_index.map { |id, i| "WHEN #{id} THEN #{i}" }.join(' ')
      scope.order("CASE categories.id #{sql} END")
    end
  }

  def self.mark_dead!(&each)
    Category.find_each do |category|
      each.(category) if each

      all_count = category.products.count

      if all_count == 0
        category.update(is_dead: true)
        next
      end

      if all_count == category.products.where(is_dead: true).count
        category.update(is_dead: true)
        next
      end

      if category.is_dead
        category.update(is_dead: false)
      end
    end
  end

  def self.fetch_by_lcbo_cat_names(names)
    cats = names.each_with_index.map do |cat, i|
      { name:  cat,
        ref:   cat.parameterize,
        depth: i }
    end

    fetched = []

    cats.reduce(nil) do |parent, c|
      category = if (found = where(lcbo_ref: c[:ref], depth: c[:depth]).first)
        found
      else
        h = {}
        h[:lcbo_ref] = c[:ref]
        h[:depth]    = c[:depth]
        h[:name]     = c[:name].
          gsub('/', ' / ').
          gsub(' & ', ' and ').
          gsub(/[ ]+/, ' ').
          strip
        h[:parent_category_id] = parent.id if parent
        create!(h)
      end

      fetched << category

      category
    end

    fetched
  end

  def products
    Product.where('? = ANY(category_ids)', id)
  end

  def update_parent_category_ids
    ids = []
    cat = self

    loop do
      if (cat = cat.parent_category)
        ids.insert(0, cat.id)
      else
        break
      end
    end

    update_column :parent_category_ids, ids
  end
end
