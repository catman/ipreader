require 'date'
require 'haml'
require 'sqlite3'

require_relative "ipreader/database_utils"
require_relative "ipreader/display"

module Ipreader

  KNOWN_FORMATS = [ "xml", "csv", "html" ]
  NO_TEMPLATE = "no template chosen"
  LIBRARY_LOCATION = "ipreader"
  TEMPLATE_LOCATION = "templates"
  
  class Controller

    include Ipreader::Database::Utils
    include Ipreader::Display

    def initialize(backup_path = nil, format = "html" , options = {} )
      @conversations = []
      @backup_path = backup_path
      @template_type = format
      @options = options
    end

    def start
      read_backups
      display_sms(@template_type)
    end
    
    # control which backup directories to read through
    # TODO more than one backup directory
    # TODO more than one database type
    def read_backups
      Dir.foreach(@backup_path) do |file_name|
        full_name = File.join(@backup_path, file_name)
        unless File.directory?(full_name) 
          if is_sqlite3?(full_name)
            @conversations << read_sms_table(full_name, @options) if sms_db?(full_name)
          end
        end
      end
      return @conversations
    end
    
  end
    
end
