FROM apache/hadoop:3

RUN mkdir -p /opt/hadoop/dfs/data
VOLUME /opt/hadoop/dfs/data

EXPOSE 9864

HEALTHCHECK CMD curl -f http://localhost:9864/ || exit 1

CMD ["/opt/hadoop/bin/hdfs", "datanode"]
