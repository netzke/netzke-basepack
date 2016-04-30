# v1.0.1.0 - 2016-05-01

### Breaking changes

*   Grid, Tree: use the `attributes` config option if you need to configure what attributes are shown in both the grid
    and its forms. The `columns` config option now only takes effect on grid, and it doesn't modify the layout of its
    forms.

*   `edit_inline` config option is gone (see the new `editing` option).

*   Provide full association name using the double-underscore notation in locales (e.g. `author__name` instead of just
    `author`). This reverts the change introduced in 1.0.0.0.

### New and mproved

*   Grid: new `paging` and `editing` options allow for more flexible combinations of different editing and paging modes.

*   Tree: fixed date and datetime columns in some browsers.

*   Tree: implement `scope` config option for Tree.

*   Fix bug that allowed editing grids in inline mode by dblclicking the rows.

*   Fix bug that allowed toggling checkbox in grids with prohibited update.

*   Explicitly speficying grid actions will no longer display the buttons, whose actions are not permitted.

Please check [1-0-0](https://github.com/netzke/netzke-basepack/blob/1-0-0/CHANGELOG.md) for previous changes.
