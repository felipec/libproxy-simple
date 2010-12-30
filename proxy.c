#include <stdlib.h>
#include <string.h>

#include "proxy.h"

struct px_factory {
};

struct px_factory *px_proxy_factory_new(void)
{
	struct px_factory *factory;
	factory = calloc(1, sizeof(*factory));
	return factory;
}

char **px_proxy_factory_get_proxies(struct px_factory *factory, const char *url)
{
	char **proxies;
	proxies = calloc(1, sizeof(*proxies));
	proxies[0] = strdup("direct://");
	return proxies;
}

void px_proxy_factory_free(struct px_factory *factory)
{
	free(factory);
}
