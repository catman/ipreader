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
  
      def read_sms_table(full_name, filters = {} )
        
        sms_list = Array.new
        SQLite3::Database.new(full_name) do |db|
          
          message_table_columns = db.execute2("SELECT * FROM message LIMIT 0").flatten
          column_keys = filters.keys.collect { |k| k.to_s }
          non_matched_columns = column_keys - message_table_columns
          if non_matched_columns.length > 0
            raise ArgumentError, "can't find column [#{non_matched_columns}] in messages" 
            exit
          else
            optional_filters = ""
            filters.keys.each do |filter|
            optional_filters += " AND #{filter} LIKE :#{filter}"
          end
            sql =  "SELECT rowid, date(date,'unixepoch'), address, text, flags, time(date,'unixepoch')"
            sql += " FROM message"
            sql += " WHERE text is not null #{optional_filters}"
            sql += " ORDER BY address AND date ASC"
            
#            puts "sql=#{sql}"
#            sql += " LIMIT 5"

            begin
              db.execute(sql, filters) do |row|
                direction = case row[4]
                when 2 then "to"
                when 3 then "from"
                else "??"
                end
                # TODO connascence of position
                row_hash = { :rowid => row[0],
                  :on_date => row[1], 
                  :at_time => row[5], 
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