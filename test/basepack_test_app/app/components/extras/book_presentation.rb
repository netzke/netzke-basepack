module Extras
  module BookPresentation
    # A setter that creates an author on the fly
    def author_first_name_setter
      lambda do |r,v|

        data_adapter = Netzke::Basepack::DataAdapters::AbstractAdapter.adapter_class(r.class).new(r.class)

        if v.is_a?(Integer)
          r.author = data_adapter.find_record(v)
        else
          r.author = data_adapter.new_record(:first_name => v).save!
        end
      end
    end

    # A getter that returns "YES" if exemplars are more than 3, "NO" otherwise
    def in_abundance_getter
      lambda {|r| r.exemplars.to_i > 3 ? "YES" : "NO"}
    end

  end
end
