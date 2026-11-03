{
  user = {
    username = "ivy";
    fullName = "ivy forever";
    homeDirectory = "/home/ivy";

    emails = {
      primary = "ivy@ivy.rs";
      gmail = "ivyturner78@gmail.com";
    };

    sshKeys = {
      aspen = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtFawaAWSklr1GGYiBZzGr/ydKSSOatBfGfY72eqKGZ";
      alder = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdNudbGaj76Gu5Kn9bKsTCb8cAMPM0lg/hS6TriaWY7";
    };
  };

  domains = {
    personal = "ivy.rs";
    services = "houseplants.cloud";
  };

  tailnet = {
    domain = "ocelot-perch.ts.net";
    ingressProxyIp = "100.64.20.1";
  };

  hosts = {
    alder = {
      name = "alder";
      system = "aarch64-linux";
    };

    aspen = {
      name = "aspen";
      system = "aarch64-darwin";
    };

    maple = {
      name = "maple";
      system = "x86_64-linux";
    };

    willow = {
      name = "willow";
      system = "x86_64-linux";
    };
  };
}
