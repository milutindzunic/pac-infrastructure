# PAC Frontend
Infrastructure for the PAC 2020 application (Conferencing app)

## Running on Minikube
* First, configure your Minikube with some resources and necessary addons:

    ```
    minikube config set cpus 4
    minikube config set memory 8192
    minikube config set disk-size 50g
    minikube addons enable ingress
    ```

* In order to access the services that will run in Minikube properly, you will need to update your /etc/hosts file to include the following:

    | Address | Host |
    | --------------- | --------------------- |
    | minikube_ip  |  conference.frontend |
    | minikube_ip  |  conference.backend |
    | minikube_ip  |  conference.keycloak |
    | minikube_ip  |  conference.prometheus |
    | minikube_ip  |  conference.grafana |
    | minikube_ip  |  keycloak-http.keycloak.svc.cluster.local |
    | minikube_ip  |  backend.backend |

    Note: Minikube ip can be found by running `minikube ip`.

* PAC Infrastructure expects two Docker images for the frontend and backend services. Pull the projects from https://github.com/milutindzunic/pac-frontend and https://github.com/milutindzunic/pac-backend
and build them as Docker images tagged "pac-frontend" and "pac-backend". Before running Docker build, run `eval $(minikube docker-env)` so that the images are pushed directly to minikube's Docker daemon.

* Go into pac-infrastructure/terraform and run `./install`. This will run terraform and install all the components to Minikube.

* Front end of the application can be accessed at http://conference.frontend.

##### Loading test data

To access and test the application properly, some test data needs to be loaded.

* To load the initial conferencing data, run: `curl -XPOST http://conference.backend/initDB`. The data should be visible on http://conference.frontend now.

* The event detail page is protected by Keycloak, so you will need to create a new user there to access the page:

    * Get the keycloak admin password by running `kubectl -n keycloak get secret keycloak-access -o yaml`
    * Copy the base64 encoded password from secret's "data.password" property.
    * Decode it with ` echo '<password>' | base64 -D`
    * Login to keycloak at http://conference.keycloak with admin/<decoded_password>
    * In the PAC realm, create your user with some credentials
    
* Now the application is ready to be accessed and tested!
