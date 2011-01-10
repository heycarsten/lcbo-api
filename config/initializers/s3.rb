AWS::S3::Base.establish_connection!(
  :access_key_id     => LCBOAPI[:s3][:access_key],
  :secret_access_key => LCBOAPI[:s3][:secret_key]
)
