require 'spec_helper'

feature "Mocha specs", js: true do
  # if a spec path is provided, create a single spec for it
  if path = ENV["S"]
    it "passes Mocha specs for #{path}" do
      run_js_specs(path)
    end
  else
    # create a spec for each file spec dir that ends on "_spec.js.coffee"
    dir = File.dirname(__FILE__)
    Dir[File.join(dir, "**/*_spec.js.coffee")].each do |f|
      spec_path = f.sub(dir, '')[1..-1].sub(/_spec\..*$/, '')

      it "passes Mocha specs for #{spec_path.classify}" do
        run_js_specs(spec_path)
      end
    end
  end
end
