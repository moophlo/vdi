FROM ubuntu:20.04

MAINTAINER Andrea Odorisio

RUN apt update && apt -y full-upgrade && apt install -y wget gnupg gnupg2
RUN wget https://dbeaver.io/debs/dbeaver.gpg.key
RUN apt-key add ./dbeaver.gpg.key
RUN echo "deb https://dbeaver.io/debs/dbeaver-ce /" | tee /etc/apt/sources.list.d/dbeaver.list
ARG ADDITIONAL_PACKAGES="git python3 openjdk-8-jdk curl winbind dnsutils net-tools samba-common winbind libpam-winbind libnss-winbind krb5-config samba-dsdb-modules samba-vfs-modules cifs-utils policykit-1-gnome gtk2-engines-pixbuf pm-utils smbclient openjdk-11-jdk openjdk-11-jre dbeaver-ce geany curl dirmngr gnupg apt-transport-https ca-certificates software-properties-common telnet netcat"
ENV ADDITIONAL_PACKAGES=${ADDITIONAL_PACKAGES}

ENV DEBIAN_FRONTEND noninteractive
RUN apt update && apt -y full-upgrade && apt install -y \
  ca-certificates \
  firefox \
  less \
  locales \
  openssh-server \
  pepperflashplugin-nonfree \
  pulseaudio \
  sudo \
  supervisor \
  uuid-runtime \
  vim \
  wget \
  xauth \
  xautolock \
  xfce4 \
  xfce4-clipman-plugin \
  xfce4-cpugraph-plugin \
  xfce4-netload-plugin \
  xfce4-screenshooter \
  xfce4-taskmanager \
  xfce4-terminal \
  xfce4-xkb-plugin \
  xorgxrdp \
  xprintidle \
  xrdp \
  iputils-ping \
  apt-transport-https \
  htop \
  libopenjfx-java \
  libopenjfx-jni \
  openjfx \
  maven \
  mongodb-clients \
  xdg-utils \
  libgconf-2-4 \
  dirmngr \
  gnupg \
  software-properties-common \
  $ADDITIONAL_PACKAGES \
  && \
  rm -rf /var/cache/apt /var/lib/apt/lists && \
  mkdir -p /var/lib/xrdp-pulseaudio-installer


RUN wget https://downloads.mongodb.com/compass/mongodb-compass_1.28.1_amd64.deb
RUN dpkg --ignore-depends=mongodb-compass_1.28.1_amd64.deb  -i mongodb-compass_1.28.1_amd64.deb
#RUN sed -i 's/Exec=mongodb-compass %U/Exec=mongodb-compass --no-sandbox %U/g' /usr/share/applications/mongodb-compass.desktop
RUN rm mongodb-compass_1.28.1_amd64.deb
RUN apt --fix-broken install -y
RUN curl -fsSL https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
RUN sudo add-apt-repository "deb https://download.sublimetext.com/ apt/stable/"
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
RUN sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
RUN rm -f packages.microsoft.gpg
RUN apt update
RUN apt install code sublime-text geany -y
RUN apt --fix-broken install -y

ADD bin /usr/bin
ADD etc /etc
ADD usr/share/applications /usr/share/applications
ADD autostart /etc/xdg/autostart

# Configure
RUN mkdir /var/run/dbus && \
  cp /etc/X11/xrdp/xorg.conf /etc/X11 && \
  sed -i "s/console/anybody/g" /etc/X11/Xwrapper.config && \
  sed -i "s/xrdp\/xorg/xorg/g" /etc/xrdp/sesman.ini && \
  locale-gen en_US.UTF-8 && \
  echo "xfce4-session" > /etc/skel/.Xclients && \
  cp -r /etc/ssh /ssh_orig && \
  rm -rf /etc/ssh/* && \
  rm -rf /etc/xrdp/rsakeys.ini /etc/xrdp/*.pem

# Docker config
VOLUME ["/etc/ssh","/home"]
EXPOSE 3389 22 9001
ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]
CMD ["supervisord"]
