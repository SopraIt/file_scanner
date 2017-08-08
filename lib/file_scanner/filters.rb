require "file_scanner/refinements"

module FileScanner
  using Refinements
  module Filters
    def self.defaults
      constants.map do |name|
        self.const_get(name).new
      end
    end

    class LastAccess
      DAY = 3600*24

      def initialize(atime = Time.now-30*DAY)
        @atime = atime
      end

      def call(file)
        @atime >= File.atime(file)
      end
    end

    class MatchingName
      def initialize(regexp = nil)
        @regexp = compile(regexp)
      end

      def call(file)
        return true unless @regexp
        File.basename(file).matches?(@regexp)
      end

      private def compile(regexp)
        return unless regexp
        return regexp if regexp.is_a?(Regexp)
        Regexp.compile(regexp.to_s)
      end
    end

    class SizeRange
      def initialize(min: 100, max: Float::INFINITY)
        @range = min..max
      end

      def call(file)
        @range === File.size(file)
      end
    end
  end
end
