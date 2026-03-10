variable "project"     { type = string }
variable "environment" { type = string }
variable "location"    { type = string; default = "East US" }
variable "tags"        { type = map(string); default = {} }
