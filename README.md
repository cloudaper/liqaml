# Liqaml

Use Liquid template language with Yaml to process nested translations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liqaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liqaml

## Usage

First for each translation you need to have files in  2 folders(templates and keys), e.g. 'en/templates' and 'en/keys' with appropriate content in those files.
Yaml keys that only provide variables for templates belong to keys files. Yaml keys that provide variables but also provide
content for templates - and will appear in processed translations - belong to templates files.

```ruby
require 'liqaml'

# Set array of folders containing files that need to be processed and targets for new yaml and json files
arr = ['locales/en', 'locales/cs',]
yaml_target = 'liqaml/yamls'
json_target = 'liqaml/jsons'

Liqaml.new(arr, yaml_target, json_target).process_and_convert

# Optionally you can also provide processing count argument for deeper nesting if needed (default is 10)
process_count = 50

Liqaml.new(arr, yaml_target, json_target, process_count).process_and_convert
```
