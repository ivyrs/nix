{self, lib, ... }: {
  den.aspects.gaming.nixos = {pkgs, lib, ...}:
    lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
        programs.steam = {
          enable = true;
          gamescopeSession.enable = true;
          remotePlay.openFirewall = true;
          dedicatedServer.openFirewall = true;
        };
      })
      # nixpkgs' `programs.steam` unconditionally needs pkgsi686Linux
      # (glibc-multi) to build its FHS rootfs, and that package set throws
      # on non-x86 hosts regardless of hardware.graphics.enable32Bit — Steam
      # has no native aarch64 Linux build. On aarch64 (alder/Asahi) run it
      # instead via Distrobox, using Fedora Asahi Remix's FEX-based x86
      # translation layer: https://gist.github.com/stevesoltys/af4c5c45317c543fa3b88da7d08a7218
      (lib.mkIf pkgs.stdenv.hostPlatform.isAarch64 {
        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
        };
        environment.systemPackages = [pkgs.distrobox];
      })
    ];
}
