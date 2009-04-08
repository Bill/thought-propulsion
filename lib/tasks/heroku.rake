namespace 'propel' do
  namespace 'heroku' do

    # usage (locally): rake propel:heroku:initialize
    desc 'local task to set up a brand new Heroku instance'
    task :initialize do
      `heroku create thoughtpropulsion`
      %w( www.thoughtpropulsion.com blog.thoughtpropulsion.com propeller.twipl.com).each do | domain |
        `heroku domains:add --app thoughtpropulsion '#{domain}'`
      end
      `git push heroku master`
      `heroku rake --app thoughtpropulsion db:migrate`
      `heroku db:push --app thoughtpropulsion 'mysql://root:WAE8YVL3oGMH@localhost/thoughtpropulsion'`
    end
    
    desc 'local task to set up heroku domains'
    task :configure_domains do
      %w( www.thoughtpropulsion.com blog.thoughtpropulsion.com propeller.twipl.com).each do | domain |
        puts `heroku domains:add --app thoughtpropulsion '#{domain}'`
      end
    end
    
    desc 'local task to create and download a Heroku bundle'
    task :snapshot_bundle do
      timestamp = `date -u '+%Y-%m-%d-%H-%M'`.chomp
      bundle_name = "bundle-#{timestamp}"
      `heroku bundles:capture --app thoughtpropulsion '#{bundle_name}'`
      # poll for completion
      begin
        bundles = `heroku bundles --app thoughtpropulsion`
      end while bundles.match(/complete/).nil?
      %w(download destroy).each do | action |
        `heroku bundles:#{action} --app thoughtpropulsion '#{bundle_name}'`
      end
    end

    # usage (remotely): heroku rake propel:heroku:update_git_submodules 
    desc 'remote task to have Heroku update git submodules'
    task :update_git_submodules do
      puts `git submodule init 2>&1`
      puts `git submodule update 2>&1`
    end
    
    namespace :db do
      desc "remote task to purge the tables of the Heroku (PostgreSQL) database" 
      task :purge do
        load 'config/environment.rb'
        abcs = ActiveRecord::Base.configurations
        case abcs[RAILS_ENV]["adapter"]
        when 'postgresql'
          ActiveRecord::Base.establish_connection(abcs[RAILS_ENV])
          postgres_tables_query = %|SELECT n.nspname as "Schema", c.relname as "Name", CASE c.relkind WHEN 'r' THEN 'table' WHEN 'v' THEN 'view' WHEN 'i' THEN 'index' WHEN 'S' THEN 'sequence' WHEN 's' THEN 'special' END as "Type", u.usename as "Owner" FROM pg_catalog.pg_class c LEFT JOIN pg_catalog.pg_user u ON u.usesysid = c.relowner LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace WHERE c.relkind IN ('r','') AND n.nspname NOT IN ('pg_catalog', 'pg_toast') AND pg_catalog.pg_table_is_visible(c.oid) ORDER BY 1,2;|
          conn = ActiveRecord::Base.connection
          conn.execute(postgres_tables_query).each { |b| puts "Deleting table: #{b[1]}"; conn.execute("DROP TABLE #{b[1]}"); }
        else
          raise "Task not supported by '#{abcs[RAILS_ENV]['adapter']}'"
        end
      end
    end 
    
  end
end
