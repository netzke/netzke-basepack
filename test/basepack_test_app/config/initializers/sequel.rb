if defined? Sequel
  Sequel::Model.plugin :active_model
  Sequel::Model.plugin :validation_helpers
  Sequel::Model.plugin :identity_map
  db = Sequel.connect(YAML.load(ERB.new(File.read(File.join(Rails.root,'config','database.yml'))).result)[Rails.env])
  db.logger = Logger.new $stdout if Rails.env.development?

    Sequel::Model.class_eval do
      # Emulate ARs timestamp behavior
      def before_create
        self.created_at ||= Time.now
        self.updated_at ||= Time.now
      end

      def before_update
        self.updated_at ||= Time.now
      end

      # enable mass-assignment of pk, so that pickle scenarios can work properly when id is specified
      unrestrict_primary_key

      # FactoryGirl compatibility fix
      def save!
        save :raise_on_save_failure => true
      end
    end
end
