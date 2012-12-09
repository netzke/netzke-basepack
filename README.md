# Netzke Basepack [![Build Status](https://secure.travis-ci.org/nomadcoder/netzke-basepack.png?branch=master)](http://travis-ci.org/nomadcoder/netzke-basepack) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/netzke/netzke-basepack)

[RDocs](http://rdoc.info/github/netzke/netzke-basepack)

**WARNING 2012-10-20: This README is reflecting the upcoming v0.8. For v0.7 see the [0-7 branch](https://github.com/netzke/netzke-core/tree/0-7).**

A pack of pre-built [Netzke](http://netzke.org) components that can be used as building blocks for your application.

## Included components

Basepack includes the following components:

* [Grid](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Grid) - a grid panel with a thick bag of features
* [Form](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Form) - a form panel with automatic binding of fields
* [TabPanel](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/TabPanel) - a tab panel with support for lazy loading of nested components
* [Accordion](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Accordion) - an accordion panel with support for lazy loading of nested components
* [Window](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Window) - a window which stores its size, position, and maximized state

Besides, Basepack implements persistence of region sizes and collapsed states of an arbitrary component that uses [border layout](http://docs.sencha.com/ext-js/4-1/#!/api/Ext.layout.container.Border) (see [ItemPersistence](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/ItemPersistence)).

For more pre-built components refer to [Netzke Community-pack](https://github.com/netzke/netzke-communitypack).

## Requirements

* Ruby ~> 1.9.2
* Rails ~> 3.2.0
* Ext JS ~> 4.1.0

## Installation

In your Gemfile:

    gem 'netzke-basepack'

For the "edge" stuff, tell bundler to get the gem straight from GitHub:

    gem 'netzke-basepack', :git => "git://github.com/netzke/netzke-basepack.git"

## Usage

Embed a basepack component into a view as any other Netzke component, e.g.:

```erb
<%= netzke :books, :class_name => 'Netzke::Basepack::Grid', :model => 'Book' %>
```

For more examples, see http://netzke-demo.herokuapp.com ([source code](https://github.com/netzke/netzke-demo)), and look into `test/basepack_test_app`.

## Running tests

The bundled `test/basepack_test_app` application used for automated testing can be easily run as a stand-alone Rails app. It's a good source of concise, focused examples. After starting the application, access any of the test components (located in `app/components`) by using the following url:

    http://localhost:3000/components/{name of the component's class}

For example [http://localhost:3000/components/BookGrid](http://localhost:3000/components/BookGrid)

Also, you can see the list of test components on the index page (along with links to the source code):

    http://localhost:3000/

Before being able run the test app and the tests themselves, you must link your Ext JS library to `test/basepack_test_app/public`, e.g. (from the gems's root):

    $ ln -s ~/code/sencha/ext-4.1.1 test/basepack_test_app/public/extjs

For cucumber tests (from `test/basepack_test_app`):

    $ cucumber features


## Using ORM other than ActiveRecord

Using ActiveRecord as its default ORM, Basepack is designed to be extendable with data adapters for other ORMs. If you're thinking about implementing an adapter, `AbstractAdapter` and `ActiveRecordAdapter` classes can be used as a reference.

There's some work being done in the direction of implementing [DataMapper](https://github.com/nomadcoder/netzke-basepack-dm) and [Sequel](https://github.com/nomadcoder/netzke-basepack-sequel) adapters, but at this moment the code is broken.

## Icons support

Netzke Basepack can make use of FamFamFam Silk icon set (http://www.famfamfam.com/archive/silk-icons-thats-your-lot/). To enable this, download the icons and put the "icons" folder into your app's public/images folder. Then restart your application.

## Useful links
* [Project website](http://netzke.org)
* [Live-demo](http://netzke-demo.herokuapp.com)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

---
Copyright (c) 2008-2012 [nomadcoder](https://twitter.com/nomadcoder), released under the MIT license (see LICENSE).

**Note** that Ext JS is licensed [differently](http://www.sencha.com/products/extjs/license/), and you may need to purchase a commercial license in order to use it in your projects!
