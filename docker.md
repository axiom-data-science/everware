
# Run Everware in a Docker container

This section explains how to run Everware in a container, and the different possibilities to run users container

## Build Everware container

[Dockerfile](Dockerfile)

```
  docker build -t everware .
```

## Create user containers on same machine as the Everware one

Edit `etc/container_config.py` file to set `c.DockerSpawner.hub_ip_connect` and `c.DockerSpawner.container_ip` to the IP of your machine running the Everware container.

```
  docker run -d --name everware \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v $(pwd)/etc/container_config.py:/config.py \
      -e GITHUB_CLIENT_ID=xxx \
      -e GITHUB_CLIENT_SECRET=xxx \
      -e OAUTH_CALLBACK_URL=http://xxxxxx:8000/hub/oauth_callback \
      -p 8000:8000 \
      -p 8081:8081 \
      everware /config.py --no-ssl --debug
```

## Create user containers on a remote Docker machine

Edit `etc/container_config.py` file to set `c.DockerSpawner.hub_ip_connect` and `c.DockerSpawner.container_ip` to the IP of your machine running the Everware container. Define a `DOCKER_HOST` env variable and set to the IP of your remote Docker machine.

```
docker run -d --name everware \
    -v $(pwd)/etc/container_config.py:/config.py \
    -e GITHUB_CLIENT_ID=xxx \
    -e GITHUB_CLIENT_SECRET=xxx \
    -e OAUTH_CALLBACK_URL=http://xxxxxx:8000/hub/oauth_callback \
    -e DOCKER_HOST=xxx.xxx.xxx.xxx \
    -p 8000:8000 \
    -p 8081:8081 \
    everware /config.py --no-ssl --debug
```

## Create user containers on a Docker Swarm cluster

Edit `etc/container_swarm.py` file to set `c.DockerSpawner.hub_ip_connect` to the IP of your machine hosting Everware container. This allows to create users container on a Docker Swarm cluster. Define a `DOCKER_HOST` env variable and set to the IP of your Swarm master.

```
  docker run -d --name everware \
      -v $(pwd)/etc/container_swarm_config.py:/config.py \
      -v /home/ubuntu/docker:/etc/docker \
      -e GITHUB_CLIENT_ID=xxx \
      -e GITHUB_CLIENT_SECRET=xxx \
      -e OAUTH_CALLBACK_URL=http://xxxxxx:8000/hub/oauth_callback \
      -e EVERWARE_WHITELIST=whitelist.txt \
      -e DOCKER_CERT_PATH=/etc/docker \
      -e DOCKER_HOST=tcp://xxx.xxx.xxx.xxx:2376 \
      -e DOCKER_TLS_VERIFY=1 \
      -p 8000:8000 \
      -p 8081:8081 \
      everware /config.py --no-ssl --debug
```
