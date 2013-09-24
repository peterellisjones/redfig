Redfig
======

Redis-backed configuration management library for Ruby. Useful when you have a bunch of different apps and services running in different environments, that all need to share configuration parameters (like db settings or API keys etc). 

Currently, the parameters are fetched lazily and cached locally.

## Usage

In your Gemfile:

    gem 'redfig', :git => 'git://github.com/ukoki/redfig.git'
    
To initialize the client:

    require 'redfig'
    $Redfig ||= Redfig.new app: 'my_awesome_app', env: 'development'
    
Optionally pass redis parameters (as you'd pass to [redis-rb](https://github.com/redis/redis-rb)):

    require 'redfig'
    $Redfig ||= Redfig.new app: 'my_awesome_app', env: 'development', redis: {host: 'localhost', port: 6379}

Import settings from yml files. They MUST be formatted like this:

    environment:
       app-name:
          namespace:
             keyname: value(s)
             
Environment and app can just be 'default'. For example:

    # my-settings.yml
    default:
      default:
        db:
          host: dev.db.example.com
          user: user
          password: secret
    prod:
      default:
        db:
          host: prod.db.example.com
      site:
        db:
          user: "another_user"
          password: "another_password"
    

Load yml files by passing a File object or filename

    yml = File.open('my=settings.yml')
    $Redfig.load_yml! yml

Access settings like this:

    $Refig['namespace:key-name']
    
Eg:

    $Redfig['db:host']
    => dev.db.example.com
    
Example Rails database.yml using Redfig:

     <% require 'redfig'
      $Redfig ||= Redfig.new app: 'my_awesome_app', env: Rails.env %>
    
     <%= $Redfig.env %>:
       adapter: sqlserver
       host: <%= $Redfig["db:host"] %>
       username: <%= $Redfig["db:username"] %>
       password: <%= $Redfig["db:password"] %>
    
