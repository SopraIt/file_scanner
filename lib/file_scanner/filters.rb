module FileScanner
  module Filters
    def self.all
      constants
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
