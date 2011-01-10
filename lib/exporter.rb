class Exporter

  def initialize(key)
    @key = key
    @s3  = RightAws::S3Interface.new(ENV['S3_ACCESS_KEY'], ENV['S3_SECRET_KEY'])
    @dir = Dir.mktmpdir
    @zip = File.join(@dir, Time.now.strftime('lcbo-%Y%m%d.zip'))
  end

  def self.run(key)
    new(key).run
  end

  def run
    copy_tables
    make_archive
    upload_archive
  end

  def copy_tables
    copy :stores
    copy :products
    copy :inventories
  end

  def make_archive
    Zippy.create(@zip) do |zip|
      %w[ stores products inventories ].each do |table|
        zip["#{table}.csv"] = File.open(csv_file(table))
      end
    end
  end

  def upload_archive
    @s3.put(ENV['S3_BUCKET'], "datasets/#{@key}.zip", open(@zip),
      'x-amz-acl'    => 'public-read',
      'Content-Type' => 'application/zip'
    )
  end

  private

  def cols(table)
    { :stores => Store,
      :products => Product,
      :inventories => Inventory
    }[table].public_fields.join(', ')
  end

  def csv_file(table)
    File.join(@dir, "#{table}.csv")
  end

  def copy(table)
    DB << "COPY #{table} (#{cols(table)}) TO '#{csv_file(table)}' DELIMITER ',' CSV HEADER"
  end

end