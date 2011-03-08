require File.dirname(__FILE__) + '/../vendor/maruku/maruku'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../vendor/syntax'
require 'syntax/convertors/html'

class Post < ActiveRecord::Base
	
	before_save :cache_html

	def url
		d = created_at
		"/past/#{d.year}/#{d.month}/#{d.day}/#{slug}/"
	end

	def full_url
		Blog.url_base.gsub(/\/$/, '') + url
	end

	def summary
		summary, more = split_content(body)
		summary
	end

	def more?
		summary, more = split_content(body)
		more
	end

	def linked_tags
		tags.split(",").inject([]) do |accum, tag|
			accum << "<a href=\"/past/tags/#{tag}\">#{tag}</a>"
		end.join(" ")
	end

	def self.make_slug(title)
		candidate = title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
    slug,cnt = nil,1
    while slug.nil? 
      p = Post.find_by_slug("#{candidate}#{cnt}")
      if p.nil?
        slug = "#{candidate}#{cnt}"
      end
      cnt += 1 
    end
    slug
	end

	########

	def to_html(markdown)
		h = Maruku.new(markdown).to_html
		h.gsub(/<code>([^<]+)<\/code>/m) do
			convertor = Syntax::Convertors::HTML.for_syntax "ruby"
			highlighted = convertor.convert($1)
			"<code>#{highlighted}</code>"
		end
	end

	def split_content(string)
		parts = string.gsub(/\r/, '').split("\n\n")
		show = []
		hide = []
		parts.each do |part|
			if show.join.length < 400
				show << part
			else
				hide << part
			end
		end
		[ to_html(show.join("\n\n")), hide.size > 0 ]
	end
	
	def cache_html
	  self.body_html = to_html(body)
	  # Maruku will occasionlly escape a trailing </p>, easier to strip it out than to figure out why.
	  self.summary_html = to_html(summary).gsub("&lt;/p&gt;", "")
	end
end