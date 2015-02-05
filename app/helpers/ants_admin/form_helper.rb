module AntsAdmin
  module FormHelper
    def self.text_for_form(model_string)
      YAML.load_file('config/ants_admin/form.yml')[model_string] rescue {}
    end
  end
end