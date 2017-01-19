class Account < ActiveRecord::Base
  has_many :user

  before_save :init
  def init
    default_settings = {
      environments: [{code: 'prod', name: "Production", category: "production"},
            {code: 'test', name: "Test", category: "test"},
            {code: 'uat', name: "User Acceptance", category: "test"}
          ]
    }
    self.settings ||= default_settings.to_json
  end
end
