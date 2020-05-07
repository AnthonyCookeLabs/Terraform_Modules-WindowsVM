# Terraform Windows VM Module

<br>Terrafrom module for creating:
<br>
<br>- Windows VM
<br>- Vnet / Subnet
<br>- NICS
<br>- Public IP
<br>- NSG (3389 Open)
<br>- Tags 
<br>
<br>Input variables include:
<br>
<br>- RG Name
<br>- Resource Group location
<br>- Prefix (included in all resource names)
<br>- Environment (included in all resource names)
<br>
<br>Optional input Variables
<br>
<br>- Address_prefix (optional - Default: 10.0.2.0/24)
<br>- address_space (optional - Default: "10.0.0.0/16")


variable "address_space" {
    type = list
    default = ["10.0.0.0/16"]

<br>module "windowsVM" {
<br>  source = "./winvm"
<br>
<br>  windowsvmrgname = var.rgname
<br>  location = "westus"
<br>  prefix = "tesst"
<br>  environment = "uat"
<br>  
<br>}