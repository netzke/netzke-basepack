### Form, Grid, Tree
*   New `attribute` DSL method and accompanying `attribute_overrides` config option allow reconfiguring the way specific model attributes are presented by both the grid and the form. The `column` DSL method has been left for configuring what's specific for a column.

*   `strong_default_attrs` config option has been renamed to `strong_values`

*   `attr_type` config option for columns/fields has been renamed to `type`

### Form
*   The `netzkeSubmit` and `netzkeLoad` endpoints have been renamed to `submit` and `load` respectively; keep
    this in mind if you override them in your app.

### Grid
*   The `del` action has been renamed to `delete`.

*   Columns configuration (by using the `Grid.column` DSL method, or the `columns` configuration option) no longer has effect on corresponding form fields. Use the new `attribute` DSL method or the `attribute_overrides` config option (see above) to set the common configuration option for both column and form field.

*   Virtual columns declared with the `column` DSL method are no longer automatically appended to the end of the column
    list; use the `columns` config option or override the `Grid#columns` method to explicitely list them.

*   Warn the user at an attempt to change the page when there are unapplied changes; disable the warning by
    setting `disable_dirty_page_warning` to `true`.

*   The endpoints dropped their prefix `server`; additionally, `serverDelete` has become `destroy`; keep this in mind if you override endpoints in your app.

*   By default, Grid now handles large number of records by using a buffered store (allows for "infinite scrolling").
    Set `paging` to `true` if you want pagination instead.

*   By default, Grid now uses form to add/edit records. Set `edit_inline` to true to use inline editing when possible
    (implicitly sets `paging` to `true`).

*   The toolbar was reduced to 'add', 'edit', 'delete', and 'search' buttons by default. Additionally, the 'apply'
    button is added when `edit_inline` is set to `true`.

*   All scope-related configs (including those of the columns) now only accept a Proc object.

*   Class-level configuration is gone (its sole purpose was to allow reducing the amount of generated JS code - not worth it).

*   `enable_edit_in_form`, `enable_edit_inline`, `enable_pagination` options are gone.

*   `enable_extended_search` option is gone.

### Misc
*   Base classes of main componens have been renamed from `Netzke::Basepack::{Grid|Form|Tree|Window|Viewport}` to `Netzke::{Grid|Form|Tree|Window|Viewport}::Base`.
*   Remove `Netzke::Basepack::TapPanel` and `Netzke::Basepack::Accordion`. The only purpose for them was dynamic loading
    of child components, which didn't prove that useful.

Please check [0-12](https://github.com/netzke/netzke-basepack/blob/0-12/CHANGELOG.md) for previous changes.
