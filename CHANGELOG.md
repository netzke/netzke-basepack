## Grid
* By default, grid now uses form to add/edit records. Set `edit_inline` to true to use inline editing when possible.
* The toolbar got reduced to 'add', 'edit', 'delete', and 'search' buttons by default. The 'apply' button is added when
  `edit_inline` is set to `true`.
* `enable_edit_in_form` and `enable_edit_inline` options are gone.
* `enable_extended_search` option is gone
* All scope-related configs (including those of the columns) now only accept a Proc object.

## Misc
* Remove `Netzke::Basepack::TapPanel` and `Netzke::Basepack::Accordion`. The only purpose for them was dynamic loading
    of child components, which didn't prove that useful.

Please check [0-12](https://github.com/netzke/netzke-basepack/blob/0-12/CHANGELOG.md) for previous changes.
