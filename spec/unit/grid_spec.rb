require 'spec_helper'
describe Netzke::Grid::Base do
  describe "#configure_form_window" do
    it "passes shared config to the form" do
      class GridTestOne < Netzke::Grid::Base
        def configure(c)
          super
          c.model = "Book"
        end
      end

      config = ActiveSupport::OrderedOptions.new
      GridTestOne.new.configure_form_window(config)

      expect(config.form_config.model).to eql Book
    end

    it "passes attribute configs down to its forms" do
      class GridTestTwo < Netzke::Grid::Base
        attribute :title do |c|
          c.read_only = true
        end

        def configure(c)
          super
          c.model = "Book"
        end
      end

      form = GridTestTwo.new.component_instance(:add_window).component_instance(:add_form)

      expect(form.fields[:title][:read_only]).to eql true
    end
  end
end
