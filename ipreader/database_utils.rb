require 'sqlite3'
require 'date'

module Ipreader
  
  module Database
    
    module Utils
      
      def is_sqlite3?(full_name)
        return false if full_name.nil? 
        file_data = File.open(full_name, "r") 
        file_header = file_data.gets
        file_header =~ /^SQLite format 3/
      end      
      
      def sms_db?(full_name)
        return false if full_name.nil? 
        SQLite3::Database.new(full_name) do |db|
          begin
            if db.execute("SELECT count(*) FROM SQLITE_MASTER WHERE type='table' AND name='message'").flatten.first > 0
              return true
            else 
              return false
            end
            rescue SQLite3::SQLException, SQLite3::IOException, NilClass => e
              return false
          end
        end
      end
  
      def read_sms_table(full_name, options = {} )
        
        sms_list = Array.new
        SQLite3::Database.new(full_name) do |db|
          
          message_table_columns = db.execute2("SELECT * FROM message LIMIT 0").flatten
          column_keys = options.keys.collect {|k| k.to_s}
          non_matched_columns = column_keys - message_table_columns
          if non_matched_columns.length > 0
            raise ArgumentError, "can't find column [#{non_matched_columns}] in messages" 
            exit
          else
            options_filters = ""
            options.keys.each do |option|
              options_filters += " AND #{option} LIKE :#{option}"
            end
            sql = "SELECT rowid, date, address, text, flags FROM message WHERE text is not null #{options_filters} ORDER BY address AND date ASC"
            begin
              db.execute(sql, options) do |row|
                direction = case row[4]
                when 2 then "to"
                when 3 then "from"
                else "??"
                end
                sms_date = DateTime.parse(row[1])
                row_hash = { :rowid => row[0],
                  :on_date => sms_date.strftime("%Y/%m/%d"), 
                  :at_time => sms_date.strftime("%H:%M:%S"), 
                  :address => row[2],
                  :direction => direction, 
                  :text => row[3]
                }
                sms_list << row_hash
              end
            rescue SQLite3::Exception => e
            end
          end
        end
        return sms_list
      end
  
    end
  end
end