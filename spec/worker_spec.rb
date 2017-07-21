require "helper"

describe FileScanner::Worker do
  let(:loader) { -> { Stubs.paths } }
  let(:filter) { ->(file) { true } }

  it "must yield all the paths if no slice size is specified" do
    instance = FileScanner::Worker.new(loader: loader, filter: filter)
    instance.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end

  it "must yield slice of paths on given block" do
    instance = FileScanner::Worker.new(loader: loader, filter: filter, slice_size: 5)
    instance.call do |files|
      files.size.must_equal 5
    end
  end

  it "must call policies for each slice of paths" do
    policies = []
    policies << ->(slice) { :delete_cache }
    policies << ->(slice) { :remove_from_disk }
    instance = FileScanner::Worker.new(loader: loader, filter: filter, policies: policies, slice_size: 5)
    instance.call.uniq.must_equal %i[delete_cache remove_from_disk]
  end

  it "must prevent yielding slice if policies are specified" do
    instance = FileScanner::Worker.new(loader: loader, filter: filter, policies: [->(slice) { :call_me } ], slice_size: 5)
    instance.call { |slice| fail "never reached" }.uniq.must_equal(%i[call_me])
  end
end
