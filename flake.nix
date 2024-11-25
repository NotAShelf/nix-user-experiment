{
  description = "Streamlined $HOME management via system-tmpfiles";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      flake.nixosModules = {
        # For now, and for debugging purposes only, this is a standalone nixosModule
        # that needs to be imported manually and other possible modules must follow
        # this concept of standalone functionality. In the future, a top-level module
        # might import all of them, similar to nixpkgs.
        users-groups = ./modules/users-groups.nix;
      };

      perSystem = {pkgs, ...}: {
        packages.default = pkgs.testers.nixosTest ({lib, ...}: {
          name = "nixosTest-test";
          nodes.machine = {pkgs, ...}: {
            imports = [inputs.self.nixosModules.users-groups];
            users.users.root.files = {
              foo.text = "bar";
            };
          };

          # The test script, for now, is irrelevant. We are more interested in whether
          # or not the package evaluates correctly.
          testScript = ''
            machine.succeed("hello | figlet >/dev/console")
          '';
        });
      };
    };
}
