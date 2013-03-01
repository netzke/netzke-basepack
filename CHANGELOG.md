# 0.8.2 - WIP
* improvements
  * Add grid column config option `filter_with` (by firemind)
  * Add ActionColumn (move over from Communitypack)
  * `Grid.column` DSL method now appends the declared column to the list of default columns
  * Add support for autoSync store option (by scho)
  * Fix a glitch with Grid context menu
  * Add `enable_edit_inline` option for Grid; when set to false, all editing is done via forms
  * Make checkcolumn respect the `read_only` option

* bug fix
  * Fix one-to-many association method falling back to 'id'
  * Attributes in QueryBuilder displayed as 'null'

# 0.8.1 - 2012-12-15
* bug fix
  * TabPanel now shows the active tab's nested component upon loading
  * Accordion now shows the active pane's nested component upon loading

* improvements
  * Add support for validation errors on `before_destroy` (by firemind)

# 0.8.0 - 2012-12-09
* Basepack component renaming:
  * GridPanel -> Grid
  * FormPanel -> Form
  * AccordionPanel -> Accordion

* improvements
  * Grid/Form respect `attr_accessible` and `attr_protected` on the model; set the `role` config option on them to tune mass-assignment security
  * New `data_store` config option in Grid
  * Major internal refactorings
  * Window now also stores its 'maximized' state

* changes
  * BorderLayoutPanel is removed. Any component can now enable its items persistence by including `Netzke::Basepack::ItemPersistence` module
  * Methods like `netzke_attribute`, `netzke_expose_attributes` etc are gone. Define your columns/fields directly in your grids/forms.
  * Accordion and TabPanel now lazily load the Netzke components by default; set `eager_loading` to true for the components that should be loaded eagerly.

## Grid

### Customizing grid's forms

The windows with a form inside, which is used for adding/(multi-)editing of records, are now referred as: `add_window`, `edit_window` (instead of `add_form` and `edit_form`). Both accept a config param `form_config`, which can be used to configure the contained Form - e.g., to change its layout or even class. For example, to change the layout of a form that is found in the edit window, do the following in your grid class:

    component :edit_window do |c|
      super(c)
      c.form_config.items = [:name, :author__name]
    end

DSL methods `add_form_config`, `edit_form_config`, `multi_edit_form_config`, `add_form_window_config`, `edit_form_window_config`, `multi_edit_form_window_config` are gone.

### Customizing columns

Use the new `column` DSL method that accepts a block:

    column :extra_column do |c|
      c.text = "Extra"
    end

If needed, this can be overridden in the subclass the same way as components and actions can be.

DSL method `override_column` is gone.

### Misc

`Grid.extended_search_available` -> `Grid.advanced_search_available`

# 0.7.6 - 2012-07-27
* Fix netzke-core version dependency in gemspec

# 0.7.5 - 2012-07-27
* Rails 3.2

* improvements
  * data-related operations in grids and forms are moved to data adapters; implemented (partial) support for DataMapper and Sequel (see updated README)
  * afterApply event in forms and grids (pschyska)
  * apply event fired before apply button is processed in Form (pschyska)

* bug fix
  * advanced search panel works again (pididi)
  * fixed a problem with session and GridPanel

# 0.7.4 - 2012-03-05
* bug fix
  * :enable_pagination is now respected in GridPanel
  * Virtual columns are not sortable by default now
  * Datetime column now works
  * Make Window respect persistence: false
  * Disable persistence for search window in GridPanel

# 0.7.3 - 2011-10-23
* bug fix
  * :sorting_scope is now respected in GridPanel
  * regression: filtering on association column is fix (covered with tests)

# 0.7.2 - 2011-10-20
* bug fix
  * Filter on a date column
  * Using date column caused Form to crash
  * Virtual columns are no longer editable by default

