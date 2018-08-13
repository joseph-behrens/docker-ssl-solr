# Run docker on a Windows container with SSL

## Description

This will create a container using a self-signed certificate that's trusted by both the host and the container.  

The primary use case is for Sitecore development. The plan is to create other conainers for Sitecore roles and have this as a service in the full cluster.  

The installation will modify your hosts file with the IP of the container to be able to use a friendly URL.

## Install

- [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) is required and must be running in Windows mode.
- Clone the repository `git clone https://github.com/joseph-behrens/docker-ssl-solr.git`
- Open PowerShell and cd to the directory where the code has been cloned.
- Open setup-container.ps1 in an editor. Change `$solrHost = "dockersolr"` to replace "dockersolr" with what you'd like to use for your site. This will be used as your URL to access the admin site. If the default is kept it would be [https://dockersolr:8983](https://dockersolr:8983)
- `$StaticIP` will need to be set do a different address in the subnet if this is going to run in parallel with other instances of this container.
- If `$StaticIp` is change in the setup-container.ps1 file you must also update the ip in the docker-compose.yml file.
- If `$solrHost` is changed in the setup-container.ps1 file you must also update the name in the solr-install.ps1 file.
- Run the setup script `.\setup-container.ps1` to install, this will also run the container in the session. You can then go to the solr admin site. The shell needs to stay open for the application to run in this mode.
- Press `ctrl+c` in the shell to stop the container.
- User `docker-compose down` to clean up the network, image and container.
- To run the container again after the initial installation go to the cloned directory in a shell and run `docker-compose up`