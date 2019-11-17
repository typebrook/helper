    ele_pattern="(node|way|relation)"
    sed -nr "/<$ele_pattern/,/<\/$ele_pattern/ {
        /<tag k=\"$1\"/ {
            s/.*v=\"([^\"]+)\".*/\1/
            h
        }
        /<\/$ele_pattern/ {x;p;s/.*//;x}
    }"
