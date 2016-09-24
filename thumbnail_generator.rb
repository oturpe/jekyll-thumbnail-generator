require 'rmagick'
include Magick

module Jekyll
  class GenerateThumbnails < Generator
    safe true
    priority :low

    # Value to use as an image dimension when no limit is desired
    LargeDimension = 1e4

    def generate(site)
    	# TODO
    	site.posts.docs.each do |post|
    	    gallery = post.data["gallery"]
    	    next if not gallery

    	    directory = "assets/posts/#{post.data['slug']}";

            thumbnails_dir = "#{directory}/thumbnails"
            Dir.mkdir thumbnails_dir if not (File.exists? thumbnails_dir)

    	    gallery.each do |item|
    	        image = Image.read("#{directory}/#{item['file']}")[0]
    	        image.resize_to_fit(LargeDimension, 240)

                thumbnail_file = "#{thumbnails_dir}/#{item['file']}"
                image.write(thumbnail_file) if not File.exists? thumbnail_file
    	    end
        print "\n"
        end
    end

    def generate_thumbnails()
    end
  end
end