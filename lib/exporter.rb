class Exporter

  def initialize(key)
    @key = key
    @s3  = AWS::S3::S3Object
    @dir = Dir.mktmpdir
    File.chmod(0766, @dir)
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
    @s3.store("datasets/#{@key}.zip", open(@zip), ENV['S3_BUCKET'],
      :content_type => 'application/zip',
      :access => :public_read
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