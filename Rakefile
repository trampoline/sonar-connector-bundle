BUNDLER_VERSION = "bundler-1.0.0"
JRUBY_FILENAME = "jruby-complete-1.5.2-bundler-1.0.0.jar"

CURRENT_DIR = File.dirname(__FILE__)

BUILD_DIR = File.join(CURRENT_DIR, "build")
BUILD_BUNDLE_DIR = File.join(BUILD_DIR, "vendor", "bundle")

LIB_DIR = File.join(CURRENT_DIR, "lib")
BUILD_LIB_DIR = File.join(BUILD_DIR, "lib")

FILE_LIST = ["config", "Gemfile", "script", "vendor"]

task :default => :build

desc "Build Windows deployment"
task :build => [:clean, :copy, :wipe_build_bundle, :install_build_bundle] do
  puts "Moving vendor/bundle/ruby to vendor/bundle/jruby"
  FileUtils.mv File.join(BUILD_BUNDLE_DIR, "ruby"), File.join(BUILD_BUNDLE_DIR, "jruby")
  
  puts "Copying #{JRUBY_FILENAME} to jruby-complete.jar"
  FileUtils.mkdir_p File.join(BUILD_DIR, "lib")
  FileUtils.cp File.join(LIB_DIR, JRUBY_FILENAME), File.join(BUILD_LIB_DIR, "jruby-complete.jar")
  
  puts "Creating jruby_boot.rb from template file"
  t = File.read File.join(LIB_DIR, "jruby_boot.rb.template")
  t.gsub!("{{bundler_version}}", BUNDLER_VERSION)
  File.open(File.join(BUILD_LIB_DIR, 'jruby_boot.rb'), "w"){|f| f << t}
  
  puts "Done!"
end

desc "Wipe the build dir"
task :clean do
  puts "Wiping the build dir: #{BUILD_DIR}"
  FileUtils.rm_rf BUILD_DIR
  FileUtils.mkdir_p BUILD_DIR
end

desc "Copies all required files into build dir"
task :copy do
  puts "Copying files"
  FILE_LIST.each do |f|
    FileUtils.cp_r f, BUILD_DIR
  end
end

desc "Wipe the build bundle"
task :wipe_build_bundle do
  puts "Wiping the build bundle"
  FileUtils.rm_rf BUILD_BUNDLE_DIR
  FileUtils.rm_f File.join(BUILD_DIR, "Gemfile.lock")
end

desc "Install the build bundle"
task :install_build_bundle do
  puts "Installing the build bundle"
  `cd #{BUILD_DIR}; bundle install vendor/bundle --local --no-prune --no-cache`
end
