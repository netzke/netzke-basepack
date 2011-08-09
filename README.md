# Netzke Basepack

A pack of pre-built [Netzke](http://netzke.org) components - such as grid, form, tab panel, etc.

## Requirements

* Ruby 1.9.2 (1.8.7 may work, too)
* Rails >= 3.0.0
* Ext JS >= 4.0.0

## Installation

In your Gemfile:

    gem 'netzke-basepack'

For the "edge" stuff, tell bundler to get the gem straight from GitHub:

    gem 'netzke-basepack', :git => "git://github.com/skozlov/netzke-basepack.git"

## Usage

Embed a basepack component into a view as any other Netzke component, e.g.:

  <%= netzke :books, :class_name => 'Netzke::Basepack::GridPanel', :model => 'Book' %>

For more examples, see http://demo.netzke.com, and look into test/rails_app.

## Testing and playing with Netzke Basepack

Netzke Basepack is bundled with Cucumber and RSpec tests. If you would like to contribute to the project, you may want to learn how to [run the tests](https://github.com/skozlov/netzke-core/wiki/Automated-testing).

Besides, the bundled test application is a convenient [playground](https://github.com/skozlov/netzke-core/wiki/Playground) for those who search to experiment with the framework.

After setting up the test application, you can access the test components (from test/rails_app/app/components) like this:

    http://localhost:3000/components/<name_of_the_test_component_class>

e.g.:

    http://localhost:3000/components/UserGrid

## Icons support
Netzke Basepack can make use of FamFamFam Silk icon set (http://www.famfamfam.com/archive/silk-icons-thats-your-lot/). To enable this, download the icons and put the "icons" folder into your app's public/images folder. Then restart your application.

## Ext 3 support
Versions 0.6.x are for you if you're using Ext 3 (*hardly maintained*)

## Rails 2 support
With Rails 2 (and Ext 3 only), use versions 0.5.x (*not maintained*)

## More info
Official project site: http://netzke.org

Twitter:

* latest news about Netzke: http://twitter.com/netzke
* author's rambling about osx, productivity and what not:  http://twitter.com/nomadcoder

Many (if a bit outdated) tutorials: http://blog.writelesscode.com

---
Copyright (c) 2008-2011 NomadCoder, released under the MIT license
