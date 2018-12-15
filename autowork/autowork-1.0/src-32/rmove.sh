#!/bin/bash
sed -i "s/\/usr\/lib\/autowork\/autowork.sh > \/dev\/null 2>&1//" /etc/rc.local

rm -rf  /usr/lib/autowork/
