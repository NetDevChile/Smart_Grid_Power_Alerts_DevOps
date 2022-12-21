#!/bin/sh
cd /usr/share/snmp/mibs && \
    wget --no-check-certificate --content-disposition https://raw.githubusercontent.com/NetDevChile/MIBS/main/mibs.zip && wget --no-check-certificate --content-disposition https://raw.githubusercontent.com/NetDevChile/MIBS/main/7za && \
    chmod +x ./7za && \
    ./7za x mibs.zip
