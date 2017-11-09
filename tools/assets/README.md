## Build Ubuntu Assets

Create the build environment:

```
docker build . -f Dockerfile.ubuntu -t sensu-plugins-ubuntu
```

Create a Sensu 2.0 sensu-plugins asset containing the AWS plugin:

```
docker run -v$(pwd):/tmp/assets sensu-plugins-ubuntu create-asset.sh sensu-plugins-aws
```
