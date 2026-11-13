FROM rockylinux/rockylinux:10.2 AS installer
  
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    -i.bak \
    /etc/yum.repos.d/rocky*.repo

RUN dnf makecache &&\
    dnf install -y bc strace ncurses procps-ng avahi

COPY houdini-22.0.466-linux_x86_64_gcc14.2.tar.gz /root/houdini.tar.gz
COPY ./x64/FilePatch /root/FilePatch

RUN  mkdir -p /etc/init.d &&\
     mkdir -p /root/houdini_download &&\
     tar -xvf /root/houdini.tar.gz -C /root/houdini_download --strip-components=1 &&\
     /root/houdini_download/sesinetd.install

RUN cp /usr/lib/sesi/sesinetd sesinetd &&\
    chmod +x /root/FilePatch &&\
    /root/FilePatch sesinetd &&\
    cp sesinetd /usr/lib/sesi/sesinetd


FROM rockylinux/rockylinux:10.2

WORKDIR /root

COPY --from=installer /usr/lib/sesi /usr/lib/sesi
COPY ./entrypoint.sh ./entrypoint.sh

RUN useradd sesinetd &&\
    useradd www-data

RUN chmod +x /usr/lib/sesi/sesinetd &&\
    chmod +x ./entrypoint.sh &&\
    touch /usr/lib/sesi/licenses &&\
    touch /usr/lib/sesi/licenses.disabled

EXPOSE 1715

ENTRYPOINT ["./entrypoint.sh"]
