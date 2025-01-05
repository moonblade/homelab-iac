module "k3svm" {
  source = "../../terraform-modules/proxmox-vm-qemu"

  vmid        = 301
  target_node = "athena"
  name        = "k3svm"
  clone       = "nixos-base"
  cores       = 2
  memory      = 4096
  desc        = "VM for k3s"
  sshkeys     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCvpzgPlIDIhTtEMK7epWJKL+8wLu+t/V5Pl/+r8+CH/FqedsZZoWfJQ+to/MDC/WmBby8vVEV0Qfym/pf89w+ZgKI0rUNOPhKjtsLs2NGMjIFE8uvgPD8AXRP2eUBUfvpUaf3ycAFZh6KMBerkinANBH98qZKlFkIphC2gcw94jxWUN7VOwMnMIdqmYGpCkmufFWl+mqA5Sq7eCqkLyTPz6n4cs62faYTYayYbKjgP09RudZ6HRKezJixPM1SUv7A+rflPIDIwvPvtQaZUVv+3OQ9EEJh/7Qg/+yKHZbnn5mtd5Vd1NgFVs+1+meVgibsK3lZu6cce7qVCHbfnXU8enVi1KpT+YgXLaRmqn/WjPy5OoCoieotYxL6nrufg0qcFoEevx6BHnUC0DoKkJ33i7UlEN5CX/63vQQJaML0xbt/pCZ7KHQQxj0HoN9Y/KKtR/kfG+4dQ+EJb96XpSqSLqpcUjn99q6zCPYqHzof9BBu8gnT5Xogjl2LwTyw/5E3LScc9pnG12ETGTRjlEyPkFwvZD7XM96K+9gbusE+KCzzZpuvlCLHE+8EupqsHZWqWOqVXNcozyMhS4Cc3YlOPa/NzpsC3hXvHkCYKdtSh2yPRIudY8Y2lWM15joGnQBrvMIpSozWlSkO5Mg/sh6Wd3w9uZn4gHwxCWV0gxRh5AQ== mb work lap rsa"
  ipv4_addr   = "192.168.1.150/24"
  ipv4_gw     = "192.168.1.1"
  disk_size   = "200G"
  tags        = "k3s"
  vm_state    = "stopped"
}
