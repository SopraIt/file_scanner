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
                   filecheck: false,
                   logger: Logger.new(nil))
      @path = File.expand_path(path)
      @filters = filters
      @mode = mode(all)
      @filecheck = filecheck
      @logger = logger
    end

    def call
      @logger.debug { "skipping directories" } if @filecheck
      paths.lazy.select { |file| valid?(file) && filter(file) }
    rescue StandardError => e
      @logger.error { e.message }
      raise e
    end

    private def mode(all)
      all ? ALL : ANY
    end

    private def valid?(file)
      return true unless @filecheck
      FileTest.file?(file)
    end

    private def filter(file)
      @logger.debug { "filters applied by \e[35m#{@mode}\e[0m" }
      @filters.send(@mode) do |filter|
        @logger.debug { "filtering on \e[33m#{File.basename(file)}\e[0m" }
        filter.call(file)
      end
    end

    private def paths
      Find.find(@path)
    end
  end
end
