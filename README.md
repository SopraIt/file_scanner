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
    * [Consuming results](#consuming-results)
    * [Mode](#mode)
    * [File check](#file-check)
    * [Logger](#logger)

## Scope
This gem is aimed to lazily collect a list of files by path and a set of filters.

## Motivation
This gem is helpful to purge obsolete files or to promote relevant ones, by calling external services (CDN APIs) and/or local file system actions (copy, move, delete, etc).  
By working lazily, this library is aimed to work with a subset of large files list: just remember to apply a subset method to the final enumerator.

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

You can update default filters behaviour by passing custom arguments:
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
The `call` method of the worker return a lazy enumerator with the filtered elements:
```ruby
worker = FileScanner::Worker.new(path: "~/Downloads", filters: filters, slice: 35)
p worker.call
=> #<Enumerator::Lazy: ...
```

#### Consuming results
To leverage on the lazy behaviour remember to call a subset method on the resulting enumerator:
```ruby
worker.call.take(1000).each do |file|
  # perform action on filtered files
end
```

#### Mode
By default the worker does select paths by applying any of the matching filters: it suffice just one of the filters to match to grab the path.  
In case you want restrict paths selection by all matching filters, just specify the `all` option:
```ruby
worker = FileScanner::Worker.new(loader: loader, filters: filters, all: true)
worker.call # will filter by applying all? predicate
```

#### File check
By default the worker does collect both directories and files. 
In case you want restrict selction by files only, just specify the `filecheck` option:
```ruby
worker = FileScanner::Worker.new(loader: loader, filters: filters, filecheck: true)
worker.call # skip directories
```

#### Logger
If you dare to trace what the worker is doing (including errors), you can specify a logger to the worker class:
```ruby
my_logger = Logger.new("my_file.log")
worker = FileScanner::Worker.new(loader: loader, logger: my_logger)
```
