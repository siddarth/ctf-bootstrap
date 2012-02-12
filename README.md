# About

ctf-bootstrap is to bootstrap a capture the flag environment environment.

# Usage

    $ git clone git://github.com/siddarth/ctf-bootstrap.git; cd ctf-bootstrap

###### To generate the environment

    $ cp sample-code code/; cp sample.config.yaml config.yaml

Make changes to sample-code and config.yaml

    $ ./bootstrap -c config.yaml

###### To clear out the existing environment

This hoses all the levels specified in config.yaml along with their home
directories and /level. Careful.

    $ ./bootstrap -c config.yaml -d

Inspired by SmashTheStack I/O.