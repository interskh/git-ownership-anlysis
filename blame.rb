require 'json'

class Blame
  attr_reader :file, :repo

  def initialize(args)
    @authors = Hash.new(0)
    @author_scores = Hash.new(0.0)
    @cur_ts = Time.now.to_i
    @ready = false
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
    self.populate
  end

  def populate
    unless @ready
      Dir.chdir(@repo)
      author = nil
      `git blame '#{@file}' --line-porcelain -w`
        .encode('utf-8', 'utf-8', :invalid => :replace).lines.each do |line|
        if /^author (.+)$/ =~ line
          author = line[/^author (.+)$/, 1]
          @authors[author] += 1
        end
        if /^author-time (.+)$/ =~ line
          ts = line[/^author-time (.+)$/, 1].to_i
          @author_scores[author] += 1/(1+(@cur_ts - ts)/60/60/24/30)
        end
      end
      @ready = true
    end
  end

  def top_authors(n)
    @author_scores.sort_by {|k,v| -v}
      .first(n)
      .map{|k,v| [k, @authors[k]]}
  end

  def output(n)
    unless @authors.empty?
      puts "#{@file},#{top_authors(n).map{|a| a.join(",")}.join(",")}"
    end
  end
end
