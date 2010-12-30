#ifndef PROXY_H
#define PROXY_H

#define pxProxyFactory px_factory

typedef struct px_factory px_factory;

px_factory *px_proxy_factory_new(void);
char **px_proxy_factory_get_proxies(px_factory *self, const char *url);
void px_proxy_factory_free(px_factory *self);

#endif
