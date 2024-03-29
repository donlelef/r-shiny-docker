FROM r-base:4.2.1

# Make R ready for packaging
RUN apt-get update -qq
RUN apt-get -y --no-install-recommends install \
  libfontconfig1-dev \
  libharfbuzz-dev \
  libfribidi-dev \
  libfreetype6-dev \
  libpng-dev \
  libtiff5-dev \
  libjpeg-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libssh2-1-dev \
  libxml2-dev
RUN R -e 'install.packages("devtools")'

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

# Install PhantomJs for Shiny testing
ENV OPENSSL_CONF=/etc/ssl/
RUN R -e 'install.packages("shinytest")'
RUN R -e 'shinytest::installDependencies()'
