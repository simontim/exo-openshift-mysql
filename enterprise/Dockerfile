FROM exo 

MAINTAINER simontim <simone.mastrodonato@telecomitalia.it>
USER root
RUN chgrp -R 0 ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXO_LOG_DIR} /tmp ${EXO_SHARED_DATA_DIR}
RUN chmod -R g+rwX ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXO_LOG_DIR} /tmp ${EXO_SHARED_DATA_DIR}
RUN chmod 755 /opt/wait-for-it.sh && \
    chown ${EXO_USER}:0 /opt/wait-for-it.sh  
RUN chmod 755 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
    chown ${EXO_USER}:0 ${EXO_APP_DIR}/bin/setenv-docker-customize.sh && \
    sed -i '/# Load custom settings/i \
\# Load custom settings for docker environment\n\
[ -r "$CATALINA_BASE/bin/setenv-docker-customize.sh" ] \
&& . "$CATALINA_BASE/bin/setenv-docker-customize.sh" \
|| echo "No Docker eXo Platform customization file : $CATALINA_BASE/bin/setenv-docker-customize.sh"\n\
' ${EXO_APP_DIR}/bin/setenv.sh && \
  grep 'setenv-docker-customize.sh' ${EXO_APP_DIR}/bin/setenv.sh    
RUN cat /etc/passwd> /tmp/passwd && \
   chmod -R g=u /etc/passwd 

ADD enterprise/bin/set_user ${EXO_APP_DIR}/bin/set_user

RUN chmod a+x ${EXO_APP_DIR}/bin/set_user

ENV PATH=$PATH:${EXO_APP_DIR}/bin

USER 999

ENTRYPOINT ["/opt/exo/bin/set_user"]

CMD [ "/opt/exo/start_eXo.sh" ]
