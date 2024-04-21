# Vespa sample applications - Simple hybrid search with ColBERT

Adapted from [here](https://github.com/vespa-engine/sample-apps/blob/e7f6ab63d7d1bc4cbce0f77a0a0b646ce2af6116/colbert/README.md).

Deploy:

```
vespa deploy apps/colbert
```

Feed:

```
vespa document apps/colbert/ext/1.json -t http://localhost:8081
vespa document apps/colbert/ext/2.json -t http://localhost:8081
vespa document apps/colbert/ext/3.json -t http://localhost:8081
```

Query:

```
vespa query 'yql=select * from doc where userQuery() or ({targetHits: 100}nearestNeighbor(embedding, q))'\
 'input.query(q)=embed(e5, "query: space contains many suns")' \
 'input.query(qt)=embed(colbert, @query)' \
 'query=space contains many suns' -C query
```

```
vespa query 'yql=select * from doc where userQuery() or ({targetHits: 100}nearestNeighbor(embedding, q))'\
 'input.query(q)=embed(e5, "query: shipping stuff over the sea")' \
 'input.query(qt)=embed(colbert, @query)' \
 'query=shipping stuff over the sea' -C query
```

```
vespa query 'yql=select * from doc where userQuery() or ({targetHits: 100}nearestNeighbor(embedding, q))'\
 'input.query(q)=embed(e5, "query: exchanging information by sound")' \
 'input.query(qt)=embed(colbert, @query)' \
 'query=exchanging information by sound' -C query
```
