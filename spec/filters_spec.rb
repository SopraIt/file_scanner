require "helper"

describe FileScanner::Filters do
  it "must return default instances" do
    filters = FileScanner::Filters.defaults
    filters.first.must_be_instance_of FileScanner::Filters::LastAccess
    filters.last.must_be_instance_of FileScanner::Filters::SizeRange
  end

  describe FileScanner::Filters::LastAccess do
    it "must exclude files last accessed after specified time" do
      filter = FileScanner::Filters::LastAccess.new
      Stubs.files.select { |f| filter.call(f) }.must_be_empty
    end

    it "must include files last accessed before specified time" do
      filter = FileScanner::Filters::LastAccess.new(Time.now+1)
      Stubs.files.select { |f| filter.call(f) }.size.must_equal Stubs.files.size
    end
  end

  describe FileScanner::Filters::SizeRange do
    it "must include files smaller than min_size" do
      filter = FileScanner::Filters::SizeRange.new(min: 5, max: 9)
      Stubs.files.select { |f| filter.call(f) }.size.must_equal Stubs.files.size
    end
  end
end
