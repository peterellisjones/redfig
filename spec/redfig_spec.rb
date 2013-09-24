require 'rspec'
require './lib/redfig'

describe Redfig do

  before :each do 
    r = Redis.new
    r.flushall
  end

  describe "redfig" do
    it "Sets app and env" do
      redfig = Redfig.new app: 'my_app', env: 'my_env'
      redfig.app.should == 'my_app'
      redfig.env.should == 'my_env'
    end

    it "Sets the default prefix to 'redfig'" do
      redfig = Redfig.new app: 'my_app', env: 'my_env'
      Redis.any_instance.stub(:set) do |key|
        key.split(':').first.should == 'redfig'
      end
      redfig.set! 'test_key', 'test_value'
    end

    it "Lets you set a specific prefix" do 
      redfig = Redfig.new app: 'my_app', env: 'my_env', redis: {prefix: 'my_prefix'}
      Redis.any_instance.stub(:set) do |key|
        key.split(':').first.should == 'my_prefix'
      end
      redfig.set! 'test_key', 'test_value'
    end

    it "Stores parameters in Redis" do
      redfig = Redfig.new app: 'my_app', env: 'my_env'
      redfig.set! 'test_namespace:test_key', 'test_value'

      key = "redfig:my_env:my_app:test_namespace:test_key"
      redfig.redis.get(key).should == 'test_value'
    end

    # it "Loads parameters from yml" do 
    #   file = mock 'file'
    #   file.stub
    # end
  end
end