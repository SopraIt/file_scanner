module Stubs
  extend self

  def files(n = 10, exts = %w[jpg gif])
    @files ||= n.times.map do |i|
      exts.map do |ext|
        Tempfile.new(["obsolete", ".#{ext}"]).tap do |f| 
          f.puts("#{ext} bits")
          f.rewind
        end
      end
    end.flatten 
  end

  def paths
    files.map { |f| f.path }
  end

  def dirname
    @dirname ||= files.map { |f| File.dirname(f) }.uniq.last
  end

  def dirs(n = 10)
    n.times.map do |i|
      Dir.mktmpdir("tmp_#{i}")
    end
  end
end
