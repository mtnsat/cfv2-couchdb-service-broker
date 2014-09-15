require 'couchdb'

class CouchDBService
  def initialize(server, port, user, pass)
    @server = CouchDB::Server.new(server, port, user, pass)
  end

  def create_db!(name)
    database(name).create_if_missing!
  end

  def delete_db!(name)
    database(name).delete_if_missing!
  end

  private

  def database(name)
    CouchDB::Database.new(@server, name)
  end
end
