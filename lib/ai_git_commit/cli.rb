# frozen_string_literal: true

require "thor"
require "fileutils"

module AiGitCommit
  # CLI class provides command-line interface for AI Git Commit tool.
  # It uses Thor for command parsing and execution.
  class CLI < Thor
    HOOK_PATH = ".git/hooks/prepare-commit-msg"
    SCRIPT = <<~SCRIPT
      #{"#!/bin/bash" unless File.exist?(HOOK_PATH)}
      ruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
    SCRIPT

    # Installs the prepare-commit-msg hook.
    # If the hook already exists, appends the script; otherwise, creates a new hook file.
    # Makes the hook executable and prints a confirmation message.
    desc "install", "Set up prepare-commit-msg hook"
    def install
      if File.exist?(HOOK_PATH)
        File.open(HOOK_PATH, "a") { |f| f.puts SCRIPT }
      else
        File.write(HOOK_PATH, SCRIPT)
      end

      FileUtils.chmod("+x", HOOK_PATH)
      puts "AI Git Commit prepare-commit-msg hook set up."
    end
  end
end
