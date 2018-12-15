#!/bin/bash
sed -i "s/exit 0/\/usr\/lib\/autowork\/autowork.sh \> \/dev\/null 2\>\&1 \nexit 0/" /etc/rc.local
install -p -D -m 0755 autowork.sh /usr/lib/autowork/autowork.sh
