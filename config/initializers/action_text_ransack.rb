# config/initializers/action_text_ransack.rb

Rails.application.config.to_prepare do
  ActionText::RichText.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      # List of attributes you want to be searchable.
      # Ensure to only include those that are safe and intended for search.
      ["body", "created_at", "id", "name", "record_id", "record_type", "updated_at"]
    end
  end
end
