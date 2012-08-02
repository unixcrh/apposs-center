# coding: utf-8
namespace :daily do

  task :default => [:app]

  desc "sync apps"
  task :app => :environment do
    include Rails.configuration.adapter
    AppLoader.load
  end

  desc "sync machines"
  task :machine => :environment do
    include Rails.configuration.adapter
    MachineLoader.load_all
  end

end
