module Netzke
  module Grid
    # Ext.grid.Panel-based component with the following features:
    #
    # * infinite scrolling or pagination
    # * automatic default attribute configuration (overridable via config)
    # * multi-line CRUD operations
    # * adding/editing records via a form
    # * editing multiple records simultaneously
    # * one-to-many association support
    # * server-side sorting and filtering
    # * permissions
    # * persistent column resizing, moving and toggling
    # * complex query search with preset management
    #
    # Client-side methods are documented here: http://api.netzke.org/client/classes/Netzke.Grid.Base.html.
    #
    # == Configuration
    #
    # The following config options are supported:
    #
    # [model]
    #
    #   Name of the ActiveRecord model that provides data to this Grid (e.g. "User") or the model's class (e.g. User).
    #   Required.
    #
    # [columns]
    #
    #   Explicit list of columns to be displayed in the grid; each column may be represented by a symbol (attribute name),
    #   or a hash, which contains the +name+ key pointing to the attribute name and additional configuration keys (see
    #   the "Configuring attributes" section below). For example:
    #
    #      class Users < Netzke::Grid::Base
    #        def configure(c)
    #          super
    #          c.model = User
    #          c.columns = [
    #            :first_name,
    #            :last_name,
    #            { name: :salary, with: 50 }
    #          ]
    #        end
    #      end
    #
    #   Defaults to model attribute list.
    #
    #   Note, that you can also individually override column configs (e.g. setting a column's width) by using the
    #   +column+ DSL method (see +Basepack::Columns+), and override attributes (e.g. making an attribute read-only) by
    #   using the +attribute+ DSL method (see +Basepack::Attributes+).
    #
    # [form_items]
    #
    #   Array of form items. This may define arbitrary form layout. An item that represents a specific attribute, should
    #   be specified as either a symbol (attribute name), or a hash containing the +name+ key pointing to the attribute
    #   name, as well as additional configuration keys.
    #
    #      class Users < Netzke::Grid::Base
    #        def configure(c)
    #          super
    #          c.model = User
    #          c.form_items = [
    #            {
    #              xtype: 'fieldset', title: 'Name', items: [:first_name, :last_name]
    #            },
    #            { name: :salary, disabled: true }
    #          ]
    #        end
    #      end
    #
    #   Defaults to model attribute list.
    #
    # [attribute_overrides]
    #
    #   Hash of per-attribute configurations. This allows overriding attributes configs that will be reflected by both
    #   corresponding grid column and form field.
    #
    #   Using this option may be convenient when building composite components containing multiple grids. From inside a
    #   given grid class it's easier to use the +attribute+ DSL method (see "Configuring attributes").
    #
    # [scope]
    #
    #   A Proc or a Hash used to scope out grid data. The Proc will receive the current relation as a parameter and must
    #   return the modified relation. For example:
    #
    #      class Books < Netzke::Grid::Base
    #        def configure(c)
    #          super
    #          c.model = Book
    #          c.scope = lambda {|r| r.where(author_id: 1) }
    #        end
    #      end
    #
    #   Hash is being accepted for conivience, it will be directly passed to `where`. So the above can be rewritten as:
    #
    #      class Books < Netzke::Grid::Base
    #        def configure(c)
    #          super
    #          c.model = Book
    #          c.scope = {author_id: 1}
    #        end
    #      end
    #
    # [strong_values]
    #
    #   A hash of attributes to be merged atop of every created/updated record, e.g. +role_id: 1+
    #
    # [edit_inline]
    #   Whether record editing should happen inline (as opposed to using a form). When set to +true+, automatically sets
    #   +paging+ to +true+. Defaults to +false+.
    #
    # [context_menu]
    #
    #   An array of actions (e.g. [:edit, "-", :delete] - see the Actions section) or +false+ to disable the context menu.
    #
    # [paging]
    #
    #   Set to +true+ to use pagination instead of infinite scrolling. Is automatically set to
    #   +true+ if +edit_inline+ is +true+. Defaults to +false+.
    #
    # [store_config]
    #
    #   Extra configuration for the JS class's internal store (Ext.data.ProxyStore), which will override Netzke's
    #   defaults. For example, to modify amount of records per page (defaults to 25), do:
    #
    #     def configure(c)
    #       c.paging = true
    #       c.store_config = {page_size: 100}
    #       super
    #     end
    #
    #   Another example, enable (multi) sorting initially:
    #
    #     def configure(c)
    #       c.store_config = {sorters: [:title, {property: :author__first_name, direction: :DESC}]}
    #       super
    #     end
    #
    # [disable_dirty_page_warning]
    #
    #   Do not warn the user about dirty records on the page when changing the page. Defaults to +false+.
    #
    # [permissions]
    #
    #   Hash that can have a combination of the following boolean keys: +create+, +read+, +update+, +delete+ that
    #   set corresponding permissions on the grid. For example, to disable deleting records:
    #
    #       c.permissions = {delete: false}
    #
    # == Configuring attributes (columns and form fields)
    #
    # === Overriding individual attributes
    #
    # To override configuration for a specific attribute, you may either use the +attribute_overrides+ configuration
    # option (see above), or the +attribute+ DSL method, for example:
    #
    #      class Books < Netzke::Grid::Base
    #        attribute :price do |c|
    #          c.read_only = true
    #        end
    #
    #        def configure(c)
    #          c.model = Book
    #          super
    #        end
    #      end
    #
    # This will make the 'price' column (as well as corresponding form field) read-only.
    #
    # The same DSL method may be used for defining virtual attributes. For details, refer to +Basepack::Attributes+.
    #
    # === Overriding individual column settings
    #
    # To override configuration for a column (like making the column hidden or specyfing its initial width), either add
    # the +column_config+ key to the +attribute_overrides+ (see above), or use the +column+ DSL method, for example:
    #
    #       column :full_name do |c|
    #         c.width = 200
    #       end
    #
    # For details, refer to +Basepack::Columns+.
    #
    # === Specifying column list
    #
    # To explicitely specify columns in the grid, use the +columns+ config option, or override +Grid#columns+:
    #
    #     def columns
    #       super + [:extra_column]
    #     end
    #
    # == One-to-many association support
    #
    # If the model bound to a grid +belongs_to+ another model, Grid can display an "assocition column" - where the user
    # can select the associated record from a drop-down box. You can specify which method of the association should be
    # used as the display value for the drop-down box options by using the double-underscore notation on the column
    # name, where the association name is separated from the association method by "__" (double underscore). For
    # example, let's say we have a Book that +belongs_to+ model Author, and Author responds to +first_name+. This way,
    # the book grid can have a column defined as follows:
    #
    #     {name: "author__first_name"}
    #
    # Grid will detect it to be an association column, and will use the drop-down box for selecting an author, where the
    # list of authors will be represented by the author's first name.
    #
    # In order to scope out the records displayed in the drop-down box, the +scope+ column option can be used, e.g.:
    #
    #     {name: "author__first_name", scope: lambda {|relation| relation.where(popular: true).limit(10)}
    #
    # == Add/Edit forms
    #
    # Add/Edit forms are each wrapped in a separate +Window::Base+-descending component (called +RecordFormWindow+
    # for the add/edit forms, and can be overridden individually as any other child component.
    #
    # === Overriding form windows
    #
    # Override the following direct child components to change the looks of the pop-up windows: +:add_window+,
    # +:edit_window+, +:multiedit_window+, and +:search_window+. For example, to override the title of the Add form,
    # do:
    #
    #     component :add_window do |c|
    #       super c
    #       c.title = "Adding new record"
    #       c.width = "90%"
    #     end
    #
    # === Modifying forms
    #
    # The forms will by default display the fields that correspond to the configured columns, taking over meaningful
    # configuration options (e.g. +text+ will be converted into +fieldLabel+).
    # You may override the default fields displayed in the all add/edit forms by overriding the
    # +default_form_items+ method, which should return an array understood by the +items+ config property of the
    # +Form+. If you need to use a custom +Form::Base+-descending class instead of +Form+, you need to override the
    # +configure_form_window+ method:
    #
    #     def configure_form_window(c)
    #       super
    #       c.form_config.klass = UserForm
    #     end
    #
    # To individually override forms, you should override the wrapping window components, as shown in the previous
    # session. E.g., to modify the set of fields in the Add form:
    #
    #     component :add_window do |c|
    #       super c
    #       c.form_config.items = [:title]
    #     end
    #
    # == Actions
    #
    # You can override Grid's actions to change their text, icons, and tooltips (see
    # http://rdoc.info/github/netzke/netzke-core/Netzke/Core/Actions).
    #
    # Grid implements the following actions:
    #
    # [add]
    #
    #   Add record
    #
    # [delete]
    #
    #   Delete record(s)
    #
    # [edit]
    #
    #   Edit record(s)
    #
    # [apply]
    #
    #   Applying inline changes (after inline adding/editing of record)
    #
    # [search]
    #
    #   Show advanced search query builder
    class Base < Netzke::Base
      include Netzke::Grid::Configuration
      include Netzke::Grid::Endpoints
      include Netzke::Grid::Services
      include Netzke::Grid::Actions
      include Netzke::Grid::Components
      include Netzke::Grid::Permissions
      include Netzke::Grid::Client
      include Netzke::Basepack::Attributes
      include Netzke::Basepack::Columns
      include Netzke::Basepack::DataAccessor

      client_class do |c|
        c.extend = "Ext.grid.Panel"
        c.include :advanced_search
        c.include :remember_selection

        c.mixins << "Netzke.Grid.Columns"
        c.mixins << "Netzke.Grid.EventHandlers"

        c.translate :are_you_sure, :confirmation, :proceed_with_unapplied_changes

        c.require :extensions
      end
    end
  end
end
