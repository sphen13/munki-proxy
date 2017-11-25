# munki-proxy

Simple docker container to act as local caching proxy for a munki repo.

## Environment Variables

Variable | Example | Description
--- | --- | ---
MUNKI_ROOT | /munki | Path from web root to the repo. Include first slash. Do not end in a slash.
UPSTREAM_SERVER | https://munkiserver.example.com:8080 | Web server to be proxied including protocol. Do not end in slash. Can include port
SERVER_NAME | munkiproxy.example.com | Set proxy web server name if needed.
GRUNTWORK | bXVua2k6bXVua2k= | Encoded basic auth header for upstream repo

## Mappable Volumes

Path | Description
--- | ---
/cache | Local proxy cache

## Usage

Example usage:

```
docker run -d --name munki-proxy \
	-e MUNKI_ROOT=/munki \
	-e UPSTREAM_SERVER=https://munkiserver.example.com \
	-v /var/docker/munki-proxy:/cache
	-p 8080:80 \
	--restart always \
	sphen/munki-proxy
```

## Gruntwork

There are some considerations made when trying to be in front of a gruntwork server.  All you need to so is specify the GRUNTWORK environment variable and populate with the basic auth info.  This can be found by running `sudo defaults read /var/root/Library/Preferences/ManagedInstalls.plist` on an existing client.  Only populate the variable with the final string that follows `Authorization: Basic`.  You can then specify this as a staging server in the gruntwork web dashboard.