FROM r-base:3.6.3

# Make R ready for packaging
RUN apt-get update -qq
RUN apt-get -y --no-install-recommends install \
  libssl-dev \
  libcurl4-openssl-dev \
  libssh2-1-dev \
  libxml2-dev
RUN install2.r --error \
    devtools \
    roxygen2

# Install SQL Server dirver
RUN apt-get update --allow-releaseinfo-change \
 && apt-get install --yes --no-install-recommends \
        apt-transport-https \
        curl \
        gnupg \
        unixodbc \
        unixodbc-dev \
 && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*

# Install Oracle Drivers
RUN apt-get update && apt-get install -y alien libaio1
RUN mkdir oracle_downloads && cd oracle_downloads \
  && wget https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm \
  && wget https://download.oracle.com/otn_software/linux/instantclient/19600/oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm \
  && alien -i oracle-instantclient19.6-basic-19.6.0.0.0-1.x86_64.rpm \
  && alien -i oracle-instantclient19.6-devel-19.6.0.0.0-1.x86_64.rpm \
  && cd ..
ENV LD_LIBRARY_PATH=/usr/lib/oracle/19.6/client64/lib:$LD_LIBRARY_PATH
ENV ORACLE_HOME=/usr/lib/oracle/19.6/client64
ENV PATH=$PATH:$ORACLE_HOME/bin

# Install ROracle
COPY ROracle.tar.gz /tmp/
RUN R CMD INSTALL /tmp/ROracle.tar.gz

# Install PhantomJs for Shiny testing
ENV OPENSSL_CONF=/etc/ssl/
RUN R -e 'install.packages("shinytest")'
RUN R -e 'shinytest::installDependencies()'
