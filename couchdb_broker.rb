require 'sinatra'
require 'json'
require 'yaml'
require_relative 'couchdb_service'

## Set if you want to switch the settings config
# SETTINGS_FILENAME = 'config/foo.yml'
SERVER = 'localhost'
PORT = 5985

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

  # Catalog
  get '/v2/catalog' do
    content_type :json

    @@settings.fetch('catalog').to_json
  end

  # Provision
  put '/v2/service_instances/:id' do |id|
    content_type :json

    # returns nil (false) when db already exists
    code = couchdb_service.create_db!(id) ? 201 : 200

    status code
    {'dashboard_url' => "http://#{SERVER}:#{PORT}/#{id}"}.to_json
  end

  # Bind
  put '/v2/service_instances/:instance_id/service_bindings/:id'
    service_id
  end

  # Deprovision
  delete '/v2/service_instances/:id' do |id|
    content_type :json

    # returns nil (false) when db does not exist
    code = couchdb_service.delete_db!(id) ? 200 : 410

    status code
    {}.to_json
  end

  private

  def couchdb_service
    creds = @@settings.fetch('couchdb')
    CouchDBService.new(SERVER, PORT, creds.fetch('user'), creds.fetch('pass'))
  end
end
