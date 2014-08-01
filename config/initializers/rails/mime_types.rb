Mime::Type.unregister :json
Mime::Type.unregister :csv

Mime::Type.register 'application/json', :json, %w[
  text/x-json
  application/jsonrequest
  application/vnd.api+json
  application/vnd.lcboapi.v1+json
  application/vnd.lcboapi.v2+json
]

Mime::Type.register 'text/csv', :csv, %w[
  text/vnd.lcboapi.v1+csv
  text/vnd.lcboapi.v2+csv
]

Mime::Type.register 'text/tsv', :tsv, %w[
  text/vnd.lcboapi.v1+tsv
  text/vnd.lcboapi.v2+tsv
]
