FROM debian:stretch
MAINTAINER pihizi@msn.com

ENV SPHINX_VERSION 3.0.3-facc3fb
ENV DEBIAN_FRONTEND noninteractive

# install dependencies
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    libpq-dev \
    wget

RUN apt-get -y autoremove && apt-get -y autoclean && apt-get -y clean

# set timezone
RUN cp /usr/share/zoneinfo/CET /etc/localtime && dpkg-reconfigure tzdata

RUN wget http://sphinxsearch.com/files/sphinx-${SPHINX_VERSION}-linux-amd64.tar.gz -O /tmp/sphinxsearch.tar.gz
RUN mkdir -pv /sphinx
RUN cd /sphinx && tar -xf /tmp/sphinxsearch.tar.gz
RUN rm /tmp/sphinxsearch.tar.gz

RUN mkdir -pv /etc/sphinxsearch/conf.d /var/lib/sphinxsearch
VOLUME ["/var/lib/sphinxsearch"]

# point to sphinx binaries
RUN echo "export PATH=/sphinx/sphinx-3.0.3/bin:$PATH" >> /etc/profile
ENV PATH /sphinx/sphinx-3.0.3/bin:$PATH
RUN indexer -v

# 9312 Sphinx Plain Port
# 9306 SphinxQL Port
EXPOSE 9312 9306

CMD ["/sphinx/sphinx-3.0.3/bin/searchd", "--nodetach", "--config", "/etc/sphinxsearch/sphinx.conf.sh"]
