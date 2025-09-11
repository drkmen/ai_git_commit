require "fileutils"

module AiGitCommit
  class CLI
    def self.install_hook
      hook_path = ".git/hooks/prepare-commit-msg"
      script = <<~SCRIPT
        #!/bin/bash
        ruby -r './lib/ai_git_commit.rb' -e 'puts AiGitCommit::Generator.commit_message' >> .git/COMMIT_EDITMSG
      SCRIPT

      File.write(hook_path, script)
      FileUtils.chmod("+x", hook_path)
      puts "AI Git Commit prepare-commit-msg hook installed."
    end
  end
end