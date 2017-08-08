module FileScanner
  module Refinements
    refine(String) do
      def matches?(re)
        return match?(re) if defined?("".match?)
        !!match(re)
      end
    end
  end
end
