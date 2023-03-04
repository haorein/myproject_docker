# A template for deploying django with docker+redis+mysql+nginx+uwsgi

## Usage 

1. Clone this repository and access the project path
    ```shell
    git clone https://github.com/haorein/myproject_docker.git
    cd myproject_docker
    ```
2. Build the image and launch the project
    ```shell
    # Build images, it only needs to be executed the first time or when there are changes of the image.
    sudo docker-compose build
    
    # Check if the image has been successfully built
    sudo docker images
    
    # Start the service
    sudo docker-compose up
    ```
   Now open your browser and visit http://127.0.0.1/admin/, if you see the familiar Django console login screen, then you've run it successfully.


## Reference: 
https://pythondjango.cn/django/advanced/16-docker-deployment/#top
