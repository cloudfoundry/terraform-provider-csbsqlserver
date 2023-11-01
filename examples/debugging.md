## Debugging the provider using GoLang and Delve

> Warning: SO Linux is used in this example. Use the correct architecture for your system.


1. Create a folder where we will build the binary that will be recognized by Terraform as a provider or plugin
    * mkdir -p /home/<YOUR_HOME_FOLDER_HERE>/.terraform.d/plugins/cloudfoundry.org/cloud-service-broker/csbsqlserver/1.0.0/linux_amd64
    * Attention: the folder sets the namespace used in the example.tf file.

2. Create a Run/Debug configuration to build the TF provider: Type Go Build

* Run kind: File
* Files: `/home/<YOUR_HOME_FOLDER_HERE>/workspace/csb/csb-brokerpak-aws/providers/terraform-provider-csbsqlserver/main.go`
* Output directory: `/home/<YOUR_HOME_FOLDER_HERE>/.terraform.d/plugins/cloudfoundry.org/cloud-service-broker/csbsqlserver/1.0.0/linux_amd64`
* Run after build: No
* Working directory: `/home/<YOUR_HOME_FOLDER_HERE>/workspace/csb/terraform-provider-csbsqlserver`
* Go tool arguments: `-gcflags="all=-N -l" -o /home/<YOUR_HOME_FOLDER_HERE>/.terraform.d/plugins/cloudfoundry.org/cloud-service-broker/csbsqlserver/1.0.0/linux_amd64/terraform-provider-csbsqlserver_v1.0.0`
* Program arguments: `-debug=true`



3. Create Run/Debug configuration to execute the provider using the debugger delve: Type Shell Script

* Script text: `dlv --listen=:23456 --headless=true --api-version=2 --accept-multiclient exec ./terraform-provider-csbsqlserver_v1.0.0 -- -debug=true`
* Working directory: `/home/<YOUR_HOME_FOLDER_HERE>/.terraform.d/plugins/cloudfoundry.org/cloud-service-broker/csbsqlserver/1.0.0/linux_amd64`
* Execute in the terminal: Yes
* Before launch: Add the Run configuration created in the previous section


4. Create a Run/Debug configuration to listen to the Go process in the background: Type Go Remote
* Host: localhost
* Port: 23456
* On disconnect: Stop remote Delve process.

5. SQL Server running:

* Docker [docs](https://learn.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-ver16&pivots=cs1-bash)
* Execute SQL Server: `docker run -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD=<YOUR_SUPERADMIN_PASSWORD_HERE> --name <YOUR_DOCKER_CONTAINER_NAME_HERE> -p 1433:1433 mcr.microsoft.com/mssql/server:2022-latest`
* Connect to the server:
    * `docker exec -it  <YOUR_DOCKER_CONTAINER_NAME_HERE> "bash"`
    * `/opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P "<YOUR_DOCKER_CONTAINER_NAME_HERE>"`

6. Debugging

   1. Run the SQL Server. Read step number 4.
   2. Run the Shell Script debug configuration created in step number 2.
   3. Run the configuration Go Remote created in step number 4.
   4. In the folder examples, modify the `example.tf` file. Change `YOUR_ADMIN_PASSWORD_HERE` and use the selected password introduced in the step number 4: `<YOUR_SUPERADMIN_PASSWORD_HERE>`
   5. Create a breakpoint in the code you want to debug.
   6. In the terminal created by the shell script must be a variable associated with the TF process we want to debug.
      Copy and export it in the same terminal we will execute the terraform commands suggested in the next step.
      Example:
      ```shell
       Provider started. To attach Terraform CLI, set the TF_REATTACH_PROVIDERS environment variable with the following:
       TF_REATTACH_PROVIDERS='{"cloudfoundry.org/cloud-service-broker/csbsqlserver":{"Protocol":"grpc","ProtocolVersion":5,"Pid":191239,"Test":true,"Addr":{"Network":"unix","String":"/tmp/plugin934126461"}}}'
      ```
      ```shell
      export TF_REATTACH_PROVIDERS='{"cloudfoundry.org/cloud-service-broker/csbsqlserver":{"Protocol":"grpc","ProtocolVersion":5,"Pid":191239,"Test":true,"Addr":{"Network":"unix","String":"/tmp/plugin934126461"}}}'
      ```
   8. Run `terraform init`, `terraform plan` and `terraform apply` to execute the client.