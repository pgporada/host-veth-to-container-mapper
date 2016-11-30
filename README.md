# Overiew

[![License](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

Tcpdump is a really valuable tool for troubleshooting. However, you don't just run tcpdump and call it a day. In my particular use case, I needed to debug a file being sent over the wire and into a container because somewhere along the path the file was getting corrupted. With help from [Liguang Cheng from IBM](https://developer.ibm.com/recipes/tutorials/networking-your-docker-containers-using-docker0-bridge/) and [this forensics blog](https://blog.rootshell.be/2009/04/15/forensics-reconstructing-data-from-pcap-files/), I was able to capture the file at various stops through my network.

The problem though is that I wanted to capture the file as it passed through the virtual ethernet interface, or [veth](http://stackoverflow.com/questions/25641630/virtual-networking-devices-in-linux), that Docker creates upon launching a container. I run countless containers so manually going through the list of veths was simply a no-go.

- - - -
# Usage

Run the script on a machine hosting containers

        ./container-host-veth-interface.sh

You'll see output such as

        Container naughty_yonath                 - Host veth54a5896
        Container goofy_darwin                   - Host vethe9b08d0
        Container goofy_franklin                 - Host vethca7fe61

You can verify that the you are tcpdumping the correct container as follows

        $ docker ps
        CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS                                              NAMES
        09195d2584ba        elasticsearch       "/docker-entrypoint.s"   1 seconds ago        Up 1 seconds        0.0.0.0:32779->9200/tcp, 0.0.0.0:32778->9300/tcp   tiny_cray
        f0ed5a984572        httpd               "httpd-foreground"       9 seconds ago        Up 8 seconds        0.0.0.0:32777->80/tcp                              goofy_darwin
        b5d0a387f732        redis               "docker-entrypoint.sh"   About a minute ago   Up About a minute   0.0.0.0:32774->6379/tcp                            goofy_franklin

        $ ip addr | grep veth
        29: veth54a5896@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
        31: vethe9b08d0@if30: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
        33: vethca7fe61@if32: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default

Start a tcpdump session in a separate terminal session

        $ sudo tcpdump -i veth54a5896

Send some data to the webserver container

        $ curl -XPOST -d"Phil was here" localhost:32777
        <html><body><h1>It works!</h1></body></html>

You should see traffic come across the wire

        $ # Terminal session running your tcpdump
        tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
        listening on veth54a5896, link-type EN10MB (Ethernet), capture size 262144 bytes
        ....
        14:35:12.246010 IP 192.168.178.1.34082 > 192.168.178.3.http: Flags [P.], seq 1:163, ack 1, win 229, options [nop,nop,TS val 5307363 ecr 5307363], length 162: HTTP: POST / HTTP/1.1
        ....

- - - -
# License and Author Information

MIT

(c) 2016 [Phil Porada](pporada@greenlancer.com) @ [GreenLancer.com](http://www.greenlancer.com)
