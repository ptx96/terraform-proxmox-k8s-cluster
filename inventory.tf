locals {

  services = [
    for i in proxmox_vm_qemu.srv_vm : {
      name      = i.name
      public_ip = i.ssh_host
    }
  ]

  controlplanes = [
    for i in proxmox_vm_qemu.controlplane_vm : {
      name      = i.name
      public_ip = i.ssh_host
    }
  ]

  workers = [
    for i in proxmox_vm_qemu.worker_vm : {
      name      = i.name
      public_ip = i.ssh_host
    }
  ]

  inventory = templatefile("inventory.tpl", {
    all_nodes          = concat(local.services, local.controlplanes, local.workers)
    srv_nodes          = local.services
    controlplane_nodes = local.controlplanes
    worker_nodes       = local.workers
    admin_user         = var.ci_user
  })

}

output "inventory" {
  value = local.inventory
}
