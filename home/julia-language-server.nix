{ pkgs, ... }:
let
  julia = pkgs.julia;
  lsSrc = pkgs.fetchFromGitHub {
    owner = "JuliaEditorSupport";
    repo = "LanguageServer.jl";
    rev = "7032c0f637b243cb5049f78ed5569a2525ee2b4c";
    hash = "sha256-thsoczOebPmlgQVlqlN+lWbggIZtecAHLwz3Ry736aY=";
  };
  juliaLs = pkgs.writeShellScriptBin "julia-language-server" ''
    set -euo pipefail
    exec ${julia}/bin/julia --startup-file=no --history-file=no -e '
      using Pkg
      Pkg.activate("${lsSrc}")
      Pkg.instantiate()
      using LanguageServer
      using SymbolServer
      depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
      project_path = Base.current_project()
      server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
      server.runlinter = true
      run(server)
    '
  '';

  juliaFormatter = pkgs.writeShellScriptBin "juliaformatter" ''
    set -euo pipefail
    exec ${julia}/bin/julia --startup-file=no --history-file=no -e '
      using Pkg
      Pkg.activate(temp=true)
      Pkg.add("JuliaFormatter")
      using JuliaFormatter
      JuliaFormatter.format(ARGS)
    ' -- "$@"
  '';
in
{
  home.packages = [
    juliaLs
    juliaFormatter
  ];
}
