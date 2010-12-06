DB = Sequel.connect(
  if (config = YAML.load((Rails.root + 'config' + 'database.yml').to_s))
    config[Rails.env.to_sym]
  else
    raise "Unable to pull connection string from config/database.yml"
  end
)
