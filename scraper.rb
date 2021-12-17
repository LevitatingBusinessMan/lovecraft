require 'net/http'
require 'nokogiri'
require 'fileutils'

DIR = Pathname.new (ENV["OUTPUT_DIR"] || "x")
DOUBLE_NEWLINES = false

FileUtils.mkdir_p DIR

list_page = Nokogiri.HTML5 Net::HTTP.get(URI("https://hplovecraft.com/writings/texts/"))

for story in list_page.css('tbody > tr:nth-child(3) > td > font > div > ul > ul:nth-child(2) > li > a')
	name = story.inner_html
	name.gsub!(/<\/?\w+.*>/, "") # sometimes there is <i> used in the title
	puts "Downloading \e[93m#{name}\e[0m"

	uri = URI "https://hplovecraft.com/writings/texts/#{story["href"]}"
	doc = Nokogiri.HTML5 Net::HTTP.get(uri)

	text = doc.css('tbody > tr:nth-child(3) > td > div > font > div').inner_html

	text.gsub!("\n", "") # Remove all existing newlines (were used as wordwrap)

 	# I need to work with these so they can't be removed
	text.gsub!("<center>", "{center}")
	text.gsub!("</center>", "{/center}")
	text.gsub!("<br>", "{br}")

	text.gsub!(/<[^<>]+>/, "") # rip out any other elements but leave content

	text.gsub!("{br}{br}", "{br}") # Remove double breaks
	text.gsub!("{br}", DOUBLE_NEWLINES ? "\n\n" : "\n") # Place actual double newlines at <br>
	text.gsub!("{/center}", DOUBLE_NEWLINES ? "" : "\n") # Anything centered prob needs a newline
	text.gsub!("{center}", DOUBLE_NEWLINES ? "" : "\n")

	File.write DIR.join(name + ".txt"), text.strip + "\n"
end
