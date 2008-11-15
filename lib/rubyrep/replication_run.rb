module RR
  
  # Executes a single replication run
  class ReplicationRun

    # The current Session object
    attr_accessor :session

    # Returns the current ReplicationHelper; creates it if necessary
    def helper
      @helper ||= ReplicationHelper.new(self)
    end

    # Returns the current replicator; creates it if necessary.
    def replicator
      @replicator ||=
        Replicators.replicators[session.configuration.options[:replicator]].new(helper)
    end

    # Executes the replication run.
    def run
      success = false

      loop do
        diff = ReplicationDifference.new session
        diff.load
        break unless diff.loaded?
        replicator.replicate_difference diff
      end
      success = true # considered to be successful if we get till here
    ensure
      helper.finalize success
    end

    # Creates a new ReplicationRun instance.
    # * +session+: the current Session
    def initialize(session)
      self.session = session
    end
  end
end