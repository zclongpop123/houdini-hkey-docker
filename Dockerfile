FROM ubuntu:18.04 AS installer

COPY ./houdini-19.5.303-linux_*.tar.gz /root/

RUN mkdir /root/houdini_download \
    && tar xf /root/houdini-19.5.303-linux_*.tar.gz -C /root/houdini_download --strip-components=1 \
    && apt-get update \
    && apt-get install -y bc strace \
    && /root/houdini_download/houdini.install --auto-install --accept-EULA 2021-10-13 --install-license --no-install-houdini --no-install-engine-maya --no-install-engine-unity --no-install-menus --no-install-hfs-symlink



FROM ubuntu:18.04

COPY --from=installer /usr/lib/sesi/ /usr/lib/sesi
COPY ./sesinetd /usr/lib/sesi/
COPY startHoudiniLicenseServer.sh /root/

RUN  chmod +x /usr/lib/sesi/sesinetd \
     && chmod +x /root/startHoudiniLicenseServer.sh \
     && rm /usr/lib/sesi/licenses.disabled \
     && touch /usr/lib/sesi/licenses

ENV HOME /root

WORKDIR /root

EXPOSE 1715

ENTRYPOINT ["./startHoudiniLicenseServer.sh"]
