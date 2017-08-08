## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)
  * [Loader](#loader)
  * [Filters](#filters)
  * [Policies](#policies)
  * [Worker](#worker)

## Scope
This gem is aimed to collect a set of file paths starting by a wildcard rule, filter them by default/custom filters (access time, size range) and apply a set of custom policies to them.

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

### Filters
The second step is to provide the filters list to select files for which the `call` method is truthy.  

#### Default
If you specify no filters the existing onee will select files by:
* checking if file is older than *30 days* 
* checking if file size is *smaller than 100 bytes*

You can configure default behaviour by passing different arguments:
```ruby
accessed_a_week_ago = FileScanner::Filters::LastAccess.new(Time.now-7*24*3600)
one_to_two_mega = FileScanner::Filters::SizeRange.new(min: 1024**2, max: 2*1024**2)

filters = []
filters << accessed_a_week_ago
filters << one_to_two_mega
```

#### Custom
It is convenient to create custom filters by just relying on `Proc` instances that satisfy the `callable` protocol:
```ruby
filters << ->(file) { File.directory?(file) }
```

### Policies
The third step is creating custom policies objects (no defaults exist) to be applied to the list of filtered paths.  
Again, it suffice the policy responds to the `call` method and accept an array of paths as an argument:
```ruby
require "fileutils"

remove_from_disk = ->(paths) do
  FileUtils.rm_rf(paths)
end

policies = []
policies << remove_from_disk
```

### Worker
Now that you have all of the collaborators in place, you can create the `Worker` instance:
```ruby
worker = FileScanner::Worker.new(loader: loader, filters: filters, policies: policies)
worker.call # apply all the specified policies to the filtered file paths
```

#### Slice of files
In case you are going to scan a large number of files, it is better to work in batches.  
The `Worker` constructor accepts a `slice` attribute to better distribute loading (no sleep by default, use block syntax):
```ruby
worker = FileScanner::Worker.new(loader: loader, policies: policies, slice: 1000)
worker.call # call policies by slice of 1000 files with default filters
```

#### Block syntax
In case you prefer to specify the policies inside a block for a more granular control on the slice of paths, you must omit the `policies` argument and use the block syntax:
```ruby
worker = FileScanner::Worker.new(loader: loader)
worker.call do |slice|
  policy = ->(slice) { FileUtils.chmod_R(0700, slice) }
  policy.call
  sleep 10 # wait 10 seconds before slurping next slice 
end
```

#### Use a logger
If you dare to trace what the worker is doing (including errors), you can specify a logger to the worker class:
```ruby
my_logger = Logger.new("my_file.log")
worker = FileScanner::Worker.new(loader: loader, logger: my_logger)
worker.call do |slice|
  fail "Doh!" # will log error to my_file.log and re-raise exception
end
```
