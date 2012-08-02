logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

conn = ActiveRecord::Base.connection
data_file = "#{Rails.root}/features/fixtures/load_all.sql"
begin
  File.readlines(data_file).each{ |line| conn.execute line }
rescue Exception => e
  $stderr.puts "Error: #{e.message}"
end
ActiveRecord::Base.logger = logger

