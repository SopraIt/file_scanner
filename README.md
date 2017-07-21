## Table of Contents

* [Scope](#scope)
* [Motivation](#motivation)
* [Installation](#installation)
* [Usage](#usage)

## Scope
This gem is aimed to collect a set of files by specified path and extensions), filter them by custom policies (creation and access times, filesize, etc)
and apply a set of custom actions to them in the fascion of a callable proc accepting an arrray of paths.

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
