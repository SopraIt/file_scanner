require "helper"

describe FileScanner::Filter do
  it "must exclude files last accessed after last_atime and larger than min_size" do
    instance = FileScanner::Filter.new
    Stubs.files.select { |f| instance.call(f) }.must_be_empty
  end

  it "must include files last accessed before last_atime" do
    instance = FileScanner::Filter.new(last_atime: Time.now+1)
    Stubs.files.select { |f| instance.call(f) }.size.must_equal Stubs.files.size
  end

  it "must include files smaller than min_size" do
    instance = FileScanner::Filter.new(min_size: "1024")
    Stubs.files.select { |f| instance.call(f) }.size.must_equal Stubs.files.size
  end
end
