## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)
  * [Loader](#loader)
  * [Filters](#filters)
    * [Defaults](#defaults)
    * [Custom](#custom)
  * [Worker](#worker)
    * [Batches](#batches)
    * [Logger](#logger)

## Scope
This gem is aimed to collect a set of file paths starting by a wildcard rule, filter them by any default/custom filters (access time, matching name and size range) and apply a set of actions via a block call.

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
The second step is to provide the filters list to select file paths for which the `call` method is *truthy*.  
Selection is done with the `any?` predicate, so also one matching filter will do the selection.

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
It is convenient to create custom filters by creating `Proc` instances that satisfy the `callable` protocol:
```ruby
filters << ->(file) { File.directory?(file) }
```

### Worker
Now that you have all of the collaborators in place, you can create the `Worker` instance to performs actions on the filtered paths:
```ruby
worker = FileScanner::Worker.new(loader: loader, filters: filters)
worker.call do |paths|
  # do whatever you want with the paths list
end
```

#### Batches
In case you are going to scan a large number of files, it is suggested to work in batches.  
The `Worker` constructor accepts a `slice` attribute to give you a chance to distribute loading:
```ruby
worker = FileScanner::Worker.new(loader: loader, slice: 1000)
worker.call do |slice|
  # perform action on a slice of 1000 paths
end
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
