$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "file_scanner"
require "minitest/autorun"
require "stubs"
require "tempfile"
require "tmpdir"
require "benchmark/ips"
