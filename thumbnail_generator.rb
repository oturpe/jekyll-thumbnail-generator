require 'rmagick'
include Magick

module Jekyll
  class GenerateThumbnails < Generator
    safe true
    priority :low

    # Value to use as an image dimension when no limit is desired
    LargeDimension = 1e4

    # Directory names
    Thumbnails_dir = "thumbnails"

    def generate(site)
        # TODO
        site.posts.docs.each do |post|
            gallery = post.data["gallery"]
            next if not gallery

            asset_dir = "assets/posts/#{post.data['slug']}";
            if not File.exists? asset_dir
                raise "Asset directory '#{asset_dir}' not found."
            end

            thumbnails_dir = "#{asset_dir}/#{Thumbnails_dir}"
            Dir.mkdir thumbnails_dir if not (File.exists? thumbnails_dir)

            gallery.each do |item|
                image = Image.read("#{asset_dir}/#{item['file']}")[0]
                image.resize_to_fit!(LargeDimension, 120)

                thumbnail_file = "#{thumbnails_dir}/#{item['file']}"
                image.write(thumbnail_file) if not File.exists? thumbnail_file
    	    end
        end
    end

    def generate_thumbnails()
    end
  end
end