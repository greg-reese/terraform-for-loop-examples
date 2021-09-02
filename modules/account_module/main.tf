variable "account_id" {
  default = ""
}

variable "name" {
  default = ""
}

variable "business_unit" {
  default = ""
}

resource "null_resource" "account" {
  count = var.account_id != "" ? 1 : 0
  triggers = {
    account_id = var.account_id
  }
}

resource "null_resource" "name" {
  count = var.name != "" ? 1 : 0
  triggers = {
    name = var.name
  }
}

resource "null_resource" "business_unit" {
  count = var.business_unit != "" ? 1 : 0
  triggers = {
    business_unit = var.business_unit
  }
}
