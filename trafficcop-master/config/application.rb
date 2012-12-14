require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Trafficcop
  class Application < Rails::Application

=begin     URL TO GET A NEW AUTHO_CODE IN CASE NEEDED.
https://accounts.google.com/o/oauth2/auth?scope=https://www.google.com/apis/ads/publisher https://adwords.google.com/api/adwords&response_type=code&redirect_uri=https://localhost/oauth2callback&approval_prompt=auto&client_id=1096301339654-rvsk0qse1f3ssdg4ap7po989mbdtdj6a.apps.googleusercontent.com&hl=en-US&from_login=1&access_type=offline 
=end 

    API_VERSION = :v201208
    GOOGLE_REFRESH_TOKEN = '1/QQM23j2TN1FNlBoeXKhUJ6UJr0O9vhEhSgvRxQVvhjk'
    CLIENT_ID = '1096301339654-rvsk0qse1f3ssdg4ap7po989mbdtdj6a.apps.googleusercontent.com'
    CLIENT_SECRET = '4c7mPGVfK7biAb5okz0bNMTv'
    REDIRECT_URI  = 'https://localhost/oauth2callback'
    GOOGLE_AUTHORIZATION_CODE= '4/ytJ6aMPcyp4eVCp_-NMcpVGdwP96.EtxW-4Yme8QXuJJVnL49Cc9KYVDGdgI'
    GOOGLE_DFP_SCOPE = 'https://www.google.com/apis/ads/publisher'
    GOOGLE_ADWORDS_SCOPE='https://adwords.google.com/api/adwords'
    GOOGLE_DFP_ORDER_ID = 104721244
    
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
  end
end
