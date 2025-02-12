require 'sidekiq'
require 'sidekiq/api'

module Sidekiq::Instrument
  class Worker
    include Sidekiq::Worker

    # These defaults are for compatibility with Resque's stats names
    # (i.e. the metrics will reported as :processed, :workers, :pending, and :failed).
    # Feel free to override.
    METRIC_NAMES = {
      processed:    nil,
      workers_size: :workers,
      enqueued:     :pending,
      failed:       nil
    }

    def perform
      info = Sidekiq::Stats.new

      self.class::METRIC_NAMES.each do |method, stat|
        stat ||= method

        StatsD.gauge "shared.sidekiq.stats.#{stat}", info.send(method)
      end

      working = Sidekiq::ProcessSet.new.select { |p| p[:busy] == 1 }.count
      StatsD.gauge "shared.sidekiq.stats.working", working

      info.queues.each do |name, size|
        StatsD.gauge "shared.sidekiq.#{name}.size", size
      end

      Sidekiq::Queue.all.each do |queue|
        StatsD.gauge "shared.sidekiq.#{queue.name}.latency", queue.latency
      end
    end
  end
end
