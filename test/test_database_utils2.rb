require_relative "test_helper"  
require_relative "../ipreader/database_utils"
require "sqlite3"

class TestDatabaseUtils < Test::Unit::TestCase

  SMS_TABLE_CREATE = "CREATE TABLE message (rowid INTEGER, date TEXT, address TEXT, text TEXT, flags INTEGER)"
  
  class IpDbUtils
    include Ipreader::Database::Utils
  end
  
  def setup
    @db_name = File.join(File.dirname(__FILE__), "tmp/dummy.sqlite3")
    file_teardown(@db_name) if File.exists?(@db_name)
    @ipdbutils = IpDbUtils.new
    @db = SQLite3::Database.new @db_name
  end
  
  def teardown
    @db.close unless @db.closed?
    GC.start
    file_teardown(@db_name) 
  end
  
  def file_teardown(file_name)
    File.delete(file_name) if File.exists?(file_name)
  end
  
  must "recognise an sms backup" do
    @db.execute SMS_TABLE_CREATE
    assert @ipdbutils.sms_db?(@db_name)
  end

  must "recognise when database is not an sms backup" do
    @db.execute "CREATE TABLE smerf (name VARCHAR(30))"
    refute @ipdbutils.sms_db?(@db_name)
  end

  must "fail gracefully if passed a file name that is not a SQLite3 database" do
    dummy_file = File.join(test_root, "tmp/empty.sqlite3")
    File.open(dummy_file, "w") { |df| df.puts " " } # "w" truncates existing db contents
    refute @ipdbutils.sms_db?(dummy_file)
  end  
  
  must "fail gracefully if passed a nil reference" do
    refute @ipdbutils.sms_db?(nil)
  end
  
  def setup_testdb
    @db.execute SMS_TABLE_CREATE
    @test_sms = []
    (1..4).each do |test_item|
      insert_sms = "INSERT INTO message (rowid, date, address, text, flags) VALUES( '#{test_item}', '2011-01-31 12:00:00', '+4479867#{test_item}#{test_item}#{test_item}#{test_item}', 'sms text #{test_item}', '2' );"
      @db.execute(insert_sms)
      @test_sms << { 
        :rowid    => test_item, 
        :on_date  => "2011/01/31", 
        :at_time  => "12:00:00", 
        :address  => "+4479867#{test_item}#{test_item}#{test_item}#{test_item}",
        :direction => 'to',
        :text     => "sms text #{test_item}"
      }
    end    
  end
  
  must "return all rows when no filter is applied" do 
    setup_testdb
    test_result = @ipdbutils.read_sms_table(@db_name)
    assert_equal test_result, @test_sms
    assert_equal @test_sms.length, test_result.length
  end
  
  must "correctly use the options hash to filter sms data" do
    setup_testdb
    result = []
    result << @test_sms.first
    options = { :address => "+44798671111" }
    test_result = @ipdbutils.read_sms_table(@db_name, options)
    assert_equal test_result, result
    assert_equal test_result.length, 1
  end
  
  must "ignore case when filtering sms data" do
    setup_testdb
    options = { :text => "sms text 1" }
    assert_equal @ipdbutils.read_sms_table(@db_name, options).length, 1
    options = { :text => "SMS TEXT 1" }
    assert_equal @ipdbutils.read_sms_table(@db_name, options).length, 1
  end
  
  must "ignore surplus options without erroring" do
    setup_testdb
    options = { :telephone => "011232131232" }
    assert_raises(ArgumentError) { @ipdbutils.read_sms_table(@db_name, options) }
  end

end
