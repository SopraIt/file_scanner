require "logger"

module FileScanner
  class Worker
    attr_reader :policies

    def initialize(loader:, filter: Filter.new, policies: [], logger: Logger.new(nil), slice_size: nil)
      @loader = loader
      @filter = filter
      @policies = policies
      @slice_size = slice_size.to_i
      @logger = logger
    end

    def call
      slices.map do |slice|
        yield(slice) if block_given? && policies.empty?
        policies.map do |policy|
          @logger.info { "applying \e[1m#{policy}\e[0m to \e[1m#{slice.size}\e[0m files" }
          policy.call(slice)
        end
      end.flatten
    rescue StandardError => e
      @logger.error(e.message)
      raise e
    end

    private def files
      @files ||= Array(@loader.call).select do |f|
        @filter.call(f)
      end
    end

    private def slices
      return [files] if @slice_size.zero?
      files.each_slice(@slice_size)
    end
  end
end
