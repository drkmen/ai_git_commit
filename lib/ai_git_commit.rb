# frozen_string_literal: true

require_relative "ai_git_commit/version"
require "openai"

module AiGitCommit
  class Error < StandardError; end

  class << self
    def generate_commit_message
      message = "# AI skipped: OPENAI_API_KEY is not set."
      return message unless ENV["OPENAI_API_KEY"]

      fetch_message
    rescue StandardError => e
      e
    end

    private

    def fetch_message
      response = openai.chat.completions.create(
        model: "gpt-3.5-turbo",
        messages: [
          {
            role: "system",
            content: "You are a senior Ruby developer. Your task is to write a concise, clear commit" \
              "message and a detailed description based on the provided code changes. The message" \
              "should be in the imperative mood. The body should be wrapped at 72 characters."
          },
          {
            role: "user",
            content: "Generate a git commit message and description for the following changes" \
              "(please do not include control chars):\n\n\(#{staged_diff})"
          }
        ],
        max_tokens: 300,
        temperature: 0.7
      )
      message = response.choices.first.message.content
      message
    end

    def openai
      @openai ||= OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    end

    def staged_diff
      `git diff --cached`
    end
  end
end
