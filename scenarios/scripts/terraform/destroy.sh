# validate if wants to proceed

echo "Do you want to destroy the deployment? (y/n)"
read -r response

if [[ $response =~ ^[Yy]$ ]]; then
    source "./.env"
    echo "Using TFVARS: ${ENVIRONMENT_TAG}.tfvars"
    cd ../../apim-baseline/terraform 
    terraform destroy --auto-approve -var-file="${ENVIRONMENT_TAG}.tfvars"
else
	echo "Exiting..."
fi