* improvements
  * New DSL method (model) for declaring a model for grids
  * New DSL method (column) for declaring columns for grids
  * New :override_columns config option for grid allows overriding specified column config without influencing other columns' order/presence
  * New DSL method (override_column) to override a specific column config without influencing other columns' order/presence.
  * Grid's title is set to model's pluralized name by default.
  * New :read_only option for Form - makes all fields read-only and removes the "Apply" button.
  * Form implements DSL shortcuts for the following options in default config: :model, :items, :record_id.
  * GridPanel implements DSL shortcuts for the following options in default config: :model, :add_form_config, :edit_form_config, :multi_edit_form_config.
  * New Form option :multi_edit - set when the form is used for editing multiple records at a time
  * Introduce action columns (see BookGridWithColumnActions)

* API changes
  * Skip supporting ModelExtensions. The preferred way is using setters and getters on columns/fields.

# 0.7.1 - 2011-09-04
* bug fix
  * Form: fix the netzke_load endpoint when association fields are present
  * dates were not displayed in date fields, and submitting a form with date fields might result in erasing those fields

* Rails 3.1 compatibility
  * no meta_where dependencies (searching and filtering done with Arel)

# 0.7.0 - 2011-08-09
* Core 0.7.0 and Ext 4 compatibility
* API changes
  * [JS] Removed the helper BorderLayoutPanel#get<Region>Component method altogether. Use Ext 4 Container#child instead

# v0.6.5 - to be released
* enhancements
  * When columns states are saved in the persistent storage, adding/removing columns (e.g. in the code) will reset the saved states
  * Moved features and specs to test/basepack_test_app
* bug fix
  * Form with multiple association fields wouldn't submit data correctly
  * GridPanel's forms take over the `text` configuration option for columns as `fieldLabel` for default fields

# v0.6.4 - 2011-02-26
* API changes
  * The combo field able to talk to the server has changed its xtype from combobox to netzkeremotecombo. When getting values from the server via AJAX, it expects a 2-dimensional array now, where the first value is the real value (which gets submitted), and the second value is the display value.
  * xdatetime is no more. datetimefield is used instead.

