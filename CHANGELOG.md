### Form
*   The `netzkeSubmit` and `netzkeLoad` endpoints have been renamed to `submit` and `load` respectively; keep
    this in mind if you override them in your app.

### Grid
*   Grid: warn the user at an attempt to change the page when there are unapplied changes; disable the warning by
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

*   Remove `Netzke::Basepack::TapPanel` and `Netzke::Basepack::Accordion`. The only purpose for them was dynamic loading
    of child components, which didn't prove that useful.

Please check [0-12](https://github.com/netzke/netzke-basepack/blob/0-12/CHANGELOG.md) for previous changes.
