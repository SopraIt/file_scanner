require "find"
require "logger"
require "file_scanner/filters"

module FileScanner
  class Worker
    SLICE = 1000
    ALL = :all?
    ANY = :any?

    attr_reader :filters

    def initialize(path:, 
                   filters: Filters::defaults, 
                   slice: SLICE, 
                   all: false, 
                   logger: Logger.new(nil))
      @path = File.expand_path(path)
      @filters = filters
      @slice = slice.to_i
      @mode = mode(all)
      @logger = logger
    end

    def call
      return slices unless block_given?
      slices.each do |slice|
        yield(slice, @logger)
      end
    rescue StandardError => e
      @logger.error { e.message }
      raise e
    end

    private def mode(all)
      all ? ALL : ANY
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

    private def filtered
      paths.lazy.select { |file| filter(file) }
    end

    private def slices
      filtered.each_slice(@slice)
    end
  end
end
