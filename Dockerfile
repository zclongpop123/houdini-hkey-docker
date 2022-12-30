FROM ubuntu:18.04 AS iterim
  
COPY ./houdini-19.5.*-linux_x86_64_gcc9.3.tar.gz /root/houdini.tar.gz

RUN sed -i "s@http://.*archive.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list &&\
    sed -i "s@http://.*security.ubuntu.com@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list &&\
    apt-get update &&\
    apt-get install -y bc strace

RUN  mkdir /root/houdini_download &&\
     tar xf /root/houdini.tar.gz -C /root/houdini_download --strip-components=1 &&\
     /root/houdini_download/sesinetd.install

#-
FROM ubuntu:18.04

COPY --from=iterim /usr/lib/sesi/ /usr/lib/sesi
COPY startHoudiniLicenseServer.sh /root/

RUN chmod +x /root/startHoudiniLicenseServer.sh &&\
    rm /usr/lib/sesi/licenses.disabled &&\
    touch /usr/lib/sesi/licenses &&\
    touch /usr/lib/sesi/licenses.disabled

ENV HOME /root

WORKDIR /root

EXPOSE 1715

ENTRYPOINT ["/root/startHoudiniLicenseServer.sh"]
