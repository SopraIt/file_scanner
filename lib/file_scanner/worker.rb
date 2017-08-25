require "find"
require "logger"
require "file_scanner/filters"

module FileScanner
  class Worker
    ALL = :all?
    ANY = :any?

    attr_reader :filters

    def initialize(path:, 
                   filters: Filters::defaults, 
                   all: false, 
                   check: false,
                   logger: Logger.new(nil))
      @path = File.expand_path(path)
      @filters = filters
      @mode = mode(all)
      @check = check
      @logger = logger
    end

    def call
      paths.lazy.select { |file| valid?(file) && filter(file) }
    rescue StandardError => e
      @logger.error { e.message }
      raise e
    end

    private def mode(all)
      all ? ALL : ANY
    end

    private def valid?(file)
      return true unless @check
      FileTest.file?(file)
    end

    private def filter(file)
      @filters.send(@mode) do |filter|
        @logger.debug { "filtering by \e[33m#{@mode}\e[0m with \e[33m#{filter}\e[0m on #{File.basename(file)}" }
        filter.call(file)
      end
    end

    private def paths
      Find.find(@path)
    end
  end
end
