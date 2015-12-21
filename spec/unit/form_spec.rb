require 'spec_helper'

describe Netzke::Form::Base do
  describe "without bottombar" do
    it "does not include bbar in client config" do
      class NoBbarForm < Netzke::Form::Base
        def configure(c)
          super
          c.bbar = false
        end
      end

      expect(NoBbarForm.new.js_config[:bbar]).to be_falsy
    end
  end
end
