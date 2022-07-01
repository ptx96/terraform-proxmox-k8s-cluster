# These "locals" help us manipulating string type variables,
# letting us sum the ip last bit and the vm counter.index 
# avoiding to spoil code readability inside resources section

locals {
  service_substring      = element(split(".", "${var.ci_ip0["service"]}"), 3)
  service_number         = tonumber(element(split(".", "${var.ci_ip0["service"]}"), 3))
  controlplane_substring = element(split(".", "${var.ci_ip0["controlplane"]}"), 3)
  controlplane_number    = tonumber(element(split(".", "${var.ci_ip0["controlplane"]}"), 3))
  worker_substring       = element(split(".", "${var.ci_ip0["worker"]}"), 3)
  worker_number          = tonumber(element(split(".", "${var.ci_ip0["worker"]}"), 3))
}

resource "proxmox_vm_qemu" "srv_vm" {
  count       = var.vms_number["service"]
  name        = "${var.vm_prefix}-srv-${count.index}"
  desc        = "${var.vm_prefix}-srv-vm"
  vmid        = var.vms_id["service"] + count.index
  target_node = "labs"
  pool        = var.vm_pool
  clone       = var.vms_template["service"]
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  qemu_os     = "l26"
  agent       = 1
  boot        = "order=scsi0"

  # CLOUD INIT PROVISIONING
  os_type      = "cloud-init"
  ciuser       = var.ci_user
  cipassword   = var.ci_password
  searchdomain = var.dns_domain
  nameserver   = var.dns_servers
  ipconfig0    = join("", ["ip=", trimsuffix(var.ci_ip0["service"], local.service_substring), local.service_number + count.index, "/", var.ci_length0, ",gw=", var.ci_gateway0])
  sshkeys      = var.ssh_keys

  disk {
    size     = "20G"
    format   = "qcow2"
    type     = "scsi"
    storage  = var.disk_storage
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }
}

resource "proxmox_vm_qemu" "controlplane_vm" {
  count       = var.vms_number["controlplane"]
  name        = "${var.vm_prefix}-controlplane-0${count.index}"
  desc        = "${var.vm_prefix}-controlplane-vm"
  vmid        = var.vms_id["controlplane"] + count.index
  target_node = "labs"
  pool        = var.vm_pool
  clone       = var.vms_template["controlplane"]
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  qemu_os     = "l26"
  agent       = 1
  boot        = "order=scsi0"

  # CLOUD INIT PROVISIONING
  os_type      = "cloud-init"
  ciuser       = var.ci_user
  cipassword   = var.ci_password
  searchdomain = var.dns_domain
  nameserver   = var.dns_servers
  ipconfig0    = join("", ["ip=", trimsuffix(var.ci_ip0["controlplane"], local.controlplane_substring), local.controlplane_number + count.index, "/", var.ci_length0, ",gw=", var.ci_gateway0])
  sshkeys      = var.ssh_keys

  disk {
    size     = "20G"
    format   = "qcow2"
    type     = "scsi"
    storage  = var.disk_storage
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }
}

resource "proxmox_vm_qemu" "worker_vm" {
  count       = var.vms_number["worker"]
  name        = "${var.vm_prefix}-worker-0${count.index}"
  desc        = "${var.vm_prefix}-worker-vm"
  vmid        = var.vms_id["worker"] + count.index
  target_node = "labs"
  pool        = var.vm_pool
  clone       = var.vms_template["worker"]
  cores       = 2
  sockets     = 1
  cpu         = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  qemu_os     = "l26"
  agent       = 1
  boot        = "order=scsi0"

  # CLOUD INIT PROVISIONING
  os_type      = "cloud-init"
  ciuser       = var.ci_user
  cipassword   = var.ci_password
  searchdomain = var.dns_domain
  nameserver   = var.dns_servers
  ipconfig0    = join("", ["ip=", trimsuffix(var.ci_ip0["worker"], local.worker_substring), local.worker_number + count.index, "/", var.ci_length0, ",gw=", var.ci_gateway0])
  sshkeys      = var.ssh_keys

  disk {
    size     = "20G"
    format   = "qcow2"
    type     = "scsi"
    storage  = var.disk_storage
    iothread = 0
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  lifecycle {
    ignore_changes = [
      network
    ]
  }
}
