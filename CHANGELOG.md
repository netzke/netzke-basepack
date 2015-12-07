### Form

*   `netzkeSubmit` and `netzkeLoad` endpoints have been renamed to `serverSubmit` and `serverLoad` respectively; keep
    this in mind also when if you override them in your app.

### Grid

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
