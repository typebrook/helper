#!/bin/bash

# scripts from https://josm.openstreetmap.de/wiki/Download#Webstart
echo deb https://josm.openstreetmap.de/apt $(lsb_release -sc) universe | sudo tee /etc/apt/sources.list.d/josm.list > /dev/null &&\
wget -q https://josm.openstreetmap.de/josm-apt.key -O- | sudo apt-key add - &&\
sudo apt-get update &&\
sudo apt-get remove josm josm-plugins &&\
sudo apt-get install josm
