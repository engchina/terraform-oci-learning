Host *
  IdentityFile ${private_key_path}
  User ${destination_ssh_user}
  Port 22
  IgnoreUnknown UseKeychain
  StrictHostKeyChecking no
  AddKeysToAgent yes
  ServerAliveInterval=10
  UserKnownHostsFile=/dev/null
