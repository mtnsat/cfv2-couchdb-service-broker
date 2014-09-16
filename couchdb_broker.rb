require 'sinatra'
require 'json'
require 'yaml'
require_relative 'couchdb_service'

## Set if you want to switch the settings config
# SETTINGS_FILENAME = 'config/foo.yml

class CouchDBBroker < Sinatra::Base
  def initialize
    super

    settings_file = defined?(SETTINGS_FILENAME) ? SETTINGS_FILENAME : 'config/settings.yml'
    @@settings = YAML.load_file(settings_file)
    @@couch_settings = @@settings.fetch('couchdb')
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
    code = couchdb_service.create_db!(db_name(id)) ? 201 : 200

    status code
    {'dashboard_url' => "http://#{@@couch_settings.fetch('ip')}:#{@@couch_settings.fetch('port')}/#{db_name(id)}"}.to_json
  end

  # Bind
  put '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json

    begin
      credentials = couchdb_service.create_user_for_db(db_name(instance_id), binding_id)
      status 201
      {"credentials" => credentials}.to_json
    rescue CouchDB::UnauthorizedError
      status 401
      {"description" => "Unauthorized"}.to_json
    rescue CouchDB::NotFoundError
      status 404
      {"description" => "Not found"}.to_json
    end
  end

  # Unbind
  delete '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json

    begin
      credentials = couchdb_service.remove_user_for_db(db_name(instance_id), binding_id)
      status 200
      {}.to_json
    rescue CouchDB::UnauthorizedError
      status 401
      {"description" => "Unauthorized"}.to_json
    rescue CouchDB::NotFoundError
      status 404
      {"description" => "Not found"}.to_json
    end
  end

  # Deprovision
  delete '/v2/service_instances/:id' do |id|
    content_type :json

    # returns nil (false) when db does not exist
    code = couchdb_service.delete_db!(db_name(id)) ? 200 : 410

    status code
    {}.to_json
  end

  private

  def couchdb_service
    CouchDBService.new(@@couch_settings.fetch('ip'),
                       @@couch_settings.fetch('port'),
                       @@couch_settings.fetch('admin'),
                       @@couch_settings.fetch('pass'))
  end

  def db_name(id)
    "db_#{id}"
  end
end
