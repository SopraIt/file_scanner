require "helper"

describe FileScanner::Worker do
  let(:truthy) { [->(_) { true }] }
  let(:falsey) { [ ->(_) { false }] }
  let(:mixed) { truthy.concat(falsey) }
  let(:worker) { FileScanner::Worker.new(path: Stubs.dirname, filters: truthy) }

  it "must return a lazy enumerator when no block is passed" do
    worker.call.must_be_instance_of Enumerator::Lazy
  end

  it "must yield an empty array if no filter matches" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: falsey)
    worker.call do |slice|
      slice.must_be_empty
    end
  end
  
  it "must select files by any matching filter" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: mixed)
    worker.call do |slice|
      slice.wont_be_empty
    end
  end

  it "must select files by all matching filter" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: mixed, all: true)
    worker.call do |slice|
      slice.must_be_empty
    end
  end

  it "must yield slice of files when specified" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: truthy, slice: 5)
    worker.call do |slice|
      (slice.size <= 5).must_equal true
    end
  end
end
