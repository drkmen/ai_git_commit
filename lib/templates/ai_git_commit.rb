# frozen_string_literal: true

AiGitCommit.configure do |config|
  # OpenAI API key
  config.api_key = ENV.fetch("OPENAI_API_KEY", nil)

  # Specifies the OpenAI model to use for generating commit messages.
  config.model = "gpt-3.5-turbo"

  # Defines the programming language context for commit message generation.
  config.program_language = "Ruby"

  # Limits the maximum number of tokens in the generated response.
  config.max_tokens = 300

  # Controls the randomness of the AI's output (0.0 = deterministic, 1.0 = creative).
  config.temperature = 0.7

  # Sets the system prompt for the AI
  config.system_role_message = <<~MESSAGE
    You are a senior #{config.program_language} developer. Your task is to write a concise, clear commit
    message and a detailed description based on the provided code changes. The message
    should be in the imperative mood. The body should be wrapped at 72 characters.
  MESSAGE
end
