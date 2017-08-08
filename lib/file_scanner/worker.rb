require "logger"

module FileScanner
  class Worker
    attr_reader :filters, :policies

    def initialize(loader:, filters: [], policies: [], logger: Logger.new(nil), slice: nil)
      @loader = loader
      @filters = filters
      @policies = policies
      @slice = slice.to_i
      @logger = logger
    end

    def call
      slices.each do |slice|
        yield(slice) if block_given? && policies.empty?
        policies.each do |policy|
          @logger.info { "applying \e[1m#{policy}\e[0m to \e[1m#{slice.size}\e[0m files" }
          policy.call(slice)
        end
      end
    rescue StandardError => e
      @logger.error { e.message }
      raise e
    end

    private def files
      @files ||= Array(@loader.call).select do |f|
        @filters.all? do |filter|
          @logger.info { "applying \e[1m#{filter.class}\w[0m to \e[1m#{File.basename(f)}\e[0m" }
          filter.call(f)
        end
      end
    end

    private def slices
      return [files] if @slice.zero?
      files.each_slice(@slice)
    end
  end
end
