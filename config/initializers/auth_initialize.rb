module AuthInitialize
  def self.env_mode
    @env_mode ||= Rails.env.to_sym
  end

  def self.name
    @name = case AuthInitialize.env_mode
    when :production
      ENV['AUTH_NAME']
    else
      'admin'
    end
  end

  def self.password
    @password = case AuthInitialize.env_mode
    when :production
      ENV['AUTH_PASSWORD']
    else
      'password'
    end
  end
end