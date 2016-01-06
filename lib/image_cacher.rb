class ImageCacher
  CF_DISTRO = 'dx5vpyka4lqst'

  MIMES = {
    jpeg: 'image/jpeg',
    jpg:  'image/jpeg',
    png:  'image/png'
  }

  EXT = {
    'image/jpeg' => 'jpeg',
    'image/png'  => 'png'
  }

  TYPES = {
    image_url: 'full',
    image_thumb_url: 'thumb'
  }

  def self.run
    new.run
  end

  def initialize
    @s3 = Aws::S3::Client.new(
      region: 'us-east-1',
      credentials: Aws::Credentials.new(
        Rails.application.secrets.s3_access_key,
        Rails.application.secrets.s3_secret_key
      )
    )
  end

  def uncached
    Product.where('image_url LIKE ?', '%www.lcbo.com%')
  end

  def run
    uncached.find_each do |product|
      [:image_url, :image_thumb_url].each do |col|
        src_url  = product.read_attribute(col)
        src_ext  = File.extname(src_url).sub('.', '').downcase.to_sym
        src_mime = MIMES[src_ext]

        puts "Downloading #{col} for product #{product.id}..."
        response = Excon.get(src_url)

        unless response.status == 200
          puts "Skipping #{col} for product #{product.id} (#{response.status})"
          next
        end

        puts "Saving #{col} for product #{product.id}..."
        key = store_product_image(product, col, src_mime, response.body)

        product.update_column(col, "https://#{CF_DISTRO}.cloudfront.net/#{key}")
      end
    end
  end

  def store_product_image(product, col, mime, data)
    type   = TYPES[col] || raise("FUCK")
    ext    = EXT[mime] || raise("FUCK")
    bucket = Rails.application.secrets.s3_bucket
    key    = "products/#{product.id}/images/#{type}.#{ext}"

    @s3.put_object(
      acl: 'public-read',
      key: key,
      bucket: bucket,
      content_type: mime,
      body: data
    )

    key
  end
end