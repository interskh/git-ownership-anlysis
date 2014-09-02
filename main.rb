require_relative "repo.rb"

Repo.new({repo: ARGV[0]}).blame
