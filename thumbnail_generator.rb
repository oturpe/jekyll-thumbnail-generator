require 'rmagick'
include Magick

module Jekyll
  class GenerateThumbnails < Generator
    safe true
    priority :low

    # Directory names
    Thumbnails_dir = "thumbnails"

    # Default configuration values
    Thumbnail_gallery = { 'width' => 200, 'height' => 120 }

    attr_accessor :thumbnail_gallery

    def generate(site)
        if site.config['thumbnail_gallery']
            @thumbnail_gallery = site.config['thumbnail_gallery']
        else
            @thumbnail_gallery = Thumbnail_gallery
        end

        site.posts.docs.each do |post|
            generate_post_thumbnails(site, post)
        end
    end

    def generate_post_thumbnails(site, post)
        gallery = post.data['gallery']
        return if not gallery

        asset_dir = "assets/posts/#{post.data['slug']}";
        if not File.exists? asset_dir
            raise "Asset directory '#{asset_dir}' not found."
        end

        thumbnails_dir = "#{asset_dir}/#{Thumbnails_dir}"
        Dir.mkdir thumbnails_dir if not (File.exists? thumbnails_dir)

        new_files = []
        gallery.each do |item|
            image_file = "#{asset_dir}/#{item['file']}"
            image = Image.read(image_file)[0]
            thumbnail_file = "#{thumbnails_dir}/#{item['file']}"

            next if not thumbnail_needed?(image_file, thumbnail_file)

            image.resize_to_fit!(
                @thumbnail_gallery['width'],
                @thumbnail_gallery['height']
            )

            image.write(thumbnail_file)
            new_files.push thumbnail_file if not File.exists? thumbnail_file
        end        

        reader = StaticFileReader.new(site, thumbnails_dir)
        site.static_files.concat(reader.read(new_files))
    end

    def thumbnail_needed?(image_file, thumbnail_file)
        return true if not File.exists? thumbnail_file
        return File.mtime(thumbnail_file) < File.mtime(image_file)
    end
  end
end