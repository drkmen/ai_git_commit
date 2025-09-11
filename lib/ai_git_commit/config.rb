# frozen_string_literal: true

module AiGitCommit
  class Config
    attr_accessor :openai_api_key, :model, :program_language, :system_role_message

    def initialize
      @openai_api_key = ENV["OPENAI_API_KEY"]
      @model = "gpt-3.5-turbo"
      @program_language = "Ruby"
      @system_role_message = <<~MESSAGE
        You are a senior #{@program_language} developer. Your task is to write a concise, clear commit
        message and a detailed description based on the provided code changes. The message
        should be in the imperative mood. The body should be wrapped at 72 characters.
      MESSAGE
    end
  end

  class << self
    attr_accessor :config

    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
    end
  end
end