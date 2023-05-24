run_segment(){
    temp=$(sensors | grep Package | grep -oE '[0-9]+(\.[0-9]+)?°C' | head -n 1)
    echo CPU:$temp
    return 0
}
