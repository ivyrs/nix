{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule (finalAttrs: {
  pname = "glance-agent";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "glanceapp";
    repo = "agent";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eNhOelHR3EB3RWWMe7fG6vklgADX7XFy6QMI4Lfr8oM=";
  };

  vendorHash = "sha256-vjcyZctfgnAhzFEF0c+GhtWQqa4gVvLLj0E3sCLS0RE=";

  ldflags = ["-s" "-w" "-X github.com/glanceapp/agent/internal/agent.buildVersion=${finalAttrs.version}"];

  postInstall = ''
    mv $out/bin/agent $out/bin/glance-agent
  '';

  meta = {
    description = "Companion agent for Glance's server-stats widget, reporting system metrics from a remote machine";
    homepage = "https://github.com/glanceapp/agent";
    license = lib.licenses.gpl3Only;
    mainProgram = "glance-agent";
  };
})
