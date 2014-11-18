# Ants Admin

Admin Panel mudule for Rails 4 application

## Installation

Add this line to your application's Gemfile:

    ```gem 'ants_admin', git: "https://github.com/ThanhKhoaIT/ants_admin.git"```

And then execute:

    ```$ bundle```

## Usage

### Icons
http://fortawesome.github.io/Font-Awesome/icons/

### Config model
  Apply smart model: ```include AntsAdmin::SmartModel```

  * 1. Disable for create page
    ```CREATE_DISABLED = true```
    
  * 2. Set title page for model
    ```TITLE = "Item management"```

  * 3. Set title for table
    ```TABLE_SHOW = "title", "description", "category", "show"```

  * 4. Select attributes for search on model
    ```SEARCH_FOR = "title", "description"```
    
  * 5. Config for action in table
    ```
    def actions
      "<action edit remove id=#{self.id}/>"
    end
    ```