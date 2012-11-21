# Netzke Basepack [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/nomadcoder/netzke-basepack)

[RDocs](http://rdoc.info/github/nomadcoder/netzke-basepack)

**WARNING 2012-10-20: This README is reflecting the upcoming v0.8. For v0.7 see the [0-7 branch](https://github.com/nomadcoder/netzke-core/tree/0-7).**

A pack of pre-built [Netzke](http://netzke.org) components that can be used as building blocks for your application.

## Included components

Basepack includes the following components:

* [GridPanel](http://rdoc.info/github/nomadcoder/netzke-basepack/Netzke/Basepack/GridPanel) - a grid panel with a thick bag of features
* [FormPanel](http://rdoc.info/github/nomadcoder/netzke-basepack/Netzke/Basepack/FormPanel) - a form panel with automatic binding of fields
* [TabPanel](http://rdoc.info/github/nomadcoder/netzke-basepack/Netzke/Basepack/TabPanel) - a tab panel with support for lazy loading of nested components
* [AccordionPanel](http://rdoc.info/github/nomadcoder/netzke-basepack/Netzke/Basepack/AccordionPanel) - an accordion panel with support for lazy loading of nested components
* [Window](http://rdoc.info/github/nomadcoder/netzke-basepack/Netzke/Basepack/Window) - a window which stores its size, position, and maximized state

Besides, Basepack implements persistence of region sizes and collapsed states of an arbitrary component that uses [border layout](http://docs.sencha.com/ext-js/4-1/#!/api/Ext.layout.container.Border) (see [ItemsPersistence](http://rdoc.info/github/nomadcoder/netzke-basepack/Netzke/Basepack/ItemsPersistence)).

For more pre-built components refer to [Netzke Community-pack](https://github.com/nomadcoder/netzke-communitypack).

## Requirements

* Ruby ~> 1.9.2
* Rails ~> 3.2.0
* Ext JS ~> 4.1.0

## Installation

In your Gemfile:

    gem 'netzke-basepack'

For the "edge" stuff, tell bundler to get the gem straight from GitHub:

    gem 'netzke-basepack', :git => "git://github.com/nomadcoder/netzke-basepack.git"

## Usage

Embed a basepack component into a view as any other Netzke component, e.g.:

```erb
<%= netzke :books, :class_name => 'Netzke::Basepack::GridPanel', :model => 'Book' %>
```

For more examples, see http://netzke-demo.herokuapp.com ([source code](https://github.com/nomadcoder/netzke-demo)), and look into `test/basepack_test_app`.

## Testing and playing with Netzke Basepack

Netzke Basepack is bundled with Cucumber and RSpec tests. If you would like to contribute to the project, you may want to learn how to [run the tests](https://github.com/nomadcoder/netzke-core/wiki/Automated-testing).

Besides, the bundled test application is a convenient [playground](https://github.com/nomadcoder/netzke-core/wiki/Playground) for those who search to experiment with the framework.

After starting up the test app, you can see the list of functional test components on the index page (along with links to the source code):

    http://localhost:3000/

## Using ORM other than ActiveRecord

Using ActiveRecord as its default ORM, Basepack is designed to be extendable with data adapters for other ORMs. If you're thinking about implementing an adapter, `AbstractAdapter` and `ActiveRecordAdapter` classes can be used as a reference.

There's some work being done in the direction of implementing [DataMapper](https://github.com/nomadcoder/netzke-basepack-dm) and [Sequel](https://github.com/nomadcoder/netzke-basepack-sequel) adapters.

## Icons support

Netzke Basepack can make use of FamFamFam Silk icon set (http://www.famfamfam.com/archive/silk-icons-thats-your-lot/). To enable this, download the icons and put the "icons" folder into your app's public/images folder. Then restart your application.

## Useful links
* [Project website](http://netzke.org)
* [Live-demo](http://netzke-demo.herokuapp.com)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

---
Copyright (c) 2008-2012 [nomadcoder](http://twitter.com/nomadcoder), released under the MIT license.

Note, that Ext JS itself is licensed [differently](http://www.sencha.com/products/extjs/license/).
