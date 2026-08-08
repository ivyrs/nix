{
  flake.lib.meta = rec {
    domain = "houseplants.cloud";
    tailnet = "ocelot-perch.ts.net";
    email = "ivy@ivy.rs";

    oidcIssuer = "https://id.${domain}";

    smtp = {
      host = "smtp.fastmail.com";
      port = 587;
      username = email;
    };

    syncthing = {
      devices = {
        aspen = "34BRASD-JF433B5-65QROJF-7WRJZ74-LISAYBR-4ADQBVC-XXX672X-O7IAJA6";
        alder = "IW3IYSH-QZZXLNV-553NXOQ-5EPBYLW-3MWQJJB-3JEEZB2-H7JIKSQ-NW4C6A2";
        elm = "TJPGEOG-GD5YAMM-47UEI4V-XTTAS4J-USDHS2B-JLNX4ED-NBEBUPF-WMYMOAC";
        maple = "5JH2CJ6-GEFOZAI-YTE2HIW-EK2NNHG-4CATBIM-WA4F2ZD-HUFTQIN-QXCBJAI";
        birch = "IGGM65Q-7D3CXXE-WL2DZBQ-JFTAVZH-2IGGI3T-NNSEIOE-Y26ERF2-357RMQM";
      };
      obsidianFolderId = "obsidian-vault";
      passwordStoreFolderId = "password-store";
    };
  };
}
