FROM upmcenterprises/fluentd:v0.14-debian
MAINTAINER Steve Sloka <slokas@upmc.edu>

COPY /start.sh /home/fluent/start.sh

ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH

# !! root access required to read container logs !!
USER root

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && sudo -u fluent gem install \
        fluent-plugin-elasticsearch \
        fluent-plugin-s3 \
        fluent-plugin-systemd \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-rewrite-tag-filter \
        fluent-plugin-cloudwatch-logs \
 && sudo -u fluent gem sources --clear-all \
 && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
           /home/fluent/.gem/ruby/2.3.0/cache/*.gem

# Copy plugins
COPY plugins /fluentd/plugins/


ENTRYPOINT ["sh", "start.sh"]
