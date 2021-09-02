/**** SIMPLE LOOP ****/

# note toset()

# The given "for_each" argument value is unsuitable: the "for_each" argument
# must be a map, or set of strings, and you have provided a value of type tuple.

module "module_1" {
  for_each = toset(["100", "200"])
  source   = "./modules/account_module"

  business_unit = each.key #or each.value
}

/**** USING LOCALS ****/

locals {
  accounts = {
    "account-1" = {
      first_name = "john"
      last_name  = "smith"
    }
    "account-2" = {
      first_name = "james"
      last_name  = "brown"
    }
  }
}

module "module_2" {
  for_each = local.accounts
  source   = "./modules/account_module"

  account_id = each.key
  name       = "${each.value.first_name} ${each.value.last_name}"
}

/**** SIMPLE LOOP ****/

locals {
  complex_accounts = {
    accounts = [
      {
        name           = "john smith"
        account_id     = "account-1"
        business_units = ["100", "200", "500"]
      },
      {
        name           = "james brown"
        account_id     = "account-2"
        business_units = ["300", "400", "500"]
      }
    ]
  }
}

/**** FOR EACH SUB LOOP ****/

module "module_3" {
  for_each = toset(
    [for account in local.complex_accounts.accounts :
      account.account_id
    ]
  )
  # creates ["account-1", "account-2"]
  source = "./modules/account_module"

  account_id = each.key
}

/**** CONDITIONAL ****/

module "module_4" {
  for_each = toset(
    [for account in local.complex_accounts.accounts :
      account.account_id if account.name == "john smith"
    ]
  )
  # creates ["account-1"]

  source = "./modules/account_module"

  account_id = each.value
}

/**** CONDITIONAL - sub array ****/

module "module_5" {
  for_each = toset(
    [for account in local.complex_accounts.accounts :
      account.account_id if contains(account.business_units, "300")
    ]
  )
  # creates ["account-2"]

  source = "./modules/account_module"

  account_id = each.value
}

/**** MAP LOOP ****/

locals {
  the_val = { for account in local.complex_accounts.accounts :
    account.account_id => { # => is used for defining maps, could as easily be string => string
      name = account.name
    }
  }
}
module "module_6" {
  for_each = local.the_val
  # creates { "account-1" = { name = "john smith" } "account-2" = { name = "james smith" } }

  source = "./modules/account_module"

  account_id = each.key
  name       = each.value.name
}

/**** MULTI-LAYER LOOP ****/

# flatten
# [["a"],["b"],["c"]] to
# ["a","b","c"]

module "module_7" {
  for_each = toset(
    distinct(
      flatten(
        [for account in local.complex_accounts.accounts :
          [for business_unit in account.business_units : business_unit
          ]
        ]
      )
    )
  )
  # creates ["100", "200", "300", "400", "500"]

  source = "./modules/account_module"

  business_unit = each.key #or each.value
}

/**** MULTI-LAYER STRING ****/

module "module_8" {
  for_each = toset(
    flatten(
      [for account in local.complex_accounts.accounts :
        [for business_unit in account.business_units :
          "${account.account_id}~${business_unit}"
        ]
      ]
    )
  )

  # creates 
  # [
  #   "account-1~100", "account-1~200", "account-1~500"
  #   "account-2~300", "account-2~400, "account-2~500"
  # ]

  source        = "./modules/account_module"
  account_id    = split("~", each.key)[0] # account_id
  business_unit = split("~", each.key)[1] # business_unit
}
