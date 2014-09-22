# Copyright (c) 2014 MTN Satellite Communications

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'couchdb'
require 'faker'

class CouchDBService
  def initialize(server, port, user, pass)
    @server = CouchDB::Server.new(server, port, user, pass)
    @server.password_salt = Faker::Internet.password(7)
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
    user_password = Faker::Internet.password(11)
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
