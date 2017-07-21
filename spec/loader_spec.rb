require "helper"

describe FileScanner::Loader do
  let(:path) { Stubs.dirname }

  it "must collect no files for invalid path" do
    instance = FileScanner::Loader.new(path: "noent", extensions: %w[jpg gif])
    instance.call.must_be_empty
  end

  it "must collect all files in path when no extensions is specified" do
    instance = FileScanner::Loader.new(path: path)
    (instance.call.size >= Stubs.files.size).must_equal true
  end

  it "must collect files in path with specified extension only" do
    instance = FileScanner::Loader.new(path: path, extensions: %w[gif])
    instance.call.each do |f|
      File.extname(f).must_equal ".gif"
    end
  end

  it "must collect files in path with specified extensions" do
    instance = FileScanner::Loader.new(path: path, extensions: %w[jpg gif])
    instance.call.sort.must_equal Stubs.paths.sort
  end
end
