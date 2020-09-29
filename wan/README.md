# Docker Compose Example

This example brings up 2 consul servers, one in `DC1` and one in `DC2`. For ease
of use, these two servers come up on the same docker network, `consul`. However,
in a more realistic environment these servers would likely be in separate,
network segregated data centers. However, in order to WAN federate these
service the WAN ports must be accessible from both servers. For default WAN
federation this includes port 8301 open to TCP and UDP.

To run this example:

1. Bring up the servers

```bash
> docker compose up
```

1. Option 1 - WAN federate via IP

> First get the IP addresses of the instances on the `consul` docker network

```bash
> docker network inspect docker_consul
```

> Next, join the servers

```bash
> docker exec docker_consul-server-dc1_1 consul join -wan <IP of server 1> <IP of server 2>
```

1. Option 2 - WAN federate via hostname

> First get the hostnames of the instances on the `consul` docker network

```bash
> docker network inspect docker_consul
```

> Next, join the servers

```bash
> docker exec docker_consul-server-dc1_1 consul join -wan docker_consul-server-dc1_1 docker_consul-server-dc1_2
```