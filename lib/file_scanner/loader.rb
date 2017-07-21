module FileScanner
  class Loader
    def initialize(path:, extensions: [])
      @path = path
      @extensions = extensions
    end

    def call
      Dir.glob(files_path)
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
