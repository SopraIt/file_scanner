require "logger"
require "file_scanner/filters"
require "file_scanner/loader"

module FileScanner
  class Worker
    def self.factory(path:, extensions: [], filters: [], all: false, slice: nil, limit: -1, logger: Logger.new(nil))
      loader = Loader.new(path: path, extensions: extensions, limit: limit)
      new(loader: loader, filters: filters,  slice: slice, all: all, logger: logger)
    end

    attr_reader :loader, :filters

    def initialize(loader:, filters: Filters::defaults, all: false, slice: nil, logger: Logger.new(nil))
      @loader = loader
      @filters = filters
      @all = !!all
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

    private def fetch_mode(mode)
      return :any? unless @filters.respond_to?(mode)
      mode
    end

    private def filtered
      files = @loader.call
      files.select! { |file| filter(file) } || files
    end

    private def mode
      return :all? if @all
      :any?
    end

    private def filter(file)
      @filters.send(mode) do |filter|
        @logger.debug { "selecting by \e[33m#{mode}\e[0m with filter \e[33m#{filter}\e[0m on #{File.basename(file)}" }
        filter.call(file)
      end
    end

    private def slices
      return [filtered] if @slice.zero?
      filtered.each_slice(@slice)
    end
  end
end
