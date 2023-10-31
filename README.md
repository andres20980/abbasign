## ABB-DevOps-Assignment
# Unique Visitor Counter

This application counts the number of unique visitors storing the IP in database and displays this values.

We use Docker and Docker Compose to test it locally.
It is deployed to Azure using Terraform.


## Getting started
To start this service from scratch using this solution, follow these steps:

Install the necessary tools:
```
Docker
Docker Compose
Azure CLI
Terraform
```
Fork the repo https://github.com/andres20980/abbasign.git in [YOUR_GITHUB_ACCOUNT]

Clone the solution repository:
```
git clone https://github.com/[YOUR_GITHUB_ACCOUNT]/abbasign.git && cd abassign
```
### Local Solution
Build the Docker images for the application:

Go to **app.py and COMMENT Azure UP && UNCOMMENT Docker UP code** (Ctrl + K, Ctrl + U), after that:
```
docker compose up -d abbasign_db
docker compose build
docker compose up abbasign_app
```
_* in case **Error starting userland proxy: listen tcp4 0.0.0.0:5432: bind: address already in use.**_
```
sudo lsof -i tcp:5432
#(copy the PID)
sudo kill PID
```
### Azure
Go to **app.py and COMMENT Docker UP && UNCOMMENT Azure UP code** (Ctrl + K, Ctrl + U), after that:

Deploy the application to Azure WEB App + PostgreSQL Database:
```
cd infra
az login
terraform init
terraform apply
```
After terraform creates the environment, let's deploy de Web App:

_Go to **Azure>abbasign Web App>Deployment Center** and set the Github repo_ https://github.com/[YOUR_GITHUB_ACCOUNT]/abbasign.git

Once the application is deployed, it will be accessible at [https://abbasign.azurewebsites.net]
![External Image](https://raw.githubusercontent.com/andres20980/abbasign/main/abbassign-app-architecture.png)

## CI/CD

When you set up a _source control_ for a Web App in Azure: **GitHub Actions** sets up Continuous Integration (CI) for your application. 

You can see the Workflow here: https://github.com/[YOUR_GITHUB_ACCOUNT]/abbassign/blob/main/.github/workflows/main_abbasign.yml

Here’s what happens:

* **GitHub Actions Workflow Configuration**: You define a workflow in your GitHub repository that specifies the steps to build, test, and deploy your web app. This workflow is automatically triggered when changes are pushed to the repository.

* **Automated Build and Test:** GitHub Actions automatically builds your code based on the defined workflow. It compiles, runs tests, and checks for errors.

* **Deployment:** If the build and tests pass, GitHub Actions deploys your web app to Azure. This ensures that your application is always up-to-date with the latest code changes.

You can see that Workflows in **https://github.com/[YOUR_GITHUB_ACCOUNT]/abbasign/actions**

### Updating the application ###
To update the application, simply make changes to the source code and push them to the master branch of the repository. The GitHub Actions CI/CD pipeline will automatically build, test, and deploy the updated application to Azure.
## How to use the application
The application has two endpoints:

/: This endpoint save the visitor's IP and show a list of unique IP's registered.
/version: This endpoint returns the current app version.

For example, to get the current unique visitor count, you would send the following HTTP request:
```
curl https://abbasign.azurewebsites.net
```
This would return a list of unique IP's registered.

## Monitoring the application
To monitor your Azure Web App, you can follow these steps:

* **Application Insights**: Create an Application Insights resource in the Azure Portal. It monitors availability, performance, and usage of your web apps. Use the Availability pane to set up ping tests.
* **Built-in Monitoring**: Azure App Service provides built-in monitoring functionality for web apps, mobile, and API apps. In the Azure portal, review quotas, metrics, set up alerts, and autoscaling rules based on metrics.
* **Diagnostic Settings**: Configure diagnostic settings to collect platform metrics and logs. Specify which categories of logs to collect for detailed insights.
* **Resource Logs**: Route platform logs and metrics to specific locations using diagnostic settings.

## How to scale the number of servers to take more load
_Attention: Auto-scaling will depend on the price tier of the element in question._
To scale the number of servers to take more load, you can use the Azure App Service Scale Controller. The Scale Controller allows you to automatically scale your App Service instance up or down based on demand.

To enable the Scale Controller, follow these steps:

* Go to the Azure portal.
* Navigate to your App Service instance.
* Click on Scale in the left-hand navigation pane.
* Under Scale Controller, click on Enable.
* Configure the desired scaling settings.
* Once the Scale Controller is enabled, it will automatically scale your App Service instance up or down based on demand.
