require_relative "test_helper"  
require_relative "../ipreader/database_utils"

require 'fakefs/safe'

class TestDatabaseUtils < Test::Unit::TestCase

  include FakeFS
  
  class IpDbUtils
    include Ipreader::Database::Utils
  end
  
  def setup
    @ipdbutils = IpDbUtils.new
    FakeFS.activate!    
    FileSystem.clear
  end
  
  def teardown
    FakeFS.deactivate!
  end
  
  must "is_sqlite3? returns true the given file IS in a Sqlite3 format" do
    test_db_path = File.join(test_root, "tmp", "sqlite3_valid_fake.sqlite3" )
    File.open(test_db_path, 'w') { |f| f.write "SQLite format 3" }
    assert @ipdbutils.is_sqlite3?(test_db_path), "first characters of a valid SQLite3 database should be 'SQLite format 3'"
  end

  must "is_sqlite3? returns false if the given file is NOT a valid Sqlite3 format" do
    test_bad_path = File.join(test_root, "tmp", "sqlite3_invalid_fake.MSSQL" )
    File.open(test_bad_path, 'w') { |f| f.write "SQL Server 2000" }
    refute @ipdbutils.is_sqlite3?(test_bad_path), "should return false to a non SQLite3 file"
  end
  
  must "return false if the SQLite3 file is malformed" do
    test_malformed_path = File.join(test_root, "tmp", "sqlite3_malformed_fake.sqlite3" )
    File.open(test_malformed_path, 'w') { |f| f.write "xxxxxxxxxxxxxxSQLite format 3" }
    refute @ipdbutils.is_sqlite3?(test_malformed_path), "first characters are not a valid SQLite3 database"
  end  
  
  must "fail gracefully if the given file does not exist" do
    refute @ipdbutils.is_sqlite3?(nil), "should return false when no file is given"
  end
  
end
