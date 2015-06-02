# abtpeople/pentaho-di

Docker image for Pentaho Data Integration (PDI), also known as Kettle, Community Edition. It supports running Carte as a service, or Pan or Kitchen as batch jobs. It also supports the running of custom scripts to fully customise derived Docker images.

By default, running a container from this image runs `carte.sh` with the configuration file `/pentaho-di/carte_config.xml` that sets up the container as a Carte master node listening on port 8080. The default settings can be changed using environment variables or by supplying a custom configuration file (see *Running Carte* below).

Alternatively, this image can be used as a base image to run specific PDI jobs or transformations. The examples below illustrate how this can be done.

## Supported Tags and Links to Dockerfiles

* [`5.2`](https://github.com/abtpeople/docker-pentaho-di/blob/5.2/docker/Dockerfile)
* [`5.3`](https://github.com/abtpeople/docker-pentaho-di/blob/5.3/docker/Dockerfile), [`latest`](https://github.com/abtpeople/docker-pentaho-di/blob/master/docker/Dockerfile)

## Environment Variables

The following environment variables can be passed to `docker run` using the `-e` option:

* `CARTE_NAME`: The name of this Carte node *(default: carte-server)*
* `CARTE_NETWORK_INTERFACE`: The network interface to bind to *(default: eth0)*
* `CARTE_PORT`: The port to listen to *(default: 8080)*
* `CARTE_USER`: The username for this node *(default: cluster)*
* `CARTE_PASSWORD`: The password for this node *(default: cluster)*
* `CARTE_IS_MASTER`: Whether this is a master node *(default: Y)*
* `CARTE_INCLUDE_MASTERS`: Whether to include a `masters` section in the Carte configuration *(default: N)*

If `CARTE_INCLUDE_MASTERS` is `'Y'`, then these additional environment variables apply:

* `CARTE_REPORT_TO_MASTERS`: Whether to notify the defined master node that this node exists *(default: Y)*
* `CARTE_MASTER_NAME`: The name of the master node *(default: carte-master)*
* `CARTE_MASTER_HOSTNAME`: The hostname of the master node *(default: localhost)*
* `CARTE_MASTER_PORT`: The port of the master ndoe *(default: 8080)*
* `CARTE_MASTER_USER`: The username of the master node *(default: cluster)*
* `CARTE_MASTER_PASSWORD`: The password of the master node *(default: cluster)*
* `CARTE_MASTER_IS_MASTER`: Whether this master node is a master node *(default: Y)*

These environment variables are used to set up a Carte configuration file at `/pentaho-di/carte_config.xml`. If `CARTE_INCLUDE_MASTERS` is `'N'` (the default), then `carte_config.xml` will contain the following:

```xml
<slave_config>
  <slaveserver>
    <name>CARTE_NAME</name>
    <network_interface>CARTE_NETWORK_INTERFACE</network_interface>
    <port>CARTE_PORT</port>
    <username>CARTE_USER</username>
    <password>CARTE_PASSWORD</password>
    <master>CARTE_IS_MASTER</master>
  </slaveserver>
</slave_config>

```

Otherwise, it will contain:

```xml
<slave_config>
  <masters>
    <slaveserver>
      <name>CARTE_MASTER_NAME</name>
      <hostname>CARTE_MASTER_HOSTNAME</hostname>
      <port>CARTE_MASTER_PORT</port>
      <username>CARTE_MASTER_USER</username>
      <password>CARTE_MASTER_PASSWORD</password>
      <master>CARTE_MASTER_IS_MASTER</master>
    </slaveserver>
  </masters>
  <report_to_masters>CARTE_REPORT_TO_MASTERS</report_to_masters>
  <slaveserver>
    <name>CARTE_NAME</name>
    <network_interface>CARTE_NETWORK_INTERFACE</network_interface>
    <port>CARTE_PORT</port>
    <username>CARTE_USER</username>
    <password>CARTE_PASSWORD</password>
    <master>CARTE_IS_MASTER</master>
  </slaveserver>
</slave_config>

```

## Running Carte

This image can be used to run Carte as a long-running service, by simply using `docker run`:

```bash
docker run -d -p=8080:8080 abtpeople/pentaho-di
```

The Carte configuration can be customised using environment variables, as described above:

```bash
docker run -d -p=8080:8080 -e CARTE_NAME=mycarte -e CARTE_USER=john -e CARTE_PASSWORD=83h7c2 abtpeople/pentaho-di
```

For more advanced Carte configuration, create a new Dockerfile and supply a custom Carte configuration file. See [Carte Configuration](http://wiki.pentaho.com/display/EAI/Carte+Configuration) for available configuration options.

```dockerfile
FROM abtpeople/pentaho-di

COPY my_carte_config.xml /my_carte_config.xml

CMD ["carte.sh", "/my_carte_config.xml"]
```

## Running Pan or Kitchen

This image can be used to run specific transformations or jobs using Pan or Kitchen, respectively. This is useful for packaging ETL scripts as Docker images, and running these images on a schedule (e.g. using cron or Chronos).

To do this, create a Dockerfile with this image in the `FROM` command. Copy the transformation and job files into the image, along with any Kettle configurations required, and run Pan or Kitchen with the appropriate command line options.

For example, in order to run jobs and transformations from a file-based repository, the repository location first needs to be set in the file `KETTLE_HOME/.kettle/repositories.xml`. Note that the path `base_directory` must be defined in the context of the Docker image, not the host machine.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<repositories>
  <repository>
    <id>KettleFileRepository</id>
    <name>my_pdi_repo</name>
    <description>My PDI Repository</description>
    <base_directory>/pentaho-di/repo</base_directory>
    <read_only>N</read_only>
    <hides_hidden_files>N</hides_hidden_files>
  </repository>
</repositories>
```

Then, assuming the transformations and jobs are in the `hostrepo` folder on the host machine, copy them to the `base_directory` in the image, and set up `CMD` to run the default job.

```dockerfile
FROM abtpeople/pentaho-di

COPY .kettle/repositories.xml $KETTLE_HOME/.kettle/repositories.xml

COPY hostrepo/* /pentaho-di/repo/

CMD ["kitchen.sh", "-rep=my_pdi_repo",  "-dir=/",  "-job=firstjob"]
```

Once the Docker image has been built, we can run the `firstjob` job. The `--rm` option can be used to automatically remove the Docker container once the job is completed, since this is a batch command and not a long-running service.

```bash
docker build -t pdi_myrepo
run docker run --rm pdi_myrepo
```

The same image can also be used to run any arbitrary job or transformation in the repository:

```bash
run docker run --rm pdi_myrepo kitchen.sh -rep=my_pdi_repo -dir=/ -job=secondjob
run docker run --rm pdi_myrepo pan -rep=my_pdi_repo -dir=/ -trans=subtrans
```

See the [Pan](http://wiki.pentaho.com/display/EAI/Pan+User+Documentation) and [Kitchen](http://wiki.pentaho.com/display/EAI/Kitchen+User+Documentation) user documentation for their full command line reference.

## Running Custom Scripts

This image allows for full configuration and customisation via custom scripts. For example, a script can be used to clone a Git repository containing the transformations and jobs to be run.

To use custom scripts, name them with a `.sh` extension, and copy them to the `/docker-entrypoint.d` folder. For example:

```dockerfile
FROM abtpeople/pentaho-di

COPY script1.sh /docker-entrypoint.d/
COPY script2.sh /docker-entrypoint.d/
COPY script3.sh /docker-entrypoint.d/

...
```
