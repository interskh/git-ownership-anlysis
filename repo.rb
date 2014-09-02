require_relative 'blame.rb'

class Repo
  attr_reader :repo

  def initialize(args)
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    @files = self.ls_files
  end

  def ls_files
    Dir.chdir(@repo)
    @files = `git ls-files`.split("\n")
      .find_all{|e|
        e.end_with?(".php", ".py", ".js", ".java") and
        not e.include?("/ext/")}
  end

  def blame
    @files.each do |file|
      f = Blame.new({repo: @repo, file: file})
      f.output(3)
    end
  end

end
