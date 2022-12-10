#!/bin/bash
  
# Probably a simple, but bad idea:
/etc/init.d/sesinetd start
nginx -g "daemon off;";
