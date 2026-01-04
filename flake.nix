{
	description = "The Base48's Next-Gen CNC Project";

	inputs = {
		# Release inputs
			nixpkgs-master.url = "github:nixos/nixpkgs/master";
			nixpkgs-staging-next.url = "github:nixos/nixpkgs/staging-next";
			nixpkgs-staging.url = "github:nixos/nixpkgs/staging";
			nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

			nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
			# nixpkgs.url = "git+file:///nix/persist/NiXium/vendor/nixpkgs-stable";

			nixpkgs-25_11.url = "github:nixos/nixpkgs/nixos-25.11";
			nixpkgs-25_05.url = "github:nixos/nixpkgs/nixos-25.05";
			nixpkgs-24_11.url = "github:nixos/nixpkgs/nixos-24.11";
			nixpkgs-24_05.url = "github:nixos/nixpkgs/nixos-24.05";
			nixpkgs-23_11.url = "github:nixos/nixpkgs/nixos-23.11";
			nixpkgs-23_05.url = "github:nixos/nixpkgs/nixos-23.05";

		# Principle inputs
			nixos-flake.url = "github:srid/nixos-flake";
			flake-parts.url = "github:hercules-ci/flake-parts";
			mission-control.url = "github:Platonic-Systems/mission-control";

			flake-root.url = "github:srid/flake-root";

		# DISKO
			disko = {
				url = "github:nix-community/disko";
				inputs.nixpkgs.follows = "nixpkgs";
			};
			disko-unstable = {
				url = "github:nix-community/disko";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			disko-master = {
				url = "github:nix-community/disko";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		# Home-Manager
			hm = {
				url = "github:nix-community/home-manager/release-25.11";
				inputs.nixpkgs.follows = "nixpkgs";
			};

			hm-25_11 = {
				url = "github:nix-community/home-manager/release-25.11";
				inputs.nixpkgs.follows = "nixpkgs-24_11";
			};

			hm-25_05 = {
				url = "github:nix-community/home-manager/release-25.05";
				inputs.nixpkgs.follows = "nixpkgs-25_05";
			};

			hm-24_11 = {
				url = "github:nix-community/home-manager/release-24.11";
				inputs.nixpkgs.follows = "nixpkgs-24_11";
			};

			hm-24_05 = {
				url = "github:nix-community/home-manager/release-24.05";
				inputs.nixpkgs.follows = "nixpkgs-24_05";
			};
			hm-23_11 = {
				url = "github:nix-community/home-manager/release-23.11";
				inputs.nixpkgs.follows = "nixpkgs-23_11";
			};

			hm-unstable = {
				url = "github:nix-community/home-manager/master";
				inputs.nixpkgs.follows = "nixpkgs-unstable";
			};
			hm-master = {
				url = "github:nix-community/home-manager/master";
				inputs.nixpkgs.follows = "nixpkgs-master";
			};

		nixos-generators = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nixos-generators-unstable = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};
		nixos-generators-master = {
			url = "github:nix-community/nixos-generators";
			inputs.nixpkgs.follows = "nixpkgs-master";
		};
	};

	outputs = inputs @ { self, ... }:
		inputs.flake-parts.lib.mkFlake { inherit inputs; } {
			imports = [
				./tasks # Include Tasks

				inputs.flake-root.flakeModule
				inputs.mission-control.flakeModule
			];

			# Set Supported Systems
			systems = [
				"x86_64-linux"
				"aarch64-linux"
				"riscv64-linux"
				"armv7l-linux"
			];

			perSystem = { system, config, inputs', ... }: {
				devShells.default = inputs.nixpkgs.legacyPackages.${system}.mkShell {
					name = "NiXium-devshell";
					nativeBuildInputs = [
						# Shell
						inputs.nixpkgs.legacyPackages.${system}.ksh # For Scripting
						inputs.nixpkgs.legacyPackages.${system}.bashInteractive # For terminal
						inputs.nixpkgs.legacyPackages.${system}.shellcheck # Linting of shell files

						# Nix
						inputs.nixpkgs.legacyPackages.${system}.nil # Needed for linting
						inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt # Nixpkgs formatter

						inputs.nixpkgs.legacyPackages.${system}.sops # Secret management
						inputs.nixpkgs.legacyPackages.${system}.sbctl # To set up secureboot
						inputs.nixpkgs.legacyPackages.${system}.fira-code # For liquratures in code editors

						# Benchmarks
						inputs.nixpkgs.legacyPackages.${system}.perf

						# Utilities
						inputs.nixpkgs.legacyPackages.${system}.git # Working with the codebase
						inputs.nixpkgs.legacyPackages.${system}.nano # Editor to work with the codebase in cli

						inputs.nixos-generators.packages.${system}.nixos-generate

						inputs.disko.packages.${system}.disko

						inputs.nixpkgs.legacyPackages.${system}.ncurses
						inputs.nixpkgs.legacyPackages.${system}.pkg-config

						inputs.nixpkgs.legacyPackages.${system}.ungoogled-chromium # Web browser used in the integrated developer environment for interacting with the outside resources
					];
					inputsFrom = [
						config.mission-control.devShell
						config.flake-root.devShell
					];
					# Environmental Variables
					#VARIABLE = "value"; # Comment
				};

				formatter = inputs.nixpkgs.legacyPackages.${system}.nixpkgs-fmt;
			};
		};
}
