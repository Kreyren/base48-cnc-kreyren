{ ... }:

{
	perSystem = { inputs', lib, pkgs, ... }: {
		mission-control.scripts = {
			freecad = {
				description = "Open repository-standardized FreeCAD version with configuration";
				category = "Integrated Development Environments";
				exec = "${inputs'.nixpkgs.legacyPackages.freecad}/bin/freecad ./default.FCStd";
			};
		};
	};
}
