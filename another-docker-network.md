# Configure another default docker network to avoid overlap

https://serverfault.com/questions/916941/configuring-docker-to-not-use-the-172-17-0-0-range

With `sudo` rights:

```bash
nano /etc/docker/daemon.json

{
"bip": "10.50.0.1/24",
"default-address-pools":[
{"base":"10.51.0.0/16","size":24},
{"base":"10.52.0.0/16","size":24}
]
}

service docker restart
```

If there is a need add IPv6:

```bash
nano /etc/docker/daemon.json

{
"default-address-pools": [
{ "base": "172.18.0.0/16", "size": 26 },
{ "base": "2001:db8::/56", "size": 64 }
]
}

docker network create --ipv6 ip6net

docker network inspect ip6net
```