require 'Redis'
require 'json'
require 'yaml'

class Redfig

  attr_reader :app, :env, :redis

  # How configuration values are stored in Redis:
  #
  # keys are formatted as:
  #
  # prefix:env:app:key
  # 
  # eg: redfig:development:auth-api:db_host
  # eg: redfig:prod:default:support_email


  def initialize options={}
    # set defaults
    @env                  = options[:env] || 'default'
    @app                  = options[:app] || 'default'
    @verbose              = options[:verbose].nil?              ? true : options[:verbose]
    @subscribe_to_changes = options[:subscribe_to_changes].nil? ? true : options[:subscribe_to_changes]
    @cache_locally        = options[:cache_locally].nil?        ? true : options[:cache_locally]

    redis_options = options[:redis] || {}

    @prefix = redis_options[:prefix] || 'redfig'

    @local_cache = {}

    puts "- Initializing Redis client with settings: #{redis_options.inspect}" if @verbose

    @redis = Redis.new redis_options
  end

  def set! identifier, val, app=nil, env=nil
    raise "Key must not be type nil" if identifier.nil?

    puts "- Setting #{identifier} => #{val.inspect}" if @verbose

    app ||= @app
    env ||= @env

    unless val.instance_of? String
      val = val.to_json
    end

    key = "#{@prefix}:#{env}:#{app}:#{identifier}"
    puts "KEY: #{key}"

    @redis.set key, val
  end

  def get! identifier
    puts "- Getting #{identifier}"

    # need to fetch four keys, in order of priority
    # alternatively can just glob.. glob???
    candidates = @redis.multi do
      @redis.get "#{@prefix}:#{@env}:#{@app}:#{identifier}"
      @redis.get "#{@prefix}:default:#{@app}:#{identifier}"
      @redis.get "#{@prefix}:#{@env}:default:#{identifier}"
      @redis.get "#{@prefix}:default:default:#{identifier}"
    end

    # iterate through keys, first non-nil wins
    candidates.each do |candidate|
      if candidate
        @local_cache[identifier] = candidate
        return candidate
      end
    end

    raise "Key not found"
  end

  def [] identifier
    # if we have a local cache entry, just return that
    return val if val = @local_cache[identifier]

    # otherwise lazily fill the cache from Redis
    get! identifier
  end

  # import file given file handler or filename
  def import_file! file
    # if given a file name, try opening it
    if file.instance_of? String
      _file = File.open file
    elsif file.instance_of? File
      _file = file
    else
      raise "type not recognized: #{file.class.name}"
    end

    puts "- Iterating over keys in #{_file.inspect}"
    
    # iterate over keys
    YAML::load(_file).each do |env, env_hash|
      env_hash.each do |app, app_hash|
        app_hash.each do |namespace, namespace_hash|
          namespace_hash.each do |identifier, value|
            k = "#{namespace}:#{identifier}"
            set! k, value, app, env
          end
        end
      end
    end
  end

  # import every yaml file in folder
  def import_folder! folder
  end
end