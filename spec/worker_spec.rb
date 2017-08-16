require "helper"

describe FileScanner::Worker do
  let(:loader) { -> { Stubs.paths } }
  let(:truthy) { [->(_) { true }] }
  let(:falsey) { [ ->(_) { false }] }
  let(:mixed) { truthy.concat(falsey) }

  it "must factory an instance" do
    worker = FileScanner::Worker.factory(path: "/", extensions: %w[gif])
    worker.loader.must_be_instance_of FileScanner::Loader
    worker.must_be_instance_of FileScanner::Worker
  end

  it "must yield an empty array if no filter matches" do
    worker = FileScanner::Worker.new(loader: loader, filters: falsey)
    worker.call do |files|
      files.must_be_empty
    end
  end
  
  it "must select files by any matching filter" do
    worker = FileScanner::Worker.new(loader: loader, filters: mixed, limit: "none")
    worker.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end

  it "must select files by all matching filter" do
    worker = FileScanner::Worker.new(loader: loader, filters: mixed, all: true)
    worker.call do |files|
      files.must_be_empty
    end
  end

  it "must return plain enumerator if no block is passed" do
    worker = FileScanner::Worker.new(loader: loader, filters: truthy, slice: 5)
    worker.call.must_be_instance_of Enumerator
  end

  it "must yield all files if no slice is specified" do
    worker = FileScanner::Worker.new(loader: loader, filters: truthy, all: true)
    worker.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end

  it "must yield slice of files when specified" do
    worker = FileScanner::Worker.new(loader: loader, filters: truthy, slice: 5)
    worker.call do |files|
      files.size.must_equal 5
    end
  end

  it "must limit files by specified number" do
    worker = FileScanner::Worker.new(loader: loader, filters: truthy, limit: 13)
    worker.call.to_a.flatten.size.must_equal 13
  end
end
