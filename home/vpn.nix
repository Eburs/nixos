{ pkgs, ... }:
{
  home.packages = [
    pkgs.openconnect
    pkgs.libsecret
    pkgs.oath-toolkit
  ];

  home.file.".local/bin/uni-vpn" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      HOST="vpn-ac.urz.uni-heidelberg.de"
      USERNAME="''${UNI_VPN_USER:-}"
      if [[ -z "$USERNAME" ]]; then
        USERNAME="$(secret-tool lookup vpn uni-heidelberg account default 2>/dev/null || true)"
      fi
      if [[ -z "$USERNAME" && -f "$HOME/.config/uni-vpn/username" ]]; then
        USERNAME="$(cat "$HOME/.config/uni-vpn/username" 2>/dev/null || true)"
      fi
      if [[ -z "$USERNAME" ]]; then
        read -r -p "Username: " USERNAME
        mkdir -p "$HOME/.config/uni-vpn"
        printf '%s' "$USERNAME" > "$HOME/.config/uni-vpn/username"
        chmod 600 "$HOME/.config/uni-vpn/username"
        echo "Saved username to $HOME/.config/uni-vpn/username"
        echo "Optional: also store it in GNOME Keyring with:"
        echo "  secret-tool store --label='Uni Heidelberg VPN user' vpn uni-heidelberg account default"
      fi

      PASSWORD="$(secret-tool lookup vpn uni-heidelberg user "$USERNAME" 2>/dev/null || true)"
      if [[ -z "$PASSWORD" ]]; then
        read -r -s -p "Password: " PASSWORD
        echo
        echo "No saved password found in GNOME Keyring."
        echo "To save it, run:"
        echo "  secret-tool store --label='Uni Heidelberg VPN' vpn uni-heidelberg user \"$USERNAME\""
      fi
      OTP="$(secret-tool lookup vpn uni-heidelberg kind totp 2>/dev/null || true)"
      if [[ -z "$OTP" ]]; then
        read -r -s -p "OTP (2FA token): " OTP
        echo
        echo "No TOTP secret found in GNOME Keyring."
        echo "To store it (the TOTP secret, not the 6-digit code), run:"
        echo "  secret-tool store --label='Uni Heidelberg VPN TOTP' vpn uni-heidelberg kind totp"
      else
        OTP="$(${pkgs.oath-toolkit}/bin/oathtool --totp -b "$OTP")"
      fi

      printf '%s\n%s\n' "$PASSWORD" "$OTP" | sudo ${pkgs.openconnect}/bin/openconnect \
        --protocol=anyconnect \
        --user="$USERNAME" \
        --passwd-on-stdin \
        "$HOST"
    '';
  };
}
