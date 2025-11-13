# validate if wants to proceed

source "./.env"
echo "Using TFVARS: ../../apim-baseline/terraform/${ENVIRONMENT_TAG}.tfvars"

echo "Do you want to destroy the deployment? (y/n)"
read -r response

if [[ $response =~ ^[Yy]$ ]]; then

    cd ../../apim-baseline/terraform 
    terraform destroy --auto-approve -var-file="${ENVIRONMENT_TAG}.tfvars"
else
	echo "Exiting..."
fi

