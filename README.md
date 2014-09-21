# CouchDB Service Broker for Cloud Foundry v2

## About

This application sets up a Cloud Foundry v2 service broker to provide
access to a [CouchDB](http://couchdb.apache.org/) server.

This was developed specifically to support the Stackato v3.4 environment, but should work for any Cloud Foundry v2 based PaaS.


## Configuration

All of the broker's settings are configured in ``config/setting.yml``.

### basic_auth

Access to the service broker requires basic HTTP authentication. The credentials required are set here.

### couchdb

CouchDB IP address, port, and admin credentials are set here.


## Installation

### Stackato v3

- Push as a new application to Stackato as usual. A basic ``stackato.yml`` manifest is provided for this purpose.
- Register the broker: `stackato add-service-broker`


## Usage

### Create database

A new database can be generated on the targeted CouchDB instance by creating a new service instance:

e.g. on Stackato v3: ``stackato create-service couchdb newdb myapp``

### Bind credentials

User credentials can be generated and bound to the new database by binding the app to the service:

e.g. on Stackato v3: ``stackato bind-service newdb myapp``

Credentials for the new user are automatically passed as an environment variable (``VCAP_SERVICES['couchdb']['credentials']``) in the bound app's container.

### Purge credentials

Previously generated user credentials can be deleted from the CouchDB instance by unbinding the associated service and app:

e.g. on Stackato v3: ``stackato unbind-service newdb myapp``

### Delete database

An existing database can be deleted by deleting the associated service instance:

e.g. on Stackato v3: ``stackato delete-service couchdb``
