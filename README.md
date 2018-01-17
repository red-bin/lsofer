# lsofer

Similarly to `lsof -i`, this script returns processes' /proc data, whenever there is an open inet socket. 

The code follows a very functional data model and is designed to run in a large and cluttered linux environment.

Info gathered:
  * startup commands
  * environment variables
  * tcp/tcp6/udp socket info
  * files loaded in memory
  * open files' info
  * cwd

Todo:
Restrict to one to reduce latency.
