## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)
  * [Filters](#filters)
    * [Defaults](#defaults)
    * [Custom](#custom)
  * [Worker](#worker)
    * [Enumerator](#enumerator)
    * [Block](#block)
    * [Mode](#mode)
    * [Check](#check)
    * [Logger](#logger)

## Scope
This gem is aimed to collect a set of file paths starting by a wildcard rule, filter them by any/all default/custom filters (access time, matching name and size range) and apply a set of actions via a block call.

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

### Filters
The first step is to provide the filters list to select file paths for which the `call` method is *truthy*.  

#### Defaults
If you specify no filters the default ones are loaded, selecting files by:
* checking if file is older than *30 days* 
* checking if file size is within *0KB and 5KB*
* checking if file *basename matches* the specified *regexp* (if any)

You can update default filters behaviours by passing custom arguments:
```ruby
a_week_ago = FileScanner::Filters::LastAccess.new(Time.now-7*24*3600)
one_two_mb = FileScanner::Filters::SizeRange.new(min: 1024**2, max: 2*1024**2)
hidden = FileScanner::Filters::MatchingName.new(/^\./)
filters = [a_week_ago, one_two_mb, hidden]
```

#### Custom
It is convenient to create custom filters by using `Proc` instances that satisfy the `callable` protocol:
```ruby
filters << ->(file) { File.directory?(file) }
```

### Worker
The second step is to create the `Worker` instance by providing the path to scan and the list of filters to apply.  

#### Enumerator
The `call` method of the worker return a lazy enumerator with the filtered elements, sliced by the specified number (default to 1000):
```ruby
worker = FileScanner::Worker.new(path: "~/Downloads", filters: filters, slice: 35)
p worker.call
=> #<Enumerator::Lazy: ...
```

#### Block
To perform actions on each of the sliced paths just pass a block:
```ruby
worker.call do |slice|
  # perform actions on a slice of at max 35 elements
end
```

#### Mode
By default the worker will select paths by applying any of the matching filters: this is it, it suffice just one of the specified filters to be true to grab the path.  
In case you want restrict paths selection by all matching filters, just specify the `all` option:
```ruby
worker = FileScanner::Worker.new(loader: loader, filters: filters, all: true)
worker.call # will filter by applying all? predicate
```

#### Check
By default the worker will scan for both directories and files. 
In case you want restrict paths selection by files only, just specify the `check` option:
```ruby
worker = FileScanner::Worker.new(loader: loader, filters: filters, check: true)
worker.call # will skip directories
```

#### Logger
If you dare to trace what the worker is doing (including errors), you can specify a logger to the worker class:
```ruby
my_logger = Logger.new("my_file.log")
worker = FileScanner::Worker.new(loader: loader, logger: my_logger)
worker.call do |slice|
  fail "Doh!" # will log error to my_file.log and re-raise exception
end
```

If you want to easily pass the same logger instance to the actions you are performing, it's available as the second argument of the block:
```ruby
require "fileutils"

worker.call do |slice, logger|
  logger.info { "going to remove #{slice.size} files from disk!" }
  FileUtils.rm_rf(slice)
end
```
