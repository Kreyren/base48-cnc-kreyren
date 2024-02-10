{
	description = "Kreyren's Infrastructure Management With NiXium";

	inputs = {
		# Release inputs
		nixpkgs-legacy.url = "github:nixos/nixpkgs/nixos-23.05";
		nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
		# # nixpkgs.url = "git+file:///home/raptor/src/nixpkgs";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
		# nixpkgs-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable";
		nixpkgs-master.url = "github:nixos/nixpkgs/master";
    nixpkgs-staging.url = "github:nixos/nixpkgs/staging";

    # Principles
    flake-parts.url = "github:hercules-ci/flake-parts";
    mission-control.url = "github:Platonic-Systems/mission-control";
    flake-root.url = "github:srid/flake-root";
	};

	outputs = inputs @ { self, ... }:
		inputs.flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				inputs.flake-root.flakeModule
				inputs.mission-control.flakeModule
			];

			systems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];

			perSystem = { system, config, ... }: {
				# FIXME-QA(Krey): Move this to  a separate file somehow?
				# FIXME-QA(Krey): Figure out how to shorten the `inputs.nixpkgs-unstable.legacyPackages.${system}` ?
				## _module.args.nixpkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
				## _module.args.nixpkgs = import inputs.nixpkgs { inherit system; };
				mission-control.scripts = {
					freecad = {
						description = "FreeCAD (fully integrated)";
						category = "Integrated Editors";
						exec = "${inputs.nixpkgs.legacyPackages.${system}.freecad}/bin/freecad ./default.FCStd";
					};
				};
				devShells.default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
					name = "NiXium-devshell";
					nativeBuildInputs = [
						inputs.nixpkgs.legacyPackages.${system}.bashInteractive # For terminal
						inputs.nixpkgs.legacyPackages.${system}.nil # Needed for linting
						inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt # Nixpkgs formatter
						inputs.nixpkgs.legacyPackages.${system}.git # Working with the codebase
						inputs.nixpkgs.legacyPackages.${system}.fira-code # For liquratures in code editors
					];
					inputsFrom = [ config.mission-control.devShell ];
					# Environmental Variables
					#RULES = "./secrets/secrets.nix"; # For ragenix to know where secrets are
				};

				formatter = inputs.nixpkgs.nixpkgs-fmt;
			};
		};
}
