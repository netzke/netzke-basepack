# Netzke Basepack [![Build Status](https://travis-ci.org/netzke/netzke-basepack.svg?branch=master)](https://travis-ci.org/netzke/netzke-basepack) [![Code Climate](https://codeclimate.com/github/netzke/netzke-basepack/badges/gpa.svg)](https://codeclimate.com/github/netzke/netzke-basepack)

[RDocs](http://rdoc.info/github/netzke/netzke-basepack)

A pack of pre-built [Netzke](http://netzke.org) components that can be used as building blocks for your webapps.

*Notes on versioning:*

* The latest *released* version is: [![Gem Version](https://badge.fury.io/rb/netzke-basepack.svg)](https://badge.fury.io/rb/netzke-basepack)
* The version under development (master): [version.rb](https://github.com/netzke/netzke-core/blob/master/lib/netzke/core/version.rb)
* For other versions check corresponding [branches](https://github.com/netzke/netzke-core/branches)

## Included components

Basepack includes the following components:

* [Grid](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Grid/Base) - a grid panel with a thick bag of features
* [Tree](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Tree/Base) - a tree panel with features similar to the Grid
* [Form](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Form/Base) - a form panel with automatic binding of fields
* [Window](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Window/Base) - a window which stores its size, position, and maximized state
* [Viewport](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Viewport/Base) - a full-window component usually used as one-page application base

Besides, Basepack implements:

* persistence of region sizes and collapsed states of an arbitrary component that uses
Ext's border layout (see [ItemPersistence](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/ItemPersistence))
* [GridLiveSearch](http://rdoc.info/github/netzke/netzke-basepack/Netzke/Basepack/GridLiveSearch) - a plugin that allows
enhancing any grid with live search functionality

## Requirements

* Ruby >= 1.9.3
* Rails ~> 4.2.0
* Ext JS = 5.1.1

## Installation

In your Gemfile:

    gem 'netzke-basepack'

For the "edge" stuff, instruct bundler to get the gem straight from GitHub:

    gem 'netzke-basepack', github: "netzke/netzke-basepack"

## Basic usage

Embed a basepack component into a view as any other Netzke component, e.g.:

```erb
<%= netzke :books, class_name: 'Netzke::Grid::Base', model: 'Book' %>
```

This will give you a grid with all the many features, configured to use your `Book` model.

For detailed examples with code see http://demo.netzke.org

## Running tests

Before running the tests, you must link your Ext JS library to `spec/rails_app/public`, e.g. (from the gems's root):

    $ ln -s PATH/TO/YOUR/EXTJS/FILES spec/rails_app/public/extjs

The bundled `spec/rails_app` application used for automated testing can be easily run as a stand-alone Rails app. It's a
good source of concise, focused examples. After starting the application, access any of the test components (located in
`app/components`) by using the following url:

    http://localhost:3000/netzke/components/{name of the component's class}

For example [http://localhost:3000/netzke/components/Grid::Books](http://localhost:3000/netzke/components/Grid::Books)

To run all the tests (from the gem's root):

    $ rake

*Sourcing Ext JS files from Sencha CDN is not possible with Basepack at the moment*.

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

If you feel particularily generous, you can donate a couple of bucks weekly at [Gratipay](https://gratipay.com/~mxgrn/).

## Useful links
* [Project website](http://netzke.org)
* [Live demo](http://demo.netzke.org)
* [Twitter](http://twitter.com/netzke) - latest news about the framework

---
Copyright (c) 2009-2015 [Good Bit Labs](http://goodbitlabs.com/), released under the same license as [Ext JS](https://www.sencha.com/legal/#Sencha_Ext_JS)
