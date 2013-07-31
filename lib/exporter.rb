class Exporter

  TABLES = %w[ stores products inventories ]

  def initialize(key)
    AWS::S3::Base.establish_connection!(
      access_key_id:     LCBOAPI[:s3][:access_key],
      secret_access_key: LCBOAPI[:s3][:secret_key])
    @key = key
    @s3  = AWS::S3::S3Object
    @dir = File.join(Dir.tmpdir, 'lcboapi-tmp')
    `mkdir -p #{@dir} && chmod 0777 #{@dir}`
    @zip = File.join(@dir, Time.now.strftime('lcbo-%Y%m%d.zip'))
  end

  def self.run(key)
    new(key).run
  end

  def run
    copy_tables
    make_archive
    upload_archive
    cleanup
  end

  def copy_tables
    copy :stores
    copy :products
    copy :inventories
  end

  def make_archive
    files = TABLES.map { |t| csv_file(t) }.join(' ')
    `zip -j #{@zip} #{files}`
  end

  def upload_archive
    @s3.store("datasets/#{@key}.zip", open(@zip), LCBOAPI[:s3][:bucket],
      content_type: 'application/zip',
      access: :public_read
    )
  end

  def cleanup
    `rm -rf #{@dir}`
  end

  private

  def cols(table)
    { stores:      Store,
      products:    Product,
      inventories: Inventory
    }[table].public_columns.join(', ')
  end

  def csv_file(table)
    File.join(@dir, "#{table}.csv")
  end

  def copy(table)
    File.open(csv_file(table), 'w') do |file|
      DB.copy_table("COPY #{table} (#{cols(table)}) TO STDOUT DELIMITER ',' CSV HEADER") do |line|
        file.puts(line)
      end
    end
  end

end
