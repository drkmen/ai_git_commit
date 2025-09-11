# frozen_string_literal: true

require "openai"

module AiGitCommit
  class Generator
    class << self
      def commit_message
        return "# AI skipped: OPENAI_API_KEY is not set." unless openai_api_key

        diff = staged_diff
        return "# No staged changes found." if diff.strip.empty?

        fetch_message(diff)
      rescue StandardError => e
        "# AI error: #{e.message}"
      end

      private

      def fetch_message(diff)
        response = openai.chat.completions.create(completion_payload(diff))
        response.choices.first.message.content
      end

      def completion_payload(diff)
        {
          model: config.model,
          messages: [
            {
              role: "system",
              content: config.system_role_message
            },
            {
              role: "user",
              content: "Generate a git commit message and description for the following changes" \
                "(please do not include control chars):\n\n\(#{diff})"
            }
          ],
          max_tokens: 300,
          temperature: 0.7
        }
      end

      def openai
        @openai ||= OpenAI::Client.new(api_key: openai_api_key)
      end

      def staged_diff
        `git diff --cached`
      end

      def config
        @config ||= AiGitCommit.config
      end

      def openai_api_key
        AiGitCommit.config.openai_api_key
      end
    end
  end
end
