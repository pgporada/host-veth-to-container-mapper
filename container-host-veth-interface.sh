#!/usr/bin/env bash
# AUTHOR: technology@greenlancer.com
# WHAT: Displays a mapping of a host veth interface to the corresponding container

declare -A C_INFO
declare -a C_INTERFACE

for i in $(docker ps --format "{{ .ID }}__{{ .Names }}"); do
    # Data snippets
    C_ID="$(echo "${i}" | awk -F'__' '{print $1}')"
    C_NAME="$(echo "${i}" | awk -F'__' '{print $2}')"

    # Bash 4.3 associative array
    C_INFO+=( [${C_ID}]="${C_NAME}" )
done

for i in "${!C_INFO[@]}"; do
    for j in $(ip addr | grep veth | awk -F':' '{print $2}' | sed -e 's/[[:space:]]//g' | awk -F'@' '{print $1}'); do

        # Test if the container has "ip", otherwise fall back to "ifconfig"
        docker exec -it ${i} ip addr > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            CMD="ip addr"
        else
            CMD="ifconfig"
        fi

        CONTAINER_INT=$(docker exec -it ${i} $(echo "${CMD}") | grep eth0 | awk -F':' 'NR==1{print $1}' | sed 's/Link encap//')
        HOST_INT=$(ethtool -S "${j}" | grep peer_ifindex | awk -F':' '{print $2}' | sed -e 's/[[:space:]]//g')

        if [[ "${CONTAINER_INT}" == "${HOST_INT}" ]]; then
            printf "Container %-30s - Host %-10s\n" "${C_INFO[$i]}" "${j}"
        fi
    done
done
