let
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGifS0QzVf8pT1rVYC5GGsAz1lYASMTyvN6fdPrIeBVw";
in
{
  "password-zacharie.age".publicKeys = [ sshKey ];
}
