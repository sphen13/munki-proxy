# munki-proxy

Simple docker container to act as local caching proxy for a munki repo.

If you define the `AVAHI_HOST` environment variable the container will advertise with Bonjour/mDNS. It will be listed as a `_munki._tcp.` service.  This must use the host networking adapter to work properly `--net=host`.

## Environment Variables

Variable | Example | Description
--- | --- | ---
MUNKI_ROOT | `/munki` | Path from web root to the repo. Include first slash. Do not end in a slash.
UPSTREAM_SERVER | `https://munkiserver.example.com:8080` | Web server to be proxied including protocol. Do not end in slash. Can include port
SERVER_NAME | `munkiproxy.example.com` | Set proxy web server name if needed.
PORT | `8080` | Port to host repo on, Defaults to `8080`
AVAHI_HOST | `munki-proxy` | mDNS hostname for proxy host.  Empty by default (mDNS disabled)
AVAHI_DOMAIN | `local` | mDNS domain. Defaults to `local`.
GRUNTWORK | `bXVua2k6bXVua2k=` | Encoded basic auth header for upstream repo

## Mappable Volumes

Path | Description
--- | ---
`/cache` | Local proxy cache

## Usage

Example usage without mDNS:
> Note you will need to map the port correctly if you change from the default 8080
```
docker run -d --name munki-proxy \
	-e MUNKI_ROOT=/munki \
	-e UPSTREAM_SERVER=https://munkiserver.example.com \
	-v /var/docker/munki-proxy:/cache \
	-p 8080:8080 \
	--restart always \
	sphen/munki-proxy
```

Example usage with mDNS:

```
docker run -d --name munki-proxy \
	-e MUNKI_ROOT=/munki \
	-e UPSTREAM_SERVER=https://munkiserver.example.com \
	-e AVAHI_HOST=munki-proxy \
	-v /var/docker/munki-proxy:/cache \
	--net=host \
	--restart always \
	sphen/munki-proxy
```

## Gruntwork

There are some considerations made when trying to be in front of a gruntwork server.

All you need to so is specify the `GRUNTWORK` environment variable and populate with the basic auth info.  This can be found by running `sudo defaults read /var/root/Library/Preferences/ManagedInstalls.plist` on an existing client.  Only populate the variable with the final string that follows `Authorization: Basic`.  You can then specify this as a staging server in the gruntwork web dashboard.