module FileScanner
  class Filter
    DAY = 3600*24

    attr_reader :last_atime, :min_size

    def initialize(last_atime: Time.now-30*DAY, min_size: 0)
      @last_atime = last_atime
      @min_size = min_size.to_i
    end 

    def call(file)
      File.atime(file) <= @last_atime || File.size(file) <= @min_size
    end
  end
end
