require "helper"

SIZE = 10*1024
LIMIT = 5000

Benchmark.ips do |x|
  x.report("Dir") do
    Dir.glob(File.expand_path("~/**/*")).select do |f| 
      FileTest.file?(f) && File.size(f) >= SIZE
    end.take(LIMIT)
  end

  x.report("Find") do
    Find.find(File.expand_path("~")).lazy.select do |f|
      FileTest.file?(f) && File.size(f) >= SIZE
    end.take(LIMIT).to_a
  end

  x.compare!
end
