# v0.7 to v0.8 upgrade guide

This guide describes the API changes that took place in Netzke Basepack, additionally to those that are found in Netzke Core (see Netzke Core upgrade guide).

## GridPanel

### Customizing the add/edit forms

The components that represent a window with a form inside, that is used for adding/(multi-)editing of records, are now referred as: `add_window`, `edit_window` (instead of `add_form` and `edit_form`). Both accept a config param `form_config`, which can be used to configure the contained FormPanel - e.g., to change its layout or even class. For example, to change the layout of a form that is found in the edit window, do the following in your grid class:

    def edit_window_component(c)
      super
      c.form_config.items = [:name, :author__name]
    end

Here, by defining `edit_window_component` method, we override the `edit_window` component - the functionality provided by Netzke Core.
