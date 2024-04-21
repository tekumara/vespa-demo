# Vespa sample applications - Simple semantic search

Adapted from [here](https://github.com/vespa-engine/sample-apps/blob/e7f6ab63d7d1bc4cbce0f77a0a0b646ce2af6116/simple-semantic-search/README.md).

Deploy:

```
vespa deploy apps/simple-semantic-search/package
```

Feed:

```
vespa document apps/simple-semantic-search/ext/1.json -t http://localhost:8081
vespa document apps/simple-semantic-search/ext/2.json -t http://localhost:8081
vespa document apps/simple-semantic-search/ext/3.json -t http://localhost:8081
```

Query:

```
vespa query 'yql=select * from doc where userQuery() or ({targetHits: 100}nearestNeighbor(embedding, e))' \
 'input.query(e)=embed(e5, "query: space contains many suns")' \
 'query=space contains many suns' -C query
```

```
vespa query 'yql=select * from doc where userQuery() or ({targetHits: 100}nearestNeighbor(embedding, e))' \
 'input.query(e)=embed(e5, "query: shipping stuff over the sea")' \
 'query=shipping stuff over the sea' -C query
```

```
vespa query 'yql=select * from doc where userQuery() or ({targetHits: 100}nearestNeighbor(embedding, e))' \
 'input.query(e)=embed(e5, "query: exchanging information by sound")' \
 'query=exchanging information by sound' -C query
```
