require "helper"

describe FileScanner::Worker do
  let(:loader) { -> { Stubs.paths } }
  let(:filters) { [->(file) { true }] }

  it "must yield all the paths if no slice size is specified" do
    worker = FileScanner::Worker.new(loader: loader, filters: filters)
    worker.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end

  it "must yield slice of paths on given block" do
    worker = FileScanner::Worker.new(loader: loader, filters: filters, slice: 5)
    worker.call do |files|
      files.size.must_equal 5
    end
  end
end
