# Set these constants
JRUBY_FILENAME = File.basename(Dir[File.expand_path("../../lib/jruby-complete-*", __FILE__)].first)
$stderr << "JRUBY_FILENAME: #{JRUBY_FILENAME}\n"
BUNDLER_VERSION = JRUBY_FILENAME[/jruby-complete-[\d\.]+-(bundler-.+)\.jar/,1]
$stderr << "BUNDLER_VERSION: #{BUNDLER_VERSION}\n"

ROOT_DIR = File.expand_path '..', File.dirname(__FILE__)
BUILD_DIR = File.join ROOT_DIR, "build"
CONNECTOR_VERSION = File.read File.join(ROOT_DIR, 'VERSION')
TARGET_NAME = "SonarConnector"
TARGET_DIR = File.join BUILD_DIR, TARGET_NAME
TARGET_BUNDLE_DIR = File.join TARGET_DIR, "vendor", "bundle"
TEMPLATE_DIR = File.join ROOT_DIR, "packager", "templates"
LIB_DIR = File.join ROOT_DIR, "lib"
TARGET_LIB_DIR = File.join TARGET_DIR, "lib"

FILE_LIST = ["config/", "lib/", "vendor/", "tools/", "doc/", "Gemfile", "Gemfile.lock", "VERSION", "LICENSE"]
DELETE_FILE_LIST = ["**/*~", "config/config.json"] # delete files matching these globs from the target
COPY_FILE_LIST = [["config/config.json.example", "config/config.json"]] # make these copies in the target

LOCAL_SOURCE_GEMS = {
  "actionmailer_extensions" => "~/development/archived/actionmailer_extensions",
  "sonar_connector" => "~/development/trampoline/connector/sonar-connector",
  "sonar_connector_filestore" => "~/development/trampoline/connector/sonar-connector-filestore",
  "sonar_imap_pull_connector" => "~/development/trampoline/connector/sonar-imap-pull-connector",
  "sonar_push_connector" => "~/development/trampoline/connector/sonar-push-connector"
}
VENDOR_CACHE_DIR = File.join ROOT_DIR, 'vendor', 'cache'

task :default do
  puts "Choose a rake task:\n" + `rake -T`
end

namespace :build do
  
  desc "pre build steps for both Windows and Linux deployments"
  task :pre => ["gems:rebuild_all", :clean, :copy, :wipe_build_bundle, :install_build_bundle] do
    puts "Moving vendor/bundle/ruby to vendor/bundle/jruby"
    FileUtils.mv File.join(TARGET_BUNDLE_DIR, "ruby"), File.join(TARGET_BUNDLE_DIR, "jruby")
  
    puts "Copying #{JRUBY_FILENAME} to jruby-complete.jar"
    FileUtils.mkdir_p File.join(TARGET_DIR, "lib")
    FileUtils.cp File.join(LIB_DIR, JRUBY_FILENAME), File.join(TARGET_LIB_DIR, "jruby-complete.jar")
  
    puts "Creating jruby_boot.rb from template file"
    t = File.read File.join(TEMPLATE_DIR, "jruby_boot.rb.template")
    t.gsub!("{{bundler_version}}", BUNDLER_VERSION)
    File.open(File.join(TARGET_LIB_DIR, 'jruby_boot.rb'), "w"){|f| f << t}
  end
  
  desc "build Windows deployment"
  task :windows => ['build:pre'] do
    puts "building Windows deployment"
    
    if `which makensis` == ''
      puts "warning: can't compile the installer executable without the NSIS compiler!"
    else
      puts "Building the installer executable"
      system('makensis packager/windows/connector.nsi')
    end
  
    puts "Done!"
  end
  
  desc "build Linux deployment"
  task :linux => ['build:pre'] do
    puts "building Linux deployment"
    puts "Zipping the build"
    
    FileUtils.cd(BUILD_DIR) {
      `tar cfvz #{TARGET_NAME}.tar.gz #{TARGET_NAME}`
    }
    
    puts "Done!"
  end
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

  Dir.chdir(TARGET_DIR) do
    DELETE_FILE_LIST.each do |gl|
      Dir[gl].each do |f|
        File.delete(f)
      end
    end

    COPY_FILE_LIST.each do |from,to|
      File.open(from,"r") do |ins|
        File.open(to, "w") do |outs|
          outs << ins.read
        end
      end
    end
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
