#!/bin/bash
echo "Change Permission of $(pwd)"
echo " - Folders to 755"
echo " - Files to 644"

find $(pwd) -type d -exec chmod 755 {} \;
find $(pwd) -type f -exec chmod 644 {} \;

echo "Done"
