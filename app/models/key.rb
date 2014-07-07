class Key < ActiveRecord::Base
  SIZE = 12

  enum usage: [
    :mobile,
    :server,
    :client,
    :plugin,
    :business,
    :consulting,
    :aggregation,
    :curiosity,
    :other
  ]

  belongs_to :user

  before_validation :set_data, on: :create

  validates :user_id, presence: true
  validates :data,    presence: true

  def self.lookup(encoded_key)
    id62, data = encoded_key.split('-')
    id         = Base62.uuid_decode(id62)
    key        = find(id)

    if SecureCompare.compare(data, key.data)
      key
    else
      raise ActiveRecord::RecordNotFound, "the requested secret was not found"
    end
  end

  def encoded_id
    Base62.uuid_encode(id)
  end

  def payload
    encoded_id + '-' + data
  end

  private

  def set_data
    self.data = SecureRandom.urlsafe_base64(SIZE)[0, SIZE].tr('-_', 'aA')
  end
end
