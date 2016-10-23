require 'rmagick'
include Magick

module Jekyll
  class GenerateThumbnails < Generator
    safe true
    priority :low

    # Fixed values
    Asset_base = "assets/posts/"
    Thumbnails_dir = "thumbnails"
    Default_cover = "cover.jpg"

    # Default configuration values
    Thumbnail_gallery = { 'width' => 200, 'height' => 120 }
    Thumbnail_cover = { 'width' => 400, 'height' => 240 }

    attr_accessor :thumbnail_gallery, :thumbnail_cover

    def generate(site)
        get_parameters! site

        site.posts.docs.each do |post|
            asset_dir = "#{Asset_base}/#{post.data['slug']}";
            if not File.exists? asset_dir
                raise "Asset directory '#{asset_dir}' not found."
            end

            thumbnails_dir = "#{asset_dir}/#{Thumbnails_dir}"
            Dir.mkdir thumbnails_dir if not File.exists? thumbnails_dir

            new_files = []
            new_files.concat generate_gallery_thumbnails(site, post, asset_dir)
            new_files.concat generate_cover_thumbnail(site, post, asset_dir)

            reader = StaticFileReader.new(site, thumbnails_dir)
            site.static_files.concat(reader.read(new_files))
        end
    end

    def get_parameters!(site)
        @thumbnail_gallery = site.config['thumbnail_gallery'] || Thumbnail_gallery
        @thumbnail_cover = site.config['thumbnail_cover'] || Thumbnail_cover
    end

    def generate_gallery_thumbnails(site, post, asset_dir)
        gallery = post.data['gallery']
        return [] if not gallery

        new_thumbnails = gallery.map do |item|
            image_file = "#{asset_dir}/#{item['file']}"
            image = Image.read(image_file)[0]
            thumbnail_file = "#{asset_dir}/#{Thumbnails_dir}/#{item['file']}"

            next nil if not thumbnail_needed?(image_file, thumbnail_file, @thumbnail_gallery)

            preexisting = File.exists? thumbnail_file
            save_thumbnail image, thumbnail_file, @thumbnail_gallery

            next nil if preexisting
            item['file']
        end

        return new_thumbnails == nil ? [] : new_thumbnails.compact
    end

    def generate_cover_thumbnail(site, post, asset_dir)
        cover = post.data['cover'] || Default_cover
        cover_file = "#{asset_dir}/#{cover}"

        image = Image.read(cover_file)[0]
        thumbnail_file = "#{asset_dir}/#{Thumbnails_dir}/#{cover}"

        return [] if not thumbnail_needed?(cover_file, thumbnail_file, @thumbnail_cover)

        preexisting = File.exists? thumbnail_file
        save_thumbnail image, thumbnail_file, @thumbnail_cover

        return [] if preexisting
        [cover]
    end

    def save_thumbnail(image, file, size)
        image.resize_to_fit! size['width'], size['height']
        image.write file
    end

    def thumbnail_needed?(image_file, thumbnail_file, size)
        # No thumbnail yet?
        return true if not File.exists? thumbnail_file
        # Image has changed?
        return true if File.mtime(thumbnail_file) < File.mtime(image_file)

        # Need to resize?
        metadata = (Image.ping thumbnail_file)[0]
        existing_size = {
            'width' => metadata.columns,
            'height' => metadata.rows
        }

        return false if (
            size['width'] == existing_size['width'] and
            size['height'] >= existing_size['height']
        )
        return false if
            size['height'] == existing_size['height'] and
            size['width'] >= existing_size['width']

        true
    end
  end
end