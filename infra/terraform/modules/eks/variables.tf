variable "region" { 
  type = string 
}

variable "cluster_name" { 
  type = string 
 }

variable "private_subnet_ids" { 
  type = list(string)
}

variable "cluster_role_arn" { 
    type = string 
}

variable "project" {
     type = string 
}

variable "owner" { 
    type = string 
}
