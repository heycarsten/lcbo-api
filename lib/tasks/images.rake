desc 'Populate product images'
task images: :environment do
  require 'excon'

  puts "Attaching product images..."

  Product.where("is_dead = 'f' AND image_url IS NULL").each do |product|
    id = product.id.to_s.rjust(7, '0')

    thumb_url = "http://www.lcbo.com/app/images/products/thumbs/#{id}.jpg"
    full_url  = "http://www.lcbo.com/app/images/products/#{id}.jpg"

    if Excon.head(thumb_url).status == 200
      product.update_attributes(
        image_url:       full_url,
        image_thumb_url: thumb_url
      )
      dot = '.'
    else
      dot = '-'
    end

    STDOUT.print(dot)
    STDOUT.flush
  end

  puts
end
