require "helper"

describe FileScanner::Worker do
  let(:loader) { -> { Stubs.paths } }
  let(:truthy) { [->(_) { true }] }
  let(:falsey) { [ ->(_) { false }] }

  it "must factory an instance" do
    worker = FileScanner::Worker.factory(path: "/", extensions: %w[gif])
    worker.loader.must_be_instance_of FileScanner::Loader
    worker.must_be_instance_of FileScanner::Worker
  end

  it "must yield all the paths if no slice size is specified" do
    worker = FileScanner::Worker.new(loader: loader, filters: truthy)
    worker.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end

  it "must yield slice of paths on given block" do
    worker = FileScanner::Worker.new(loader: loader, filters: truthy, slice: 5)
    worker.call do |files|
      files.size.must_equal 5
    end
  end

  it "must yield an empty array if no filter matches" do
    worker = FileScanner::Worker.new(loader: loader, filters: falsey)
    worker.call do |files|
      files.must_be_empty
    end
  end
  
  it "must select file for any matching filter" do
    filters = truthy.concat(falsey)
    worker = FileScanner::Worker.new(loader: loader, filters: filters)
    worker.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end
end
