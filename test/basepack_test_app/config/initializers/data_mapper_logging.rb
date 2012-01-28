DataMapper::Logger.new($stdout, :debug) unless Rails.env.production?
