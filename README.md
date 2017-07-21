## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)
  * [Loader](#loader)
  * [Filter](#filter)
  * [Policies](#policies)
  * [Worker](#worker)

## Scope
This gem is aimed to collect a set of files by specified path and extensions), filter them by custom policies (creation and access times, filesize, etc)
and apply a set of custom actions to them in the fashion of a callable proc accepting an arrray of paths.

## Motivation
This gem is helpful to purge obsolete files or to promote relevant ones, by calling external services (CDN APIs) and/or local file system actions (copy, move, delete, etc).

## Installation
Add this line to your application's Gemfile:
```ruby
gem "file_scanner"
```

And then execute:
```shell
bundle
```

Or install it yourself as:
```shell
gem install file_scanner
```

## Usage

### Loader
The first step is to create a `Loader` instance by specifying the path where the files need to be scanned with optional extensions list:
```ruby
require "file_scanner"

loader = FileScanner::Loader.new(path: ENV["HOME"], extensions: %w[html txt])
```

### Filter
The second step, optional, is to configure the `Filter` instance by specifying the last access time (default to 30 days ago) and the min size in bytes (default to 0 bytes): 
```ruby
# detect file last accessed more than a week ago with a size smaller than 1 MB
filter = FileScanner::Filter.new(last_atime: Time.now - 7*3600*24, min_size: 1024*1024)
```

### Policies
You can now create your custom policies objects, the only constraint is that they must respond to the `call` method and accept an array of file path as the unique argument:
```ruby
policies = []

# remove file from disk policy
remove_from_disk = ->(files) do
  require "fileutils"
  FileUtils.rm_rf(files)
end

policies << remove_from_disk
```

### Worker
Now that you have all of the collaborators in place, you can create the `Worker` instance:
```ruby
worker = FileScanner::Worker.new(loader: loader, filter: filter, policies: policies)
worker.call # apply all the specified policies to the files
```

#### Slice of files
In case you are going to scan a large number of files, is better to do your work in batches.  
This is exactly why the `Worker` class accept a `slice_size` attribute, so it can distribute the work and avoid saturating the resources used by the specified policies:
```ruby
worker = FileScanner::Worker.new(loader: loader, filter: filter, policies: policies, slice_size: 1000)
worker.call # call policies by slice of 1000 files
```

#### Policies by block
In case you prefer to specify the policies as a block yielding the files slice, you can omit the `policies` argument at all:
```ruby
worker = FileScanner::Worker.new(loader: loader, filter: filter)
worker.call do |slice|
  # call your policies here yielding the files slice
end
```

#### Use a logger
If you dare to trace what the worker is doing (including errors), you can specify a logger to the worker class:
```ruby
my_logger = Logger.new("my_file.log")
worker = FileScanner::Worker.new(loader: loader, filter: filter, logger: my_logger)
worker.call # will log worker actions to my_file.log
```
