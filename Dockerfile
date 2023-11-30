FROM ubuntu:22.04 AS installer
  
COPY ./houdini-py3-18.5.759-linux_x86_64_gcc6.3.tar.gz /root/houdini.tar.gz

RUN apt-get update &&\
    apt-get install -y bc strace

RUN  mkdir /root/houdini_download &&\
     tar xf /root/houdini.tar.gz -C /root/houdini_download --strip-components=1 &&\
     /root/houdini_download/sesinetd.install

#-
FROM ubuntu:22.04

COPY --from=installer /usr/lib/sesi /usr/lib/sesi
COPY startHoudiniLicenseServer.sh /root/
COPY ./sesinetd /usr/lib/sesi/

RUN chmod +x /root/startHoudiniLicenseServer.sh &&\
    chmod +x /usr/lib/sesi/sesinetd &&\
    touch /usr/lib/sesi/licenses &&\
    touch /usr/lib/sesi/licenses.disabled

ENV HOME /root

WORKDIR /root

EXPOSE 1715

ENTRYPOINT ["/root/startHoudiniLicenseServer.sh"]
