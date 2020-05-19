# MISP
A dockerfile for the MISP project based on alpine Linux.
The dockerfile used to generate the image for the SOC DIRISI's docker image

# Basic usage
```
$ git clone https://github.com/soc-dirisi/MISP.git
$ cd misp
$ docker build -t socdirisi/misp .
$ docker volume create misp-conf
$ docker volume create apache-conf
$ docker run -d -p 80:80 -p 443:443 --name misp -v misp-conf:/var/www/MISP/app/Config -v apache-conf:/etc/apache2/conf.d socdirisi/misp
$ vim /var/lib/docker/volumes/misp-conf/_data/database.php # Add your database credentials and hostname
$ docker restart misp
# Go to https://<your misp IP>
```
