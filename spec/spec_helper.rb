require 'rspec'
require 'fileutils'
require 'tempfile'

Dir['../lib/**/*.rb'].each &method(:require)

require './lib/ransack_mongo'

RSpec.configure do |config|
  config.formatter = 'progress'
end

