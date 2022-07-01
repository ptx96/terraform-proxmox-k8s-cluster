# Kubeadm template

This terraform module is based on Telmate [terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox);\
it aims to deploy a "kubeadm ready" infrastructure on top of Proxmox VE platform with the use of a gitops methodology.

## Prerequisites

* Terraform >= v1.1.0
* Terraform Cloud API token
* Proxmox user credentials

### Configuration

First of all, clone this repository:

```bash
git clone https://github.com/clastix/labs-wiki
```

then, move to [kubeadm-template](https://github.com/clastix/labs-wiki/tree/master/provisioning/terraform/kubeadm-template) folder;\
here, create a *.auto.tfvars file and fill it in accordance with the [vars.tf](https://github.com/clastix/labs-wiki/blob/master/provisioning/terraform/kubeadm-template/vars.tf) file, for example:

```hcl
~/labs-wiki/provisioning/terraform$ cat kubeadm.auto.tfvars

pm_api_url = "https://labs.foo.io:8006/api2/json"
pm_user = "place.holder@pam"
pm_password = ""
pm_parallel = 6
ci_gateway0 = "192.168.30.1"
ci_ip0 = {
  "service"      = "192.168.30.100"
  "controlplane" = "192.168.30.110"
  "worker"       = "192.168.30.120"
}
disk_storage  = "local"
vms_id = {
  "service"      = 350
  "controlplane" = 310
  "worker"       = 320
}
vm_prefix = "bar"
vm_pool = "bar"
network_bridge = "bar-vmbr0"
ssh_keys = <<EOF
ssh-rsa MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgHfa38LJQJQofhqhSaDJcIfWwKlQieWAJ3bHc6hN0gUNejAU+pp/LsOWaY22RfUhdCpQ5+/hGhSEmpFwxxLhY+HwFiJrDhvrDdH6veebLSV9cLsyZYoGKNEja7NAoWSBgtU0IL/Z2zqnbTcI5przJZ2XYr9zHs/TLNX6eBmhSMg1AgMBAAE= place.holder@clastix.io
EOF
# keep an empty line after EOF
```

**N.B.**: some variables are mandatory, such as those of the proxmox server credentials, others will be filled by default; take a look at the Proxmox Provider [documentation](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs) for further details.

## Quickstart 

First of all, make sure you are logged into the corporate terraform cloud through user / team api token:

```bash
~/labs-wiki/provisioning/terraform$ terraform login

Terraform will request an API token for app.terraform.io using your browser.

If login is successful, Terraform will store the token in plain text in
the following file for use by subsequent commands:
    /home/ptx/.terraform.d/credentials.tfrc.json

Do you want to proceed?
  Only 'yes' will be accepted to confirm.

  Enter a value: yes

[...]

---------------------------------------------------------------------------------

Generate a token using your browser, and copy-paste it into this prompt.

Terraform will store the token in plain text in the following file
for use by subsequent commands:
    /home/ptx/.terraform.d/credentials.tfrc.json

Token for app.terraform.io:
  Enter a value: <INSERT HERE YOUR API TOKEN>


Retrieved token for user api-team_498179

---------------------------------------------------------------------------------

                                          -
                                          -----                           -
                                          ---------                      --
                                          ---------  -                -----
                                           ---------  ------        -------
                                             -------  ---------  ----------
                                                ----  ---------- ----------
                                                  --  ---------- ----------
   Welcome to Terraform Cloud!                     -  ---------- -------
                                                      ---  ----- ---
   Documentation: terraform.io/docs/cloud             --------   -
                                                      ----------
                                                      ----------
                                                       ---------
                                                           -----
                                                               -
```

Choose a target workspace inside the [backend.tf](https://github.com/clastix/labs-wiki/blob/master/provisioning/terraform/kubeadm-template/backend.tf) and proceed to download the necessary terraform providers with `terraform init`; \

the output should be similar to the following:

```bash
~/labs-wiki/provisioning/terraform$ terraform init

Initializing the backend...

[...]
Initializing provider plugins...
- Finding telmate/proxmox versions matching "2.9.6"...
- Finding hashicorp/local versions matching "2.1.0"...
- Installing telmate/proxmox v2.9.6...
- Installed telmate/proxmox v2.9.6 (self-signed, key ID A9EBBE091B35AFCE)
- Installing hashicorp/local v2.1.0...
- Installed hashicorp/local v2.1.0 (signed by HashiCorp)

Terraform has been successfully initialized!
[...]
```

afterwards, make sure that the VMs' resources located in the [main.tf](https://github.com/clastix/labs-wiki/blob/master/provisioning/terraform/kubeadm-template/main.tf) are the desired ones:

```hcl
[...]
  cores                     = 2
  sockets                   = 1
  cpu                       = "host"
  memory                    = 4096
[...]
```

then, verify that the execution plan is the one you want with `terraform plan`:
```hcl
[...]
~/labs-wiki/provisioning/terraform/kubeadm-template$ terraform plan
proxmox_vm_qemu.controlplane_vm[2]: Refreshing state... [id=labs/qemu/312]
proxmox_vm_qemu.worker_vm[2]: Refreshing state... [id=labs/qemu/322]
proxmox_vm_qemu.controlplane_vm[0]: Refreshing state... [id=labs/qemu/310]
proxmox_vm_qemu.controlplane_vm[1]: Refreshing state... [id=labs/qemu/311]
proxmox_vm_qemu.worker_vm[1]: Refreshing state... [id=labs/qemu/321]
proxmox_vm_qemu.worker_vm[0]: Refreshing state... [id=labs/qemu/320]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # proxmox_vm_qemu.srv_vm[0] will be created
  + resource "proxmox_vm_qemu" "srv_vm" {
      + additional_wait           = 15
      + agent                     = 1
      + balloon                   = 0
      + bios                      = "seabios"
      + boot                      = "order=scsi0"
      + bootdisk                  = (known after apply)
      + cipassword                = (sensitive value)
      + ciuser                    = "clastix"
      + clone                     = "ubuntu-vanilla"
      + clone_wait                = 15
      + cores                     = 2
      + cpu                       = "host"
      + default_ipv4_address      = (known after apply)
      + define_connection_info    = true
      + desc                      = "bar-srv-vm"
      + force_create              = false
      + full_clone                = true
      + guest_agent_ready_timeout = 60
      + hotplug                   = "network,disk,usb"
      + id                        = (known after apply)
      + ipconfig0                 = "ip=192.168.30.100/24,gw=192.168.30.1"
      + kvm                       = true
      + memory                    = 4096
      + name                      = "bar-srv-00"
      + nameserver                = (known after apply)
      + numa                      = false
      + onboot                    = true
      + os_type                   = "cloud-init"
      + preprovision              = true
      + reboot_required           = (known after apply)
      + scsihw                    = "virtio-scsi-pci"
      + searchdomain              = (known after apply)
      + sockets                   = 1
      + ssh_host                  = (known after apply)
      + ssh_port                  = (known after apply)
[...]
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  ~ srv_ip_addr = [
      + (known after apply),
    ]

```

now, you can safely apply the stack with `terraform apply` :
```hcl
~/labs-wiki/provisioning/terraform/kubeadm-template$ terraform apply
proxmox_vm_qemu.worker_vm[0]: Refreshing state... [id=labs/qemu/320]
proxmox_vm_qemu.worker_vm[2]: Refreshing state... [id=labs/qemu/322]
proxmox_vm_qemu.controlplane_vm[0]: Refreshing state... [id=labs/qemu/310]
proxmox_vm_qemu.controlplane_vm[2]: Refreshing state... [id=labs/qemu/312]
proxmox_vm_qemu.controlplane_vm[1]: Refreshing state... [id=labs/qemu/311]
proxmox_vm_qemu.worker_vm[1]: Refreshing state... [id=labs/qemu/321]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
[...]
```
and confirm it writing `yes`:
```hcl
[...]
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

proxmox_vm_qemu.srv_vm[0]: Creating...
proxmox_vm_qemu.srv_vm[0]: Still creating... [10s elapsed]
proxmox_vm_qemu.srv_vm[0]: Still creating... [20s elapsed]
proxmox_vm_qemu.srv_vm[0]: Still creating... [30s elapsed]
proxmox_vm_qemu.srv_vm[0]: Still creating... [40s elapsed]
proxmox_vm_qemu.srv_vm[0]: Still creating... [50s elapsed]
proxmox_vm_qemu.srv_vm[0]: Still creating... [1m0s elapsed]
proxmox_vm_qemu.srv_vm[0]: Creation complete after 1m9s [id=labs/qemu/350]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

srv_ip_addr = [
  "192.168.30.150",
]
```

finally, to tear down the entire infrastructure, simply throw `terraform destroy` and, as seen before, confirm it with `yes`:
```hcl
~/labs-wiki/provisioning/terraform/kubeadm-template$ terraform destroy

[...]

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

proxmox_vm_qemu.srv_vm[0]: Destroying... [id=labs/qemu/350]
proxmox_vm_qemu.controlplane_vm[0]: Destroying... [id=labs/qemu/310]
proxmox_vm_qemu.controlplane_vm[1]: Destroying... [id=labs/qemu/311]
proxmox_vm_qemu.worker_vm[1]: Destroying... [id=labs/qemu/321]
proxmox_vm_qemu.controlplane_vm[2]: Destroying... [id=labs/qemu/312]
proxmox_vm_qemu.worker_vm[2]: Destroying... [id=labs/qemu/322]
proxmox_vm_qemu.worker_vm[0]: Destroying... [id=labs/qemu/320]
proxmox_vm_qemu.controlplane_vm[1]: Destruction complete after 5s
proxmox_vm_qemu.srv_vm[0]: Destruction complete after 5s
proxmox_vm_qemu.controlplane_vm[2]: Destruction complete after 5s
proxmox_vm_qemu.worker_vm[1]: Destruction complete after 7s
proxmox_vm_qemu.worker_vm[0]: Destruction complete after 7s
proxmox_vm_qemu.controlplane_vm[0]: Destruction complete after 7s
proxmox_vm_qemu.worker_vm[2]: Destruction complete after 10s

Destroy complete! Resources: 8 destroyed.
```

## Troubleshooting

The provider is able to output detailed logs upon request; this feature could be used to help investigate bugs. 

To activate it, write the following code inside [provider.tf](https://github.com/clastix/labs-wiki/blob/master/provisioning/terraform/kubeadm-template/provider.tf):
```hcl
provider "proxmox" {
  pm_log_enable = true
  pm_log_file = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default = "debug"
    _capturelog = ""
  }
}
```

### Known bugs

The provider is not yet very stable; during the creation phase of the VMs, you may encounter errors like:

```
│ Error: Plugin did not respond
│
│ with proxmox_vm_qemu.controlplane_vm [2],
│ on main.tf line 60, in resource "proxmox_vm_qemu" "controlplane_vm":
│ 60: resource "proxmox_vm_qemu" "controlplane_vm" {
│
│ The plugin encountered an error, and failed to respond to the
│ plugin. (* GRPCProvider) .ApplyResourceChange call. The plugin logs may
│ contain more details.
```

Even in the middle of the process (resulting in a dirty deploy).

In this case, make sure the VMs are not in a bootloop and proceed to execute a terraform destroy; if necessary, erase the remaining residues by hand.

Finally, cast a terraform apply again (and cross your fingers)