require 'couchdb'
require 'faker'

class CouchDBService
  def initialize(server, port, user, pass)
    @server = CouchDB::Server.new(server, port, user, pass)
  end

  def create_db!(name)
    database(name).create_if_missing!
  end

  def delete_db!(name)
    database(name).delete_if_exists!
  end

  def create_user_for_db!(database, name)

    # create user
    user_database = CouchDB::UserDatabase.new(@server)
    couch_user = CouchDB::User.new(user_database, name)

    # set password 
    user_password = Faker::Internet.password(8)
    couch_user.password = user_password

    # save
    couch_user.save

    # add user as database admin
    couch_database = database(database)
    couch_database.security.administrators << couch_user

    { :database => couch_database.url, :user => name, :password => user_password }
  end

  def remove_user_for_db!(database, name)

    # create user
    user_database = CouchDB::UserDatabase.new(@server)
    couch_user = CouchDB::User.new(user_database, name)

    # add user as database admin
    couch_database = database(database)
    couch_database.security.administrators.names.delete(couch_user.name)

    # destroy user
    couch_user.destroy
  end

  private

  def database(name)
    CouchDB::Database.new(@server, name)
  end
end
