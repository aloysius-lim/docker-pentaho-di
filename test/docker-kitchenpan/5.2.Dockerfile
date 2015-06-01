FROM abtpeople/pentaho-di:5.2

MAINTAINER Aloysius Lim

COPY .kettle/ $KETTLE_HOME/.kettle/

COPY repo/ $KETTLE_HOME/repo/

CMD ["kitchen.sh", "-version"]
