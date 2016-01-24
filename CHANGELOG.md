# v1.0.0.0 - 2016-01-04

## Components changed/renamed

*   Base classes of main componens have been renamed from `Netzke::Basepack::{Grid|Form|Tree|Window|Viewport}` to `Netzke::{Grid|Form|Tree|Window|Viewport}::Base`.

*   `Netzke::Basepack::TabPanel` and `Netzke::Basepack::Accordion` have been removed. The only purpose for them was dynamic loading of child components, which didn't prove that useful.

## Form, Grid, Tree

### Breaking changes

*   `strong_default_attrs` config option has been renamed to `strong_values`.

*   `attr_type` config option for columns/fields has been renamed to `type`.

*   The new `attribute` DSL method and the accompanying `attribute_overrides` config option allow reconfiguring the way specific model attributes are presented by both the grid and the form. The `column` DSL method has been left for configuring what's specific for a column. For details, see [Netzke::Basepack::Attributes](http://www.rubydoc.info/github/netzke/netzke-basepack/Netzke/Basepack/Attributes).

*   `data_adapter` method has been renamed to `model_adapter`

*   `model_class` method in `AbstractAdapter` has been renamed to `model`

## Form

### Breaking changes

*   The `netzkeSubmit` and `netzkeLoad` endpoints have been renamed to `submit` and `load` respectively; keep this in mind if you override them in your app.

## Grid

### Breaking changes

*   Column/field label for association no longer includes association method name by default. For example, for
    `author__name` attribute it'll now be "Author", not "Author  name".

*   `preconfigure_record_window` has been renamed to `configure_form_window`

*   The `default_fields_for_forms` method has been renamed to `default_form_items`.

*   The `data_store` config option has been renamed to `store_config`.

*   Permissions configuration got consolidated into single `permissions` config option. See [Netzke::Grid::Base](http://www.rubydoc.info/github/netzke/netzke-basepack/Netzke/Grid/Base)

*   The `del` action has been renamed to `delete`.

*   Columns configuration (by using the `Grid.column` DSL method, or the `columns` configuration option) no longer has effect on corresponding form fields. Use the new `attribute` DSL method or the `attribute_overrides` config option (see above) to set the common configuration option for both column and form field.

*   Virtual columns declared with the `column` DSL method are no longer automatically appended to the end of the column
    list; use the `columns` config option or override the `Grid#columns` method to explicitely list them.

*   The endpoints dropped their prefix `server`; additionally, `serverDelete` has become `destroy`; keep this in mind if you override endpoints in your app.

*   All scope-related configs (including those of the columns) now only accept a Proc or a Hash.

*   Class-level component configuration is gone (its sole purpose was to allow reducing the amount of generated JS code - not worth it).

*   `enable_edit_in_form`, `enable_edit_inline`, `enable_pagination` options are gone.

*   `enable_extended_search` option is gone.

### I18n

*   Before to localize association attribute it was needed to specify the attribute in the doubre-underscore notation,
    for example:


        es:
          activerecord:
            attributes:
              book:
                author__name: Autor

    Now it should be cut down to the association name:

        es:
          activerecord:
            attributes:
              book:
                author: Autor

### New and improved

*   By default, Grid now uses form to add/edit records. Set `edit_inline` to true to use inline editing when possible (implicitly sets `paging` to `true`).

*   By default, Grid now handles large number of records by using a buffered store (allows for "infinite scrolling"). Set `paging` to `true` if you want pagination instead.

*   The toolbar was reduced to 'add', 'edit', 'delete', and 'search' buttons by default. Additionally, the 'apply' button is added when `edit_inline` is set to `true`.

*   Buttons previously disabled due to permissions are now not added to the bottom bar alltogether.

*   Override new `configure_form` method to specify extra configuration to the forms

*   Warn the user at an attempt to change the page when there are unapplied changes; disable the warning by setting `disable_dirty_page_warning` to `true`.

*   Proper support for decimal datatype was added

*   Multiediting of reconds now works properly with boolean fields (a tristate selector was implemented).

Please check [0-12](https://github.com/netzke/netzke-basepack/blob/0-12/CHANGELOG.md) for previous changes.
