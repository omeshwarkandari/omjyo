Enable Authentication:
We can hide secret credentials "username" and "password" by using authetication for terraform
plan/apply/destroy rather than using the hard coded values, by refactoring the variable.tf 
and dbinstance.tf configuration to remove hard coded database "username" and "password".

If you were to run terraform apply or plan then Terraform would prompt you for values
for these new variables since you haven't assigned defaults to them.




Automate the authentication by setting values with a .tfvars file:
Entering values manually is time consuming and error prone so lest add .tfvars file to pick the
usename and password.
Terraform supports setting variable values with variable definition (.tfvars) files.
You can use multiple variable definition files, and many practitioners use a separate file to set sensitive or secret values.

Create a new file called secret.tfvars to assign values to the new variables.

$ nano secret.tfvars
db_username = "test"
db_password = "password"


$ terraform apply -var-file="secret.tfvars"

$ terraform destroy -var-file="secret.tfvars"



