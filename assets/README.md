# Icon Assets

This directory should contain the following icon files for the Electron app:

- `icon.icns` - macOS icon (1024x1024 recommended)
- `icon.ico` - Windows icon (256x256 recommended)
- `icon.png` - Linux icon (512x512 recommended)

## Creating Icons

You can use tools like:
- [electron-icon-builder](https://github.com/safu9/electron-icon-builder)
- [iConvert Icons](https://iconverticons.com/)
- ImageMagick

Example with ImageMagick:
```bash
# Create PNG from source image
convert source.png -resize 512x512 icon.png

# Create ICO for Windows
convert source.png -resize 256x256 icon.ico

# For ICNS (macOS), use iconutil or a specialized tool
``` 