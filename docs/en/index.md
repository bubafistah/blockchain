# Lethean Blockchain Documentation

We now recommend using our premade containers, all our images are hosted by the very generous Docker inc who sponsor lethean.

Using our images won't affect any of your Docker Hub pull rate limits, because they love open source projects, thanks again Docker <3

The fastest way to play with the system is to run the below command

```shell
docker run lthn/chain
```
This will start a local chain daemon and start synchronising with the network, but, everything is contained within a virtual operating system.
So we need to mount the blockchain data directory to a folder on your computer, then, you can delete and remake your chain container as much as you like
reusing the same blockchain data (or configurations). We also want to open ports to your container to ensure it's accessible once started. Optional parameters are setup to provide a friendly container name and dettaching container on-start for a better experience.

```shell
# -d = daemon, spawns docker in the background
# --name = give our container a name "chain-daemon" for easy reference.
# -p = open the desired ports to ensure the daemon can service connecting clients.
# -v = mount, here we make a docker volume called data, this can be a full path to any dir you want
docker run -d --name chain-daemon -p 48772:48772 -p 48782:48782 -v $(pwd)/data:/home/lthn/chain/data lthn/chain
```

Check the health of your letheand daemon container "chain-daemon".

```shell
docker logs -f chain-daemon
# Ctrl + C  - Abort and stop viewing the container logs. This will not stop the container from running.
# NOTE: Realtime log output is provided showing sync and other events.
```

And that is it, you can now point your GUI wallet or cli wallet at localhost:48782 or <chain-daemon-ip>:48782

If that looks TL:DR run this.
```shell
wget https://gitlab.com/lthn.io/projects/chain/lethean/-/raw/next/docker-compose.yml && docker-compose up -d
```

or use and build on this docker compose file

```yaml
version: "3.9"
services:
  blockchain:
    image: lthn/chain
    container_name: chain
    build: .
    expose:
      - 48792
      - 48782
      - 48772
    volumes:
      - data:/home/lthn/chain/data:rw

```
