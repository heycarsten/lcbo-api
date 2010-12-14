class Store < Sequel::Model

  unrestrict_primary_key

  plugin :timestamps, :update_on_create => true
  plugin :geo
  plugin :archive, :crawl_id

  many_to_one :crawl
  one_to_many :inventories

  def self.place(attrs)
    id = attrs[:store_no]
    raise ArgumentError, "attrs must contain :store_no" unless id
    (store = self[id]) ? store.update(attrs) : create(attrs)
  end

  def store_no=(value)
    self.id = value
  end

  def store_no
    id
  end

  def as_json
    { :store_no => id }.
      merge(super['values']).
      except(:id, :is_dead, :latrad, :lngrad, :created_at, :updated_at, :crawl_id)
  end

  def before_save
    super
    self.latrad = (self.latitude  * (Math::PI / 180.0))
    self.lngrad = (self.longitude * (Math::PI / 180.0))
  end

end
