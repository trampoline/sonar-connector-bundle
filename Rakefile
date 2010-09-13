# Set these constants
BUNDLER_VERSION = "bundler-1.0.0"
JRUBY_FILENAME = "jruby-complete-1.5.2-bundler-1.0.0.jar"
TARGET_NAME = 'SonarConnector'


CURRENT_DIR = File.dirname __FILE__
BUILD_DIR = File.join CURRENT_DIR, "build"
TARGET_DIR = File.join BUILD_DIR, TARGET_NAME
TARGET_BUNDLE_DIR = File.join TARGET_DIR, "vendor", "bundle"
LIB_DIR = File.join CURRENT_DIR, "lib"
TARGET_LIB_DIR = File.join TARGET_DIR, "lib"

FILE_LIST = ["config", "Gemfile", "LICENSE", "script", "vendor"]

task :default => :build

desc "Build Windows deployment"
task :build => [:clean, :copy, :wipe_build_bundle, :install_build_bundle] do
  
  puts "Moving vendor/bundle/ruby to vendor/bundle/jruby"
  FileUtils.mv File.join(TARGET_BUNDLE_DIR, "ruby"), File.join(TARGET_BUNDLE_DIR, "jruby")
  
  puts "Copying #{JRUBY_FILENAME} to jruby-complete.jar"
  FileUtils.mkdir_p File.join(TARGET_DIR, "lib")
  FileUtils.cp File.join(LIB_DIR, JRUBY_FILENAME), File.join(TARGET_LIB_DIR, "jruby-complete.jar")
  
  puts "Creating jruby_boot.rb from template file"
  t = File.read File.join(LIB_DIR, "jruby_boot.rb.template")
  t.gsub!("{{bundler_version}}", BUNDLER_VERSION)
  File.open(File.join(TARGET_LIB_DIR, 'jruby_boot.rb'), "w"){|f| f << t}
  
  puts "Zipping the build"
  FileUtils.cd(BUILD_DIR) {
    `zip -r #{TARGET_DIR}.zip #{TARGET_NAME}`
  }
  
  if `which makensis` == ''
    puts "warning: can't compile the installer executable without the NSIS compiler!"
  else
    puts "Building the installer executable"
    system('makensis installer/connector.nsi')
  end
  
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
  FileUtils.mkdir_p TARGET_DIR
  FILE_LIST.each do |f|
    FileUtils.cp_r f, TARGET_DIR
  end
end

desc "Wipe the build bundle"
task :wipe_build_bundle do
  puts "Wiping the build bundle"
  FileUtils.rm_rf TARGET_BUNDLE_DIR
  FileUtils.rm_f File.join(TARGET_DIR, "Gemfile.lock")
end

desc "Install the build bundle"
task :install_build_bundle do
  puts "Installing the build bundle"
  `cd #{TARGET_DIR}; bundle install vendor/bundle --local --no-prune --no-cache`
end
