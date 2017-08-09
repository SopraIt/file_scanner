require "logger"

module FileScanner
  class Worker
    attr_reader :filters

    def self.default_logger
      Logger.new(nil).tap do |logger|
        logger.level = Logger::ERROR
      end
    end

    def initialize(loader:, filters: Filters::defaults, logger: self.class.default_logger, slice: nil)
      @loader = loader
      @filters = filters
      @slice = slice.to_i
      @logger = logger
    end

    def call
      slices.each do |slice|
        yield(slice, @logger) if block_given?
      end
    rescue StandardError => e
      @logger.error { e.message }
      raise e
    end

    private def files
      paths = @loader.call
      paths.select! { |file| filter(file) } || paths
    end

    private def filter(file)
      @filters.any? do |filter|
        @logger.info { "applying \e[33m#{filter}\e[0m to #{File.basename(file)}" }
        filter.call(file)
      end
    end

    private def slices
      return [files] if @slice.zero?
      files.each_slice(@slice)
    end
  end
end
