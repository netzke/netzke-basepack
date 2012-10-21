# Netzke Basepack [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/nomadcoder/netzke-basepack)

[RDocs](http://rdoc.info/github/nomadcoder/netzke-basepack)

**WARNING 2012-10-20: This README is WIP, in the transition from v0.7 to v0.8. For v0.7 see the [0-7 branch](https://github.com/nomadcoder/netzke-basepack/tree/0-7).**

A pack of pre-built [Netzke](http://netzke.org) components - such as grid, form, tab panel, etc.

## Requirements

* Ruby 1.9.2
* Rails ~> 3.1.0
* Ext JS ~> 4.1.0

## Installation

In your Gemfile:

    gem 'netzke-basepack'

For the "edge" stuff, tell bundler to get the gem straight from GitHub:

    gem 'netzke-basepack', :git => "git://github.com/nomadcoder/netzke-basepack.git"

## Usage

Embed a basepack component into a view as any other Netzke component, e.g.:

  <%= netzke :books, :class_name => 'Netzke::Basepack::GridPanel', :model => 'Book' %>

For more examples, see http://netzke-demo.herokuapp.com, and look into test/basepack_test_app.

## Testing and playing with Netzke Basepack

Netzke Basepack is bundled with Cucumber and RSpec tests. If you would like to contribute to the project, you may want to learn how to [run the tests](https://github.com/nomadcoder/netzke-core/wiki/Automated-testing).

Besides, the bundled test application is a convenient [playground](https://github.com/nomadcoder/netzke-core/wiki/Playground) for those who search to experiment with the framework.

After starting up the test app, you can see the list of functional test components on the index page (along with links to the source code):

    http://localhost:3000/

## Using ORM other than ActiveRecord
Using ActiveRecord as its default ORM, Basepack is designed to be extendable with data adapters for other ORMs. If you're thinking about implementing an adapter, `AbstractAdapter` and `ActiveRecordAdapter` classes can be used as a reference.

There's some work done in the direction of implementing [DataMapper](https://github.com/nomadcoder/netzke-basepack-dm) and [Sequel](https://github.com/nomadcoder/netzke-basepack-sequel) adapters.

## Icons support
Netzke Basepack can make use of FamFamFam Silk icon set (http://www.famfamfam.com/archive/silk-icons-thats-your-lot/). To enable this, download the icons and put the "icons" folder into your app's public/images folder. Then restart your application.

## Ext JS 3 support
Versions 0.6.x are for you if you're using Ext 3 (*hardly maintained*)

## Useful links
* [Project website](http://netzke.org)
* [Documentation](https://github.com/nomadcoder/netzke/wiki)
* [Live-demo](http://netzke-demo.herokuapp.com)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

---
Copyright (c) 2008-2012 [nomadcoder](http://twitter.com/nomadcoder), released under the MIT license.

Note, that Ext JS itself is licensed [differently](http://www.sencha.com/products/extjs/license/).
