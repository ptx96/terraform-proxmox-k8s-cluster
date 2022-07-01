[all]
%{ for node in all_nodes }${node.name} ansible_host=${node.public_ip} ansible_user=${admin_user} #ansible_ssh_private_key_file=inventory/ssh.key
%{ endfor }

# ## configure a bastion host if your nodes are not directly reachable
# [bastion]
# %{ for node in srv_nodes }${node.name} ansible_host=${node.public_ip} ansible_user=${admin_user} #ansible_ssh_private_key_file=inventory/ssh.key
# %{ endfor }

[kube_control_plane]
%{ for node in controlplane_nodes }${node.name}
%{ endfor }

[etcd]
%{ for node in controlplane_nodes }${node.name}
%{ endfor }

[kube-node]
%{ for node in worker_nodes }${node.name}
%{ endfor }

[k8s-cluster:children]
kube_control_plane
kube-node
