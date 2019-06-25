FROM exoplatform/base-jdk:jdk8
LABEL maintainer="telecomitalia"

MAINTAINER Simone e Vittorio, simone.mastrodonato@telecomitalia.it

#Variabili d'ambiente
#ENV EXO_VERSION 5.0.0-M34
ENV EXO_VERSION 5.1.0

ENV EXO_APP_DIR /opt/exo
ENV EXO_CONF_DIR /etc/exo
ENV EXO_DATA_DIR /srv/exo
ENV EXO_LOG_DIR /var/log/exo
ENV EXO_TMP_DIR /tmp/exo-tmp

ENV EXO_USER exo

ENV EXO_GROUP ${EXO_USER}

#Permetto di fare override sulla lista degli addon
ARG ADDONS="exo-jdbc-driver-mysql:1.1.0"

#Cambio la Shell
RUN rm -f /bin/sh && ln -s /bin/bash /bin/sh

#Creo utente e assegno i permessi
RUN useradd --create-home --user-group --shell /bin/bash ${EXO_USER}

#aggiungere \ && echo "exo ALL = NOPASSWD: ALL" > /etc/sudoers.d/e xo && chmod 440 /etc/sudoers.d/exo

#Installo qualche utile tool
RUN apt-get -qq update \
&& apt-get -qq -y upgrade ${_APT_OPTIONS} \
&& apt-get -qq -y install ${_APT_OPTIONS} xmlstarlet \
&& apt-get -qq -y install ${_APT_OPTIONS} libreoffice-calc libreoffice-draw libreoffice-impress libreoffice-math libreoffice-writer \
&& apt-get -qq -y autoremove \
&& apt-get -qq -y clean \
&& rm -rf /var/lib/apt/lists/*

#Creo le cartelle necessarie
RUN mkdir -p ${EXO_DATA_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_DATA_DIR} \
&& mkdir -p ${EXO_TMP_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_TMP_DIR} \
&& mkdir -p ${EXO_LOG_DIR} && chown ${EXO_USER}:${EXO_GROUP} ${EXO_LOG_DIR}

#Installo il portale eXo Platform
ENV DOWNLOAD_URL http://PROVENG/sw/timwork/2.0/exo-${EXO_VERSION}/platform-${EXO_VERSION}.zip
RUN curl -L -o /srv/downloads/eXo-Platform-community-${EXO_VERSION}.zip ${DOWNLOAD_URL} \
&& unzip -q /srv/downloads/eXo-Platform-community-${EXO_VERSION}.zip -d /srv/downloads/ \
&& rm -f /srv/downloads/eXo-Platform-community-${EXO_VERSION}.zip \
&& mv /srv/downloads/platform-community-${EXO_VERSION} ${EXO_APP_DIR} \
&& chown -R ${EXO_USER}:${EXO_GROUP} ${EXO_APP_DIR} \
&& ln -s ${EXO_APP_DIR}/gatein/conf /etc/exo \
&& rm -rf ${EXO_APP_DIR}/logs && ln -s ${EXO_LOG_DIR} ${EXO_APP_DIR}/logs

#Attribuzioni per corretta esecuzione in Openshift
RUN chmod +x ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXOLOG DIR} /tmp
RUN chgrp -R 0 ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXO_LO G_DIR} /tmp
RUN chmod -R g+rwX ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EX O_LOG_DIR} /tmp

#Installo i file di personalizzazione per girare su Openshift
ADD https://raw.githubusercontent.com/exo-docker/exo-community/master/scripts/setenv-docker-customize.sh ${EXO_APP_DIR}/bin/setenv-docker-customize.sh
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh \
&& chown ${EXO_USER}:0 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh \
&& sed -i '/# Load custom settings/i \
# Load custom settings for docker environment\n\
[ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] && { \n\
source $CATALINA_BASE/bin/setenv-docker-customize.sh \n\
if [ $? != 0 ]; then \n\
echo "Problem during docker customization process ... startup abor ted !" \n\
exit 1 \n\
fi \n\
} || echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
' ${EXO_APP_DIR}/bin/setenv.sh \
&& grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh

#ADD https://raw.githubusercontent.com/exo-docker/exo-community/master/scripts/wait-for-it.sh /opt/wait-for-it.sh
ADD https://raw.githubusercontent.com/simontim/exo/master/bin/wait-for-it.sh /opt/wait-for-it.sh
RUN chmod 755 /opt/wait-for-it.sh \
&& chown ${EXO_USER}:0 /opt/wait-for-it.sh

EXPOSE 8080

WORKDIR "/opt/exo/"
VOLUME ["/srv/exo"]

RUN for a in ${ADDONS}; do echo "Installing addon $a"; /opt/exo/addon install $a; done
USER ${EXO_USER}
ENTRYPOINT ["/opt/exo/start_eXo.sh", "--data", "/srv/exo"]
