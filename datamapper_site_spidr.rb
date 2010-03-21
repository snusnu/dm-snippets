require "pathname"
require "rubygems"
require "spidr"


TARGET_DIR = Pathname(__FILE__).dirname.expand_path + 'spidr_content'

Spidr.site "http://datamapper.org/doku.php" do |agent|
  agent.every_page do |page|
    if page.html?
      title = page.doc.css("title").first.content.strip
      puts "XXX: saving #{page.url} to file #{title}.html"
      File.open(TARGET_DIR + "#{title}.html", 'w') do |f|
        f.write(page.body)
      end
    end
  end
end

"wget -rkvpL http://datamapper.org/doku.php"