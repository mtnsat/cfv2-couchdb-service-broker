require 'sinatra'
require 'json'
require 'yaml'

## Set if you want to switch the settings config
# SETTINGS_FILENAME = 'config/foo.yml'

class CouchDBBroker < Sinatra::Base
  get '/catalog' do
    content_type :json

    self.class.settings.fetch('catalog').to_json
  end

  private

  def self.settings
    file = defined?(SETTINGS_FILENAME) ? SETTINGS_FILENAME : 'config/settings.yml'
    @settings ||= YAML.load_file(file)
  end
end
