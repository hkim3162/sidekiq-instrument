$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
require 'pry'
require 'statsd/instrument'
require 'sidekiq/testing'

Sidekiq::Testing.inline!

require 'sidekiq/instrument'

RSpec.configure do |config|
  config.include StatsD::Instrument::Matchers
end

class MyWorker
  include Sidekiq::Worker

  def perform; end
end

class MyOtherWorker
  include Sidekiq::Worker

  def perform; end

  def statsd_metric_name(event)
    "my_other_worker.#{event}"
  end
end
