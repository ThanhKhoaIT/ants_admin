# AntsAdmin

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'ants_admin'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ants_admin

## Usage

### Icons
http://fortawesome.github.io/Font-Awesome/icons/

### Config model
  * 1. Disable for create page
    ```CREATE_DISABLED = true```
    
  * 2. Set title page for model
    ```TITLE = "Item management"```

  * 3. Select attributes for search on model
    ```SEARCH_FOR = "title", "description"```
    
  * 4. Config for action in table
    ```
    def actions
      ["<action type='edit'>Edit</action>",
      "<action type='delete'>Remove</action>"].join()
    end
    ```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/ants_admin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
