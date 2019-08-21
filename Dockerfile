FROM r-base:latest

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
        unixodbc-dev \
 && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
 && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
 && apt-get update \
 && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/*


# Install PhantomJs for Shiny testing
ENV OPENSSL_CONF=/etc/ssl/
RUN apt-get update --allow-releaseinfo-change \
 && apt-get install build-essential chrpath libssl-dev libxft-dev -y \
 && apt-get install libfreetype6 libfreetype6-dev -y \
 && apt-get install libfontconfig1 libfontconfig1-dev -y \
 && cd ~ \
 && export PHANTOM_JS="phantomjs-2.1.1-linux-x86_64" \
 && wget --max-redirect=50 http://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2 \
 && tar xvjf $PHANTOM_JS.tar.bz2 \
 && mv $PHANTOM_JS /usr/local/share \
 && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin
