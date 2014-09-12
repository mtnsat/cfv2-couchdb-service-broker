require 'sinatra'
require 'json'
require 'yaml'

## Set if you want to switch the settings config
# SETTINGS_FILENAME = 'config/foo.yml'

class CouchDBBroker < Sinatra::Base
  get '/catalog' do
    content_type :json

    self.class.app_settings.fetch('catalog').to_json
  end

  private

  def self.app_settings
    settings_filename = defined?(SETTINGS_FILENAME) ? SETTINGS_FILENAME : 'config/settings.yml'
    @app_settings ||= YAML.load_file(settings_filename)
  end
end
