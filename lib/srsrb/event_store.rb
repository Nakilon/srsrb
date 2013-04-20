require 'srsrb/errors'
require 'hamster/vector'
require 'hamster/set'
require 'hamsterdam'
require 'atomic'

module SRSRB

  class EventStore
    UNSPECIFIED = Object.new
    def initialize
      self.events = Hamster.vector
      self.subscribers = Hamster.set
      self.versions = Atomic.new Hamster.hash
    end

    def record! stream_id, event, expected_version=UNSPECIFIED
      stream_version = versions.get.fetch(stream_id) { current_version }
      raise WrongEventVersionError if expected_version != UNSPECIFIED && stream_version != expected_version

      $stderr.puts "No version passed to #{self.class.name}#record! at #{caller[0]}" if expected_version == UNSPECIFIED

      commit = Commit.new stream_id: stream_id, data: event
      self.events = events.add(commit)

      stream_version = current_version

      versions.update { |vs| vs.put(stream_id, stream_version) }

      subscribers.each do |listener|
        listener.handle_event stream_id, event
      end

      stream_version
    end

    def subscribe listener
      events.each do |commit|
        listener.handle_event commit.stream_id, commit.data
      end

      self.subscribers = subscribers.add listener
    end

    def count
      events.size
    end

    def current_version
      events.size
    end

    private
    attr_accessor :events, :subscribers, :versions
  end

  Commit = Hamsterdam::Struct.define(:stream_id, :data)
end
