# frozen_string_literal: true

require "openai"

module AiGitCommit
  # Generator class responsible for creating AI-generated git commit messages
  class Generator
    class << self
      # Generates a commit message using OpenAI based on staged git diff
      # @return [String] the generated commit message or an error message
      def commit_message
        return "# AI skipped: OPENAI_API_KEY is not set." unless openai_api_key

        diff = staged_diff
        return "# No staged changes found." if diff.strip.empty?

        fetch_message(diff)
      rescue StandardError => e
        "# Error: #{e.message}"
      end

      private

      # Sends the staged diff to OpenAI and returns the generated message
      # @param diff [String] the staged git diff
      # @return [String] the commit message from OpenAI
      def fetch_message(diff)
        response = openai.chat.completions.create(completion_payload(diff))
        response.choices.first.message.content
      end

      # Builds the payload for the OpenAI API request
      # @param diff [String] the staged git diff
      # @return [Hash] the payload for OpenAI API
      def completion_payload(diff)
        {
          model: config.model,
          messages: [
            { role: "system", content: config.system_role_message },
            { role: "user", content: user_role_message(diff) }
          ],
          max_tokens: config.max_tokens,
          temperature: config.temperature
        }
      end

      # Formatted message instructing the AI to create a Git commit message and description.
      # @param diff [String] The diff content representing changes in the repository.
      # @return [String] A formatted message ready to be sent to the AI.
      def user_role_message(diff)
        <<~CONTENT
          Generate a git commit message and description for the following changes.
          Do not include control chars. Keep description under 200-300 chars.\n
          Changes:\n(#{diff})
        CONTENT
      end

      # Returns an instance of OpenAI::Client
      # @return [OpenAI::Client]
      def openai
        @openai ||= OpenAI::Client.new(api_key: openai_api_key)
      end

      # Returns the configuration for AiGitCommit
      # @return [AiGitCommit::Config]
      def config
        @config ||= AiGitCommit.config
      end

      # Returns the OpenAI API key from configuration
      # @return [String, nil] the API key or nil if not set
      def openai_api_key
        AiGitCommit.config.openai_api_key
      end

      # Gets the staged git diff
      # @return [String] the output of `git diff --cached`
      def staged_diff
        `git diff --cached`
      end
    end
  end
end
