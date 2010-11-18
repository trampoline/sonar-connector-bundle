import 'packager/build_tasks.rake'
require 'fileutils'

namespace :gems do

  def all_submodule_gems
    status = `git submodule status`
    status.lines.map(&:chomp).map(&:split).map{|commit,submodule| submodule}
  end

  def all_submodule_paths
    all_submodule_gems.map{|submodule| File.expand_path("../#{submodule}", __FILE__)}
  end

  desc "clean all connector gems"
  task :clean_all do
    all_submodule_paths.each do |path|
      pkg_path = File.join(path, "pkg")
      $stderr << "cleaning: #{pkg_path}\n"
      FileUtils.rm_rf(pkg_path)
    end
  end

  desc "build all connector gems"
  task :build_all do
    all_submodule_paths.each do |path|
      $stderr << "building gem: #{path}\n"
      Dir.chdir(path) do
        `rake build`
      end
    end
  end

  desc "remove all connector gems from the bundle cache"
  task :uncache_all do
    all_submodule_gems.each do |submodule|
      gem_glob = File.expand_path("../vendor/cache/#{submodule.gsub('-','_')}-*", __FILE__)
      $stderr << "removing: #{gem_glob}\n"
      FileUtils.rm_f(Dir.glob(gem_glob))
    end
  end

  desc "build all connector gems and copy to bundle cache"
  task :cache_all do
    cache_path = File.expand_path("../vendor/cache", __FILE__)
    all_submodule_paths.each do |submodule_path|
      gem_glob = File.join(submodule_path, "pkg", "*")
      FileUtils.cp_r(Dir.glob(gem_glob), cache_path)
    end
  end

  desc "clean, build and cache all gems"
  task :rebuild_all=>[:uncache_all, :clean_all, :build_all, :cache_all]
end
