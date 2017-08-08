require "helper"

describe FileScanner::Worker do
  let(:loader) { -> { Stubs.paths } }
  let(:filters) { [->(file) { true }] }
  let(:policies) { Stubs.policies }

  it "must yield all the paths if no slice size is specified" do
    instance = FileScanner::Worker.new(loader: loader, filters: filters)
    instance.call do |files|
      files.size.must_equal Stubs.paths.size
    end
  end

  it "must yield slice of paths on given block" do
    instance = FileScanner::Worker.new(loader: loader, filters: filters, slice: 5)
    instance.call do |files|
      files.size.must_equal 5
    end
  end

  it "must call policies for each slice of paths" do
    policies.each { |policy| policy.expect(:call, nil, [Stubs.paths]) }
    instance = FileScanner::Worker.new(loader: loader, filters: filters, policies: policies)
    instance.call
    policies.each(&:verify)
  end

  it "must call policies on yielded slice of paths" do
    instance = FileScanner::Worker.new(loader: loader, filters: filters, slice: 5)
    instance.call do |slice|
      ->(s) { s.size }.call(slice).must_equal 5
    end
  end

  it "must prevent yielding slice if policies are specified" do
    instance = FileScanner::Worker.new(loader: loader, filters: filters, policies: [->(slice) { :call_me }], slice: 5)
    instance.call { |slice| fail "never reached" }.must_be_nil
  end
end
