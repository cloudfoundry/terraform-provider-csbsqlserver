# terraform-provider-csbsqlserver

This is a highly specialised Terraform provider designed to be used exclusively with the 
[Cloud Service Broker](https://github.com/cloudfoundry-incubator/cloud-service-broker) ("CSB")
to manage binding and unbinding operations in a SQL Server instance.


## Usage
```terraform
terraform {
   required_providers {
      csbsqlserver = {
         source  = "cloudfoundry.org/cloud-service-broker/csbsqlserver"
         version = "1.0.0"
      }
   }
}

provider "csbsqlserver" {
   server   = "localhost"
   port     = 1433
   username = "SA"
   password = "YOUR_ADMIN_PASSWORD_HERE"
   database = "mydb"
   encrypt  = "disable"
}

resource "csbsqlserver_binding" "binding" {
   username = "test_user"
   password = "test_password"
   roles    = ["db_ddladmin", "db_datareader", "db_datawriter", "db_accessadmin"]
}

```

## Releasing
To create a new GitHub release, decide on a new version number [according to Semantic Versioning](https://semver.org/), and then:
1. Create a tag on the main branch with a leading `v`:
   `git tag vX.Y.X`
1. Push the tag:
   `git push --tags`
1. Wait for the GitHub action to run GoReleaser and create the new GitHub release

