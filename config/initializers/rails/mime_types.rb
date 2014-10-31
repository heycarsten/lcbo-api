Mime::Type.register 'text/tsv', :tsv
Mime::Type.unregister :json
Mime::Type.register 'application/json', :json, %w[
  text/x-json
  application/jsonrequest
  application/vnd.api+json
  application/vnd.lcboapi.v1+json
  application/vnd.lcboapi.v2+json
]
