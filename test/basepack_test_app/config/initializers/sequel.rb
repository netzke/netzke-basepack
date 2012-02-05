if defined? Sequel
  Sequel::Model.plugin :active_model
  Sequel::Model.plugin :validation_helpers
  db = Sequel.connect(YAML.load(ERB.new(File.read(File.join(Rails.root,'config','database.yml'))).result)[Rails.env])
  db.logger = Logger.new $stdout
end
