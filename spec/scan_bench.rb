require "helper"

LIMIT = 5000
filters = ->(f) { FileTest.file?(f) && File.size(f) >= 10*1024  }

Benchmark.ips do |x|
  x.report("Dir") do
    Dir.glob(File.expand_path("~/**/*")).select { |f| filters.call(f) }.take(LIMIT)
  end

  x.report("Find") do
    Find.find(File.expand_path("~")).lazy.select { |f| filters.call(f) }.take(LIMIT).to_a
  end

  x.compare!
end
