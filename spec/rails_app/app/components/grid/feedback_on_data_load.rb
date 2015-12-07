# A grid that overrides the `get_data` endpoint in order to send a command to the client
module Grid
  class FeedbackOnDataLoad < Netzke::Basepack::Grid
    def configure(c)
      super
      c.model = 'Book'
    end

    endpoint :read do |params|
      client.nz_feedback "Data loaded!"
      super params
    end
  end
end
