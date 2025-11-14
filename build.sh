#!/bin/bash
mkdir -p static

BUCKET="pages-gcs-bucket"
ORG="perkinm3"

# Build and deploy site-a
NAME="site-a"
bundle exec jekyll build --source $NAME --destination static/$NAME
gsutil -m cp -r static/$NAME gs://$BUCKET/sites/$ORG/$NAME
mkdir -p "$(dirname sites/$ORG/$NAME)" && cp -r static/$NAME sites/$ORG/$NAME

# Build and deploy site-b
NAME="site-b"
bundle exec jekyll build --source $NAME --destination static/$NAME
gsutil -m cp -r static/$NAME gs://$BUCKET/sites/$ORG/$NAME
mkdir -p "$(dirname sites/$ORG/$NAME)" && cp -r static/$NAME sites/$ORG/$NAME