# frozen_string_literal: true

module AiGitCommit
  class Config
    attr_accessor :openai_api_key, :timeout

    def initialize
      @openai_api_key = ENV["OPENAI_API_KEY"]
      @model = "gpt-3.5-turbo"
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