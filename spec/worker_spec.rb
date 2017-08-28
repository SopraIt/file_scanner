require "helper"

describe FileScanner::Worker do
  before { Stubs.dirs }
  let(:truthy) { [->(_) { true }] }
  let(:falsey) { [ ->(_) { false }] }
  let(:mixed) { truthy.concat(falsey) }
  let(:worker) { FileScanner::Worker.new(path: Stubs.dirname, filters: truthy) }

  it "must return a lazy enumerator when no block is passed" do
    worker.call.must_be_instance_of Enumerator::Lazy
  end

  it "must yield an empty array if no filter matches" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: falsey)
    worker.call.to_a.must_be_empty
  end
  
  it "must select files by any matching filter" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: mixed)
    worker.call.to_a.wont_be_empty
  end

  it "must select files by all matching filter" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: mixed, all: true)
    worker.call.to_a.must_be_empty
  end

  it "must filter slice of files by skipping directories" do
    worker = FileScanner::Worker.new(path: Stubs.dirname, filters: truthy, filecheck: true)
    worker.call.each do |file|
      FileTest.file?(file).must_equal true
    end
  end
end
