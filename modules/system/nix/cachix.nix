{
  nix.settings = {
    extra-substituters = [
      "https://ivyturner.cachix.org"
      "https://noctalia.cachix.org"
      "https://umbriel.cachix.org"
    ];

    extra-trusted-public-keys = [
      "ivyturner.cachix.org-1:G+GeQA1oBRaM2FfsUJph4QH8bNlkpvEQmxt42YFO00o="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
    ];
  };
}
