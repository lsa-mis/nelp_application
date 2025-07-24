ActiveAdmin.setup do |config|
  # == Site Title
  #
  # Set the title that is displayed on the main layout
  # for each of the active admin pages.
  #
  config.site_title = "Nelp Application"

  # Set the link url for the title. For example, to take
  # users to your main site. Defaults to no link.
  #
  config.site_title_link = "/"

  # Set an optional image to be displayed for the header
  # instead of a string (overrides :site_title)
  #
  # Note: Aim for an image that's 21px high so it fits in the header.
  #
  # config.site_title_image = "logo.png"

  # == Load Paths
  #
  # By default Active Admin files go inside app/admin/.
  # You can change this directory.
  #
  # eg:
  #   config.load_paths = [File.join(Rails.root, 'app', 'ui')]
  #
  # Or, you can also load more directories.
  # Useful when setting namespaces with users that are not your main AdminUser entity.
  #
  # eg:
  #   config.load_paths = [
  #     File.join(Rails.root, 'app', 'admin'),
  #     File.join(Rails.root, 'app', 'cashier')
  #   ]

  # == Default Namespace
  #
  # Set the default namespace each administration resource
  # will be added to.
  #
  # eg:
  #   config.default_namespace = :hello_world
  #
  # This will create resources in the HelloWorld module and
  # will namespace routes to /hello_world/*
  #
  # To set no namespace by default, use:
  #   config.default_namespace = false
  #
  # Default:
  # config.default_namespace = :admin
  #
  # You can customize the settings for each namespace by using
  # a namespace block. For example, to change the site title
  # within a namespace:
  #
  #   config.namespace :admin do |admin|
  #     admin.site_title = "Custom Admin Title"
  #   end
  #
  # This will ONLY change the title for the admin section. Other
  # namespaces will continue to use the main "site_title" configuration.

  # == User Authentication
  #
  # Active Admin will automatically call an authentication
  # method in a before filter of all controller actions to
  # ensure that there is a user logged in.
  #
  config.authentication_method = :authenticate_admin_user!

  # == User Authorization
  #
  # Active Admin will automatically call an authorization
  # method in a before filter of all controller actions to
  # ensure that there is a user with proper rights. You can use
  # CanCanAdapter or make your own. Please refer to documentation.
  # config.authorization_adapter = ActiveAdmin::CanCanAdapter

  # In case you prefer Pundit over other solutions you can here pass
  # the name of default policy class. This policy will be used in every
  # case when Pundit is unable to find suitable policy.
  # config.pundit_default_policy = "MyDefaultPunditPolicy"

  # If you wish to maintain a separate set of Pundit policies for admin
  # resources, you may set a namespace here that Pundit will search
  # within when looking for a resource's policy.
  # config.pundit_policy_namespace = :admin

  # You can customize your CanCan Ability class name here.
  # config.cancan_ability_class = "Ability"

  # You can specify a method to be called on unauthorized access.
  # This is necessary in order to prevent a redirect loop which happens
  # because, by default, user gets redirected to Dashboard. If user
  # doesn't have access to Dashboard, he'll end up in a redirect loop.
  # Method provided here should be defined in application_controller.rb.
  # config.on_unauthorized_access = :access_denied

  # == Current User
  #
  # Active Admin will associate actions with the current
  # user performing them.
  #
  # This setting changes the method which Active Admin calls
  # (within the application controller) to return the currently logged in user.
  config.current_user_method = :current_admin_user

  # == Logging out
  #
  # Active Admin needs to know how to log users out.
  #
  config.logout_link_path = :destroy_admin_user_session_path

  # == Batch Actions
  #
  # Enable and disable Batch Actions
  #
  config.batch_actions = true

  # == Controller Filters
  #
  # You can add before, after and around filters to all of your
  # resources controller.
  #
  # config.before_action :do_something_awesome

  # == Attribute Filters
  #
  # You can exclude possibly sensitive model attributes from being displayed,
  # added to forms, or exported by default by ActiveAdmin
  #
  config.filter_attributes = [:encrypted_password, :password, :password_confirmation]

  # == Localize Date/Time Format
  #
  # Set the localize format to display dates and times.
  # To understand how to localize your app with I18n, read more at
  # https://guides.rubyonrails.org/i18n.html
  #
  # You can run `bin/rails runner 'puts I18n.t("date.formats")'` to see the
  # available formats in your application.
  #
  config.localize_format = :long

  # == Setting a Favicon
  #
  # config.favicon = 'favicon.ico'

  # == Meta Tags
  #
  # Add additional meta tags to the head element of active admin pages.
  #
  # Add tags to all pages logged in users see:
  #   config.meta_tags = { author: 'My Company' }

  # By default, sign up/sign in/recover password pages are excluded
  # from showing up in search engine results by adding a robots meta
  # tag. You can reset the hash of meta tags included in logged out
  # pages:
  #   config.meta_tags_for_logged_out_pages = {}

  # == Removing Breadcrumbs
  #
  # Breadcrumbs are enabled by default. You can customize them for individual
  # resources or you can disable them globally from here.
  #
  # config.breadcrumb = false

  # == Create Another Checkbox
  #
  # Create another checkbox is disabled by default. You can customize it for individual
  # resources or you can enable them globally from here.
  #
  # config.create_another = true

  # == Register Stylesheets & Javascripts
  #
  # We recommend using the built in Active Admin layout and loading
  # up your own stylesheets / javascripts to customize the look
  # and feel.
  #
  # To load a stylesheet:
  #   config.register_stylesheet 'my_stylesheet.css'
  #
  # You can provide an options hash for more control, which is passed along to stylesheet_link_tag():
  #   config.register_stylesheet 'my_print_stylesheet.css', media: :print
  #
  # To load a javascript file:
  #   config.register_javascript 'my_javascript.js'

  # == CSV options
  #
  # Set the CSV builder separator
  # config.csv_options = { col_sep: ';' }
  #
  # Force the use of quotes
  # config.csv_options = { force_quotes: true }

  # == Menu System
  #
  # You can add a navigation menu to be used in your application, or configure a provided menu
  #
  # To change the default utility navigation to show a link to your website & a logout btn
  #
  #   config.namespace :admin do |admin|
  #     admin.build_menu :utility_navigation do |menu|
  #       menu.add label: "My Great Website", url: "http://www.mygreatwebsite.com", html_options: { target: :blank }
  #       admin.add_logout_button_to_menu menu
  #     end
  #   end
  #
  # If you wanted to add a static menu item to the default menu provided:
  #
  #   config.namespace :admin do |admin|
  #     admin.build_menu :default do |menu|
  #       menu.add label: "My Great Website", url: "http://www.mygreatwebsite.com", html_options: { target: "_blank" }
  #     end
  #   end

  # == Download Links
  #
  # You can disable download links on resource listing pages,
  # or customize the formats shown per namespace/globally
  #
  # To disable/customize for the :admin namespace:
  #
  #   config.namespace :admin do |admin|
  #
  #     # Disable the links entirely
  #     admin.download_links = false
  #
  #     # Only show XML & PDF options
  #     admin.download_links = [:xml, :pdf]
  #
  #     # Enable/disable the links based on block
  #     #   (for example, with cancan)
  #     admin.download_links = proc { can?(:view_download_links) }
  #
  #   end

  # == Pagination
  #
  # Pagination is enabled by default for all resources.
  # You can control the default per page count for all resources here.
  #
  # config.default_per_page = 30
  #
  # You can control the max per page count too.
  #
  # config.max_per_page = 10_000

  # == Filters
  #
  # By default the index screen includes a "Filters" sidebar on the right
  # hand side with a filter for each attribute of the registered model.
  # You can enable or disable them for all resources here.
  #
  # config.filters = true
  #
  # By default the filters include associations in a select, which means
  # that every record will be loaded for each association (up
  # to the value of config.maximum_association_filter_arity).
  # You can enabled or disable the inclusion
  # of those filters by default here.
  #
  # config.include_default_association_filters = true

  # config.maximum_association_filter_arity = 256 # default value of :unlimited will change to 256 in a future version
  # config.filter_columns_for_large_association = [
  #    :display_name,
  #    :full_name,
  #    :name,
  #    :username,
  #    :login,
  #    :title,
  #    :email,
  #  ]
  # config.filter_method_for_large_association = '_start'

  # == Head
  #
  # You can add your own content to the site head like analytics. Make sure
  # you only pass content you trust.
  #
  # config.head = ''.html_safe
  config.head = proc { ApplicationController.helpers.javascript_importmap_tags('active_admin') }


  # == Footer
  #
  # By default, the footer shows the current Active Admin version. You can
  # override the content of the footer here.
  #
  # config.footer = 'my custom footer text'

  # == Sorting
  #
  # By default ActiveAdmin::OrderClause is used for sorting logic
  # You can inherit it with own class and inject it for all resources
  #
  # config.order_clause = MyOrderClause

  # == Webpacker
  #
  # By default, Active Admin uses Sprocket's asset pipeline.
  # You can switch to using Webpacker here.
  #
  # config.use_webpacker = true
  # Active Admin can be protected by basic authentication in staging environments.
  #
  # config.authentication_method = :authenticate_admin_user!

  #
  # ## Current user
  #
  # Active Admin will associate actions with the current user performing them.
  #
  # You can configure what named method it calls to find the current user here.
  #
  # config.current_user_method = :current_admin_user


  #
  # ## Root an namespace actions
  #
  # Action items will be displayed in the header of all root namespace pages.
  #
  # The default action items are:
  #
  # config.namespace_actions :admin, { 'New Post' => 'new_admin_post_path' }
  #
  # You can add your own action items for a particular namespace:
  #
  # config.namespace_actions :admin, { 'Report' => 'new_admin_report_path' }
  #
  # You can remove the an action item for a particular namespace:
  #
  # config.namespace_actions.delete_if do |namespace, action|
  #   namespace == :admin && action.name == 'New Post'
  # end


  #
  # ## Viewport meta tag
  #
  # Active Admin saw a change in its default viewport meta tag in 3.0.
  # To keep the old behavior, you can set the `viewport` option to `true`.
  #
  # config.viewport = true


  #
  # ## Custom stylesheets
  #
  # You can customize the look of Active Admin by adding your own stylesheets.
  #
  # To "push" styles onto Active Admin's included assets, use the `register_stylesheet`
  # method. It accepts a path to a file and optional media and screen defined in the options hash.
  #
  #  config.register_stylesheet 'my_stylesheet.css', media: :screen
  config.register_stylesheet 'active_admin.css'


  #
  # ## Custom javascripts
  #
  # You can customize the behavior of Active Admin by adding your own javascripts.
  #
  # To "push" javascripts onto Active Admin's included assets, use the `register_javascript`
  # method. It accepts a path to a file and optional options defined in a hash.
  #
  #  config.register_javascript 'my_javascript.js'
  # config.register_javascript 'active_admin.js', type: "module"


  #
  # ## CSV options
  #
  # Set the CSV builder separator
  #
  # config.csv_builder = {
  #   col_sep: ';',
  #   byte_order_mark: "\xEF\xBB\xBF",
  #   force_quotes: true
  # }


  #
  # ## Localize Date/Time Format
  #
  # You can localize the date/time format used in Active Admin.
  #
  # config.localize_format = :long


  #
  # ## Comments
  #
  # You can disable the comments in Active Admin.
  #
  # config.comments = false
  #
  # You can change the name under which comments are registered:
  #
  # config.comments_registration_name = 'AdminComment'
  #
  # You can change the order for the comments and you can change the column
  # to be used for ordering.
  #
  # config.comments_order = 'created_at ASC'
  #
  # You can disable the menu item for the comments index page.
  #
  # config.comments_menu = false
  #
  # You can customize the comment menu:
  #
  # config.comments_menu = { parent: 'Admin', priority: 1 }


  #
  # ## Batch Actions
  #
  # You can disable batch actions here:
  #
  # config.batch_actions = false


  #
  # ## Controller to render authorization failures
  #
  # You can change the controller and method name that renders authorization failures
  #
  # config.authorization_failure_controller = 'sessions'
  # config.authorization_failure_action = 'new'


  #
  # ## Breadcrumbs
  #
  # You can change the breadcrumb separator
  #
  # config.breadcrumb_separator = ' / '


  #
  # ## Create Another Checkbox
  #
  # You can show a "Create another" checkbox on a form page so that the user is
  # redirected to the new page after a successful save.
  #
  # config.create_another = true


  #
  # ## Pagination
  #
  # You can change the default per page values for models.
  #
  # config.default_per_page = 30
  #
  # You can change the max per page value.
  #
  # config.max_per_page = 10_000


  #
  # ## Footer
  #
  # You can customize the footer of Active Admin.
  #
  # To override the default footer text, you can change the `footer` config.
  #
  # config.footer = 'my custom footer text'
  #
  # To provide a logo for the footer, you can change the `footer_logo` config.
  #
  # config.footer_logo = 'logo.png'


  #
  # ## Table Builder Class
  #
  # You can change the table builder class used to render tables
  #
  # config.table_builder = 'ActiveAdmin::Views::TableFor'


  #
  # ## Index default actions
  #
  # You can disable default actions in index pages on a per-model basis.
  # The "View", "Edit" and "Delete" actions are enabled by default..
  #
  # config.remove_action_item(:destroy, for: User)
  # config.remove_action_item(:edit, for: User)
  # config.remove_action_item(:show, for: User)
  # config.remove_action_item(:new, for: User)


  #
  # ## Default Scopes
  #
  # You can remove the "All" scope from the index page
  #
  # config.remove_scope 'all'


  #
  # ## Preserve Filters
  #
  # You can preserve filters on a per-model basis. The options available are:
  #
  # `true`  (default) - Preserves filters locally (in browser's `localStorage`)
  # `false` - Does not preserve filters
  # `:session` - Preserves filters in the session
  #
  # config.preserve_filters = true


  #
  # ## Inflections
  #
  # Active Admin deeply relies on Active Support's inflector to pluralize and
  # singularize resource names. If you have any special cases, you can add them
  # to the inflector's rules.
  #
  # ActiveSupport::Inflector.inflections(:en) do |inflect|
  #   inflect.irregular 'person', 'people'
  # end


  #
  # ## Includes
  #
  # You can specify relationships to be included in an index page query.
  #
  # config.includes = [:author]


  #
  # ## Number formatting
  #
  # You can customize the formatting of numbers.
  #
  # config.number_format = ->(number) { service.number_to_currency(number) }


  #
  # ## Meta tags
  #
  # You can set meta tags for the Active Admin pages.
  #
  # config.meta_tags = {
  #   viewport: 'width=device-width, initial-scale=1'
  # }


  #
  # ## Favicon
  #
  # You can set a favicon for the Active Admin pages.
  #
  # config.favicon = '/favicon.ico'

  # By default, Active Admin uses its own stylesheets and JavaScripts.
  # To use a custom setup, disable the default assets and register your own.
end
