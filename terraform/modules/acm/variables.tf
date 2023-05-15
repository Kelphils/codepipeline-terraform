// Create a variable for your domain name because we'll be using it a lot.
# variable "www_domain_name" {
#   default = "www.${var.root_domain_name}"
# }

// We'll also need the root domain (also known as zone apex or naked domain).
variable "root_domain_name" {
  type    = string
  default = "kelyinc.xyz"
}

# variable "subdomain_name" {
#   type = string
# }
