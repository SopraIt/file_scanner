require "helper"

describe FileScanner::Filters do
  it "must return default instances" do
    filters = FileScanner::Filters.defaults
    filters.size.must_equal 3
    filters[0].must_be_instance_of FileScanner::Filters::LastAccess
    filters[1].must_be_instance_of FileScanner::Filters::MatchingName
    filters[2].must_be_instance_of FileScanner::Filters::SizeRange
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

  describe FileScanner::Filters::MatchingName do
    it "must exclude all file names by default" do
      filter = FileScanner::Filters::MatchingName.new
      Stubs.files.select { |f| filter.call(f) }.must_be_empty
    end

    it "must include files with names matching regex" do
      filter = FileScanner::Filters::MatchingName.new(/gif$/)
      Stubs.files.select { |f| filter.call(f) }.size.must_equal 10
    end

    it "must compile regexp before matching" do
      filter = FileScanner::Filters::MatchingName.new(:gif)
      Stubs.files.select { |f| filter.call(f) }.size.must_equal 10
    end
  end

  describe FileScanner::Filters::SizeRange do
    it "must include files within 0 and 5KB" do
      filter = FileScanner::Filters::SizeRange.new
      Stubs.files.select { |f| filter.call(f) }.size.must_equal Stubs.files.size
    end

    it "must exclude files larger than 5 bytes" do
      filter = FileScanner::Filters::SizeRange.new(max: 5)
      Stubs.files.select { |f| filter.call(f) }.must_be_empty
    end
  end
end
