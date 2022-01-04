# Prints the tun0 ip address if available

run_segment() {
        tun0="$(/sbin/ip -o -4 addr list tun0 | awk '{print $4}' | cut -d/ -f1 | cut -d' ' -f7 | tr -d '\n')"
        echo "$tun0"
        return 0
}
