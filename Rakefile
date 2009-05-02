require 'echoe'

Echoe.new("netzke-basepack") do |p|
  p.author = "Sergei Kozlov"
  p.email = "sergei@writelesscode.com"
  p.summary = "Base Netzke widgets - grid, form, tree, and more"
  p.url = "http://writelesscode.com"
  p.runtime_dependencies = ["searchlogic >=1.6.2", "netzke-core >= 0.2.12"]
  p.development_dependencies = []
  p.test_pattern = 'test/**/*_test.rb'

  # fixing the problem with lib/*-* files being removed while doing manifest
  p.clean_pattern = ["pkg", "doc", 'build/*', '**/coverage', '**/*.o', '**/*.so', '**/*.a', '**/*.log', "{ext,lib}/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/Makefile", "{ext,lib}/**/*.{bundle,so,obj,pdb,lib,def,exp}", "ext/**/Makefile", "pkg", "*.gem", ".config"]
end
