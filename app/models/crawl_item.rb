class CrawlItem < Ohm::Model

  attribute :type
  attribute :no

  def no
    read_local(:no).to_i
  end

end
