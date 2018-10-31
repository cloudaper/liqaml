# Liqaml

Use Liquid template language with Yaml.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liqaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liqaml

Then generate necessary files/folders:

    $ liqaml install

## Usage

```ruby
require 'liqaml'

Liquaml.process_all
```

## TODO
- app/filters in DM (generate by command with IcuFilters file?) or within gem?
- generate folder where unprocessed yaml files will be stored ...
- ... and define where the processed yamls and jsons will be
-> test locally with DM

- rspec few basic tests
