## NOTE
This is based on original work by ['riskmethod'] (https://github.com/riskmethods/heroku-buildpack-kong) which in turn is a fork of the original https://github.com/heroku/heroku-buildpack-kong.

Steps to patch openresty 1.19.9.1 as well as to apply the lua-kong-nginx-module come from  ['openresty-build-tools'] (https://github.com/Kong/kong-build-tools/tree/master/openresty-build-tools)

[Heroku Buildpack](https://devcenter.heroku.com/articles/buildpacks) for [Kong 2.7.0](https://getkong.org/about/)
=========================

Deploy [Kong 2.7.0](https://konghq.com) as a Heroku app.

This software is a community proof-of-concept: [MIT license](LICENSE)

Usage
-----

⏩ **Deploy the [heroku-buildpack-for-kong app](https://github.com/iuliu-burtoiu/heroku_buildpack_for_kong) to get started.**

### Upgrading

Potentially breaking changes are documented in [UPGRADING](https://docs.konghq.com/gateway/2.7.x/install-and-run/upgrade-oss/).

### Custom

Create a new git repo and Heroku app:

```bash
APP_NAME=my-kong-gateway # name this something unique for your app
mkdir $APP_NAME
cd $APP_NAME
git init
heroku create $APP_NAME
heroku buildpacks:set https://github.com/riskmethods/heroku-buildpack-kong.git
heroku addons:create heroku-postgresql:hobby-dev
```

Create the file `config/kong.conf.etlua` based on the [sample config file](config/kong.conf.etlua.sample). This is a config template which generates `config/kong.conf` at runtime.

The same must be done with config/kong.yml.etlua and config/nginx.template.sample.
The  kong.yml generated file, will be needed if declarative / dbless mode is preferred.

🚀 Check `heroku logs` and `heroku open` to verify Kong launches.

#### Plugins & other Lua source

  * [Kong plugins](https://docs.konghq.com/hub/)
  * [Development guide](https://docs.konghq.com/2.0.x/plugin-development/)
    * `lib/kong/plugins/{NAME}`
    * Add each Kong plugin name to the `custom_plugins` comma-separated list in `config/kong.conf.etlua`
    * See: [Plugin File Structure](https://docs.konghq.com/1.0.x/plugin-development/file-structure/)
  * Lua rocks
    * specify in the app's `Rockfile`
    * each line is `{NAME} {VERSION}`
  * Other Lua source modules
    * `lib/{NAME}.lua` or
    * `lib/{NAME}/init.lua`

#### Environment variables

  * `PORT` exposed on the app/dyno
    * set automatically by the Heroku dyno manager
  * `DATABASE_URL`
    * set automatically by [Heroku Postgres add-on](https://elements.heroku.com/addons/heroku-postgresql)
  * Kong itself may be configured with [`KONG_` prefixed variables](https://docs.konghq.com/1.0.x/configuration/#environment-variables)
  * Heroku build configuration:
    * These variables only effect new deployments.
    * **Setting these will lengthen build-time, usually 4-8 minutes for compilation from source.
    * `KONG_GIT_URL` git repo URL for Kong source
      * default: `https://github.com/kong/kong.git`
    * `KONG_GIT_COMMITISH` git branch/tag/commit for Kong source
      * default: `2.7.0`


#### Using Environment Variables in Plugins

To use env vars within your own code.

  1. Whitelist the variable name for use within Nginx
     * In a custom Nginx config file add `env MY_VARIABLE;`
     * See: [Nginx config](#user-content-nginx-config) (below)
  2. Access the variable in Lua plugins
     * Use `os.getenv('MY_VARIABLE')` to retrieve the value.


#### Nginx config

Kong is an Nginx-based application. To customize the underlying Nginx configuration, commit the file `config/nginx.template` with contents based on [the docs](https://docs.konghq.com/1.0.x/configuration/#custom-nginx-templates) or [this included sample](config/nginx.template.sample).

#### Pre-release script

This buildpack installs a [release phase](https://devcenter.heroku.com/articles/release-phase) script to automatically run Kong's database migrations for each deployment.

Apps can define a custom pre-release script which will be automatically invoked before the built-in release phase script.

#### Testing

This buildpack supports [Heroku CI](https://devcenter.heroku.com/articles/heroku-ci) to automate test runs and integrate with deployment workflow.

Tests should follow the [Kong plugin testing](https://docs.konghq.com/1.0.x/plugin-development/tests/) guide.

App requirements:

  * `spec/kong_tests.conf` must contain the Kong configuration for running tests

See: sample [Heroku Kong app](https://github.com/heroku/heroku-kong) which contains a complete test suite.

Background
----------
We vendor the sources for Lua, LuaRocks, & OpenResty/Nginx and compile them with a writable `/app/kong-runtime` prefix. Attempts to bootstrap Kong on Heroku using existing [Lua](https://github.com/leafo/heroku-buildpack-lua) & [apt](https://github.com/heroku/heroku-buildpack-apt) buildpacks failed due to their compile-time prefixes of `/usr/local` which is read-only in a dyno.

OpenSSL (version required by OpenResty) is also compiled from source.

### Modification

This buildpack caches the source files of its compilation artifacts in `vendor/` as compressed tar.gz files.
Changes to the sources in `vendor/` will be detected and cache will be ignored.

If you need to trigger a full rebuild without changing the source, use the [Heroku Repo CLI plugin](https://github.com/heroku/heroku-repo) to purge the cache:

```bash
heroku repo:purge_cache
```