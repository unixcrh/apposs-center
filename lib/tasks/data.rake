namespace :data do
  desc "copy data from old database"
  task :copy => 'db:migrate' do
    exit unless File.exist? 'config/old_database.yml'
    config = YAML::load(ERB.new(IO.read('config/old_database.yml')).result)
    $spec = config[Rails.env].inject({}) do |hash, value|
      hash.update value[0].to_sym => value[1]
    end
    (ActiveRecord::Base.connection.tables - ["schema_migrations"]).each {|t|
      Rails.logger.info "copy #{t}"
      new_clazz, old_clazz = prepare_class t
      old_clazz.all.each{|o|
        new_o = new_clazz.new(o.attributes)
        new_o.id = o.id
        new_o.save!
      }
    }
  end

  desc "backup all data"
  task :backup => :environment do
    Dir.mkdir "data" unless File.exist? "data"
    (ActiveRecord::Base.connection.tables - ["schema_migrations"]).each{|t|
      clazz = t.camelize.singularize
      File.open("data/#{clazz}.yml",'w') do |f| f.puts clazz.constantize.all.to_yaml end
    }
  end

  desc "restore all data"
  task :restore => :environment do
    require 'yaml'
    Dir['data/*'].each{|f|
      f =~ /\/(.+)\.yml/
      clazz = $1
      Object.send :remove_const, clazz rescue nil
      eval("class #{clazz} < ActiveRecord::Base; end")
      YAML.load(File.new(f)).each{|o|
        new_o = o.class.new(o.attributes)
        new_o.id = o.id
        new_o.save!
      }
    }
  end

  private
    def prepare_class table_name
      class_name = table_name.camelize.singularize
      eval %Q[
        class #{class_name}Old < ActiveRecord::Base
          establish_connection $spec
          set_table_name '#{table_name}'
        end
      ]
      Object.send :remove_const, class_name rescue nil
      eval("class #{class_name} < ActiveRecord::Base; end")
      [class_name.constantize, "#{class_name}Old".constantize]
    end
end
