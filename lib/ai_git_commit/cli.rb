# frozen_string_literal: true

require "thor"
require "fileutils"

module AiGitCommit
  # CLI class provides command-line interface for AI Git Commit tool.
  # It uses Thor for command parsing and execution.
  class CLI < Thor
    HOOK_PATH = ".git/hooks/prepare-commit-msg"

    # Installs the prepare-commit-msg hook.
    # If the hook already exists, appends the script; otherwise, creates a new hook file.
    # Makes the hook executable and prints a confirmation message.
    desc "install", "Set up prepare-commit-msg hook"
    def install
      if hook_file_exists?
        File.open(HOOK_PATH, "a") { _1.puts script }
      else
        File.write(HOOK_PATH, script)
      end
      FileUtils.chmod("+x", HOOK_PATH)

      source = File.expand_path("../templates/ai_git_commit.rb", __dir__)
      destination_dir = File.expand_path("config/initializers", Dir.pwd)
      destination = File.join(destination_dir, "ai_git_commit.rb")
      FileUtils.mkdir_p(destination_dir)
      FileUtils.cp(source, destination)

      puts "AI Git Commit prepare-commit-msg hook set up."
    end

    private
    # The script content for the prepare-commit-msg hook.
    # Adds a shebang line if the hook file does not exist.
    # The script runs a Ruby command to generate a commit message using AiGitCommit::Generator.
    # @return [String] the script content
    def script
      <<~SCRIPT
        #{"#!/bin/bash" unless hook_file_exists?}
        ruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
      SCRIPT
    end

    # Checks if the prepare-commit-msg hook file exists.
    # @return [Boolean] true if the hook file exists, false otherwise.
    def hook_file_exists?
      File.exist?(HOOK_PATH)
    end
  end
end
