# Netzke Basepack [![Gem Version](https://badge.fury.io/rb/netzke-basepack.png)](http://badge.fury.io/rb/netzke-basepack) [![Build Status](https://travis-ci.org/netzke/netzke-basepack.png?branch=0-9)](https://travis-ci.org/netzke/netzke-basepack) [![Code Climate](https://codeclimate.com/github/netzke/netzke-basepack.png)](https://codeclimate.com/github/netzke/netzke-basepack)

[RDocs](http://rdoc.info/github/netzke/netzke-basepack)

A pack of pre-built [Netzke](http://netzke.org) components that can be used as building blocks for your webapps.

## Included components

Basepack includes the following components:

* [Grid](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Grid) - a grid panel with a thick bag of features
* [Form](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Form) - a form panel with automatic binding of fields
* [TabPanel](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/TabPanel) - a tab panel with support for lazy loading of nested components
* [Accordion](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Accordion) - an accordion panel with support for lazy loading of nested components
* [Window](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Window) - a window which stores its size, position, and maximized state

Besides, Basepack implements:

* persistence of region sizes and collapsed states of an arbitrary component that uses
[border layout](http://docs.sencha.com/ext-js/4-1/#!/api/Ext.layout.container.Border) (see [ItemPersistence](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/ItemPersistence))
* [GridLiveSearch](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/GridLiveSearch) - a plugin that allows
enhancing any grid with live search functionality

## Requirements

* Ruby ~> 1.9.2
* Rails ~> 3.2.0
* Ext JS ~> 4.2.0

## Installation

In your Gemfile:

    gem 'netzke-basepack'

For the "edge" stuff, instruct bundler to get the gem straight from GitHub:

    gem 'netzke-basepack', github: "netzke/netzke-basepack"

## Basic usage

Embed a basepack component into a view as any other Netzke component, e.g.:

```erb
<%= netzke :books, class_name: 'Netzke::Basepack::Grid', model: 'Book' %>
```

For more examples, see http://netzke-demo.herokuapp.com ([source code](https://github.com/netzke/netzke-demo)), and look
into `spec/rails_app`.

## Running tests

Before running the tests, you must link your Ext JS library to `spec/rails_app/public`, e.g. (from the gems's root):

    $ ln -s PATH/TO/YOUR/EXTJS/FILES spec/rails_app/public/extjs

The bundled `spec/rails_app` application used for automated testing can be easily run as a stand-alone Rails app. It's a
good source of concise, focused examples. After starting the application, access any of the test components (located in
`app/components`) by using the following url:

    http://localhost:3000/netzke/components/{name of the component's class}

For example [http://localhost:3000/netzke/components/BookGrid](http://localhost:3000/netzke/components/BookGrid)

To run all the tests (from the gem's root):

    $ rake

*Sourcing Ext JS files from Sencha CDN is broken in Basepack at the moment*.

## Using ORM other than ActiveRecord

Using ActiveRecord as its default ORM, Basepack is designed to be extendable with data adapters for other ORMs. If
you're thinking about implementing an adapter, `AbstractAdapter` and `ActiveRecordAdapter` classes can be used as a
reference.

There's some work being done in the direction of implementing
[DataMapper](https://github.com/nomadcoder/netzke-basepack-dm) and
[Sequel](https://github.com/nomadcoder/netzke-basepack-sequel) adapters, but at this moment the code is broken.

## Icons support

Netzke Basepack can make use of FamFamFam Silk icon set (http://www.famfamfam.com/archive/silk-icons-thats-your-lot/).
To enable this, download the icons and put the "icons" folder into your app's `public/images` folder. Then restart your
application.

## Contributions and support

Help developing Netzke by submitting a pull request when you think others can benefit from it.

If you feel particularily generous, you can donate a couple of bucks weekly at [GitTip](https://www.gittip.com/uptomax/).

## Useful links
* [Project website](http://netzke.org)
* [Live-demo](http://netzke-demo.herokuapp.com)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

---
Copyright (c) 2008-2013 [Max Gorin](https://twitter.com/uptomax), released under the MIT license (see LICENSE).

**Note** that Ext JS is licensed [differently](http://www.sencha.com/products/extjs/license/), and you may need to
purchase a commercial license in order to use it in your projects.
