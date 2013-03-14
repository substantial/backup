# encoding: utf-8

module BackupSpec
  class PerformedJob
    attr_reader :logger, :archive
    def initialize(trigger)
      @logger = Backup::Logger.saved.shift
      @archive = BackupSpec::FinalArchive.new(trigger)
    end
  end
end
