# How to develop with this repository

* Build docker image: `./build.sh`
* Start container as devel environment: `./devel-env`
* Release new version:
    * Install requisites: `pip install bump2version`
    * Update `CHANGELOG.md`
    * Bump version: `bump2version minor`
