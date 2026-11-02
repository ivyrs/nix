{ pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # video
      wayland
      libxkbcommon
      libdecor
      libGL
      vulkan-loader
      libX11
      libXext
      libXcursor
      libXrandr
      libXi
      libXinerama
      # audio
      alsa-lib
      libpulseaudio
      pipewire
    ];
  };
}
