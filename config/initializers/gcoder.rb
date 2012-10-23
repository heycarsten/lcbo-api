GEO = GCoder.connect \
  storage:        :redis,
  storage_config: { key_ttl: 86400 },                 # 24 hours
  bounds:         [[50.09, -94.88], [41.87, -74.16]], # Ontario: The Populated Parts
  region:         :ca,
  append:         ', Ontario, Canada'
