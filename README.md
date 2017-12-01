# munki-proxy

Simple docker container to act as local caching proxy for a munki repo.

If you define the `AVAHI_HOST` environment variable the container will advertise with Bonjour/mDNS. It will be listed as a `_munki._tcp.` service.  This must use the host networking adapter to work properly `--net=host`.

## Environment Variables

Variable | Example | Description
--- | --- | ---
MUNKI_ROOT | `/munki` | Path from web root to the repo. Include first slash. Do not end in a slash.
SUS_ROOT | `/reposado` | Path from web root to Apple SUS files. Include first slash. Do not end in a slash.
**UPSTREAM_SERVER** | `https://munkiserver.example.com:8080` | Web server to be proxied including protocol. Do not end in slash. Can include port **REQUIRED**
SERVER_NAME | `munkiproxy.example.com` | Set proxy web server name if needed.
PORT | `8080` | Port to host repo on, Defaults to `8080`
MAX_SIZE | 100g | Size of munki pkgs cache. _The overall size may get larger than this due to how nginx functions_
EXPIRE_PKGS | 30d | Amount of time we keep the munki **pkgs** directory cached for
EXPIRE_ICONS | 14d | Amount of time we keep the munki **icons** directory cached for
EXPIRE_SUS | 14d | Amount of time we keep the apple sus **downloads** directory cached for
EXPIRE_OTHER | 10m | Amount of time we keep everything else cached for _(catalogs etc)_
AVAHI_HOST | `munki-proxy` | mDNS hostname for proxy host.  Empty by default (mDNS disabled)
AVAHI_DOMAIN | `local` | mDNS domain. Defaults to `local`.
GRUNTWORK | `bXVua2k6bXVua2k=` | Encoded basic auth header for upstream repo

> Valid time measurements can be found [here](http://nginx.org/en/docs/syntax.html)

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
> Note we are using host networking - no ports needed

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

## Logging

Both access and error logs are output to stdout.  You can view by `docker logs munki-proxy` or equivalent for your setup. We have specified a custom log file type which includes the `$upstream_cache_status` as the third attribute.  This should help you see and analyze how efficient the cache is if you so desire.

Example:
```
172.17.0.1 - HIT [01/Dec/2017:12:54:24 +0000]  "GET /munki/catalogs/testing HTTP/1.1" 200 1738729 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Safari/604.1.38"
172.17.0.1 - MISS [01/Dec/2017:13:12:50 +0000]  "GET /munki/catalogs/all HTTP/1.1" 200 2852330 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Safari/604.1.38"
172.17.0.1 - HIT [01/Dec/2017:13:13:19 +0000]  "GET /munki/catalogs/all HTTP/1.1" 200 2852330 "-" "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Safari/604.1.38"
```
