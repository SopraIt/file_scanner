require "logger"
require "file_scanner/filters"
require "file_scanner/loader"

module FileScanner
  class Worker
    attr_reader :loader, :filters

    def initialize(loader:, filters: Filters::defaults, all: false, slice: nil, logger: Logger.new(nil))
      @loader = loader
      @filters = filters
      @mode = mode(all)
      @slice = slice.to_i
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

    private def filtered
      @loader.call.select { |file| filter(file) }
    end

    private def mode(all)
      return :all? if all
      :any?
    end

    private def filter(file)
      @filters.send(@mode) do |filter|
        @logger.debug { "filtering by \e[33m#{@mode}\e[0m with \e[33m#{filter}\e[0m on #{File.basename(file)}" }
        filter.call(file)
      end
    end

    private def slices
      return [filtered] if @slice.zero?
      filtered.each_slice(@slice)
    end
  end
end
