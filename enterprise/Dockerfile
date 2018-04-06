FROM exo 

MAINTAINER simontim <simone.mastrodonato@telecomitalia.it>
USER root
RUN chgrp -R 0 ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXO_LOG_DIR} /tmp
RUN chmod -R g+rwX ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXO_LOG_DIR} /tmp
RUN chmod 755 /opt/wait-for-it.sh && \
    chown ${EXO_USER}:${EXO_GROUP} /opt/wait-for-it.sh
USER ${EXO_USER}
