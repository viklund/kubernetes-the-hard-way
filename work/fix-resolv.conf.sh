#!/bin/bash

ansible -i inventory workers,controllers -a 'sudo sed -i "s/127.0.0.53/8.8.8.8/" /etc/resolv.conf' -f 6
