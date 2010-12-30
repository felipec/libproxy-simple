#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "proxy.h"

#include <gconf/gconf-client.h>

struct px_factory {
	GConfClient *client;
};

struct px_factory *px_proxy_factory_new(void)
{
	struct px_factory *factory;

	factory = calloc(1, sizeof(*factory));

	g_type_init();

	factory->client = gconf_client_get_default();

	return factory;
}

static char *get_gnome_conf(struct px_factory *factory)
{
	char *proxy = NULL;
	char *mode, *host;
	int port;

	proxy = host = NULL;

	mode = gconf_client_get_string(factory->client, "/system/proxy/mode", NULL);
	if (strcasecmp(mode, "manual") != 0)
		goto disabled;

	host = gconf_client_get_string(factory->client, "/system/http_proxy/host", NULL);
	port = gconf_client_get_int(factory->client, "/system/http_proxy/port", NULL);

	if (host && port)
		asprintf(&proxy, "http://%s:%u/", host, port);

	g_free(host);
disabled:
	g_free(mode);
	return proxy;
}

char **px_proxy_factory_get_proxies(struct px_factory *factory, const char *url)
{
	char **proxies, *proxy;
	proxies = calloc(1, sizeof(*proxies));
	proxy = get_gnome_conf(factory);
	if (!proxy)
		proxy = strdup("direct://");
	proxies[0] = proxy;
	return proxies;
}

void px_proxy_factory_free(struct px_factory *factory)
{
	g_object_unref(factory->client);
	free(factory);
}
