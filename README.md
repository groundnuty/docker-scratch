# docker-scratch
A small collection of tools for manipulating layers of docker images and containers.

# Usage

## Docker Scratch

##### Execution:
```
docker-scratch.sh <container_id/name>
```

##### Example output:
```
./baseImageName_baseImageTag-crashlog-2016-06-12_09-10-04_utc.tar
```

This script takes the container and extracts the diff between the container and  container's base image. The diff layer is packed into a *tar* file.

##### Example use-case:
I use it to send logs of applications run in containers to developers for later analysys.

## Docker Apply

##### Execution:
```
docker-apply.sh ./baseImageName_baseImageTag-crashlog-2016-06-12_09-10-04_utc.tar
```

This script:

1. takes the *tar* file produced by `docker-scratch.sh` script,
2. downloads the base image of the container, 
3. adds *scratched* layer to the base image,
4. creates new image containing the *scratched* layer named `baseImageName_baseImageTag-crashlog-2016-06-12_09-10-04_utc`

##### Example use-case:

When *tar* file containing a `scratched` layer is send to a developer, he can recrate the container by combining the `scratched` layer with containers base image.

# Limitations
This scripts does not support docker volumes. 

# Licence
MIT

