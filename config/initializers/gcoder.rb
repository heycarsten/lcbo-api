GEO = GCoder.connect \
  :store => :redis,
  :bounds => [[50.09, -94.88], [41.87, -74.16]], # Ontario: The Populated Parts
  :region => :ca
