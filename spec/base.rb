require 'rubygems'
require 'spec'

require 'activerecord'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Schema.define do
  create_table :posts do |t|
    t.text :title, :body, :body_html, :summary_html, :slug, :tags
    t.timestamp :created_at
  end
end
    
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'post'

require 'ostruct'
Blog = OpenStruct.new(
	:title => 'My blog',
	:author => 'Anonymous Coward',
	:url_base => 'http://blog.example.com/'
)
