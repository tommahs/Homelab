#! /bin/bash
for vm in $(sudo virsh list --all|grep ceph|awk '{print $2}'); do sudo virsh shutdown $vm;done
sleep 10
echo "Waiting on shutdown"
for vm in $(sudo virsh list --all|grep ceph|awk '{print $2}'); do sudo qemu-img resize /data/libvirt/images/homelab_ceph/$vm.qcow2 +40G && sudo virsh start $vm;done
sleep 20
echo "Waiting on SSH"
for vm in $(sudo virsh list --all|grep ceph|awk '{print $2}'); do ssh -k -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null arch@$(sudo virsh domifaddr $vm|awk '{print $4}'|cut -d '/' -f1|grep -v 'Protocol\|^$') "sudo growpart /dev/vda 3 && sudo resize2fs /dev/vda3";done

