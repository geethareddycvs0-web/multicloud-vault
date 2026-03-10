variable "project"             { type = string }
variable "environment"         { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "allowed_ips"         { type = list(string); default = [] }
variable "tags"                { type = map(string); default = {} }
