# Enterprise-Scale-APIM
![image](https://user-images.githubusercontent.com/37597107/123334898-9911f180-d4f8-11eb-8647-03a3e849a7a1.png)

- This is the way you can execute bicep deployment;
az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev  
