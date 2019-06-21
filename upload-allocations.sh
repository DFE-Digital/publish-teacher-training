#!/bin/sh

files=$(ls public/*.xlsx)

echo "Getting access key"
access_key=`az storage account keys list --account-name sadfebatallocations --subscription "DFE BAT Development" --query "[?keyName == 'key1'].value | [0]"`;

for f in $files
do
  echo "Uploading $f"

  filename=$(echo $f | sed 's/public\///g')

  az storage blob upload --container-name find-allocations --name "$filename" --file "$f" --connection-string "DefaultEndpointsProtocol=https;AccountName=sadfebatallocations;AccountKey=$access_key;EndpointSuffix=core.windows.net" > /dev/null

  echo "Link is: https://sadfebatallocations.blob.core.windows.net/find-allocations/$filename"
done
