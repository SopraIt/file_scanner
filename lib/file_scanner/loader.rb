module FileScanner
  class Loader
    def initialize(path:, extensions: [], limit: -1)
      @path = File.expand_path(path)
      @extensions = extensions
      @limit = limit.to_i
    end

    def call
      paths = Dir.glob(files_path)
      return paths if @limit <= 0
      paths.first(@limit)
    end

    private def files_path
      File.join(@path, "**", extensions_path)
    end

    private def extensions_path
      return "*" if @extensions.empty?
      "*.{#{@extensions.join(",")}}"
    end
  end
end
