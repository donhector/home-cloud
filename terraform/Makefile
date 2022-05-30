init:
	terraform init

plan-k3s-mgmt: init
	terraform workspace select k3s-mgmt && terraform plan -var-file environments/k3s-mgmt.tfvars

apply-k3s-mgmt: init
	terraform workspace select k3s-mgmt && terraform apply -auto-approve -var-file envs/k3s-mgmt.tfvars

destroy-k3s-mgmt: init
	terraform workspace select k3s-mgmt && terraform destroy -auto-approve -var-file envs/k3s-mgmt.tfvars
	