# frozen_string_literal: true

require "openai"

module AiGitCommit
  class Generator
    class << self
      def commit_message
        return "# AI skipped: OPENAI_API_KEY is not set." unless ENV["OPENAI_API_KEY"]

        diff = staged_diff
        return "# No staged changes found." if diff.strip.empty?

        fetch_message(diff)
      rescue StandardError => e
        "# AI error: #{e.message}"
      end

      private

      def fetch_message(diff)
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
                "(please do not include control chars):\n\n\(#{diff})"
            }
          ],
          max_tokens: 300,
          temperature: 0.7
        )
        response.choices.first.message.content
      end

      def openai
        @openai ||= OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
      end

      def staged_diff
        `git diff --cached`
      end
    end
  end
end
