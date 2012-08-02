require 'git'

g = Git.open(File.expand_path('../..', __FILE__))

start = g.log.first

commits = { start.sha => start }
logs = { start.sha => start }
old_logs = {}

while logs.size > 0
  logs.each_value do |log|
    old_logs.update log.sha => log
    logs = logs.reject{|k,v| k==log.sha}
    log.parents.each do |node|
      if node.commit?
        commits.update node.sha => node
        logs.update(node.sha => node) unless old_logs.has_key?(node.sha)
      end
    end
  end
end

header = "<?xml version=\"1.0\"?>
<file_events>"
tail = "</file_events>"

lines = []

commits.values.collect do |commit|
  if commit.parent
    lines << g.diff(commit, commit.parent).stats[:files].keys.collect do |file|
      date = commit.committer_date.to_i
      author = commit.committer.name
      file = file.sub(/^\"/, '').sub(/\"$/,'')
      %Q[<event date="#{date}000" author="#{author}" filename="#{file}" ></event>]
    end
  end
end

puts header
lines.sort.each do |line|
  puts line
end
puts tail
