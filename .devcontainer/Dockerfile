FROM mcr.microsoft.com/devcontainers/java:1-17-bookworm

# Remove the stale Yarn apt source that ships in the base image.
# Its GPG key is no longer valid and causes apt-get update to fail,
# which in turn breaks any devcontainer feature that needs to install packages.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
          /etc/apt/sources.list.d/yarn.sources \
          /etc/apt/trusted.gpg.d/yarn.gpg 2>/dev/null; true
