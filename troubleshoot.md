# Common issues we ran into during execution and fixes. 

###  Disk Size Issue and Resolution

#### Problem
While building the Triton Inference Server Docker image, the build failed with: no space left on device.

This happened because the EC2 root volume was only **15 GB**, and the Triton image layers (CUDA + runtime) consumed more than the available free space.

---

#### Solution: Growing the Filesystem
We increased the root volume size to **30 GB** in the AWS Console, then expanded the partition and filesystem inside the instance:
```
# Expand partition 1 on the NVMe root disk
sudo growpart /dev/nvme0n1 1

# Resize the filesystem to use the new partition size
sudo resize2fs /dev/root
```

#### Monitor doscker disk usage 

# Show Docker disk usage
docker system df

# Clean up unused images, containers, and volumes
docker system prune -af
docker volume prune -f

# Clear build cache
docker builder prune -af

#### GPU Node debug : 

- check system logs - dmesg | grep -i nvidia
- driver module is loaded - lsmod | grep nvidia

