# v0.7 to v0.8 upgrade guide

This guide describes the API changes that took place in Netzke Basepack, additionally to those that are found in Netzke Core (see Netzke Core upgrade guide).

## Defining Netzke attributes on a model

Methods like `netzke_attribute`, `netzke_expose_attributes` etc are gone. Define your columns/fields right on grids/forms.

## GridPanel

### Customizing the add/edit forms

The components that represent a window with a form inside, that is used for adding/(multi-)editing of records, are now referred as: `add_window`, `edit_window` (instead of `add_form` and `edit_form`). Both accept a config param `form_config`, which can be used to configure the contained FormPanel - e.g., to change its layout or even class. For example, to change the layout of a form that is found in the edit window, do the following in your grid class:

    component :edit_window do |c|
      super(c)
      c.form_config.items = [:name, :author__name]
    end
