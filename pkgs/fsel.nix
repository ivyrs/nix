{
  lib,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  coreutils,
}:

rustPlatform.buildRustPackage {
  pname = "fsel";
  version = "4.0.0-nyamabeetle";

  # Stable's 3.1 lacks the borderless UI controls used by our config.
  src = fetchFromGitHub {
    owner = "Mjoyufull";
    repo = "fsel";
    rev = "2d1ddd6fa83c2214702abe8bab76c754216bd356";
    hash = "sha256-A05/N0CM3GaO2zChHvTbTUQvXUhwDT8VcevzcQ14e+g=";
  };

  cargoHash = "sha256-Vo3J2/XphNhvYkt4oasB2Z6OOj/nez7agSJZJbu+h1I=";

  # Upstream's launch tests assume a conventional /bin hierarchy.
  postPatch = ''
    substituteInPlace src/modes/app_launcher/persistent.rs tests/cli_behavior.rs       --replace-fail /bin/true ${coreutils}/bin/true
    substituteInPlace tests/cli_behavior.rs       --replace-fail /bin/false ${coreutils}/bin/false
  '';

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installManPage fsel.1
  '';

  meta = {
    description = "Fast TUI app launcher and fuzzy finder";
    homepage = "https://github.com/Mjoyufull/fsel";
    license = lib.licenses.bsd2;
    mainProgram = "fsel";
    platforms = lib.platforms.linux;
  };
}
