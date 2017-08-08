require "helper"
using FileScanner::Refinements

describe FileScanner::Refinements do
  it "must expand string with predicate matching" do
    Stubs.files.last.path.matches?(/obsolete/).must_equal true
  end
end
