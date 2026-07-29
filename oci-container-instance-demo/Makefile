.PHONY: init fmt validate plan apply deploy output smoke destroy

init:
	terraform init

fmt:
	terraform fmt -recursive

validate: init
	terraform validate

plan: validate
	terraform plan

apply: validate
	terraform apply

deploy:
	./scripts/deploy.sh

output:
	terraform output

smoke:
	./scripts/smoke-test.sh

destroy:
	./scripts/destroy.sh
