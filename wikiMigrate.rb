require 'rubygems'
require 'media_wiki'
require 'markup_converter.rb'
require "xmlrpc/client"
require "wikidot_api"
require 'config.rb'
require 'base64'

def getMediawikiPage(mw, title)
    print "Downloading " + title + "\n"
    fileText = mw.get(title)
    File.open('output/mediawiki/' + title, 'w') {|f| f.write(fileText) } 
end

def download
    mw = MediaWiki::Gateway.new(@config.mediawiki_url)
    mw.login(@config.mediawiki_user, @config.mediawiki_password)
	
    # Get templates
    files = mw.list('Template:')
    files.each { |title| getMediawikiPage(mw, title) }

    # Get regular pages
    files = mw.list('')
    files.each { |title| getMediawikiPage(mw, title) }

    # Get files
    files = mw.list("File:")
    files.each do |file|
	title = file.split(/:/)[1]
	print "Downloading " + title + "\n"
	contents = mw.download(title)
	File.open('output/files/' + title, 'w') { |f| f.write(contents) }
    end
end

def convert
    Dir.foreach('output/mediawiki') { |title|
    if (isRegularFile(title))
	print "Converting " + title + "\n"
        fileText = File.read('output/mediawiki/' + title)
        mw = MarkupConverter.new(fileText)
        fileText = mw.convert
	File.open('output/wikidot/' + title, 'w') { |f| f.write(fileText) }
	
	if (fileText.match(/\{\|/))
	    print "***ALERT!!! " + title + " contains table code.  Update manually. ***\n"
	end
    end
    }
    
    # Create a placeholder page where we'll dump all the files
    if (!File.exists?("output/wikidot/files"))
        File.open('output/wikidot/files', 'w') { |f| f.write("A placeholder for imported files.") }
    end

end


def preview
    wikidot = WikidotAPI::Client.new "wikiMigrate", @config.wikidot_api_key
    
    Dir.foreach('output/wikidot') { |title|
	if (isRegularFile(title))
	    print "Previewing " + title + "\n"
	    uploadWikidotPage(wikidot, "preview", title)
	    puts "Preview and press enter to continue.\n"
	    input = $stdin.gets.chomp
	end
    }    
end

def isRegularFile(file)
    return !File.directory?(file) && !file.match(/^\./)
end

def upload
    wikidot = WikidotAPI::Client.new "wikiMigrate", @config.wikidot_api_key
    
    # Upload files
    Dir.foreach('output/files') { |filename|
	if (isRegularFile(filename))	    
	    print "Uploading " + filename + "\n"
	    uploadWikidotFile(wikidot, "files", filename)
	end
    }
    
    # Upload pages
    Dir.foreach('output/wikidot') { |title|
	if (isRegularFile(title))	    
	    print "Uploading " + title + "\n"
	    uploadWikidotPage(wikidot, title, title)
	end
    }
    
    return
end

def uploadWikidotPage(wikidot, pageName, title)
    pageSource = File.read('output/wikidot/' + title)
    
    # Find tags
    pattern = "\\\[!--Tag=(" + TagMap::NonGreedyPrintableMatch + "*?)--\\\]"
    tags = []
    pageSource.scan(/#{pattern}/) { |t| tags << t[0] }
    pageSource = @safeGs.wrap_if_no_subs(pageSource, pageSource.gsub!(/#{pattern}/, ""))
  
    args = {
		"title" => title,
		"content" => pageSource,
		"page" => pageName,
		"tags" => tags,
		"site" => @config.wikidot_site
		}
    wikidot.pages.save_one args
end


def uploadWikidotFile(wikidot, pageName, fileName)
    contents = Base64.encode64(File.read('output/files/' + fileName))
    args = {
		"file" => fileName,
		"content" => contents,
		"page" => pageName,
		"site" => @config.wikidot_site
		}
    wikidot.files.save_one args

end

def createDirIfNotThere(name)
    if (!File.directory?(name))
	Dir.mkdir(name)
    end
end


@config = WikiConfig.new
@safeGs = SaferGsub.new

createDirIfNotThere("output")
createDirIfNotThere("output/wikidot")
createDirIfNotThere("output/mediawiki")
createDirIfNotThere("output/files")

case ARGV[0]
    when "download"
	download
    when "upload" 
	upload
    when "convert"
	convert
    when "preview"
	preview
    else
	die "Usage: wikiMigrate <download|convert|preview|upload>\n"
end

print "Done!" + "\n"






