FROM joedwards32/cs2:latest

# Switch to root for Railway volume chown
USER root

# Create entrypoint wrapper that chowns volume then drops privileges
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Railway healthcheck on TCP game port (can't UDP healthcheck)
EXPOSE 27015/tcp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash", "entry.sh"]
