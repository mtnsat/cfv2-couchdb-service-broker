require 'sinatra'
require 'json'
require 'yaml'

## Set if you want to switch the settings config
# SETTINGS_FILENAME = 'config/foo.yml'

class CouchDBBroker < Sinatra::Base
  def initialize
    super

    settings_file = defined?(SETTINGS_FILENAME) ? SETTINGS_FILENAME : 'config/settings.yml'
    @@settings = YAML.load_file(settings_file)
  end

  # HTTP Auth required for CFv2
  use Rack::Auth::Basic do |user, pass|
    creds = @@settings.fetch('basic_auth')
    user == creds.fetch('user') and pass == creds.fetch('pass')
  end

  get '/v2/catalog' do
    content_type :json

    @@settings.fetch('catalog').to_json
  end
end
