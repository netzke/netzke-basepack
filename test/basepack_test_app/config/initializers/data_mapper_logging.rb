if defined?(DataMapper) && Rails.env.development?
  DataMapper::Logger.new($stdout, :debug)
end
