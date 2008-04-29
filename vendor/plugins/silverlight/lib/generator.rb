# NOTE: requires filesystemwatcher to be installed
# http://www.jhorman.org/FileSystemWatcher/index.html
require "filesystemwatcher"
require 'xap'

# Generates the XAP on modification of watched files
class Generator
  Xap = XAPChiron
  
  def initialize
    @files = []
    class << @files
      alias :"old_carot" :"<<"
      def << (val)
        puts val
        old_carot val
      end
    end    
    puts "** Initializing Silverlight"
    generate # make sure to generate XAPs the first time 
  end
  
  # List of files/directories to watch for modification.
  # Triggers generation of the Silverlight package (XAP)
  def watch
    @watcher = FileSystemWatcher.new
    @watcher.addDirectory "#{RAILS_ROOT}/app/client"
    @watcher.addDirectory "#{RAILS_ROOT}/vendor/plugins/silverlight/client"
    
    # TODO: watch all client controllers, as well as all views
    @watcher.addFile "#{RAILS_ROOT}/app/controllers/client_controller.rb"
    
    @watcher.sleepTime = 1
    @watcher.start { |status, file| generate }
  end
  
  def generate
    ["public/client.xap"].each do |file|
      File.delete(file) if File.exists?(file)
    end
    puts "** Generating client.xap"
    FileUtils.cp_r 'vendor/plugins/silverlight/client/.', 'app/.client'
    FileUtils.cp_r 'app/client/.', 'app/.client'
    
    # TODO: copy all controllers, views, and models
    FileUtils.mkdir_p 'app/.client/controllers'
    FileUtils.cp 'app/controllers/client_controller.rb', 'app/.client/controllers'
    
    Xap.new.generate
    FileUtils.rm_r 'app/.client'
  end
end

Generator.new.watch