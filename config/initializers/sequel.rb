require 'sequel/extensions/pagination'

DB = Sequel.connect(
  if (config = YAML.load_file((Rails.root + 'config' + 'database.yml').to_s))
    config[Rails.env.to_sym]
  else
    raise "Unable to get connection information from config/database.yml"
  end
)

Sequel::Model.plugin(:active_model)

Fuzz.keyspace = Rails.env
Fuzz.add_dictionary(:products,
  :source => lambda { DB[:products].select(:name).all.map { |p| p[:name] } },
  :stop_words => %w[ woods ],
  :min_word_size => 5
)
