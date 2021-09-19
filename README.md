# Ubuntu server setup
Automate setup of Ubuntu server. Made specificly for the default Ubuntu servers from Digital Ocean, last tested with 20.04.

To get started when server is fresh, run:
```
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/initial.sh" && chmod u+x initial.sh; ./initial.sh userperson```

After the user has been setup, download `setup.sh`...
```
wget -q "https://raw.githubusercontent.com/jyggorath/ubuntu-server-setup/main/setup.sh" && chmod u+x setup.sh```

... and run it with whatever option you'd like:
```
./setup Full```