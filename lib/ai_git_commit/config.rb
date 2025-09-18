# frozen_string_literal: true

module AiGitCommit
  # Configuration class for AiGitCommit
  class Config
    attr_accessor :openai_api_key, :model, :program_language,
                  :max_tokens, :temperature, :system_role_message

    # Initializes configuration with default values
    def initialize
      @openai_api_key = ENV.fetch("OPENAI_API_KEY", nil)
      @model = "gpt-3.5-turbo"
      @program_language = "Ruby"
      @max_tokens = 300
      @temperature = 0.7
      @system_role_message = <<~MESSAGE
        You are a senior #{@program_language} developer. Your task is to write a concise, clear commit
        message and a detailed description based on the provided code changes. The message
        should be in the imperative mood. The body should be wrapped at 72 characters.
      MESSAGE
    end
  end

  # Module-level accessor for configuration
  class << self
    # Returns current configuration or initializes it
    # @return [Config]
    def config
      @config ||= Config.new
    end

    # Yields the configuration for modification
    # @yield [Config] config
    def configure
      yield(config)
    end
  end
end
