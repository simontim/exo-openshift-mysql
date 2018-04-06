FROM exo 

MAINTAINER simontim <simone.mastrodonato@telecomitalia.it>

RUN chgrp -R 0 ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EXO_LO G_DIR} /tmp
RUN chmod -R g+rwX ${EXO_APP_DIR} ${EXO_CONF_DIR} ${EXO_DATA_DIR} ${EX O_LOG_DIR} /tmp
