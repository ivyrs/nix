{ lib, ... }:

{
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "helium.desktop" ];
      "application/xhtml+xml" = [ "helium.desktop" ];
      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
      "application/pdf" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
      "application/epub+zip" = [ "org.pwmt.zathura-pdf-mupdf.desktop" ];
    } // lib.genAttrs [
      "image/x-farbfeld"
      "image/tiff"
      "image/tiff-fx"
      "image/png"
      "image/x-png"
      "image/jpeg"
      "image/jpg"
      "image/pjpeg"
      "image/svg+xml"
      "image/gif"
      "image/bmp"
      "image/x-bmp"
      "image/heif"
      "image/avif"
      "image/jxl"
      "image/webp"
      "image/qoi"
    ] (_: [ "imv.desktop" ]);
  };
}
