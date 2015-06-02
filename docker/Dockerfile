FROM java:jre

MAINTAINER Aloysius Lim

ENV PDI_RELEASE=5.3 \
    PDI_VERSION=5.3.0.0-213 \
    PDI_HOME=/opt/pentaho-di \
    KETTLE_HOME=/pentaho-di

RUN curl -L -o /tmp/pdi-ce-${PDI_VERSION}.zip \
      http://downloads.sourceforge.net/project/pentaho/Data%20Integration/${PDI_RELEASE}/pdi-ce-${PDI_VERSION}.zip && \
    unzip -q /tmp/pdi-ce-${PDI_VERSION}.zip -d $PDI_HOME && \
    rm /tmp/pdi-ce-${PDI_VERSION}.zip

ENV PATH=$PDI_HOME/data-integration:$PATH

EXPOSE 8080

RUN mkdir -p $KETTLE_HOME/.kettle /docker-entrypoint.d /templates

COPY carte_config*.xml /templates/

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["carte.sh", "/pentaho-di/carte_config.xml"]
