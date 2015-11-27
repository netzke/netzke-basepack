require 'spec_helper'

describe Netzke::Basepack::Form do
  describe "without bottombar" do
    it "should not include bbar in client config" do
      class NoBbarForm < Netzke::Basepack::Form
        def configure(c)
          super
          c.bbar = false
        end
      end

      expect(NoBbarForm.new.js_config[:bbar]).to be_falsy
    end
  end
end
