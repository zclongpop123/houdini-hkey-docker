FROM rockylinux:8
  
COPY ./houdini-19.5.303-linux_x86_64_gcc9.3.tar.gz /root/houdini.tar.gz

RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' \
    -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.aliyun.com/rockylinux|g' \
    -i.bak \
    /etc/yum.repos.d/[Rr]ocky*.repo &&\
    dnf makecache

RUN dnf install -y bc strace procps nginx &&\
    mkdir -p /root/houdini_download &&\
    tar xf /root/houdini.tar.gz -C /root/houdini_download --strip-components=1 &&\
    /root/houdini_download/sesinetd.install &&\
    sed -e 's|# port=<value>|port=2715|g' -i.bak /usr/lib/sesi/sesinetd.ini &&\
    rm -f /root/houdini.tar.gz &&\
    rm -rf /root/houdini_download

COPY ./sesinetd /usr/lib/sesi/sesinetd
COPY ./start_lic_server.sh /root/

RUN chmod +x /usr/lib/sesi/sesinetd &&\
    chmod +x /root/start_lic_server.sh

EXPOSE 2715

ENTRYPOINT ["/root/start_lic_server.sh"]
