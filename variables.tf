  
variable "location" {}

variable "prefix" {
    type = string
    default = "test"
}

variable "windowsvmrgname" {
    type = string
    default = "test"
}

variable "environment" {
    type = string
    default = "prod"
}

variable "tags" {
    type = map

    default = {
        Environment = "Prod"
          }
}

variable "address_prefix" {
    type = list
    default = ["10.0.2.0/24"]
}

variable "address_space" {
    type = list
    default = ["10.0.0.0/16"]
}


