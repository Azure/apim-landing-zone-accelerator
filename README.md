# Enterprise-Scale-APIM
Architectural Diagram:
![image](https://user-images.githubusercontent.com/37597107/133897334-13764cec-c279-4517-8218-a365c1524388.png)
Resources Deployed:
![image](https://user-images.githubusercontent.com/37597107/133897343-220a2e78-4f5a-4623-87bd-388a02949b96.png)


- This is the way you can execute bicep deployment;

az deployment sub create --location eastus --name am --template-file main.bicep --parameters workloadName=am environment=dev  
