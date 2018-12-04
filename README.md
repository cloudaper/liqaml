# Liqaml

Use [Liquid](https://github.com/Shopify/liquid) template language with Yaml to process nested translations.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'liqaml'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install liqaml

## Prepare your yaml files

Liqaml needs 2 types of yaml files - `locales` and `tokens`. `locales` define different keys/variables in various languages.
`tokens` defines templates, which are identical for all languages.

`locales` files :
- can not contain first yaml locale key ( `en: ...` )
- **have to** contain locale in filename, e.g.: `user_login.en.yml`, because this is the way how to identify specific locale/language

`tokens` files :
- can not contain first yaml locale key ( `en: ...` )
- **can not** contain locale in filename, e.g.: `messages.en.yml`, because they are used as templates for all locales/languages

Example:

user_login.en.yml(`locales`):
```yaml           
login: login               
click_on: click on         
first_name: Albert       
surname: Einstein
hello: Hello
instruction: "please {{click_on}} {{login}}"          
full_name: "{{first_name}} {{surname}}"
```     
messages.yml(`tokens`):
```yaml           
short_message: "{{Hello}}, {{instruction}}."
full_message: "{{Hello}} {{full_name}}, {{instruction}}."
```     

## Usage

As we said there are `locales` and `tokens`. Now we need to make 2 arrays of such files. Then we can pass those arrays as arguments for Liqaml.

```ruby
require 'liqaml'

# Set array of locales and tokens files that need to be processed and targets for new yaml and json files
locales = ['/locales/user_login.en.yml', '/locales/something_else.en.yml', '/locales/user_login.cs.yml', '/locales/something_else.cs.yml']
tokens  = ['/tokens/messages.yml', '/tokens/documents.yml']
yamls   = 'liqaml/yamls'
jsons   = 'liqaml/jsons'

Liqaml.new(locales_array: locales, tokens_array: tokens, yaml_target: yamls, json_target: jsons).process_and_convert

# Optionally you can also provide processing count argument for deeper nesting if needed (default is 10)

Liqaml.new(locales_array: locales, tokens_array: tokens, yaml_target: yamls, json_target: jsons, process_count: 50).process_and_convert

```

After that, we'll have 2 sets of output files(yamls & jsons) which we can find in our target folders. So from the example above we'll have `messages.en.yml, messages.cs.yml, messages.en.json, messages.cs.json, documents.en.yml, documents.cs.yml, documents.en.json, documents.cs.json`.

The file `messages.en.yml` will look like this:
```yaml
en:
  short_message: Hello, please click on login.
  full_message: Hello Albert Einstein, please click on login.
```
and `messages.en.json` like this (so it's missing locale `"en":` in the content):
```json
{
  "short_message": "Hello, please click on login.",
  "full_message": "Hello Albert Einstein, please click on login."
}
```
