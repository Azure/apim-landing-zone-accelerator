# Instructions

To take advantage of this Azure DevOps pipeline definition do the following:

- Place the pipeline.yml and apim-eslz-vars.yml in the same folder in a repo in your Azure DevOps project
- Create a new pipeline based on an Azure DevOps repo, choose to use an existing template and pick the pipeline.yml that you just created in your local repo
- Edit the apim-eslz-vars.yml file to configure this for your own environment and convenience.
- Hit validate in your pipeline to check correctness and once OK, run it!