* enhancements
  * Components updated to use Ext.Direct (by @pschyska)
  * New, improved advanced search for GridPanel and PagingForm.
  * One-to-many association support in Form/GridPanel reworked to use the foreign id instead of a string. This gives us more flexibility about what to display in the association column/field, and also provides for performance improvements (no more need to search for the associated record based on the value provided from the column/field).
  * GridPanel now memorizes its columns visibility, position and size (when :persistence is set to true)
  * I18n for GridPanel
  * A default value can now also be assigned to association column/field (the value must be the associated record's ID)
  * Slightly optimized selenium tests (no artificial sleeping whenever possible)

* bug fix
  * Long-standing visual issues with datetime columns in grid panel are solved.

# v0.6.3 - 2011-01-14
* compatibility with netzke-core 0.6.5

* refactoring
  * GridPanel code restructured, using the new `js_mixin` method

* bug fix
  * GridPanel respects strong_default_attrs
  * TabPanel doesn't fire multiple load requests per tab in case of lazy-loaded tabs and fast clicking
  * Filtering/sorting on virtual columns is now disabled by default
  * Filtering on date columns

* enhancements
  * I18n for Grid/Form
  * new `getter` config option for columns/fields, a lambda receiving the record as parameter
  * new `setter` config option for columns/fields, a lambda receiving the record as first parameter, new value as the second
  * GridPanel passes columns' default values to the "Add in form" form
  * Form can now be used without specifying a model
  * New `commalistcbg` form field for checkboxes, where boxLabels of selected checkboxes are serialized into comma-separated string (the separator is configurable)
  * New `nradiogroup` form field for radio buttons, where the value is defined by the boxLabel of the selected radio button
  * New `no_binding` option for configuring a form field. Set it to "true" when you don't want Netzke to expand the field configuration based on the `name` property. May be needed in some cases, e.g. when using checkboxes/radio buttons in the form.
  * New `nested_attribute` option for configuring data attributes (thus applicable for a column, a field, or a `netzke_attribute` in the model). When set to true for an association attribute (e.g. author__name), assigning a value to it will change the association's attribute, *not* trying to find an association by name and reassign it if found (default behavior).
  * Form shows the "Updating..." mask while sending values to the server (configurable with updateMask option/property)
  * Form now can be used in the "lockable" mode (:config => :lockable), which makes it load initially in "display mode", then "unlock" it, change the values, and "lock" it again (updating the values on the server)

# v0.6.2 - 2010-11-05
* compatibility with netzke-core 0.6.4
* bug fix
  * BorderLayoutPanel persistence fix

# v0.6.1 - 2010-11-04
* enhancements
  * BorderLayoutPanel persistence: remembers region sizes and collapsed/expanded states
  * tooltips for grid buttons

* bug fix
  * auto-detection of association's method when the latter is virtual was broken in 1.9.2

# v0.6.0 - 2010-10-24
* netzke-core 0.6.0 compatibility, thorough refactoring
* Much more thorough testing (cucumber and rspec)
* Form/GridPanel dynamic column/field configuration has been left out (planned for a separate gem)
* different bug fixes

* enhancements
  * if omitted in config, a column for the primary key is automatically added to Grid/Form

* API incompatibilities
  * in Form, define the fields layout directly in :items, not in :fields or :columns

* new
  * Form allows for arbitrary layout of fields

# v0.5.14 - 2010-09-08
* bug fix
  * fields configurator wouldn't open in some cases
  * icons location was hardcoded in search panel (credits to @pschyska)
  * quick fix for datetimes not being displayed in the preferred timezone
  * ext_config options :enable_edit_in_form and :enable_advanced_search now do have effect
  * PropertyEditor fixed for Grid/Form
  * Grid/Form again obeys persistent_config option when loading columns/fields

* enhancements
  * numberfield is default in grids also for columns of type float
  * more narrow exception rescuing in GridPanel code
  * combobox options can now be searched ("type ahead") also in virtual columns (not efficient though, use at own risk!)
  * overriding an already existing attribute with `netzke_attribute` now also has effect on association attributes, such as boss__name

# v0.5.13 - 2010-08-11
* regression
  * combobox options configuration again has effect

* bug fix
  * when a TabPanel was used as a standalone widget, the first tab was rendered empty
  * Grid/Form: dynamically changing of columns doesn't erase those column settings that are not configurable via GUI, but which were specified in the code

* enhancements
  * scopes can now be specified for an association combobox in Grid/Forms
  * GridPanel: you can now configure add/edit/multi_edit/search panels (e.g. to override the fields) and corresponding windows (e.g. to override the title)
  * minor refactoring GridPanel: moved static js out of grid_panel_js.rb

# v0.5.12 - 2010-06-21
* Fix: when used with Bundler, was crashing with the "uninitialized constant" exception

# v0.5.11 - 2010-06-20
* Fix: Partial fix for IE's (the rest to be fixed in Ext).
* Fix: In some circumstances Netzke::ActiveRecord modules were not loading.

# v0.5.10 - 2010-06-14
* Impr: Checkbox replaced with tri-state checkbox in multi-edit form in GridPanel.
* Impr: Column renderers reworked, allowing for more flexibility and cleanness.
* Fix:  After applying changes to a grid disable "Edit in form" action.
* Impr: A grid's forms are now getting the same fields as specified for the grid.

# v0.5.9 - 2010-06-11
* !!!: after updating to this version, run script/generate netzke_basepack
* New: tri-state checkbox introduced into the search form
* Impr: better defaults for the search form
* Impr: GridPanel now displays the total amount of records
* Fix: GridPanel's "local filters" are back (they were out since the release of Ext 3.0)
* Impr: obey "preloaded" option for tabs better: really add the widgets into their respective tabs from the start
* Fix: datetime filters now also are take into account when searching in GridPanel is performed
* Fix: FieldsConfigurator should now work on Heroku
* Fix: GridPanel date filter now should work
* New: GridPanel now has a method on_data_changed that can be overridden by children to detect actions that modify data
* New: New way of configuring Netzke (virtual) attributes for AR models.
* Impr: Grid/Form refactoring.
* Impr: Multi-level column/fields configuration reworked and made more consistent.
* New: New configuration layer introduced between the AR models and the rest of Netzke widgets. Use AttributesConfigurator to access it.
* New: FamFamFam Silk icons support.
* Impr: Reworked defining Netzke (virtual) attributes for Grid/Form.

# v0.5.8 - 2010-03-12
* Fix: GertThiel's method_missing-related fix enabling better compatibility with other Ruby libs
* Fix: acts_as_list runtime dependency

# v0.5.7 - 2010-02-26
* Regression: column config for GridPanel again accepts a renderer along with its parameters (as array, where the first element is the renderers name, the second - the parameters passed to the renderer, e.g.: :renderer => ["date", "y-m-d"])
* Fix: Window resize/move now works correctly
* Code: taking care of deprecated methods

# v0.5.6 - 2010-01-10
* Compatibility with latest netzke-core
* Compatibility with Ext JS v3.1
* Impr: Code reorganization
* Impr: Non-standard primary key support in GridPanel and Form
* Impr: Search button in GridPanel indicates that records filtering is active
* Fix: by default, SearchPanel excludes boolean fields for now (until a 3-state checkbox is introduced)
* Impr: made it possible to create new AR records with assigned associations using double-underscore notation, e.g.: Clerk.new(:boss__last_name => "Aguraijuja ")
* Impr: specifying an item for Netzke::Window is now optional
* Fix: xtype field in FieldsConfigurator is now a combobox
* Fix: FieldsConfigurator was crashing when fired consequently for grid and form
* Depr: :data_class_name option is deprecated, use :model
* Impr: "gear" tool is now hidden on FieldsConfigurator
* Impr: Grid/Form layouts are now not stored into the netzke_preferences table unless the defaults are modified (cleaner table)

# v0.5.5.1 - 2009-11-09
* Compatibility with latest netzke-core

# v0.5.5 - 2009-11-09
* Compatibility with latest netzke-core
* Regression: pressing "enter" was not submitting the form (Form)
* Regression: "Restore defaults" button was not working in FieldsConfigurator and PropertyEditor
* Fix: excluding columns in FieldsConfigurator was causing inconsistent column behavior (move/hide/resize)
* Fix: resolving conflicts with Ext.form.Form's <tt>submit</tt> and <tt>load</tt> methods
* New: rudimentary FileUploadField support in Form (it will do a normal, non-AJAX, form submit)
* New: Netzke::Window widget, supports persistent moving/resizing.
* New: (experimental) GridPanel's "Add in form" button now opens the new Window widget. Later all other windows will be slowly rewritten to do the same.

# v0.5.4 - 2009-10-12
* Dependencies updated

# v0.5.3 - 2009-10-12
* Compatibility with Ext 3.0 (and dropping compatibility with 2.x).
* Compatibility with netzke-core v0.4.4.
* Impr: Form/GridPanel-based widgets: more consistent Ext.Action-related functionality and code, like (context) menu, bbar, etc.
* Impr: GridPanel: <tt>rows_reordering_available</tt> is now true by default.
* Impr: TreePanel now sets "leaf" attribute to true if the node has no children.
* Impr: Grid/TreePanel now have persistent config enabled by default.
* Impr: if persistent_config is disabled, a widget won't be talking to the server in vain any more.
* Fix: GridPanel didn't fire row editing when the first column was a "checkbox" column.
* Fix: the GridPanel's <tt>:scopes</tt> parameter now correctly processes named scopes as strings inside the array, e.g.
    :scopes => ["current", [:id_gt, 100]]
* Fix: on deleting records from GridPanel, <tt>destroy</tt> method is being called instead of <tt>delete</tt>.
* Fix: FieldsConfigurator made a little bit more stable.
* Fix: patching Ext's bug that caused double firing of "columnmove" in GridPanel.
* Fix: moving columns around in GridPanel was causing erroneous mapping of data to columns after data reload.

# v0.5.2 - 2009-09-24
* Fix: combobox options for association columns didn't work properly.
* Fix: GridPanel's multi-edit functionality didn't work.
* Fix: gem dependencies are now correct.

# v0.5.1 - 2009-09-11
* Fix: crash when Form has no data_class_name specified.
* New: DataAccessor widgets (Form/GridPanel) now let the underlying model know which widget (i.e. which instance) accesses its data. Can be useful in virtual attributes for generating widget-specific HTML.
* Fix: DataAccessor widgets (Form/GridPanel) now don't crash when calculating default columns/fields for the underlying model that has polymorphic columns.
* Fix: TabPanel was sending redundant "tabchange" event to server when initially instantiated.
* Fix: column filters were making GridPanel crash when the column editor was set to "textarea".
* Fix: dongling comma and "delete" object properties caused problems in IE and Safari.
* Fix: a stand-alone TabPanel would not render the active item.
* New: BasicApp: masquerading as "World". In this mode all the "touched" persistent preferences will be overwritten for all roles and users.
* Impr: configuration panel's header now shows the underlying model's name for convenience.
* Fix: MasqueradeSelector widget added.

# v0.5.0 - 2009-09-06
* Major refactoring and code reorganization.
* Compatibility with netzke-core v0.4.0.
* New: GridPanel now supports adding/editing records in a form and extended configurable search.
* New: GridPanel now can be loaded along with initial data (saves a request to the server).
* New: context menu in GridPanel
* New: "scopes" configuration option added to GridPanel to specify the searchlogic-compatible scope for the data.
* New: "strong_default_attrs" config option added to GridPanel to specify the attributes that will be assigned to each record that is created or modified by the grid.
* Usability: GridPanel's actions now get enabled/disabled according to the current selection.
* Configuration panel for grids and forms now works more consistently.
* New: some smart defaults for column/fields in Grid/Form.
* New: BasicApp supports masquerading and application-wide AJAX activity indicator.

# v0.4.2 - 2009-05-07
* Fix: afterlayout event bind removed completely because of some tricky inconsistent behavior of Ext. BasicApp initializing code put directly into js_after_constructor.

# v0.4.1 - 2009-05-07
* Fix: afterlayout call moved to js_after_constructor in BasicApp
* Fix: cleaner persistent_config handling
* New: default's configuration enabled for Form on class-level
* Fix: differently configured forms on the same page were showing the same columns
* Fix: TableEditor was showing config-tool by default (must be hidden)

# v0.4.0 - 2009-05-07
* Refactor: got rid of NetzkeFormField and NetzkeGridPanelColumn classes along with their tables. The layout is now stored in netzke_preferences.
* New: dynamic hiding of columns from column menu in GridPanel.
* New: Form now supports combo boxes.
* Fix: config[:bbar] set to 'false' now works in grids with pagination
* New: you can specify :preloaded => true in a tab config in TabPanel to preload the widget in that tab along with the TabPanel itself
* New: hideBusy added to Ext.StatusBar
* Fix: assigning association (a Boss to a Clerk) by virtual column (like boss__name) works now
* Fix: an old bug that made GridPanel misbehave after reordering the columns

# v0.3.10
* BasicApp-based widgets can now introduce arbitrary layout, following the convention of defining "main-panel" and "main-toolbar" panels with layout 'fit'.

# v0.3.9.1
* Bug fix: (regression) appLoaded() in BasicApp gets executed again

# v0.3.9
* AccordionPanel tests added
* TabPanel works now
* AccordionPanel replaced with more intuitive TabPanel in the configuration window
* Code clean-up by using "single" option to call appLoaded() on "afterlayout"
* Table editor bug fix

# v0.3.8
* Fixing Ext's EditableItem render problem.
* Filters by default enabled again in GridPanel.
* GridPanel enhancement: base_params get sent along with post_data.

# v0.3.7
* Netzke-core version sync.
* Rails 2.3.2 compatibility.

# v0.3.6
* Netzke-core v0.2.9 compatibility.
* Cleaner handling of custom renderers in GridPanel.
* New Form-based PropertyEditor replaces PropertyGrid.
* Xcheckbox and check-column introduced.
* TODO file added.
* Bug fix: in TableEditor, the grid now responses on events also after being reconfigured.
* Bug fix: a couple of IE-related bugs.
* Significant code clean-up.

# v0.3.5
* Netzke-core v0.2.8 compatibility.

# v0.3.4
* Quick tips added to the "tools".
* Regression: the "General" configuration panel for GridPanel works again.
* GridPanel: rows_per_page configuration is now read from General config panel.

# v0.3.3.1
* Obviously using "new" as a property name in JavaScript isn't liked by Safari. Fixed.

# v0.3.3
* Bug fix: application not loading the widget specified in the URL (Ext.History-related).
* Some code refactoring and readability improvements.
* Ext.componentCache renamed into Ext.netzke.cache.
* New widget: TableEditor (a compound widget containing a grid and a form for editing table data).
* BorderLayoutPanel: a function getRegionWidget(region) added to access a widget in the specified region.
* Bug fix: BasicApp: FeedbackGhost now gets instantiated before BasicApp.
* Clearer handling of requests to non-existing aggregatees.
* Bug fix: now Ext 2.2.1 compatible.
* Column operations are now handled properly when :persistent_layout is set to false.
* Grid/Form fields configuration is extended with "ext_config" field which stores (in JSON-format) all the extra configuration, which gives extra flexibility to individual column/field configuration.
* :persistent_layout set to false now makes a widget ignore what's in the DB.
* Bug fix: AccordionPanel doesn't crash when no active item is specified.
* Bug fix: redundant flash messages for GridPanel.
* FeedbackGhost won't be showing anything if given an empty array.
* Cleaner handling of validations in GridPanel.
* Form ready for the demo.

# v0.3.2
* Minor code restructuring.
* Working on Form cont'd.

# v0.3.1
* Added the "conditions" configuration option to GridPanel to limit the search
* Basic column editor for grids has been replaced with FieldsConfigurator, which can do a bit more
* Added Checkbox column/form-field type for boolean fields
* "renderer" configuration option added for grid columns - any Ext.util.Format renderer can be specified there (thanks to Josh Holt for the initial idea)

# v0.3.0
* Added BasicApp widget - the base for a Ext.Viewport based ("application") widget with support for dynamic widget loading, browser history, authentification, and more. See the demo an http://netzke-demo.writelesscode.com

# v0.2.2
* Meta: updated netzke-core version (dependency)

# v0.2.1
* Regression: BorderLayoutPanel now restores the region sizes from the database

# v0.2.0.1
* Meta: updated netzke-core version (dependency)

# v0.2.0
* Some re-factoring and redesign along with netzke-core
* Panel widget added
* BorderLayoutPanel added
* AccordionPanel added
* Bug fix: column operations configuration misbehaving
* Renamed Grid into GridPanel
* Bug fix: exception was thrown at a column operation when no layout_manager was present
* Reworked permission handling in GridPanel.

# v0.1.4.1
* Meta: updated netzke-core version (dependency)

# v0.1.4
* Grid#get_columns provides default columns even if none of layout_manager_class & column_manager_class are available

# v0.1.3.1
* Meta: updated netzke-core version (dependency)

# v0.1.3
* Path to javascript for grid filters corrected
* Bug with creating new records in the grid fixed
* Optimized away redundant sql queries when calling Grid#get_columns (sort of memoization)
* README updated

# v0.1.2.1
* Meta: trying to succeed publishing on RubyForge

# v0.1.2
* Updated README with an example of stand-alone widget usage
* Meta: updated netzke-core version (dependency)

# v0.1.1.2
* Meta: updated netzke-core version (dependency)

# v0.1.1.1
* Meta: github gem naming convention

# v0.1.1
* Cleaner exception handling while loading data to grid
* Column resize & move functionality enabled by default
* Column filters added

# v0.1.0.1
* Meta work: replacing underscore with dash in the name

# v0.1.0 - 2008-12-20
* Initial release
