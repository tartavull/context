{
  description = "Orchestrator - Recursive Task Decomposition Electron App";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Node.js version
        nodejs = pkgs.nodejs_20;
        
        # Electron and development dependencies
        electronDeps = with pkgs; [
          electron
        ];
        
        # System dependencies for Electron
        systemDeps = with pkgs; [
          # Development tools
          git
          sqlite
        ] ++ lib.optionals stdenv.isLinux [
          # Graphics and display (Linux only)
          xorg.libX11
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXrandr
          xorg.libXrender
          xorg.libXtst
          xorg.libxcb
          
          # GTK and desktop integration
          gtk3
          glib
          nss
          nspr
          alsa-lib
          
          # Other Electron dependencies
          libdrm
          expat
          cups
          dbus
          atk
          at-spi2-atk
          pango
          cairo
          gdk-pixbuf
          mesa
          
          # Linux specific
          libxkbcommon
          systemd
        ] ++ lib.optionals stdenv.isDarwin [
          darwin.apple_sdk.frameworks.Cocoa
          darwin.apple_sdk.frameworks.WebKit
        ];
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs
            nodejs.pkgs.pnpm
            nodejs.pkgs.yarn
            nodejs.pkgs.typescript
            nodejs.pkgs.typescript-language-server
            
            # Development tools
            nodePackages.prettier
            nodePackages.eslint
            
            # Build tools
            pkg-config
            python3
            imagemagick
            
            # For node-gyp
            gnumake
            gcc
          ] ++ electronDeps ++ systemDeps;
          
          shellHook = ''
            echo "🚀 Orchestrator Development Environment"
            echo "📦 Node.js: ${nodejs.version}"
            echo "⚡ Electron: Latest"
            echo ""
            echo "Available commands:"
            echo "  pnpm install    - Install dependencies"
            echo "  pnpm dev        - Start development server"
            echo "  pnpm build      - Build the application"
            echo "  pnpm start      - Run the built application"
            echo ""
            
            # Set up Electron environment
            export ELECTRON_SKIP_BINARY_DOWNLOAD=1
            export ELECTRON_OVERRIDE_DIST_PATH=${pkgs.electron}/bin
            
            # For Linux
            ${if pkgs.stdenv.isLinux then ''
              export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath systemDeps}:$LD_LIBRARY_PATH"
            '' else ""}
            
            # Create .env.local if it doesn't exist
            if [ ! -f .env.local ]; then
              echo "Creating .env.local for API keys..."
              cat > .env.local << EOF
# Add your API keys here
OPENAI_API_KEY=
ANTHROPIC_API_KEY=
EOF
            fi
          '';
          
          # Environment variables
          LANG = "en_US.UTF-8";
          LC_ALL = "en_US.UTF-8";
        };
      });
} 