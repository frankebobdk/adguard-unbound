FROM alpine:edge

# Add the testing repository and install dependencies
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk add --no-cache \
        libcap \
        unbound=1.21.0-r0 \
        stubby@testing=0.4.3-r0

WORKDIR /tmp

RUN wget https://www.internic.net/domain/named.root -qO- >> /etc/unbound/root.hints

# Install Cloudflared
RUN wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared \
    && chmod +x /usr/local/bin/cloudflared

# Copy configuration files to the respective directories
COPY files/unbound/unbound.conf /opt/unbound/unbound.conf
COPY files/cloudflared/cloudflared.yml /opt/cloudflared/cloudflared.yml
COPY files/stubby/stubby.yml /opt/stubby/stubby.yml

COPY files/ /opt/

# Install AdGuardHome
RUN wget https://static.adguard.com/adguardhome/release/AdGuardHome_linux_amd64.tar.gz >/dev/null 2>&1 \
        && mkdir -p /opt/adguardhome/conf /opt/adguardhome/work \
        && tar xf AdGuardHome_linux_amd64.tar.gz ./AdGuardHome/AdGuardHome  --strip-components=2 -C /opt/adguardhome \
        && /bin/ash /opt/adguardhome \
        && chown -R nobody: /opt/adguardhome \
        && setcap 'CAP_NET_BIND_SERVICE=+eip CAP_NET_RAW=+eip' /opt/adguardhome/AdGuardHome \
        && chmod +x /opt/entrypoint.sh \
        && rm -rf /tmp/* /var/cache/apk/*

WORKDIR /opt/adguardhome/work

VOLUME ["/opt/adguardhome/conf", "/opt/adguardhome/work", "/opt/unbound", "/opt/stubby"]

# Expose ports (add ports for Stubby if needed)
EXPOSE 53/tcp 53/udp 67/udp 68/udp 80/tcp 443/tcp 443/udp 853/tcp 3000/tcp 5053/tcp 5053/udp 5153/tcp 5153/udp 5253/tcp 5253/udp

HEALTHCHECK --interval=30s --timeout=15s --start-period=5s\
            CMD sh /opt/healthcheck.sh

CMD ["/opt/entrypoint.sh"]

LABEL \
    maintainer="frankebob"
