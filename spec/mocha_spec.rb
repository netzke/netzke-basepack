require 'spec_helper'
require 'active_record/fixtures'

feature "Mocha specs", js: true do
  before do |x|
    # for each spec load a dedicated set of fixtures
    # TODO: replace with factories
    spec_name = x.example.description.split.last.underscore
    fixtures_dir = "../../spec/fixtures/#{spec_name}"
    Dir.glob(File.join(Rails.root, "#{fixtures_dir}/*.yml")).each do |fixture_file|
      ActiveRecord::Fixtures.reset_cache
      ActiveRecord::Fixtures.create_fixtures(File.join(Rails.root, fixtures_dir), File.basename(fixture_file, '.*'))
    end
  end

  # if a component provided, create a single spec for it
  if comp_class = ENV["C"]
    spec = comp_class.underscore.gsub("/", "__")
    it "runs successfully for #{comp_class}" do
      run_js_specs(comp_class, spec)
    end
  else
    # ... otherwise create a spec for each file in mocha/**/* except for extra/ and support/
    dir = File.join(File.dirname(__FILE__), "mocha")
    Dir[File.join(dir, "**/*")].each do |f|
      next if File.directory?(f)

      file = f.gsub(dir, "")[1..-1].split(".").first
      next if file.index(/helper$/) || file.index(/^extra\//)

      comp = file.split("/").map(&:camelize).join("::")

      it "runs successfully for #{comp}" do
        spec = comp.underscore.gsub("/", "__")
        run_js_specs(comp, spec)
      end
    end
  end
end
