## Jekyll thumbnail generator

A generator plugin for Jekyll that generated thumbnails of images related to
each post. Also includes Liquid templates showing these thumbnails in a page.

Tested with Jekyll 3.1.2.

### Dependencies

1. [rmagick][rmagick]. Tested with version 2.16.0
2. [Jekyll asset path plugin][asset-path]. Works also without, but the image paths are assumed to use the asset path plugin structure.

[rmagick]: https://github.com/rmagick/rmagick
[asset-path]: https://github.com/samrayner/jekyll-asset-path-plugin

### Usage

#### Creating image gallery thumbnails

Images to process into thumbnails are read from Jekyll front matter. The format
is the following:

```yml
gallery:
  - file: first-image.jpg
    title: First image file
  - file: second-image.jpg
    title: Second image file

```

Paths are relative to `gallery` directory under [asset path plugin][asset-path]'s asset path.
That is, for posts the gallery directory is
`assets/posts/<post-title>/gallery/` and for pages `assets/page-title/gallery/`.

Thumbnails are generated in directory `thumbnails` in the asset path.
Thumbnails are resized to fit dimensions of 200×120 pixels, or (TODO) as specified
in `_config.yml` option `thumbnail_size`:

```yml
thumbnail_gallery:
  width: 300
  height: 180
```

Generated thumbnails are included in the page as normal assets. You can use
`gallery.html` in `_includes` directory as a starting point for a gallery
implementation.

#### Creating cover photo thumbnail

Also, a shrank copy for post cover image can be made. The photo to resize is by
default `cover.jpg`. This can be overridden in front matter:

```yml
cover: other-image.png
```

Thumbnail dimensions are by default 400×240 pixels. These can be overridden in
`_config.yml`:

```yml
thumbnail_cover:
  width: 200
  height:  120
```

Cover photo thumbnail is included in pages as normal assets. See includes
`post_summary.html` and `post_summary_content.hmtl` in `_includes` directory
for example. 

### TODOs

1. Read images from `gallery` folder.
2. Read thumbnail size from configuration.
3. Implement cover thumbnail creation.
