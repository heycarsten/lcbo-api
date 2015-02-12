class Category < ActiveRecord::Base
  before_save :generate_slug

  has_many :categories, foreign_key: :parent_category_id

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
          gsub(' and ', ' & ').
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

  def generate_slug
    write_attribute(:slug, read_attribute(:name).parameterize)
    true
  end
end
