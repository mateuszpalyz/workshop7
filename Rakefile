require 'bundler/gem_tasks'
require 'rake/testtask'
require 'yaml'
require 'dotenv/tasks'
require 'active_record'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
end

task :default => :test

namespace :db do
  task :environment => :dotenv do
    ENVIRONMENT = ENV['ENVIRONMENT']
  end

  task :connection => :environment do
    db_options = ENV['DATABASE_URL'] ? ENV['DATABASE_URL'] : YAML.load_file('config/database.yml')[environment.to_s]
    ActiveRecord::Base.establish_connection(db_options)
  end

  task :migrate => :connection do
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end

  task :rollback => :connection do
    ActiveRecord::Migrator.rollback("db/migrate")
  end
end
