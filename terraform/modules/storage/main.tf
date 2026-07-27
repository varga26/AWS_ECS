resource "aws_efs_file_system" "prometheus_data" {
  creation_token   = "prometheus-data"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  
  tags = {
    Name = "prometheus-data"
  }
}

resource "aws_efs_mount_target" "prometheus_mt" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.prometheus_data.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [var.efs_sg_id]
}

resource "aws_efs_access_point" "prometheus_ap" {
  file_system_id = aws_efs_file_system.prometheus_data.id

  posix_user {
    gid = 65534
    uid = 65534
  }

  root_directory {
    path = "/prometheus"
    creation_info {
      owner_gid   = 65534
      owner_uid   = 65534
      permissions = "0755"
    }
  }
}
